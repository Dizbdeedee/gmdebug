package gmdebug.dap.srcds;


import ffi_napi.Callback;
import sys.FileSystem;
import node.worker_threads.Worker;
import haxe.Int64;
import js.Syntax;
import js.lib.Object;
import global.Buffer;
import js.Node;
import ref_array_di.TypedArray;
import ref_napi.Type_;
import ffi_napi.Library;
using StringTools;
using Lambda;
import RefNapi.refType;
import RefNapi.types as rtypes;

typedef BufInt = haxe.extern.EitherType<global.Buffer,Int>;
typedef BufBool = haxe.extern.EitherType<global.Buffer,Bool>;
 

private extern class Kernel32 {
    function CreateFileMappingA(...rest:Dynamic):global.Buffer;
    function CreateEventA(...rest:Dynamic):global.Buffer;
    function MapViewOfFile(map_file:global.Buffer,dwDesiredAccess:BufInt,dwFileOffsetHigh:global.Buffer,
        dwFileOffsetLow:global.Buffer,dwNumberOfBytesToMap:BufInt):global.Buffer;
    function UnmapViewOfFile(map_file:TypedArray<Int>):Void;
    function SetEvent(handle:global.Buffer):Bool;
    function WaitForSingleObject(event:BufInt,timeout:Int):Int;
    function CreateProcessA(lpApplicationName:global.Buffer,lpCommandLine:Buffer,lpProcessAttributes:SecurityInfo,lpThreadAttributes:SecurityInfo,bInheritHandles:BufBool,dwCreationFlags:BufInt,lpEnvironment:Buffer,lpCurrentDirectory:Buffer,lpStartupInfo:Buffer,lpProcessInformation:Buffer):Bool;
    function WaitForMultipleObjects(nCount:Int,lpHandles:global.Buffer,bWaitAll:Bool,dwMilliseconds:Int):Int;
    function SetConsoleCtrlHandler(...rest:global.Buffer):Bool;
    function CloseHandle(handle:global.Buffer):Void;
    function TerminateProcess(hProcess:global.Buffer,uExitCode:Int):Bool;
}

private extern class Lib {
    function memset(dst:global.Buffer,val:BufInt,size:BufInt):global.Buffer;
}

extern class ProcessInfo extends global.Buffer {
    var hProcess:global.Buffer;
    var dwProcessId:BufInt;
}

extern class SecurityInfo extends global.Buffer {
    var nLength:BufInt;
    var lpSecurityDescriptor:global.Buffer;
    var bSecuritHandle:BufBool;
}

extern class StartupInfo extends global.Buffer {
    var cb : BufInt;
}
// typedef ProcessInfo = global.Buffer & {
//     hProcess : global.Buffer
// }

class Redirector {

    static final STATUS_WAIT_0 = 0x00000000;

    static final WAIT_OBJECT_0 = STATUS_WAIT_0 + 0;

    static final StructType = RefStructDi.call(cast RefNapi);

    static final ArrayType = RefArrayDi.call(cast RefNapi);

    static final LPVOID = refType(RefNapi.types.void);

    static final DWORD = rtypes.ulong;

    static final WORD = rtypes.ushort;

    static final BOOL = rtypes.int;

    static final NULL = RefNapi.NULL;

    static final HANDLE = refType(rtypes.void);

    static final SECURITY_ATTR = StructType.call({
        nLength : DWORD,
        lpSecurityDescriptor : LPVOID,
        bInheritHandle : BOOL
    });

    static final PROCESS_INFO = StructType.call({
        hProcess : HANDLE,
        hThread : HANDLE,
        dwProcessId : DWORD,
        dwThreadId : DWORD
    });

    static final STARTUP_INFO = StructType.call({
        cb : DWORD,
        lpReserved : refType(rtypes.char),
        lpDesktop : refType(rtypes.char),
        lpTitle : refType(rtypes.char),
        dwX : DWORD,
        dwY : DWORD,
        dwXSize : DWORD,
        dwYSize : DWORD,
        dwXCountChars : DWORD,
        dwYCountChars : DWORD,
        dwFillAttribute : DWORD,
        dwFlags : DWORD,
        wShowWindow : WORD,
        cbReserved2 : WORD,
        lpReserved2 : refType(rtypes.byte),
        hStdInput : HANDLE,
        hStdOutput : HANDLE,
        hStdError : HANDLE
    });

    static final intBuf = ArrayType.call(rtypes.int,3);
    static final uintBuf = ArrayType.call(rtypes.uint);

    // static final callback = Callback.call_([])

    static final voidBuf = ArrayType.call(refType(rtypes.void));

    public static final K32:Kernel32 = cast new Library("kernel32", {
        untyped {
            CreateFileMappingA : [HANDLE,[HANDLE,refType(SECURITY_ATTR),rtypes.ulong,rtypes.ulong,rtypes.ulong,rtypes.CString]],
            CreateEventA : [HANDLE,[refType(SECURITY_ATTR),rtypes.bool,rtypes.bool,rtypes.CString]],
            MapViewOfFile : [refType(rtypes.void),[refType(rtypes.void), DWORD,DWORD,DWORD,rtypes.size_t]],
            UnmapViewOfFile : [rtypes.void,[intBuf]],
            SetEvent : [rtypes.bool,[refType(rtypes.void)]],
            // WaitForResponse : [],
            WaitForSingleObject : [DWORD,[rtypes.uint,DWORD]],
            CreateProcessA : [rtypes.int,[refType(rtypes.char),refType(rtypes.char),
                refType(SECURITY_ATTR),refType(SECURITY_ATTR),rtypes.bool,
                rtypes.ulong,refType(rtypes.void),refType(rtypes.char),refType(STARTUP_INFO),
                refType(PROCESS_INFO)
            ]],
            GetLastError : [DWORD,[]],
            SetConsoleCtrlHandler : [rtypes.bool,[refType(rtypes.void),rtypes.bool]],
            WaitForMultipleObjects : [DWORD,[DWORD,voidBuf,rtypes.bool,DWORD]],
            CloseHandle : [rtypes.void,[refType(rtypes.void)]],
            TerminateProcess : [rtypes.bool,[refType(rtypes.void),rtypes.uint]]
        }
    });

    static final lib:Lib = cast new Library("ucrtbase", {
        untyped {
            memset : [refType(rtypes.void),[refType(rtypes.void),rtypes.int,rtypes.size_t]]
        }
    });


    final event_parent_send:global.Buffer;

    final map_file:global.Buffer;
    
    final event_child_send:global.Buffer;

    final processInfo:ProcessInfo = cast PROCESS_INFO.call();

    static function bufferAtAddress(address:Int64):global.Buffer {
        final buf:global.Buffer = cast global.Buffer.alloc(8);
        buf.writeUInt32LE(address.high,0);
        buf.writeUInt32LE(address.low,4);
        final newType:Type_ = cast Object.assign({},rtypes.void);
        newType.indirection = 2;
        buf.type = newType;
        return RefNapi.deref(buf);
    }

    public function new() {
        final securityAttr:global.Buffer = cast SECURITY_ATTR.call({
            nLength : SECURITY_ATTR.size,
            lpSecurityDescriptor : NULL,
            bInheritHandle : true
        });
        //FFFFFFFF
        final point = bufferAtAddress(Int64.make(Syntax.code("0xFFFFFFFF"),Syntax.code("0xFFFFFFFF")));
        trace(point.address());
        map_file = K32.CreateFileMappingA(point,securityAttr.ref(),0x04,0,65536,NULL);
        trace(map_file.address());
        if (RefNapi.isNull(map_file)) {
            throw "Could not create file mapping";
        }
        event_parent_send = K32.CreateEventA(securityAttr.ref(),false,false,RefNapi.NULL);
        if (RefNapi.isNull(event_parent_send)) {
            throw "Could not create parent send event";
        }
        event_child_send = K32.CreateEventA(securityAttr.ref(),false,false,NULL);
        if (RefNapi.isNull(event_child_send)) {
            throw "Could not create child send event";
        }
    }

    public function Destroy() {
        K32.CloseHandle(map_file);
        K32.CloseHandle(event_parent_send);
        K32.CloseHandle(event_child_send);
        if (processInfo.dwProcessId != 0) {
            trace("Attempting destruction");
            K32.TerminateProcess(processInfo.hProcess,1);
            lib.memset(processInfo.ref(),0,cast PROCESS_INFO.size);
        }
        // K32.WaitForSingleObject(processInfo.hProcess,0xFFFFFFFF);
    }

    public function Start(program:String,args:Array<String>) {
        if (!FileSystem.exists(program)) {
            throw "Program path does not exist.";
        }
        if (FileSystem.isDirectory(program)) {
            throw "Program path is a directory.";
        }
        if (!haxe.io.Path.isAbsolute(program)) {
            throw "Absolute paths only.";
        }
        final si:StartupInfo = cast STARTUP_INFO.call();
        lib.memset(si.ref(),0,cast STARTUP_INFO.size);
        si.cb = cast STARTUP_INFO.size;
        final mf = map_file.address();
        final eps = event_parent_send.address();     
        final ecs = event_child_send.address();
        final argString = args.join(" ");
        final command = RefNapi.allocCString('$program -HFILE $mf -HPARENT $eps -HCHILD $ecs $argString');
        var result = K32.CreateProcessA(null,command,null,null,true,16,null,null,si.ref(),processInfo.ref());
        if (!result) throw "Good luck debugging this, asshole";
    }

    public function ReadText(iBeginLine:Int, iEndLine:Int) {
        //lock
        final pbuf = GetMappedBuffer();
        pbuf[0] = 3;
        pbuf[1] = iBeginLine;
        pbuf[2] = iEndLine;
        ReleaseMappedBuffer(cast pbuf);
        
        final eventSet = K32.SetEvent(event_parent_send);
        if (!eventSet) {
            throw "Event not set at ReadText";
        }
        if (!WaitForResponse()) {
            throw "Failed to wait at ReadText";
        }
        
        final pBuf = GetMappedBuffer();
        final output = if (pBuf[0] == 1) {
            RefNapi.readCString(pBuf.buffer.reinterpretUntilZeros(rtypes.char.size),rtypes.int.size);
        } else {
            "_";
        }
        ReleaseMappedBuffer(cast pBuf);
        //unlock
        return output;
    
    }

    public function SetScreenBufferSize(iLines:Int) {
        final pBuf = GetMappedBuffer();
        pBuf[0] = 0x5;
        pBuf[1] = iLines;
        ReleaseMappedBuffer(pBuf);
        K32.SetEvent(event_parent_send);

        if (!WaitForResponse()) {
            throw "Could not wait at SetScreenBufferSize";
        }
        final pBuf = GetMappedBuffer();
        final success = pBuf[0] == 1;
        ReleaseMappedBuffer(pBuf);
        return success;
    }

    function GetMappedBuffer() {
        final pbuf = K32.MapViewOfFile(map_file, 0x0004 | 0x0002, RefNapi.NULL,RefNapi.NULL,0);
        final pbuf2:TypedArray<Int> = cast intBuf.call(pbuf.reinterpret(3 * rtypes.int.size),3);
        if (RefNapi.isNull(cast pbuf2.buffer)) {
            //There was trace here. It's gone now
        }
        
        return pbuf2;
    }

    public function WriteText(input:String) {
        final pBuf = GetMappedBuffer();
        pBuf[0] = 0x2;
        final strBuf = pBuf.buffer.reinterpret((input.length + 1) * rtypes.char.size,1 * rtypes.int32.size);
        // strBuf.writeCString(cast input,cast 0,"utf8"); //pretty sure this is a bug in napi, or dts2hx. whatever
        strBuf.write(input + "\000",0);
        ReleaseMappedBuffer(pBuf);
        K32.SetEvent(event_parent_send);
        if (!WaitForResponse()) {
            throw "Could not wait";
        }
        final pBuf = GetMappedBuffer();
        final success = pBuf[0] == 1;
        ReleaseMappedBuffer(pBuf);
        return success;
    }

    public function GetScreenBufferSize() {
        //lock
        final pBuf = GetMappedBuffer();
        pBuf[0] = 0x4;
        ReleaseMappedBuffer(pBuf);
        final eventSet = K32.SetEvent(event_parent_send);
        if (!eventSet) {
            throw "Event not set...";
        }
        if (!WaitForResponse()) {
            throw "Could not wati...";
        }
        final pBuf = GetMappedBuffer();
        final bufferSize = if (pBuf[0] == 1) {
            pBuf[1];
        } else {
            -1;
        }
        ReleaseMappedBuffer(pBuf);
        return bufferSize;
    }

    function WaitForResponse() {
        
        final waitForEvents:TypedArray<global.Buffer> = voidBuf.call(2);
        waitForEvents[0] = event_child_send;
        waitForEvents[1] = processInfo.hProcess;
        final waitResult = K32.WaitForMultipleObjects(2,cast waitForEvents,false,0xFFFFFFF);
        if (waitResult == WAIT_OBJECT_0 + 1) {
            trace("Process ended");
            throw "Ended";
        }
        return waitResult == WAIT_OBJECT_0;
    }

    function ReleaseMappedBuffer(pbuf:TypedArray<Int>) {
        K32.UnmapViewOfFile(pbuf);
    }
   
}