package gmdebug.lua.io;

import gmdebug.Cross.PATH_AQUIRED;
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

enum AquireProcess {
	WAITING_FOR_CONNECTION;
	WAITING_FOR_PATH_INPUT_EXIST;
	WAITING_FOR_PATH_INPUT_OPEN;
	WAITING_FOR_PATH_OUTPUT;
	AQUIRED;
}

class PipeSocket implements DebugIO {

	public var input:PipeInput;

	public var output:PipeOutput;

	final locs:PipeLocations;
	
	public function new(_locs:PipeLocations) {
		locs = _locs;
		if (!FileLib.Exists(locs.folder,DATA)) {
			FileLib.CreateDir(locs.folder);
		}
		FileLib.Write(locs.client_ready,"");
		
	}

	public function aquire():AquireProcess {
		if (!FileLib.Exists(locs.ready, DATA)) {
			return WAITING_FOR_CONNECTION;
		}
		input = new PipeInput(locs);
		output = new PipeOutput(locs);
		final inputAq = input.aquire();
		if (inputAq != AQUIRED) {
			return inputAq;
		}
		final outputAq = output.aquire();
		if (outputAq != AQUIRED) {
			return outputAq;
		}
		output.writeString("\004"); //mark ready for writing...
		FileLib.Delete(locs.ready);
		FileLib.Delete(locs.client_ready);
		// FileLib.Write(join([locs.folder,AQUIRED]),"");
		return AQUIRED;
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
	var file:File;
	final locs:PipeLocations;

	public function new(_locs:PipeLocations) {
		locs = _locs;
	}

	public function aquire():AquireProcess {
		if (!FileLib.Exists(locs.input, DATA)) {
			return WAITING_FOR_PATH_INPUT_EXIST;
		}
		final f = FileLib.Open(locs.input, FileOpenMode.bin_read, DATA);
		if (f == null)
			return WAITING_FOR_PATH_INPUT_OPEN;
		file = f;
		return AQUIRED;
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

	var file:File;
	final locs:PipeLocations;

	public function new(_locs:PipeLocations) {
		locs = _locs;
	}

	public function aquire() {
		//DO NOT CHECK FOR EXISTS HERE
		final f = FileLib.Open(locs.output, FileOpenMode.write, DATA);
		if (f == null)
			return WAITING_FOR_PATH_OUTPUT;
		file = f;
		return AQUIRED;
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
