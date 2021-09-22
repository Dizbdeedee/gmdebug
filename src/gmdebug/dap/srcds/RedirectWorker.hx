package gmdebug.dap.srcds;

import node.worker_threads.Worker;
import js.Node;
using StringTools;
using Lambda;
class RedirectWorker {

    static final CON_LINE_LENGTH = 80;

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

    static var oldCmdLine:String;

    static function HandleCommandLineDisplay(r:Redirector,screenSize:Int) {
        
        final cmdLine:String = r.ReadText(screenSize - 1,screenSize - 1);
        if (cmdLine.length > 0 && !isAllWhitespace(cmdLine) && oldCmdLine != null && !cmdLine.startsWith(oldCmdLine)) {
            // Node.process.stdout.write('\r ${cmdLine.substr(0, findLastNotWhitespace(cmdLine) + 1)}');
        }
        oldCmdLine = cmdLine;
    }

    public static function makeWorker(program:String,args:Array<String>):Worker {
        final argv = [program].concat(args);
        return new Worker("./bin/redirect.js",{
            argv: argv,
            stdin: true,
            stdout: true,
            stderr: true,
        });
    }

    public static function main() {
        
        final r = new Redirector();
        trace(Node.process.argv);
        r.Start(Node.process.argv[2],Node.process.argv.slice(3));

        var bJustStarted = false;
        var outputBuffer:Array<String> = [];
        final oldOutput:Array<String> = [];
        
        while (true) {
            final screenSize = r.GetScreenBufferSize();
            if (screenSize == -1) continue;
            if (!r.SetScreenBufferSize(screenSize)) {
                trace('Failed to set screen size $screenSize');
            }
            if (Node.process.stdin.readable) {
                final read = Node.process.stdin.read();
                if (read != null) {
                    r.WriteText(Node.process.stdin.read());
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
                        continue;
                    } else {
                        trace('Console moved too fast $firstNewLine');
                        firstNewLine = 0;
                    }
                }
                for (i in firstNewLine...outputBuffer.length) {
                    oldOutput.push(outputBuffer[i]); 
                    Node.process.stdout.write(outputBuffer[i] + "\n");
                }

                final sizeDiff = oldOutput.length - screenSize;
                if (sizeDiff > 0) {
                    oldOutput.splice(0,sizeDiff);
                }
            } else if (!bJustStarted) {
                for (str in outputBuffer) {
                    oldOutput.push(str);
                    Node.process.stdout.write(str);
                }
            }
            HandleCommandLineDisplay(r,screenSize);
        }
        
    }
}