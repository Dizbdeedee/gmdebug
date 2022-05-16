// Generated by Haxe 4.2.1+bf9ff69
(function ($global) { "use strict";
class HxOverrides {
	static substr(s,pos,len) {
		if(len == null) {
			len = s.length;
		} else if(len < 0) {
			if(pos == 0) {
				len = s.length + len;
			} else {
				return "";
			}
		}
		return s.substr(pos,len);
	}
	static now() {
		return Date.now();
	}
}
HxOverrides.__name__ = true;
Math.__name__ = true;
var RefArrayDi = require("ref-array-di");
var RefNapi = require("ref-napi");
var RefStructDi = require("ref-struct-di");
class Std {
	static string(s) {
		return js_Boot.__string_rec(s,"");
	}
}
Std.__name__ = true;
var ffi_$napi_Library = require("ffi-napi").Library;
class gmdebug_dap_srcds_RedirectWorker {
	static isAllWhitespace(str) {
		let _g_offset = 0;
		while(_g_offset < str.length) {
			let c = str.charCodeAt(_g_offset++);
			if(c != 32) {
				return false;
			}
		}
		return true;
	}
	static HandleCommandLineDisplay(r,screenSize) {
		let cmdLine = r.ReadText(screenSize - 1,screenSize - 1);
		cmdLine.length > 0 && !gmdebug_dap_srcds_RedirectWorker.isAllWhitespace(cmdLine) && gmdebug_dap_srcds_RedirectWorker.oldCmdLine != null && !cmdLine.startsWith(gmdebug_dap_srcds_RedirectWorker.oldCmdLine);
		gmdebug_dap_srcds_RedirectWorker.oldCmdLine = cmdLine;
	}
	static main() {
		let r = new gmdebug_dap_srcds_Redirector();
		console.log("src/gmdebug/dap/srcds/RedirectWorker.hx:55:",process.argv);
		r.Start(process.argv[2],process.argv.slice(3));
		let bJustStarted = false;
		let outputBuffer = [];
		let oldOutput = [];
		let loop = function() {
			let screenSize = r.GetScreenBufferSize();
			if(screenSize == -1) {
				return;
			}
			if(!r.SetScreenBufferSize(screenSize)) {
				console.log("src/gmdebug/dap/srcds/RedirectWorker.hx:64:","Failed to set screen size " + screenSize);
			}
			if(process.stdin.readable) {
				let read;
				let readStr_b = "";
				while(true) {
					read = process.stdin.read();
					if(read != null) {
						console.log("src/gmdebug/dap/srcds/RedirectWorker.hx:72:",read);
						readStr_b += Std.string(read.toString());
					}
					if(!(read != null)) {
						break;
					}
				}
				if(readStr_b.length > 0) {
					console.log("src/gmdebug/dap/srcds/RedirectWorker.hx:77:",readStr_b);
					r.WriteText(readStr_b);
				}
			}
			let output = r.ReadText(1,screenSize - 2);
			outputBuffer = [];
			let lastNotEmptyIndex = -1;
			let _g = 0;
			let _g1 = screenSize - 2;
			while(_g < _g1) {
				let i = _g++;
				if(i * gmdebug_dap_srcds_RedirectWorker.CON_LINE_LENGTH >= output.length) {
					break;
				}
				let line = HxOverrides.substr(output,i * gmdebug_dap_srcds_RedirectWorker.CON_LINE_LENGTH,gmdebug_dap_srcds_RedirectWorker.CON_LINE_LENGTH);
				if(!gmdebug_dap_srcds_RedirectWorker.isAllWhitespace(line)) {
					lastNotEmptyIndex = outputBuffer.length;
				}
				outputBuffer.push(line);
			}
			if(lastNotEmptyIndex >= 0 && outputBuffer.length > lastNotEmptyIndex) {
				outputBuffer.length = lastNotEmptyIndex + 1;
			}
			if(lastNotEmptyIndex != -1) {
				bJustStarted = false;
			}
			if(oldOutput.length > 0) {
				let lastLine = oldOutput.length - 1;
				let firstNewLine = outputBuffer.length - 1;
				let hist = false;
				let _g = 0;
				let _g1 = outputBuffer.length - 1;
				while(_g < _g1) {
					let i = _g++;
					let x = outputBuffer.length - 1 - i;
					if(outputBuffer[x].startsWith(oldOutput[lastLine])) {
						++firstNewLine;
						hist = true;
						let _g = i + 1;
						let _g1 = outputBuffer.length - 1;
						while(_g < _g1) {
							let _u = _g++;
							let u = outputBuffer.length - 1 - _u;
							if(!outputBuffer[u].startsWith(oldOutput[--lastLine])) {
								lastLine = oldOutput.length - 1;
								firstNewLine -= 2;
								hist = false;
								break;
							}
						}
						if(hist) {
							break;
						}
					} else {
						--firstNewLine;
					}
				}
				if(firstNewLine < 0) {
					if(hist) {
						gmdebug_dap_srcds_RedirectWorker.HandleCommandLineDisplay(r,screenSize);
						return;
					} else {
						console.log("src/gmdebug/dap/srcds/RedirectWorker.hx:131:","Console moved too fast " + firstNewLine);
						firstNewLine = 0;
					}
				}
				let _g2 = firstNewLine;
				let _g3 = outputBuffer.length;
				while(_g2 < _g3) {
					let i = _g2++;
					oldOutput.push(outputBuffer[i]);
					process.stdout.write(outputBuffer[i] + "\n");
				}
				let sizeDiff = oldOutput.length - screenSize;
				if(sizeDiff > 0) {
					oldOutput.splice(0,sizeDiff);
				}
			} else if(!bJustStarted) {
				let _g = 0;
				while(_g < outputBuffer.length) {
					let str = outputBuffer[_g];
					++_g;
					oldOutput.push(str);
					process.stdout.write(str);
				}
			}
			gmdebug_dap_srcds_RedirectWorker.HandleCommandLineDisplay(r,screenSize);
		};
		let mainLoop = null;
		mainLoop = function() {
			loop();
			js_node_Timers.setImmediate(mainLoop);
		};
		mainLoop();
	}
}
gmdebug_dap_srcds_RedirectWorker.__name__ = true;
class gmdebug_dap_srcds_Redirector {
	constructor() {
		this.processInfo = gmdebug_dap_srcds_Redirector.PROCESS_INFO();
		let securityAttr = gmdebug_dap_srcds_Redirector.SECURITY_ATTR({ nLength : gmdebug_dap_srcds_Redirector.SECURITY_ATTR.size, lpSecurityDescriptor : gmdebug_dap_srcds_Redirector.NULL, bInheritHandle : true});
		let point = gmdebug_dap_srcds_Redirector.bufferAtAddress(new haxe__$Int64__$_$_$Int64(0xFFFFFFFF,0xFFFFFFFF));
		console.log("src/gmdebug/dap/srcds/Redirector.hx:148:",point.address());
		this.map_file = gmdebug_dap_srcds_Redirector.K32.CreateFileMappingA(point,securityAttr.ref(),4,0,65536,gmdebug_dap_srcds_Redirector.NULL);
		console.log("src/gmdebug/dap/srcds/Redirector.hx:150:",this.map_file.address());
		if(RefNapi.isNull(this.map_file)) {
			throw haxe_Exception.thrown("NOOOO");
		}
		this.event_parent_send = gmdebug_dap_srcds_Redirector.K32.CreateEventA(securityAttr.ref(),false,false,RefNapi.NULL);
		if(RefNapi.isNull(this.event_parent_send)) {
			throw haxe_Exception.thrown("Nooo 2");
		}
		this.event_child_send = gmdebug_dap_srcds_Redirector.K32.CreateEventA(securityAttr.ref(),false,false,gmdebug_dap_srcds_Redirector.NULL);
		if(RefNapi.isNull(this.event_child_send)) {
			throw haxe_Exception.thrown("NOOO!! 3");
		}
	}
	Start(program,args) {
		if(!sys_FileSystem.exists(program)) {
			throw haxe_Exception.thrown("Program path does not exist.");
		}
		if(sys_FileSystem.isDirectory(program)) {
			throw haxe_Exception.thrown("Program path is a directory.");
		}
		if(!haxe_io_Path.isAbsolute(program)) {
			throw haxe_Exception.thrown("Absolute paths only.");
		}
		let si = gmdebug_dap_srcds_Redirector.STARTUP_INFO();
		let tmp = si.ref();
		gmdebug_dap_srcds_Redirector.lib.memset(tmp,0,gmdebug_dap_srcds_Redirector.STARTUP_INFO.size);
		si.cb = gmdebug_dap_srcds_Redirector.STARTUP_INFO.size;
		let mf = this.map_file.address();
		let eps = this.event_parent_send.address();
		let ecs = this.event_child_send.address();
		let argString = args.join(" ");
		let command = RefNapi.allocCString("" + program + " -HFILE " + mf + " -HPARENT " + eps + " -HCHILD " + ecs + " " + argString);
		let result = gmdebug_dap_srcds_Redirector.K32.CreateProcessA(null,command,null,null,true,16,null,null,si.ref(),this.processInfo.ref());
		if(!result) {
			throw haxe_Exception.thrown("Good luck debugging this, asshole");
		}
	}
	ReadText(iBeginLine,iEndLine) {
		let pbuf = this.GetMappedBuffer();
		pbuf[0] = 3;
		pbuf[1] = iBeginLine;
		pbuf[2] = iEndLine;
		this.ReleaseMappedBuffer(pbuf);
		let eventSet = gmdebug_dap_srcds_Redirector.K32.SetEvent(this.event_parent_send);
		if(!eventSet) {
			throw haxe_Exception.thrown("Event not set...");
		}
		if(!this.WaitForResponse()) {
			console.log("src/gmdebug/dap/srcds/Redirector.hx:200:","Could not wait...");
			throw haxe_Exception.thrown("Yikes");
		}
		let pBuf = this.GetMappedBuffer();
		let output = pBuf[0] == 1 ? RefNapi.readCString(pBuf.buffer.reinterpretUntilZeros(RefNapi.types.char.size),RefNapi.types.int.size) : "gay";
		this.ReleaseMappedBuffer(pBuf);
		return output;
	}
	SetScreenBufferSize(iLines) {
		let pBuf = this.GetMappedBuffer();
		pBuf[0] = 5;
		pBuf[1] = iLines;
		this.ReleaseMappedBuffer(pBuf);
		gmdebug_dap_srcds_Redirector.K32.SetEvent(this.event_parent_send);
		if(!this.WaitForResponse()) {
			throw haxe_Exception.thrown("Could not wait");
		}
		let pBuf1 = this.GetMappedBuffer();
		let success = pBuf1[0] == 1;
		this.ReleaseMappedBuffer(pBuf1);
		return success;
	}
	GetMappedBuffer() {
		let pbuf = gmdebug_dap_srcds_Redirector.K32.MapViewOfFile(this.map_file,6,RefNapi.NULL,RefNapi.NULL,0);
		let pbuf2 = gmdebug_dap_srcds_Redirector.intBuf(pbuf.reinterpret(3 * RefNapi.types.int.size),3);
		if(RefNapi.isNull(pbuf2.buffer)) {
			console.log("src/gmdebug/dap/srcds/Redirector.hx:236:","Wuh oh");
		}
		return pbuf2;
	}
	WriteText(input) {
		let pBuf = this.GetMappedBuffer();
		pBuf[0] = 2;
		let strBuf = pBuf.buffer.reinterpret((input.length + 1) * RefNapi.types.char.size,RefNapi.types.int32.size);
		strBuf.write(input + "\x00",0);
		this.ReleaseMappedBuffer(pBuf);
		gmdebug_dap_srcds_Redirector.K32.SetEvent(this.event_parent_send);
		if(!this.WaitForResponse()) {
			throw haxe_Exception.thrown("Could not wait");
		}
		let pBuf1 = this.GetMappedBuffer();
		let success = pBuf1[0] == 1;
		this.ReleaseMappedBuffer(pBuf1);
		return success;
	}
	GetScreenBufferSize() {
		let pBuf = this.GetMappedBuffer();
		pBuf[0] = 4;
		this.ReleaseMappedBuffer(pBuf);
		let eventSet = gmdebug_dap_srcds_Redirector.K32.SetEvent(this.event_parent_send);
		if(!eventSet) {
			throw haxe_Exception.thrown("Event not set...");
		}
		if(!this.WaitForResponse()) {
			throw haxe_Exception.thrown("Could not wati...");
		}
		let pBuf1 = this.GetMappedBuffer();
		let bufferSize;
		if(pBuf1[0] == 1) {
			bufferSize = pBuf1[1];
		} else {
			console.log("src/gmdebug/dap/srcds/Redirector.hx:278:",pBuf1[0]);
			console.log("src/gmdebug/dap/srcds/Redirector.hx:279:",pBuf1[1]);
			bufferSize = -1;
		}
		this.ReleaseMappedBuffer(pBuf1);
		return bufferSize;
	}
	WaitForResponse() {
		let waitForEvents = gmdebug_dap_srcds_Redirector.voidBuf(2);
		waitForEvents[0] = this.event_child_send;
		waitForEvents[1] = this.processInfo.hProcess;
		let waitResult = gmdebug_dap_srcds_Redirector.K32.WaitForMultipleObjects(2,waitForEvents,false,268435455);
		if(waitResult == gmdebug_dap_srcds_Redirector.WAIT_OBJECT_0 + 1) {
			console.log("src/gmdebug/dap/srcds/Redirector.hx:293:","Process ended");
		}
		return waitResult == gmdebug_dap_srcds_Redirector.WAIT_OBJECT_0;
	}
	ReleaseMappedBuffer(pbuf) {
		gmdebug_dap_srcds_Redirector.K32.UnmapViewOfFile(pbuf);
	}
	static bufferAtAddress(address) {
		let buf = Buffer.alloc(8);
		buf.writeUInt32LE(address.high,0);
		buf.writeUInt32LE(address.low,4);
		let newType = Object.assign({ },RefNapi.types.void);
		newType.indirection = 2;
		buf.type = newType;
		return RefNapi.deref(buf);
	}
}
gmdebug_dap_srcds_Redirector.__name__ = true;
Object.assign(gmdebug_dap_srcds_Redirector.prototype, {
	__class__: gmdebug_dap_srcds_Redirector
});
class haxe_Exception extends Error {
	constructor(message,previous,native) {
		super(message);
		this.message = message;
		this.__previousException = previous;
		this.__nativeException = native != null ? native : this;
	}
	get_native() {
		return this.__nativeException;
	}
	static thrown(value) {
		if(((value) instanceof haxe_Exception)) {
			return value.get_native();
		} else if(((value) instanceof Error)) {
			return value;
		} else {
			let e = new haxe_ValueException(value);
			return e;
		}
	}
}
haxe_Exception.__name__ = true;
Object.assign(haxe_Exception.prototype, {
	__class__: haxe_Exception
});
class haxe__$Int64__$_$_$Int64 {
	constructor(high,low) {
		this.high = high;
		this.low = low;
	}
}
haxe__$Int64__$_$_$Int64.__name__ = true;
Object.assign(haxe__$Int64__$_$_$Int64.prototype, {
	__class__: haxe__$Int64__$_$_$Int64
});
class haxe_ValueException extends haxe_Exception {
	constructor(value,previous,native) {
		super(String(value),previous,native);
		this.value = value;
	}
}
haxe_ValueException.__name__ = true;
Object.assign(haxe_ValueException.prototype, {
	__class__: haxe_ValueException
});
class haxe_io_Path {
	static isAbsolute(path) {
		if(path.startsWith("/")) {
			return true;
		}
		if(path.charAt(1) == ":") {
			return true;
		}
		if(path.startsWith("\\\\")) {
			return true;
		}
		return false;
	}
}
haxe_io_Path.__name__ = true;
class haxe_iterators_ArrayIterator {
	constructor(array) {
		this.current = 0;
		this.array = array;
	}
	hasNext() {
		return this.current < this.array.length;
	}
	next() {
		return this.array[this.current++];
	}
}
haxe_iterators_ArrayIterator.__name__ = true;
Object.assign(haxe_iterators_ArrayIterator.prototype, {
	__class__: haxe_iterators_ArrayIterator
});
class js_Boot {
	static __string_rec(o,s) {
		if(o == null) {
			return "null";
		}
		if(s.length >= 5) {
			return "<...>";
		}
		let t = typeof(o);
		if(t == "function" && (o.__name__ || o.__ename__)) {
			t = "object";
		}
		switch(t) {
		case "function":
			return "<function>";
		case "object":
			if(((o) instanceof Array)) {
				let str = "[";
				s += "\t";
				let _g = 0;
				let _g1 = o.length;
				while(_g < _g1) {
					let i = _g++;
					str += (i > 0 ? "," : "") + js_Boot.__string_rec(o[i],s);
				}
				str += "]";
				return str;
			}
			let tostr;
			try {
				tostr = o.toString;
			} catch( _g ) {
				return "???";
			}
			if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
				let s2 = o.toString();
				if(s2 != "[object Object]") {
					return s2;
				}
			}
			let str = "{\n";
			s += "\t";
			let hasp = o.hasOwnProperty != null;
			let k = null;
			for( k in o ) {
			if(hasp && !o.hasOwnProperty(k)) {
				continue;
			}
			if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
				continue;
			}
			if(str.length != 2) {
				str += ", \n";
			}
			str += s + k + " : " + js_Boot.__string_rec(o[k],s);
			}
			s = s.substring(1);
			str += "\n" + s + "}";
			return str;
		case "string":
			return o;
		default:
			return String(o);
		}
	}
}
js_Boot.__name__ = true;
var js_node_Fs = require("fs");
var js_node_Timers = require("timers");
class sys_FileSystem {
	static exists(path) {
		try {
			js_node_Fs.accessSync(path);
			return true;
		} catch( _g ) {
			return false;
		}
	}
	static isDirectory(path) {
		try {
			return js_node_Fs.statSync(path).isDirectory();
		} catch( _g ) {
			return false;
		}
	}
}
sys_FileSystem.__name__ = true;
if(typeof(performance) != "undefined" ? typeof(performance.now) == "function" : false) {
	HxOverrides.now = performance.now.bind(performance);
}
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
{
	String.prototype.__class__ = String;
	String.__name__ = true;
	Array.__name__ = true;
}
js_Boot.__toStr = ({ }).toString;
gmdebug_dap_srcds_RedirectWorker.CON_LINE_LENGTH = 80;
gmdebug_dap_srcds_Redirector.STATUS_WAIT_0 = 0;
gmdebug_dap_srcds_Redirector.WAIT_OBJECT_0 = gmdebug_dap_srcds_Redirector.STATUS_WAIT_0;
gmdebug_dap_srcds_Redirector.StructType = RefStructDi(RefNapi);
gmdebug_dap_srcds_Redirector.ArrayType = RefArrayDi(RefNapi);
gmdebug_dap_srcds_Redirector.LPVOID = RefNapi.refType(RefNapi.types.void);
gmdebug_dap_srcds_Redirector.DWORD = RefNapi.types.ulong;
gmdebug_dap_srcds_Redirector.WORD = RefNapi.types.ushort;
gmdebug_dap_srcds_Redirector.BOOL = RefNapi.types.int;
gmdebug_dap_srcds_Redirector.NULL = RefNapi.NULL;
gmdebug_dap_srcds_Redirector.HANDLE = RefNapi.refType(RefNapi.types.void);
gmdebug_dap_srcds_Redirector.SECURITY_ATTR = gmdebug_dap_srcds_Redirector.StructType({ nLength : gmdebug_dap_srcds_Redirector.DWORD, lpSecurityDescriptor : gmdebug_dap_srcds_Redirector.LPVOID, bInheritHandle : gmdebug_dap_srcds_Redirector.BOOL});
gmdebug_dap_srcds_Redirector.PROCESS_INFO = gmdebug_dap_srcds_Redirector.StructType({ hProcess : gmdebug_dap_srcds_Redirector.HANDLE, hThread : gmdebug_dap_srcds_Redirector.HANDLE, dwProcessId : gmdebug_dap_srcds_Redirector.DWORD, dwThreadId : gmdebug_dap_srcds_Redirector.DWORD});
gmdebug_dap_srcds_Redirector.STARTUP_INFO = gmdebug_dap_srcds_Redirector.StructType({ cb : gmdebug_dap_srcds_Redirector.DWORD, lpReserved : RefNapi.refType(RefNapi.types.char), lpDesktop : RefNapi.refType(RefNapi.types.char), lpTitle : RefNapi.refType(RefNapi.types.char), dwX : gmdebug_dap_srcds_Redirector.DWORD, dwY : gmdebug_dap_srcds_Redirector.DWORD, dwXSize : gmdebug_dap_srcds_Redirector.DWORD, dwYSize : gmdebug_dap_srcds_Redirector.DWORD, dwXCountChars : gmdebug_dap_srcds_Redirector.DWORD, dwYCountChars : gmdebug_dap_srcds_Redirector.DWORD, dwFillAttribute : gmdebug_dap_srcds_Redirector.DWORD, dwFlags : gmdebug_dap_srcds_Redirector.DWORD, wShowWindow : gmdebug_dap_srcds_Redirector.WORD, cbReserved2 : gmdebug_dap_srcds_Redirector.WORD, lpReserved2 : RefNapi.refType(RefNapi.types.byte), hStdInput : gmdebug_dap_srcds_Redirector.HANDLE, hStdOutput : gmdebug_dap_srcds_Redirector.HANDLE, hStdError : gmdebug_dap_srcds_Redirector.HANDLE});
gmdebug_dap_srcds_Redirector.intBuf = gmdebug_dap_srcds_Redirector.ArrayType(RefNapi.types.int,3);
gmdebug_dap_srcds_Redirector.voidBuf = gmdebug_dap_srcds_Redirector.ArrayType(RefNapi.refType(RefNapi.types.void));
gmdebug_dap_srcds_Redirector.K32 = new ffi_$napi_Library("kernel32",{ CreateFileMappingA : [gmdebug_dap_srcds_Redirector.HANDLE,[gmdebug_dap_srcds_Redirector.HANDLE,RefNapi.refType(gmdebug_dap_srcds_Redirector.SECURITY_ATTR),RefNapi.types.ulong,RefNapi.types.ulong,RefNapi.types.ulong,RefNapi.types.CString]], CreateEventA : [gmdebug_dap_srcds_Redirector.HANDLE,[RefNapi.refType(gmdebug_dap_srcds_Redirector.SECURITY_ATTR),RefNapi.types.bool,RefNapi.types.bool,RefNapi.types.CString]], MapViewOfFile : [RefNapi.refType(RefNapi.types.void),[RefNapi.refType(RefNapi.types.void),gmdebug_dap_srcds_Redirector.DWORD,gmdebug_dap_srcds_Redirector.DWORD,gmdebug_dap_srcds_Redirector.DWORD,RefNapi.types.size_t]], UnmapViewOfFile : [RefNapi.types.void,[gmdebug_dap_srcds_Redirector.intBuf]], SetEvent : [RefNapi.types.bool,[RefNapi.refType(RefNapi.types.void)]], WaitForSingleObject : [gmdebug_dap_srcds_Redirector.DWORD,[RefNapi.types.uint,gmdebug_dap_srcds_Redirector.DWORD]], CreateProcessA : [RefNapi.types.int,[RefNapi.refType(RefNapi.types.char),RefNapi.refType(RefNapi.types.char),RefNapi.refType(gmdebug_dap_srcds_Redirector.SECURITY_ATTR),RefNapi.refType(gmdebug_dap_srcds_Redirector.SECURITY_ATTR),RefNapi.types.bool,RefNapi.types.ulong,RefNapi.refType(RefNapi.types.void),RefNapi.refType(RefNapi.types.char),RefNapi.refType(gmdebug_dap_srcds_Redirector.STARTUP_INFO),RefNapi.refType(gmdebug_dap_srcds_Redirector.PROCESS_INFO)]], GetLastError : [gmdebug_dap_srcds_Redirector.DWORD,[]], WaitForMultipleObjects : [gmdebug_dap_srcds_Redirector.DWORD,[gmdebug_dap_srcds_Redirector.DWORD,gmdebug_dap_srcds_Redirector.voidBuf,RefNapi.types.bool,gmdebug_dap_srcds_Redirector.DWORD]]});
gmdebug_dap_srcds_Redirector.lib = new ffi_$napi_Library("ucrtbase",{ memset : [RefNapi.refType(RefNapi.types.void),[RefNapi.refType(RefNapi.types.void),RefNapi.types.int,RefNapi.types.size_t]]});
gmdebug_dap_srcds_RedirectWorker.main();
})(typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);

//# sourceMappingURL=redirect.js.map