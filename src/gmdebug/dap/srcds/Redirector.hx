package gmdebug.dap.srcds;


import sys.FileSystem;
import node.worker_threads.Worker;
import haxe.Int64;
import js.Syntax;
import js.lib.Object;
import js.Node;
import ref_array_di.TypedArray;
import ref_napi.Type_;
import ffi_napi.Library;
using StringTools;
using Lambda;
import RefNapi.refType;
import RefNapi.types as rtypes;


extern class Kernel32 {
    // static function CreateFileMappingW(hFile:global.Buffer, securityAttr:global.Buffer, flProtect:)

    function CreateFileMappingA(...rest:Dynamic):global.Buffer;
    function CreateEventA(...rest:Dynamic):global.Buffer;
    function MapViewOfFile(map_file:global.Buffer,dwDesiredAccess:Int,dwFileOffsetHigh:global.Buffer,
        dwFileOffsetLow:global.Buffer,dwNumberOfBytesToMap:Int):global.Buffer;
    function UnmapViewOfFile(map_file:TypedArray<Int>):Void;
    function SetEvent(handle:global.Buffer):Bool;
    function WaitForSingleObject(event:Int,timeout:Int):Int;
    function CreateProcessA(...rest:global.Buffer):Bool;

    function WaitForMultipleObjects(nCount:Int,lpHandles:global.Buffer,bWaitAll:Bool,dwMilliseconds:Int):Int;
}

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

    static final voidBuf = ArrayType.call(refType(rtypes.void));

    static final K32:Kernel32 = cast new Library("kernel32", {
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
            WaitForMultipleObjects : [DWORD,[DWORD,voidBuf,rtypes.bool,DWORD]]
        }
    });

    static final lib = cast new Library("ucrtbase", {
        untyped {
            memset : [refType(rtypes.void),[refType(rtypes.void),rtypes.int,rtypes.size_t]]
        }
    });


    final event_parent_send:global.Buffer;

    final map_file:global.Buffer;
    
    final event_child_send:global.Buffer;

    final processInfo:global.Buffer = cast PROCESS_INFO.call();

    //so this is the power... of javashit programmers......
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
            throw "NOOOO";
        }
        event_parent_send = K32.CreateEventA(securityAttr.ref(),false,false,RefNapi.NULL);
        if (RefNapi.isNull(event_parent_send)) {
            throw "Nooo 2";
        }
        event_child_send = K32.CreateEventA(securityAttr.ref(),false,false,NULL);
        if (RefNapi.isNull(event_child_send)) {
            throw "NOOO!! 3";
        }
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
        final si:global.Buffer = cast STARTUP_INFO.call();
        untyped lib.memset(si.ref(),0,STARTUP_INFO.size);
        untyped si.cb = STARTUP_INFO.size;
        final mf = map_file.address();
        final eps = event_parent_send.address();     
        final ecs = event_child_send.address();
        final argString = args.join(" ");
        final command = RefNapi.allocCString('$program -HFILE $mf -HPARENT $eps -HCHILD $ecs $argString');
        var result = K32.CreateProcessA(null,command,null,null,cast true,cast 16,null,null,si.ref(),
        processInfo.ref());
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
            throw "Event not set...";
        }
        if (!WaitForResponse()) {
            trace("Could not wait...");
            throw "Yikes";
        }
        
        final pBuf = GetMappedBuffer();
        final output = if (pBuf[0] == 1) {
            RefNapi.readCString(pBuf.buffer.reinterpretUntilZeros(rtypes.char.size),rtypes.int.size);
        } else {
            "gay";
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
            throw "Could not wait";
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
            trace("Wuh oh");
        }
        
        return pbuf2;
    }

    public function WriteText(input:String) {
        final pBuf = GetMappedBuffer();
        pBuf[0] = 0x2;

        final strBuf = pBuf.buffer.reinterpret(input.length + 1,1 * rtypes.int.size);
        strBuf.writeCString(cast input,cast 0,"utf8"); //pretty sure this is a bug in napi, or dts2hx. whatever
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
            trace(pBuf[0]);
            trace(pBuf[1]);
            -1;
        }
        ReleaseMappedBuffer(pBuf);
        return bufferSize;
    }

    function WaitForResponse() {
        
        final waitForEvents:TypedArray<global.Buffer> = voidBuf.call(2);
        waitForEvents[0] = event_child_send;
        waitForEvents[1] = untyped processInfo.hProcess;
        final waitResult = K32.WaitForMultipleObjects(2,cast waitForEvents,false,0xFFFFFFF);
        if (waitResult == WAIT_OBJECT_0 + 1) {
            trace("Process ended");
        }
        return waitResult == WAIT_OBJECT_0;
    }

    function ReleaseMappedBuffer(pbuf:TypedArray<Int>) {
        K32.UnmapViewOfFile(pbuf);
    }

    

    

   
}