package gmdebug.dap;

import haxe.io.Path as HxPath;
import node.Fs;

using tink.CoreApi;
using haxe.EnumTools.EnumValueTools;
using Lambda;

interface FileLookup {
	function processFile(gmodLocation:GmodLocations):Array<GmodLocations>;
	function storeContext(gmodLocation:GmodLocationsNoLoc, context:String):Void;
	function lookupAllLocations(gmodPath:GmodPath):Array<GmodLocations>;
	function processGmodPath(gmodPath:GmodPath, gmodLocation:GmodLocationsNoLoc):ProcessGmodPathResult;
}

typedef FileLookupHasher = (str:String) -> String;

class FileLookupDef implements FileLookup {
	var hashCache:Map<String, String> = [];

	var locationsFromHash:Map<String, Array<GmodLocations>> = [];

	var possibleLocations:Map<GmodLocationsNoLoc, String> = [];

	var gmodCache:Map<String, String> = [];

	final hasher:FileLookupHasher;

	public function new(_hasher:FileLookupHasher) {
		hasher = _hasher;
	}

	public function storeContext(gmodLocation:GmodLocationsNoLoc, context:String) {
		possibleLocations.set(gmodLocation, context);
	}

	public function lookupAllLocations(gmodPath:GmodPath):Array<GmodLocations> {
		var resultArr = [];
		for (gmodLoc => _ in possibleLocations) {
			switch (processGmodPath(gmodPath, gmodLoc)) {
				case EXISTS(gmLoc, arr):
					resultArr = arr;
				default:
			}
		}
		if (resultArr.length == 0) {
			trace("*ncp no locations found for " + gmodPath);
		}
		return resultArr;
	}

	// TODO - what if contents are different on different paths? gmodPath needs context to be unique
	// Where, why what does the hash represent?
	// we will end up looking up paths each time for the failure case
	public function processGmodPath(gmodPath:GmodPath,
			gmodLocationsNoLoc:GmodLocationsNoLoc):ProcessGmodPathResult {
		switch (gmodCache.get(getGmodCacheIdent(gmodPath, gmodLocationsNoLoc))) {
			case null:
			case hash:
				var arr = locationsFromHash.get(hash);
				var gmodLocation = arr.find((glloc) -> glloc.getIndex() == gmodLocationsNoLoc.getIndex());
				return if (gmodLocation == null) {
					HASH_LOOKUP_FAIL;
				} else {
					EXISTS(gmodLocation, arr);
				}
		}
		var pathContext = possibleLocations.get(gmodLocationsNoLoc);
		return switch (gmodPath.createAbs(pathContext)) {
			case Some(abs):
				var gmLoc = GmodLocations.createByIndex(gmodLocationsNoLoc.getIndex(), [abs]);
				var arr = processFile(gmLoc);
				updateGmodPathCache(gmodPath, gmLoc);
				EXISTS(gmLoc, arr);
			default:
				NONE;
		}
	}

	function getGmodCacheIdent(gmodPath:GmodPath, gmodLocationsNoLoc:GmodLocationsNoLoc) {
		var pathContext = possibleLocations.get(gmodLocationsNoLoc);
		return gmodPath.createAbsNoCheck(pathContext);
	}

	function updateGmodPathCache(gmodPath:GmodPath, gmodLocation:GmodLocations) {
		var abs = switch (gmodLocation) {
			case PROJECT(str) | SERVER(str) | CLIENT(str):
				str;
		}
		var noLoc = GmodLocationsNoLoc.createByIndex(gmodLocation.getIndex());
		var hash = hashCache.get(abs);
		if (hash == null) {
			trace('*ncp attempt to store gmodpath without abs hash in cache!!');
		} else {
			gmodCache.set(getGmodCacheIdent(gmodPath, noLoc), hash);
		}
	}

	public function processFile(gmodLocation:GmodLocations):Array<GmodLocations> {
		var abs = switch (gmodLocation) {
			case PROJECT(str) | SERVER(str) | CLIENT(str):
				str;
		}
		var hash = hashCache.get(abs);
		hash = if (hash != null) {
			trace("*ncp hash already exists");
			hash;
		} else {
			var contents = Fs.readFileSync(abs, {encoding: 'utf8'});
			var contentsHash = hasher(contents.toString());
			hashCache.set(abs, contentsHash);
			contentsHash;
		}
		var fileLocations = locationsFromHash.get(hash);
		var fileLocationsUpd = if (fileLocations == null) {
			[gmodLocation];
		} else if (fileLocations.exists((loc:GmodLocations) -> return
			loc.getIndex() == gmodLocation.getIndex())) {
			trace("*ncp file locations already contains gmodlocation??");
			fileLocations;
		} else {
			fileLocations.push(gmodLocation);
			fileLocations;
		}
		locationsFromHash.set(hash, fileLocationsUpd);
		trace('*ncp file locations updated $fileLocationsUpd');
		return fileLocationsUpd;
	}
}

enum GmodLocationsNoLoc {
	PROJECT;
	SERVER;
	CLIENT;
}

enum GmodLocations {
	PROJECT(str:String);
	SERVER(str:String);
	CLIENT(str:String);
}

enum ProcessGmodPathResult {
	NONE;
	EXISTS(gmodLocation:GmodLocations, arr:Array<GmodLocations>);
	HASH_LOOKUP_FAIL;
}
