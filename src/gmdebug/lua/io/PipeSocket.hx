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
    AQUIRED;
}

class PipeSocket implements DebugIO {

    public var input:PipeInput;

    public var output:PipeOutput;

    final locs:PipeLocations;

    var process:AquireProcess = WAITING_FOR_CONNECTION;

    public function new(_locs:PipeLocations) {
        trace('NEW PIPE SOCKET :D ${_locs.folder}');
        locs = _locs;
        if (!FileLib.Exists(locs.folder,DATA)) {
            FileLib.CreateDir(locs.folder);
        }
        FileLib.Write(locs.client_ready,"");
        WeakTools.setGCMethod(cast this,__gc);

    }

    function connection_pass() {
        return process != WAITING_FOR_CONNECTION;
    }

    function input_pass() {
        return process != WAITING_FOR_INPUT;
    }

    function pipes_ready_pass() {
        return process != WAITING_FOR_PIPES_READY;
    }

    public function aquire():AquireProcess {
        if (process == AQUIRED) throw "Already aquired...";
        if (!connection_pass()) {
            if (!FileLib.Exists(locs.connect, DATA)) {

                return WAITING_FOR_CONNECTION;
            }
            if (!FileLib.Exists(locs.client_ack,DATA)) {
                FileLib.Write(locs.client_ack,"");
            }
            process = WAITING_FOR_PIPES_READY;
            trace(process);
        }
        if (!pipes_ready_pass()) {
            if (!FileLib.Exists(locs.pipes_ready,DATA)) {
                return WAITING_FOR_PIPES_READY;
            }
            process = WAITING_FOR_INPUT;
            trace(process);
        }
        if (!input_pass()) {
            if (input == null) {
                input = new PipeInput(locs);
            }
            final inputAq = input.aquire();
            if (inputAq != AQUIRED) {
                return inputAq;
            }
            process = WAITING_FOR_OUTPUT;
            trace(process);
        }
        if (output == null) {
            output = new PipeOutput(locs);
        }
        final outputAq = output.aquire();
        if (outputAq != AQUIRED) {
            return outputAq;
        }
        trace("first write");
        output.writeString("\004"); //mark ready for writing...
        FileLib.Delete(locs.pipes_ready);
        FileLib.Delete(locs.client_ready);
        FileLib.Delete(locs.connection_in_progress);
        process = AQUIRED;
        FileLib.Write(locs.connection_aquired,"");

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
        if (!FileLib.Exists(locs.input, DATA)) {
            return WAITING_FOR_INPUT;
        }
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
            return WAITING_FOR_OUTPUT;
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
