package gmdebug.lua.io;

import gmdebug.Cross.PATH_SEARCH;
import gmod.libs.FileLib;
import gmdebug.Cross.DataLocations;
import gmod.libs.UtilLib;
import gmod.libs.OsLib;
import haxe.io.Path as HxPath;
import gmdebug.Cross.PATH_DAT_EXT;

using gmod.helpers.TableTools;

interface DataHandshake {
	var ourID(default, null):String;
	function aquire():DataHandshakeProcess;
}

class DataHandshakeDef implements DataHandshake {
	static final VALID_SERVER_HANDSHAKE_TIME = 5;

	var serverID:String;

	public var ourID(default, null):String;

	var locs:DataLocations;

	var curProgress:DataHandshakeProcess = WAITING_FOR_SERVER;

	public function new(_locs:DataLocations) {
		locs = _locs;
	}

	function checkProcess():DataHandshakeProcessState {
		var handshakelocations = locs.handshakelocations;
		return switch (curProgress) {
			case WAITING_FOR_SERVER:
				trace('SEARCHING ${handshakelocations.pre_path_server_handshake + PATH_SEARCH}');
				var results = FileLib.Find(handshakelocations.pre_path_server_handshake + PATH_SEARCH,
					DATA);
				if (results.files == null || results.files.length() <= 0) {
					HALT(WAITING_FOR_SERVER);
				} else {
					var chosen = false;
					for (serverHandshake in results.files) {
						var filepth = HxPath.join([handshakelocations.folder, serverHandshake]);
						var filecontents = FileLib.Read(filepth);
						if (filecontents == null) {
							trace('Could not read file $filepth');
							continue;
						}
						var time = Std.parseInt(filecontents);
						if (time > OsLib.time() - 5) {
							// valid connection. maybe choose based on startup server id
							chosen = true;
						}
					}
					if (chosen) {
						ourID = generateID();
						FileLib.Write(handshakelocations.pre_path_client_handshake + ourID + PATH_DAT_EXT,
							"");
						CONTINUE(WAITING_FOR_ACK);
					} else {
						HALT(WAITING_FOR_SERVER);
					}
				}
			case WAITING_FOR_ACK:
				if (FileLib.Exists(handshakelocations.pre_path_client_handshake + ourID + PATH_DAT_EXT,
					DATA)) {
					HALT(WAITING_FOR_ACK);
				} else {
					CONTINUE(DONE);
				}
			case DONE:
				HALT(DONE);
		}
	}

	public function aquire():DataHandshakeProcess {
		if (curProgress == DONE)
			throw "Already shook...";
		while (curProgress != DONE) {
			switch (checkProcess()) {
				case CONTINUE(x):
					curProgress = x;
				case HALT(x):
					return x;
			}
		}
		return DONE;
	}

	function generateID():String {
		var id = UtilLib.MD5('${OsLib.time() + Gmod.SysTime()}');
		trace('Generated ID: $id');
		return id;
	}
}

enum DataHandshakeProcessState {
	HALT(x:DataHandshakeProcess);
	CONTINUE(x:DataHandshakeProcess);
}

enum DataHandshakeProcess {
	WAITING_FOR_SERVER;
	WAITING_FOR_ACK;
	DONE;
}
