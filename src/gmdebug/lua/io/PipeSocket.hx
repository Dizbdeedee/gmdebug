package gmdebug.lua.io;

import gmdebug.Cross.AQUIRED;
import haxe.io.Encoding;
import lua.lib.luasocket.socket.TcpClient;
import haxe.io.Bytes;
import gmod.libs.FileLib;
import gmod.gclass.File;
import haxe.io.BytesInput;
import haxe.io.Input;
import haxe.io.Output;
import sys.net.Socket;
import haxe.io.Path.join;

typedef PipeLocations = {
	folder : String,
	client_ready : String,
	ready : String,
	input : String,
	output : String
}

class PipeSocket implements DebugIO {

	public final input:PipeInput;

	public final output:PipeOutput;

	final locs:PipeLocations;
	
	public function new(_locs:PipeLocations) {
		locs = _locs;
		if (!FileLib.Exists(locs.folder,DATA)) {
			FileLib.CreateDir(locs.folder);
		}
		FileLib.Write(locs.client_ready,"");
		if (!FileLib.Exists(locs.ready, DATA)) {
			throw "Other process is not ready.";
		}
		input = new PipeInput(locs);
		output = new PipeOutput(locs);
		output.writeString("\004"); //mark ready for writing...
		FileLib.Delete(locs.ready);
		FileLib.Delete(locs.client_ready);
		FileLib.Write(join([locs.folder,AQUIRED]),"");
	}

	public function close() {
		input.close();
		output.close();
		final results = FileLib.Find('${locs.folder}/*',DATA);
		for (file in results.files) {
			trace(file);
			FileLib.Delete('${locs.folder}/$file');
		}
		FileLib.Delete(locs.folder);
	}
}

class PipeInput extends Input {
	final file:File;
	final locs:PipeLocations;

	public function new(_locs:PipeLocations) {
		locs = _locs;
		trace("Input exists");
		if (!FileLib.Exists(locs.input, DATA)) {
			throw "Input pipe does not exist";
		}
		trace("input open");
		final f = FileLib.Open(locs.input, FileOpenMode.bin_read, DATA);
		if (f == null)
			throw "Cannot open Input pipe for reading";
		file = f;
	}

	override function readByte():Int {
		return file.ReadByte();
	}
	
	override function close() {
		file.Close();
		if (FileLib.Exists(locs.input,DATA)) {
			FileLib.Delete(locs.input);
		}
	}

}

class PipeOutput extends Output {

	final file:File;
	final locs:PipeLocations;

	public function new(_locs:PipeLocations) {
		locs = _locs;
		// if (!FileLib.Exists(Cross.OUTPUT,DATA)) { IT HANGS HERE :)
		//     throw "Output pipe does not exist";
		// }
		trace("output open");
		final f = FileLib.Open(locs.output, FileOpenMode.write, DATA);
		if (f == null)
			throw "Cannot open output pipe for reading";
		file = f;
	}

	override function close() {
		file.Close();
		if (FileLib.Exists(locs.output,DATA)) {
			FileLib.Delete(locs.output);
		}
	}

	override function flush() {
		file.Flush();
	}

	override function writeString(s:String, ?encoding:Encoding) {
		file.Write(s);
	}

}
