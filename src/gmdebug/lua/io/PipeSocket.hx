package gmdebug.lua.io;

import gmod.helpers.WeakTools;
import gmdebug.Cross.PipeLocations;
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

enum AquireProcess {
	WAITING_FOR_CONNECTION;
	WAITING_FOR_PIPES_READY;
	WAITING_FOR_INPUT;
	WAITING_FOR_OUTPUT;
	WRITING_OUTPUT;
	AQUIRED;
}

enum AquireProcessState {
	CONTINUE(x:AquireProcess);
	HALT(x:AquireProcess);
}

class PipeSocket implements DebugIO {
	public var input:PipeInput;

	public var output:PipeOutput;

	final locs:PipeLocations;

	var process:AquireProcess = WAITING_FOR_CONNECTION;

	public function new(_locs:PipeLocations) {
		trace('NEW PIPE SOCKET :D ${_locs.folder}');
		locs = _locs;
		if (!FileLib.Exists(locs.folder, DATA)) {
			FileLib.CreateDir(locs.folder);
		}
		FileLib.Write(locs.client_ready, "");
		WeakTools.setGCMethod(cast this, __gc);
	}

	function checkProcess():AquireProcessState {
		return switch (process) {
			case WAITING_FOR_CONNECTION:
				if (!FileLib.Exists(locs.connect, DATA)) {
					HALT(WAITING_FOR_CONNECTION);
				} else {
					if (!FileLib.Exists(locs.client_ack, DATA)) {
						FileLib.Write(locs.client_ack, "");
					}
					CONTINUE(WAITING_FOR_PIPES_READY);
				}
			case WAITING_FOR_PIPES_READY:
				if (!FileLib.Exists(locs.pipes_ready, DATA)) {
					HALT(WAITING_FOR_PIPES_READY);
				} else {
					CONTINUE(WAITING_FOR_INPUT);
				}
			case WAITING_FOR_INPUT:
				if (input == null) {
					input = new PipeInput(locs);
				}
				final inputAq = input.aquire();
				if (inputAq != AQUIRED) {
					HALT(inputAq);
				} else {
					CONTINUE(WAITING_FOR_OUTPUT);
				}
			case WAITING_FOR_OUTPUT:
				if (output == null) {
					output = new PipeOutput(locs);
				}
				final outputAq = output.aquire();
				if (outputAq != AQUIRED) {
					HALT(outputAq);
				} else {
					CONTINUE(WRITING_OUTPUT);
				}
			case WRITING_OUTPUT:
				output.writeString("\004"); // mark ready for writing...
				FileLib.Delete(locs.pipes_ready);
				FileLib.Delete(locs.client_ready);
				FileLib.Delete(locs.connection_in_progress);
				FileLib.Write(locs.connection_aquired, "");
				HALT(AQUIRED);
			case AQUIRED:
				HALT(AQUIRED);
		}
	}

	public function aquire():AquireProcess {
		if (process == AQUIRED)
			throw "Already aquired...";
		while (process != AQUIRED) {
			switch (checkProcess()) {
				case CONTINUE(x):
					process = x;
				case HALT(x):
					return x;
			}
		}
		return AQUIRED;
	}

	public function close() {
		input.close();
		output.close();
		final results = FileLib.Find('${locs.folder}/ star', DATA);
		for (file in results.files) {
			trace(file);
			FileLib.Delete('${locs.folder}/$file');
		}
		FileLib.Delete(locs.folder);
	}

	function __gc() {
		close();
	}
}

class PipeInput extends Input {
	var file:File;
	final locs:PipeLocations;

	public function new(_locs:PipeLocations) {
		locs = _locs;
	}

	public function aquire():AquireProcess {
		// if (!FileLib.Exists(locs.input, DATA)) {
		//     return WAITING_FOR_INPUT; //suspect
		// }
		final f = FileLib.Open(locs.input, FileOpenMode.bin_read, DATA);
		if (f == null)
			return WAITING_FOR_INPUT;
		file = f;
		return AQUIRED;
	}

	override function readByte():Int {
		return file.ReadByte();
	}

	override function close() {
		file.Close();
		if (FileLib.Exists(locs.input, DATA)) {
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
		// DO NOT CHECK FOR EXISTS HERE
		final f = FileLib.Open(locs.output, FileOpenMode.write, DATA);
		if (f == null)
			return WAITING_FOR_OUTPUT;
		file = f;
		return AQUIRED;
	}

	override function close() {
		file.Close();
		if (FileLib.Exists(locs.output, DATA)) {
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
