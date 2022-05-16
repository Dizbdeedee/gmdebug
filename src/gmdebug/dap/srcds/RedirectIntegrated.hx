package gmdebug.dap.srcds;

import js.node.stream.Duplex;
import js.node.Util;
import js.node.Timers;
import js.node.stream.Writable;
import js.node.stream.Readable;
import node.buffer.Buffer;
import ffi_napi.Callback;
import js.node.stream.Writable.IWritable;
import js.node.stream.Readable.IReadable;
import RefNapi.types as rtypes;
using StringTools;


class RedirectIntegrated {

    static final CON_LINE_LENGTH = 80;

    public var stdin:IWritable;
    public var stdout:IReadable;

    var _stdout:IWritable;

    var _stdin:IReadable;

    var r:Redirector;

    var outputBuffer:Array<String> = [];

    var oldOutput:Array<String> = [];
    
    var bJustStarted = true;

    var canLoop = true;

    final onEnd:() -> Void;

    static function isAllWhitespace(str:String) {
        for (c in str) {
            if (c != " ".code) {
                return false;
            }
        }
        return true;
    }

    static function findLastNotWhitespace(str:String) {
        var retInd = null;
        for (ind => c in str) {
            if (c != " ".code) {
                retInd = ind;
            }
        }
        return retInd;
    }

    var oldCmdLine:String;

    function HandleCommandLineDisplay(r:Redirector,screenSize:Int) {
        
        final cmdLine:String = r.ReadText(screenSize - 1,screenSize - 1);
        if (cmdLine.length > 0 && !isAllWhitespace(cmdLine) && oldCmdLine != null && !cmdLine.startsWith(oldCmdLine)) {
            // Node.process.stdout.write('\r ${cmdLine.substr(0, findLastNotWhitespace(cmdLine) + 1)}');
        }
        oldCmdLine = cmdLine;
    }

    function handleDeth(...rest) {
        trace("deth handled");
        canLoop = false;
        // red.Destroy();
        return false;
    }

    public function new(_onEnd:() -> Void) {
        onEnd = _onEnd;
        _stdin = new Duplex({
            write : (chunk:Dynamic,_,next) -> {
                untyped _stdin.push(chunk);
                next(null);
            },
            read: (size) -> {}
        });
        _stdout = new Duplex({
            write : (chunk:Dynamic, _, next) -> {
                untyped _stdout.push(chunk);
                next(null);
            },
            read : (size) -> {}
        });
        stdin = cast _stdin;
        stdout = cast _stdout;
    }

    var cancelInterval:Timeout;

    public function start(program:String,args:Array<String>) {
        r = new Redirector();
        r.Start(program,args);
        Redirector.K32.SetConsoleCtrlHandler(Callback.call_(rtypes.bool,[rtypes.ulong],handleDeth),cast true);
        // run();
        cancelInterval = Timers.setInterval(run,1);
    }

    public function kill() {
        canLoop = false;
    }

    function run() {
        try {
            loop();
        } catch (e) {
            canLoop = false;
            r.Destroy();
            onEnd();
            Timers.clearInterval(cancelInterval);
            return;
        }
        if (canLoop) {
            //uh
        } else {
            r.Destroy();
            onEnd();
            Timers.clearInterval(cancelInterval);
            return;
        }
    }

    function loop() {
        trace("loop");
        final screenSize = r.GetScreenBufferSize();
        if (screenSize == -1) return;
        if (!r.SetScreenBufferSize(screenSize)) {
            trace('Failed to set screen size $screenSize');
        }
        if (_stdin.readable) {
            var read:Buffer;
            var readStr:StringBuf = new StringBuf();
            do {
                read = _stdin.read();
                if (read != null) {
                    trace(read);
                    readStr.add(read.toString());
                }
            } while (read != null);
            if (readStr.length > 0) {
                trace(readStr.toString());
                r.WriteText(readStr.toString());
            }
            
        }
        final output = r.ReadText(1,screenSize-2);
        outputBuffer = [];
        var lastNotEmptyIndex = -1;
        for (i in 0...screenSize - 2) {
            if (i * CON_LINE_LENGTH >= output.length) break;
            final line = output.substr(i * CON_LINE_LENGTH,CON_LINE_LENGTH);
            if (!isAllWhitespace(line)) {
                lastNotEmptyIndex = outputBuffer.length;
            }
            outputBuffer.push(line);
        }
        if (lastNotEmptyIndex >= 0 && outputBuffer.length > lastNotEmptyIndex) {
            outputBuffer.resize(lastNotEmptyIndex + 1);
        }

        if (lastNotEmptyIndex != -1) {
            bJustStarted = false;
        }
        if (oldOutput.length > 0) {
            var lastLine = oldOutput.length - 1;
            var firstNewLine = outputBuffer.length - 1;
            var hist = false;
            for (i in 0...outputBuffer.length - 1) {
                final x = outputBuffer.length - 1 - i;
                if (outputBuffer[x].startsWith(oldOutput[lastLine])) {
                    firstNewLine++;
                    hist = true;
                    for (_u in i + 1...outputBuffer.length - 1) {
                        // trace("match.. checking history");
                        final u = outputBuffer.length - 1 - _u;
                        if (!outputBuffer[u].startsWith(oldOutput[--lastLine])) {
                            // trace('${outputBuffer[u]} does not start With ${oldOutput[lastLine]}');
                            lastLine = oldOutput.length - 1;
                            firstNewLine -= 2;
                            hist = false;
                            break;
                        }
                    }
                    if (hist) break;
                } else {
                    firstNewLine--;
                }
            }
            if (firstNewLine < 0) {
                if (hist) {

                    HandleCommandLineDisplay(r,screenSize);
                    return;
                } else {
                    trace('Console moved too fast $firstNewLine');
                    firstNewLine = 0;
                }
            }
            for (i in firstNewLine...outputBuffer.length) {
                oldOutput.push(outputBuffer[i]); 
                _stdout.write(outputBuffer[i] + "\n");
            }

            final sizeDiff = oldOutput.length - screenSize;
            if (sizeDiff > 0) {
                oldOutput.splice(0,sizeDiff);
            }
        } else if (!bJustStarted) {
            for (str in outputBuffer) {
                oldOutput.push(str);
                _stdout.write(str);
            }
        }
        HandleCommandLineDisplay(r,screenSize);
    }
}