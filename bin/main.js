(function ($global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); },$hxEnums = $hxEnums || {},$_;
class EReg {
	constructor(r,opt) {
		this.r = new RegExp(r,opt.split("u").join(""));
	}
	match(s) {
		if(this.r.global) {
			this.r.lastIndex = 0;
		}
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	matched(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) {
			return this.r.m[n];
		} else {
			throw haxe_Exception.thrown("EReg::matched");
		}
	}
}
EReg.__name__ = true;
Object.assign(EReg.prototype, {
	__class__: EReg
	,r: null
});
class HxOverrides {
	static dateStr(date) {
		let m = date.getMonth() + 1;
		let d = date.getDate();
		let h = date.getHours();
		let mi = date.getMinutes();
		let s = date.getSeconds();
		return date.getFullYear() + "-" + (m < 10 ? "0" + m : "" + m) + "-" + (d < 10 ? "0" + d : "" + d) + " " + (h < 10 ? "0" + h : "" + h) + ":" + (mi < 10 ? "0" + mi : "" + mi) + ":" + (s < 10 ? "0" + s : "" + s);
	}
	static cca(s,index) {
		let x = s.charCodeAt(index);
		if(x != x) {
			return undefined;
		}
		return x;
	}
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
class Lambda {
	static iter(it,f) {
		let x = $getIterator(it);
		while(x.hasNext()) {
			let x1 = x.next();
			f(x1);
		}
	}
}
Lambda.__name__ = true;
Math.__name__ = true;
class Reflect {
	static field(o,field) {
		try {
			return o[field];
		} catch( _g ) {
			return null;
		}
	}
	static fields(o) {
		let a = [];
		if(o != null) {
			let hasOwnProperty = Object.prototype.hasOwnProperty;
			for( var f in o ) {
			if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) {
				a.push(f);
			}
			}
		}
		return a;
	}
	static isFunction(f) {
		if(typeof(f) == "function") {
			return !(f.__name__ || f.__ename__);
		} else {
			return false;
		}
	}
}
Reflect.__name__ = true;
class Std {
	static string(s) {
		return js_Boot.__string_rec(s,"");
	}
	static parseInt(x) {
		if(x != null) {
			let _g = 0;
			let _g1 = x.length;
			while(_g < _g1) {
				let i = _g++;
				let c = x.charCodeAt(i);
				if(c <= 8 || c >= 14 && c != 32 && c != 45) {
					let nc = x.charCodeAt(i + 1);
					let v = parseInt(x,nc == 120 || nc == 88 ? 16 : 10);
					if(isNaN(v)) {
						return null;
					} else {
						return v;
					}
				}
			}
		}
		return null;
	}
}
Std.__name__ = true;
class StringBuf {
	constructor() {
		this.b = "";
	}
}
StringBuf.__name__ = true;
Object.assign(StringBuf.prototype, {
	__class__: StringBuf
	,b: null
});
class StringTools {
	static lpad(s,c,l) {
		if(c.length <= 0) {
			return s;
		}
		let buf_b = "";
		l -= s.length;
		while(buf_b.length < l) buf_b += c == null ? "null" : "" + c;
		buf_b += s == null ? "null" : "" + s;
		return buf_b;
	}
	static replace(s,sub,by) {
		return s.split(sub).join(by);
	}
}
StringTools.__name__ = true;
class haxe_io_Input {
	readByte() {
		throw new haxe_exceptions_NotImplementedException(null,null,{ fileName : "haxe/io/Input.hx", lineNumber : 53, className : "haxe.io.Input", methodName : "readByte"});
	}
	readBytes(s,pos,len) {
		let k = len;
		let b = s.b;
		if(pos < 0 || len < 0 || pos + len > s.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		try {
			while(k > 0) {
				b[pos] = this.readByte();
				++pos;
				--k;
			}
		} catch( _g ) {
			if(!((haxe_Exception.caught(_g).unwrap()) instanceof haxe_io_Eof)) {
				throw _g;
			}
		}
		return len - k;
	}
	readFullBytes(s,pos,len) {
		while(len > 0) {
			let k = this.readBytes(s,pos,len);
			if(k == 0) {
				throw haxe_Exception.thrown(haxe_io_Error.Blocked);
			}
			pos += k;
			len -= k;
		}
	}
	readLine() {
		let buf = new haxe_io_BytesBuffer();
		let last;
		let s;
		try {
			while(true) {
				last = this.readByte();
				if(!(last != 10)) {
					break;
				}
				buf.addByte(last);
			}
			s = buf.getBytes().toString();
			if(HxOverrides.cca(s,s.length - 1) == 13) {
				s = HxOverrides.substr(s,0,-1);
			}
		} catch( _g ) {
			let _g1 = haxe_Exception.caught(_g).unwrap();
			if(((_g1) instanceof haxe_io_Eof)) {
				let e = _g1;
				s = buf.getBytes().toString();
				if(s.length == 0) {
					throw haxe_Exception.thrown(e);
				}
			} else {
				throw _g;
			}
		}
		return s;
	}
	readString(len,encoding) {
		let b = new haxe_io_Bytes(new ArrayBuffer(len));
		this.readFullBytes(b,0,len);
		return b.getString(0,len,encoding);
	}
}
haxe_io_Input.__name__ = true;
Object.assign(haxe_io_Input.prototype, {
	__class__: haxe_io_Input
});
var ValueType = $hxEnums["ValueType"] = { __ename__:true,__constructs__:null
	,TNull: {_hx_name:"TNull",_hx_index:0,__enum__:"ValueType",toString:$estr}
	,TInt: {_hx_name:"TInt",_hx_index:1,__enum__:"ValueType",toString:$estr}
	,TFloat: {_hx_name:"TFloat",_hx_index:2,__enum__:"ValueType",toString:$estr}
	,TBool: {_hx_name:"TBool",_hx_index:3,__enum__:"ValueType",toString:$estr}
	,TObject: {_hx_name:"TObject",_hx_index:4,__enum__:"ValueType",toString:$estr}
	,TFunction: {_hx_name:"TFunction",_hx_index:5,__enum__:"ValueType",toString:$estr}
	,TClass: ($_=function(c) { return {_hx_index:6,c:c,__enum__:"ValueType",toString:$estr}; },$_._hx_name="TClass",$_.__params__ = ["c"],$_)
	,TEnum: ($_=function(e) { return {_hx_index:7,e:e,__enum__:"ValueType",toString:$estr}; },$_._hx_name="TEnum",$_.__params__ = ["e"],$_)
	,TUnknown: {_hx_name:"TUnknown",_hx_index:8,__enum__:"ValueType",toString:$estr}
};
ValueType.__constructs__ = [ValueType.TNull,ValueType.TInt,ValueType.TFloat,ValueType.TBool,ValueType.TObject,ValueType.TFunction,ValueType.TClass,ValueType.TEnum,ValueType.TUnknown];
class Type {
	static getInstanceFields(c) {
		let result = [];
		while(c != null) {
			let _g = 0;
			let _g1 = Object.getOwnPropertyNames(c.prototype);
			while(_g < _g1.length) {
				let name = _g1[_g];
				++_g;
				switch(name) {
				case "__class__":case "__properties__":case "constructor":
					break;
				default:
					if(result.indexOf(name) == -1) {
						result.push(name);
					}
				}
			}
			c = c.__super__;
		}
		return result;
	}
	static typeof(v) {
		switch(typeof(v)) {
		case "boolean":
			return ValueType.TBool;
		case "function":
			if(v.__name__ || v.__ename__) {
				return ValueType.TObject;
			}
			return ValueType.TFunction;
		case "number":
			if(Math.ceil(v) == v % 2147483648.0) {
				return ValueType.TInt;
			}
			return ValueType.TFloat;
		case "object":
			if(v == null) {
				return ValueType.TNull;
			}
			let e = v.__enum__;
			if(e != null) {
				return ValueType.TEnum($hxEnums[e]);
			}
			let c = js_Boot.getClass(v);
			if(c != null) {
				return ValueType.TClass(c);
			}
			return ValueType.TObject;
		case "string":
			return ValueType.TClass(String);
		case "undefined":
			return ValueType.TNull;
		default:
			return ValueType.TUnknown;
		}
	}
}
Type.__name__ = true;
class haxe_io_Path {
	constructor(path) {
		switch(path) {
		case ".":case "..":
			this.dir = path;
			this.file = "";
			return;
		}
		let c1 = path.lastIndexOf("/");
		let c2 = path.lastIndexOf("\\");
		if(c1 < c2) {
			this.dir = HxOverrides.substr(path,0,c2);
			path = HxOverrides.substr(path,c2 + 1,null);
			this.backslash = true;
		} else if(c2 < c1) {
			this.dir = HxOverrides.substr(path,0,c1);
			path = HxOverrides.substr(path,c1 + 1,null);
		} else {
			this.dir = null;
		}
		let cp = path.lastIndexOf(".");
		if(cp != -1) {
			this.ext = HxOverrides.substr(path,cp + 1,null);
			this.file = HxOverrides.substr(path,0,cp);
		} else {
			this.ext = null;
			this.file = path;
		}
	}
	static directory(path) {
		let s = new haxe_io_Path(path);
		if(s.dir == null) {
			return "";
		}
		return s.dir;
	}
	static join(paths) {
		let _g = [];
		let _g1 = 0;
		while(_g1 < paths.length) {
			let v = paths[_g1];
			++_g1;
			if(v != null && v != "") {
				_g.push(v);
			}
		}
		if(_g.length == 0) {
			return "";
		}
		let path = _g[0];
		let _g2 = 1;
		let _g3 = _g.length;
		while(_g2 < _g3) {
			let i = _g2++;
			path = haxe_io_Path.addTrailingSlash(path);
			path += _g[i];
		}
		return haxe_io_Path.normalize(path);
	}
	static normalize(path) {
		let slash = "/";
		path = path.split("\\").join(slash);
		if(path == slash) {
			return slash;
		}
		let target = [];
		let _g = 0;
		let _g1 = path.split(slash);
		while(_g < _g1.length) {
			let token = _g1[_g];
			++_g;
			if(token == ".." && target.length > 0 && target[target.length - 1] != "..") {
				target.pop();
			} else if(token == "") {
				if(target.length > 0 || HxOverrides.cca(path,0) == 47) {
					target.push(token);
				}
			} else if(token != ".") {
				target.push(token);
			}
		}
		let tmp = target.join(slash);
		let acc_b = "";
		let colon = false;
		let slashes = false;
		let _g2_offset = 0;
		let _g2_s = tmp;
		while(_g2_offset < _g2_s.length) {
			let s = _g2_s;
			let index = _g2_offset++;
			let c = s.charCodeAt(index);
			if(c >= 55296 && c <= 56319) {
				c = c - 55232 << 10 | s.charCodeAt(index + 1) & 1023;
			}
			let c1 = c;
			if(c1 >= 65536) {
				++_g2_offset;
			}
			let c2 = c1;
			switch(c2) {
			case 47:
				if(!colon) {
					slashes = true;
				} else {
					let i = c2;
					colon = false;
					if(slashes) {
						acc_b += "/";
						slashes = false;
					}
					acc_b += String.fromCodePoint(i);
				}
				break;
			case 58:
				acc_b += ":";
				colon = true;
				break;
			default:
				let i = c2;
				colon = false;
				if(slashes) {
					acc_b += "/";
					slashes = false;
				}
				acc_b += String.fromCodePoint(i);
			}
		}
		return acc_b;
	}
	static addTrailingSlash(path) {
		if(path.length == 0) {
			return "/";
		}
		let c1 = path.lastIndexOf("/");
		let c2 = path.lastIndexOf("\\");
		if(c1 < c2) {
			if(c2 != path.length - 1) {
				return path + "\\";
			} else {
				return path;
			}
		} else if(c1 != path.length - 1) {
			return path + "/";
		} else {
			return path;
		}
	}
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
Object.assign(haxe_io_Path.prototype, {
	__class__: haxe_io_Path
	,dir: null
	,file: null
	,ext: null
	,backslash: null
});
class gmdebug_Cross {
	static readHeader(x) {
		let raw_content = x.readLine();
		let skip = 0;
		let _g = 0;
		let _g1 = raw_content.length;
		while(_g < _g1) {
			let i = _g++;
			if(HxOverrides.cca(raw_content,i) == 4) {
				++skip;
			} else {
				break;
			}
		}
		if(skip > 0) {
			raw_content = HxOverrides.substr(raw_content,skip,null);
		}
		let content_length = Std.parseInt(HxOverrides.substr(raw_content,15,null));
		x.readLine();
		return content_length;
	}
}
gmdebug_Cross.__name__ = true;
var gmdebug_CommMethod = $hxEnums["gmdebug.CommMethod"] = { __ename__:true,__constructs__:null
	,Pipe: {_hx_name:"Pipe",_hx_index:0,__enum__:"gmdebug.CommMethod",toString:$estr}
	,Socket: {_hx_name:"Socket",_hx_index:1,__enum__:"gmdebug.CommMethod",toString:$estr}
};
gmdebug_CommMethod.__constructs__ = [gmdebug_CommMethod.Pipe,gmdebug_CommMethod.Socket];
class gmdebug_FrameID {
	static getValue(this1) {
		let clientID = this1 >>> 27;
		let actualFrame = this1 & 134217727;
		return { clientID : clientID, actualFrame : actualFrame};
	}
}
var gmdebug_VariableReferenceVal = $hxEnums["gmdebug.VariableReferenceVal"] = { __ename__:true,__constructs__:null
	,Child: ($_=function(clientID,ref) { return {_hx_index:0,clientID:clientID,ref:ref,__enum__:"gmdebug.VariableReferenceVal",toString:$estr}; },$_._hx_name="Child",$_.__params__ = ["clientID","ref"],$_)
	,FrameLocal: ($_=function(clientID,frameID,ref) { return {_hx_index:1,clientID:clientID,frameID:frameID,ref:ref,__enum__:"gmdebug.VariableReferenceVal",toString:$estr}; },$_._hx_name="FrameLocal",$_.__params__ = ["clientID","frameID","ref"],$_)
	,Global: ($_=function(clientID,ref) { return {_hx_index:2,clientID:clientID,ref:ref,__enum__:"gmdebug.VariableReferenceVal",toString:$estr}; },$_._hx_name="Global",$_.__params__ = ["clientID","ref"],$_)
};
gmdebug_VariableReferenceVal.__constructs__ = [gmdebug_VariableReferenceVal.Child,gmdebug_VariableReferenceVal.FrameLocal,gmdebug_VariableReferenceVal.Global];
class gmdebug_VariableReference {
	static getValue(this1) {
		let clientID = this1 >>> 25 & 15;
		let ref = this1 >>> 29 & 3;
		switch(ref) {
		case 0:
			return gmdebug_VariableReferenceVal.Child(clientID,this1 & 16777215);
		case 1:
			return gmdebug_VariableReferenceVal.FrameLocal(clientID,this1 >>> 8 & 131071,this1 & 255);
		case 2:
			return gmdebug_VariableReferenceVal.Global(clientID,this1 & 16777215);
		}
	}
}
class gmdebug_composer_ComposeTools {
	static compose(req,str,body) {
		let response = new gmdebug_composer_ComposedResponse(req,body);
		response.success = true;
		return response;
	}
	static composeFail(req,rawerror,error) {
		let response = new gmdebug_composer_ComposedResponse(req,error);
		response.message = rawerror;
		response.success = false;
		return response;
	}
}
gmdebug_composer_ComposeTools.__name__ = true;
class gmdebug_composer_ComposedProtocolMessage {
	constructor(_type) {
		if(gmdebug_composer_ComposedProtocolMessage._hx_skip_constructor) {
			return;
		}
		this._hx_constructor(_type);
	}
	_hx_constructor(_type) {
		this.type = _type;
	}
}
gmdebug_composer_ComposedProtocolMessage.__name__ = true;
Object.assign(gmdebug_composer_ComposedProtocolMessage.prototype, {
	__class__: gmdebug_composer_ComposedProtocolMessage
	,type: null
});
class gmdebug_composer_ComposedEvent extends gmdebug_composer_ComposedProtocolMessage {
	constructor(str,body) {
		super("event");
		this.event = str;
		this.body = body;
	}
}
gmdebug_composer_ComposedEvent.__name__ = true;
gmdebug_composer_ComposedEvent.__super__ = gmdebug_composer_ComposedProtocolMessage;
Object.assign(gmdebug_composer_ComposedEvent.prototype, {
	__class__: gmdebug_composer_ComposedEvent
	,event: null
	,body: null
});
class gmdebug_composer_ComposedGmDebugMessage extends gmdebug_composer_ComposedProtocolMessage {
	constructor(msg,body) {
		super("gmdebug");
		this.msg = msg;
		this.body = body;
	}
}
gmdebug_composer_ComposedGmDebugMessage.__name__ = true;
gmdebug_composer_ComposedGmDebugMessage.__super__ = gmdebug_composer_ComposedProtocolMessage;
Object.assign(gmdebug_composer_ComposedGmDebugMessage.prototype, {
	__class__: gmdebug_composer_ComposedGmDebugMessage
	,msg: null
	,body: null
});
class gmdebug_composer_ComposedRequest extends gmdebug_composer_ComposedProtocolMessage {
	constructor(str,args) {
		super("request");
		this.command = str;
		this.arguments = args;
	}
}
gmdebug_composer_ComposedRequest.__name__ = true;
gmdebug_composer_ComposedRequest.__super__ = gmdebug_composer_ComposedProtocolMessage;
Object.assign(gmdebug_composer_ComposedRequest.prototype, {
	__class__: gmdebug_composer_ComposedRequest
	,command: null
	,'arguments': null
});
class gmdebug_composer_ComposedResponse extends gmdebug_composer_ComposedProtocolMessage {
	constructor(req,body) {
		gmdebug_composer_ComposedProtocolMessage._hx_skip_constructor = true;
		super();
		gmdebug_composer_ComposedProtocolMessage._hx_skip_constructor = false;
		this._hx_constructor(req,body);
	}
	_hx_constructor(req,body) {
		this.success = true;
		super._hx_constructor("response");
		this.request_seq = req.seq;
		this.command = req.command;
		this.body = body;
	}
}
gmdebug_composer_ComposedResponse.__name__ = true;
gmdebug_composer_ComposedResponse.__super__ = gmdebug_composer_ComposedProtocolMessage;
Object.assign(gmdebug_composer_ComposedResponse.prototype, {
	__class__: gmdebug_composer_ComposedResponse
	,request_seq: null
	,success: null
	,command: null
	,message: null
	,body: null
});
class gmdebug_dap_BaseConnected {
	constructor(fs,clID) {
		this.socket = fs;
		this.clID = clID;
	}
	sendRaw(x) {
		this.socket.write(x);
	}
	disconnect() {
		this.socket.end();
	}
}
gmdebug_dap_BaseConnected.__name__ = true;
Object.assign(gmdebug_dap_BaseConnected.prototype, {
	__class__: gmdebug_dap_BaseConnected
	,socket: null
	,clID: null
});
class gmdebug_dap_BytesProcessor {
	constructor() {
		this.lastGoodPos = 0;
		this.prevBytes = [];
		this.prevClientResults = [];
		this.fillRequested = false;
	}
	process(jsBuf,clientNo) {
		this.fillRequested = false;
		let bytes = js_node_buffer__$Buffer_Helper.bytesOfBuffer(jsBuf);
		bytes = this.conjoinHandle(bytes,clientNo);
		return this.processBytes(bytes,clientNo);
	}
	processBytes(rawBytes,clientNo) {
		let input = new haxe_io_BytesInput(rawBytes);
		try {
			return this.addMessages(input,clientNo);
		} catch( _g ) {
			let _g1 = haxe_Exception.caught(_g);
			let _g2 = _g1.unwrap();
			if(((_g2) instanceof haxe_io_Eof)) {
				this.lastGoodPos = input.pos;
				this.prevClientResults[clientNo] = null;
				this.prevBytes[clientNo] = rawBytes.sub(this.lastGoodPos,rawBytes.length - this.lastGoodPos);
				return [];
			} else if(typeof(_g2) == "string") {
				let e = _g2;
				this.lastGoodPos = input.pos;
				this.prevClientResults[clientNo] = null;
				this.prevBytes[clientNo] = rawBytes.sub(this.lastGoodPos,rawBytes.length - this.lastGoodPos);
				haxe_Log.trace(e,{ fileName : "src/gmdebug/dap/BytesProcessor.hx", lineNumber : 46, className : "gmdebug.dap.BytesProcessor", methodName : "processBytes"});
				return [];
			} else {
				throw haxe_Exception.thrown(_g1);
			}
		}
	}
	addMessages(inp,clientNo) {
		let messages = [];
		while(inp.pos != inp.totlen && this.skipAcks(inp)) {
			let prevResult = this.prevClientResults[clientNo];
			let result;
			if(prevResult == null) {
				result = this.recvMessage(inp);
			} else {
				switch(prevResult._hx_index) {
				case 0:
					result = this.recvMessage(inp);
					break;
				case 1:
					result = this.recvMessage(inp,prevResult.remaining);
					break;
				}
			}
			let tmp = this.prevClientResults;
			let tmp1;
			if(prevResult == null) {
				switch(result._hx_index) {
				case 0:
					messages.push(new haxe_format_JsonParser(result.x).doParse());
					tmp1 = result;
					break;
				case 1:
					tmp1 = result;
					break;
				}
			} else if(prevResult._hx_index == 1) {
				let _g = prevResult.x;
				switch(result._hx_index) {
				case 0:
					messages.push(new haxe_format_JsonParser(_g + result.x).doParse());
					tmp1 = result;
					break;
				case 1:
					tmp1 = gmdebug_dap_RecvMessageResponse.Unfinished(_g + result.x,result.remaining);
					break;
				}
			} else {
				switch(result._hx_index) {
				case 0:
					messages.push(new haxe_format_JsonParser(result.x).doParse());
					tmp1 = result;
					break;
				case 1:
					tmp1 = result;
					break;
				}
			}
			tmp[clientNo] = tmp1;
		}
		return messages;
	}
	conjoinHandle(curBytes,clientNo) {
		let oldByte = this.prevBytes[clientNo];
		if(oldByte != null) {
			let conjoinedBytes = new haxe_io_Bytes(new ArrayBuffer(oldByte.length + curBytes.length));
			conjoinedBytes.blit(0,oldByte,0,oldByte.length);
			conjoinedBytes.blit(oldByte.length,curBytes,0,curBytes.length);
			this.prevBytes[clientNo] = null;
			return conjoinedBytes;
		} else {
			return curBytes;
		}
	}
	recvMessage(input,remaining) {
		if(remaining == null) {
			remaining = gmdebug_Cross.readHeader(input);
		}
		let bufRemaining = input.totlen - input.pos;
		if(remaining > bufRemaining) {
			let str = input.readString(bufRemaining,haxe_io_Encoding.UTF8);
			remaining -= bufRemaining;
			return gmdebug_dap_RecvMessageResponse.Unfinished(str,remaining);
		} else {
			let str = input.readString(remaining,haxe_io_Encoding.UTF8);
			return gmdebug_dap_RecvMessageResponse.Completed(str);
		}
	}
	skipAcks(inp) {
		let _g = inp.pos;
		let _g1 = inp.totlen;
		while(_g < _g1) {
			++_g;
			let byt = inp.readByte();
			if(byt != 4) {
				inp.set_position(inp.pos - 1);
				return true;
			} else {
				this.fillRequested = true;
			}
		}
		return false;
	}
}
gmdebug_dap_BytesProcessor.__name__ = true;
Object.assign(gmdebug_dap_BytesProcessor.prototype, {
	__class__: gmdebug_dap_BytesProcessor
	,fillRequested: null
	,prevClientResults: null
	,prevBytes: null
	,lastGoodPos: null
});
var gmdebug_dap_RecvMessageResponse = $hxEnums["gmdebug.dap.RecvMessageResponse"] = { __ename__:true,__constructs__:null
	,Completed: ($_=function(x) { return {_hx_index:0,x:x,__enum__:"gmdebug.dap.RecvMessageResponse",toString:$estr}; },$_._hx_name="Completed",$_.__params__ = ["x"],$_)
	,Unfinished: ($_=function(x,remaining) { return {_hx_index:1,x:x,remaining:remaining,__enum__:"gmdebug.dap.RecvMessageResponse",toString:$estr}; },$_._hx_name="Unfinished",$_.__params__ = ["x","remaining"],$_)
};
gmdebug_dap_RecvMessageResponse.__constructs__ = [gmdebug_dap_RecvMessageResponse.Completed,gmdebug_dap_RecvMessageResponse.Unfinished];
class gmdebug_dap_Client extends gmdebug_dap_BaseConnected {
	constructor(fs,clientID,gmodID,gmodName) {
		super(fs,clientID);
		this.gmodID = gmodID;
		this.gmodName = gmodName;
	}
}
gmdebug_dap_Client.__name__ = true;
gmdebug_dap_Client.__super__ = gmdebug_dap_BaseConnected;
Object.assign(gmdebug_dap_Client.prototype, {
	__class__: gmdebug_dap_Client
	,gmodID: null
	,gmodName: null
});
class gmdebug_dap_ClientStorage {
	constructor(readFunc) {
		this.gmodIDMap = new haxe_ds_IntMap();
		this.disconnect = false;
		this.clients = [];
		this.readFunc = readFunc;
	}
	makePipeSocket(loc,id) {
		let _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				let data = haxe_io_Path.join([loc,gmdebug_Cross.DATA]);
				let input = haxe_io_Path.join([data,gmdebug_Cross.INPUT]);
				let output = haxe_io_Path.join([data,gmdebug_Cross.OUTPUT]);
				let ready = haxe_io_Path.join([data,gmdebug_Cross.READY]);
				let client_ready = haxe_io_Path.join([data,gmdebug_Cross.CLIENT_READY]);
				let ps = new gmdebug_dap_PipeSocket({ read : output, write : input, ready : ready, client_ready : client_ready},function(buf) {
					_gthis.readFunc(buf,id);
				});
				ps.aquire().handle(function(__t6) {
					try {
						let _g = tink_await_OutcomeTools.getOutcome(__t6);
						switch(_g._hx_index) {
						case 0:
							break;
						case 1:
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
							return;
						}
						haxe_Log.trace("mega aquired",{ fileName : "src/gmdebug/dap/ClientStorage.hx", lineNumber : 53, className : "gmdebug.dap.ClientStorage", methodName : "makePipeSocket"});
						__return(tink_core_Outcome.Success(ps));
						return;
					} catch( _g ) {
						let _g1 = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
					}
				});
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	newClient(clientLoc,gmodID,gmodName) {
		let _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				let clID = _gthis.clients.length;
				_gthis.makePipeSocket(clientLoc,clID).handle(function(__t7) {
					try {
						let __t7_result;
						let _g = tink_await_OutcomeTools.getOutcome(__t7);
						switch(_g._hx_index) {
						case 0:
							__t7_result = _g.data;
							break;
						case 1:
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
							return;
						}
						let pipesocket = __t7_result;
						let client = new gmdebug_dap_Client(pipesocket,clID,gmodID,gmodName);
						_gthis.clients.push(client);
						haxe_Log.trace("client created",{ fileName : "src/gmdebug/dap/ClientStorage.hx", lineNumber : 63, className : "gmdebug.dap.ClientStorage", methodName : "newClient"});
						_gthis.gmodIDMap.h[gmodID] = client;
						__return(tink_core_Outcome.Success(client));
						return;
					} catch( _g ) {
						let _g1 = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
					}
				});
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	newServer(serverLoc) {
		let _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				let clID = gmdebug_dap_ClientStorage.SERVER_ID;
				_gthis.makePipeSocket(serverLoc,clID).handle(function(__t8) {
					try {
						let __t8_result;
						let _g = tink_await_OutcomeTools.getOutcome(__t8);
						switch(_g._hx_index) {
						case 0:
							__t8_result = _g.data;
							break;
						case 1:
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
							return;
						}
						let pipesocket = __t8_result;
						haxe_Log.trace("Server created",{ fileName : "src/gmdebug/dap/ClientStorage.hx", lineNumber : 71, className : "gmdebug.dap.ClientStorage", methodName : "newServer"});
						let server = new gmdebug_dap_Server(pipesocket,clID);
						_gthis.clients[gmdebug_dap_ClientStorage.SERVER_ID] = server;
						__return(tink_core_Outcome.Success(server));
						return;
					} catch( _g ) {
						let _g1 = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
					}
				});
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	sendServer(msg) {
		let tmp = this.clients[gmdebug_dap_ClientStorage.SERVER_ID];
		let json = haxe_format_JsonPrinter.print(msg,null,null);
		let len = haxe_io_Bytes.ofString(json).length;
		tmp.sendRaw("Content-Length: " + len + "\r\n\r\n" + json);
	}
	sendClient(id,msg) {
		if(id == gmdebug_dap_ClientStorage.SERVER_ID) {
			throw haxe_Exception.thrown("Attempt to send to server....");
		}
		let tmp = this.clients[id];
		let json = haxe_format_JsonPrinter.print(msg,null,null);
		let len = haxe_io_Bytes.ofString(json).length;
		tmp.sendRaw("Content-Length: " + len + "\r\n\r\n" + json);
	}
	getClients() {
		return this.clients.slice(1);
	}
	sendAll(msg) {
		let json = haxe_format_JsonPrinter.print(msg,null,null);
		let len = haxe_io_Bytes.ofString(json).length;
		let comp = "Content-Length: " + len + "\r\n\r\n" + json;
		Lambda.iter(this.clients,function(c) {
			c.sendRaw(comp);
		});
	}
	sendAny(id,msg) {
		let tmp = this.clients[id];
		let json = haxe_format_JsonPrinter.print(msg,null,null);
		let len = haxe_io_Bytes.ofString(json).length;
		tmp.sendRaw("Content-Length: " + len + "\r\n\r\n" + json);
	}
	sendAnyRaw(id,str) {
		this.clients[id].sendRaw(str);
	}
	getByGmodID(id) {
		return this.gmodIDMap.h[id];
	}
	disconnectAll() {
		this.disconnect = true;
		Lambda.iter(this.clients,function(c) {
			c.disconnect();
		});
	}
}
gmdebug_dap_ClientStorage.__name__ = true;
Object.assign(gmdebug_dap_ClientStorage.prototype, {
	__class__: gmdebug_dap_ClientStorage
	,clients: null
	,disconnect: null
	,gmodIDMap: null
	,readFunc: null
});
class gmdebug_dap_DapFailureTools {
	static sendError(opt,req,luaDebug) {
		if(opt._hx_index == 0) {
			let _g = opt.v;
			let _this = gmdebug_composer_ComposeTools.composeFail(req,_g.message,{ id : _g.id, format : _g.message});
			haxe_Log.trace("sending from dap " + _this.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
			luaDebug.sendResponse(_this);
			return true;
		} else {
			return false;
		}
	}
}
gmdebug_dap_DapFailureTools.__name__ = true;
class gmdebug_dap_EventIntercepter {
	static event(ceptedEvent,threadId,luaDebug) {
		switch(ceptedEvent.event) {
		case "output":
			let outputEvent = ceptedEvent;
			let prefix = threadId > 0 ? "[C] - " : "[S] - ";
			outputEvent.body.output = prefix + outputEvent.body.output;
			break;
		case "stopped":
			let stoppedEvent = ceptedEvent;
			if(luaDebug.programs.xdotool && stoppedEvent.body.threadId > 0) {
				haxe_Log.trace("free my mousepointer please!!",{ fileName : "src/gmdebug/dap/EventIntercepter.hx", lineNumber : 26, className : "gmdebug.dap.EventIntercepter", methodName : "event"});
				js_node_ChildProcess.execSync("setxkbmap -option grab:break_actions");
				js_node_ChildProcess.execSync("xdotool key XF86Ungrab");
			}
			break;
		default:
		}
	}
}
gmdebug_dap_EventIntercepter.__name__ = true;
class gmdebug_dap_LaunchProcess {
	constructor(programPath,luaDebug,programArgs) {
		programArgs = programArgs == null ? [] : programArgs;
		let argString = "";
		let _g = 0;
		while(_g < programArgs.length) {
			let arg = programArgs[_g];
			++_g;
			argString += arg + " ";
		}
		this.childProcess = js_node_ChildProcess.spawn("script -c '" + programPath + " -norestart " + argString + " +sv_lan 1 +sv_hibernate_think 1' /dev/null",{ cwd : haxe_io_Path.directory(programPath), env : process.env, shell : true});
		this.childProcess.stdout.on("data",function(str) {
			let _this = new gmdebug_composer_ComposedEvent("output",{ category : "stdout", output : StringTools.replace(str.toString(),"\r",""), data : null});
			haxe_Log.trace("sending from dap " + _this.event,{ fileName : "src/gmdebug/composer/ComposedEvent.hx", lineNumber : 32, className : "gmdebug.composer.ComposedEvent", methodName : "send"});
			luaDebug.sendEvent(_this);
		});
		this.childProcess.stderr.on("data",function(str) {
			let _this = new gmdebug_composer_ComposedEvent("output",{ category : "stdout", output : str.toString(), data : null});
			haxe_Log.trace("sending from dap " + _this.event,{ fileName : "src/gmdebug/composer/ComposedEvent.hx", lineNumber : 32, className : "gmdebug.composer.ComposedEvent", methodName : "send"});
			luaDebug.sendEvent(_this);
		});
		this.childProcess.on("error",function(err) {
			let _this = new gmdebug_composer_ComposedEvent("output",{ category : "stderr", output : err.message + "\n" + err.stack, data : null});
			haxe_Log.trace("sending from dap " + _this.event,{ fileName : "src/gmdebug/composer/ComposedEvent.hx", lineNumber : 32, className : "gmdebug.composer.ComposedEvent", methodName : "send"});
			luaDebug.sendEvent(_this);
			haxe_Log.trace("Child process error///",{ fileName : "src/gmdebug/dap/LaunchProcess.hx", lineNumber : 44, className : "gmdebug.dap.LaunchProcess", methodName : "new"});
			haxe_Log.trace(err.message,{ fileName : "src/gmdebug/dap/LaunchProcess.hx", lineNumber : 45, className : "gmdebug.dap.LaunchProcess", methodName : "new"});
			haxe_Log.trace(err.stack,{ fileName : "src/gmdebug/dap/LaunchProcess.hx", lineNumber : 46, className : "gmdebug.dap.LaunchProcess", methodName : "new"});
			haxe_Log.trace("Child process error end///",{ fileName : "src/gmdebug/dap/LaunchProcess.hx", lineNumber : 47, className : "gmdebug.dap.LaunchProcess", methodName : "new"});
			luaDebug.shutdown();
		});
	}
	write(chunk) {
		this.childProcess.stdin.write(chunk);
	}
	kill() {
		this.childProcess.kill();
	}
}
gmdebug_dap_LaunchProcess.__name__ = true;
Object.assign(gmdebug_dap_LaunchProcess.prototype, {
	__class__: gmdebug_dap_LaunchProcess
	,childProcess: null
});
var vscode_debugAdapter_DebugSession = require("vscode-debugadapter").DebugSession;
class gmdebug_dap_LuaDebugger extends vscode_debugAdapter_DebugSession {
	constructor(x,y) {
		super(x,y);
		this.clientLocations = [];
		this.serverFolder = null;
		this.clientsTaken = new haxe_ds_IntMap();
		this.dapMode = gmdebug_dap_DapMode.ATTACH;
		this.commMethod = gmdebug_CommMethod.Pipe;
		this.programs = { xdotool : false};
		this.bytesProcessor = new gmdebug_dap_BytesProcessor();
		this.prevRequests = new gmdebug_dap_PreviousRequests();
		this.clients = new gmdebug_dap_ClientStorage($bind(this,this.readGmodBuffer));
		this.requestRouter = new gmdebug_dap_RequestRouter(this,this.clients,this.prevRequests);
		process.on("uncaughtException",$bind(this,this.uncaughtException));
		let s = haxe_io_Path.directory(haxe_io_Path.directory(__filename));
		process.chdir(s);
		this.checkPrograms();
		this.shouldAutoConnect = false;
	}
	checkPrograms() {
		try {
			js_node_ChildProcess.execSync("xdotool --help");
			this.programs.xdotool = true;
		} catch( _g ) {
			let _g1 = haxe_Exception.caught(_g);
			haxe_Log.trace("Xdotool not found",{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 92, className : "gmdebug.dap.LuaDebugger", methodName : "checkPrograms"});
			haxe_Log.trace(_g1.toString(),{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 93, className : "gmdebug.dap.LuaDebugger", methodName : "checkPrograms"});
		}
	}
	uncaughtException(err,origin) {
		haxe_Log.trace(err.message,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 98, className : "gmdebug.dap.LuaDebugger", methodName : "uncaughtException"});
		haxe_Log.trace(err.stack,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 99, className : "gmdebug.dap.LuaDebugger", methodName : "uncaughtException"});
		this.shutdown();
	}
	playerAddedMessage(x) {
		let _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				let success = false;
				let _this = _gthis.clientLocations;
				let _g_current = 0;
				while(_g_current < _this.length) {
					let _g1_value = _this[_g_current];
					let _g1_key = _g_current++;
					if(!_gthis.clientsTaken.h.hasOwnProperty(_g1_key)) {
						try {
							let this1 = _gthis.playerTry(_g1_value,x.playerID,x.name);
							this1.eager();
							success = true;
							break;
						} catch( _g ) {
							haxe_Log.trace("could not aquire in " + _g1_value,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 113, className : "gmdebug.dap.LuaDebugger", methodName : "playerAddedMessage"});
						}
					}
				}
				__return(tink_core_Outcome.Success(success));
				return;
			} catch( _g ) {
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(haxe_Exception.caught(_g).unwrap())));
			}
		});
	}
	playerTry(clientLoc,gmodID,playerName) {
		let _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				_gthis.clients.newClient(clientLoc,gmodID,playerName).handle(function(__t0) {
					try {
						let __t0_result;
						let _g = tink_await_OutcomeTools.getOutcome(__t0);
						switch(_g._hx_index) {
						case 0:
							__t0_result = _g.data;
							break;
						case 1:
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
							return;
						}
						let cl = __t0_result;
						_gthis.clients.sendClient(cl.clID,new gmdebug_composer_ComposedGmDebugMessage(2,{ id : cl.clID}));
						let _this = new gmdebug_composer_ComposedEvent("thread",{ threadId : cl.clID, reason : "started"});
						haxe_Log.trace("sending from dap " + _this.event,{ fileName : "src/gmdebug/composer/ComposedEvent.hx", lineNumber : 32, className : "gmdebug.composer.ComposedEvent", methodName : "send"});
						_gthis.sendEvent(_this);
						_gthis.setupPlayer(cl.clID);
						__return(tink_core_Outcome.Success(null));
						return;
					} catch( _g ) {
						let _g1 = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
					}
				});
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	setupPlayer(clientID) {
		this.clients.sendClient(clientID,new gmdebug_composer_ComposedGmDebugMessage(3,{ location : this.serverFolder, dapMode : "Launch"}));
		this.clients.sendClient(clientID,new gmdebug_composer_ComposedGmDebugMessage(2,{ id : clientID}));
		let value = this.prevRequests.get("setBreakpoints");
		if(value != null) {
			this.clients.sendClient(clientID,value);
		}
		let value1 = this.prevRequests.get("setExceptionBreakpoints");
		if(value1 != null) {
			this.clients.sendClient(clientID,value1);
		}
		let value2 = this.prevRequests.get("setFunctionBreakpoints");
		if(value2 != null) {
			this.clients.sendClient(clientID,value2);
		}
		this.clients.sendClient(clientID,new gmdebug_composer_ComposedRequest("configurationDone",{ }));
	}
	playerRemovedMessage(x) {
		let _this = new gmdebug_composer_ComposedEvent("thread",{ threadId : this.clients.getByGmodID(x.playerID).clID, reason : "exited"});
		haxe_Log.trace("sending from dap " + _this.event,{ fileName : "src/gmdebug/composer/ComposedEvent.hx", lineNumber : 32, className : "gmdebug.composer.ComposedEvent", methodName : "send"});
		this.sendEvent(_this);
		this.clientsTaken.remove(this.clients.getByGmodID(x.playerID).clID);
	}
	serverInfoMessage(x) {
		if(!this.shouldAutoConnect) {
			return;
		}
		let sp = x.ip.split(":");
		let ip = x.isLan ? gmdebug_lib_js_Ip.address() : sp[0];
		let port = sp[1];
		js_node_ChildProcess.spawn("xdg-open steam://connect/" + ip + ":" + port,{ shell : true});
	}
	processCustomMessages(x) {
		haxe_Log.trace("custom message",{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 165, className : "gmdebug.dap.LuaDebugger", methodName : "processCustomMessages"});
		switch(x.msg) {
		case 0:
			this.playerAddedMessage(x.body).handle(function(out) {
				switch(out._hx_index) {
				case 0:
					if(out.data) {
						haxe_Log.trace("Whater a sucess",{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 171, className : "gmdebug.dap.LuaDebugger", methodName : "processCustomMessages"});
					} else {
						haxe_Log.trace("Could not add a new player...",{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 173, className : "gmdebug.dap.LuaDebugger", methodName : "processCustomMessages"});
					}
					break;
				case 1:
					throw haxe_Exception.thrown(out.failure);
				}
			});
			break;
		case 1:
			this.playerRemovedMessage(x.body);
			break;
		case 2:case 3:
			throw haxe_Exception.thrown("dur");
		case 4:
			this.serverInfoMessage(x.body);
			break;
		}
	}
	pokeServerNamedPipes(attachReq) {
		let _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				let hrtime = process.hrtime();
				let timeout = hrtime[0] + hrtime[1] / 1e9 + gmdebug_dap_LuaDebugger.SERVER_TIMEOUT;
				let timedout = true;
				haxe_Log.trace(timeout,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 193, className : "gmdebug.dap.LuaDebugger", methodName : "pokeServerNamedPipes"});
				let __doCount = 0;
				let __t1_break = function() {
					if(timedout) {
						__return(tink_core_Outcome.Failure(tink_await_Error.fromAny(new haxe_Exception("Timed out..."))));
						return;
					}
					_gthis.clients.sendServer(new gmdebug_composer_ComposedGmDebugMessage(2,{ id : 0}));
					switch(_gthis.dapMode._hx_index) {
					case 0:
						_gthis.clients.sendServer(new gmdebug_composer_ComposedGmDebugMessage(3,{ location : _gthis.serverFolder, dapMode : "Attach"}));
						break;
					case 1:
						_gthis.clients.sendServer(new gmdebug_composer_ComposedGmDebugMessage(3,{ location : _gthis.serverFolder, dapMode : "Launch"}));
						break;
					}
					__return(tink_core_Outcome.Success(null));
				};
				let __t1_continue = null;
				__t1_continue = function() {
					let __do = function() {
						__doCount += 1;
						if(__doCount - 1 == 0) {
							while(true) {
								let __t2 = function() {
									__t1_continue();
								};
								let __t4 = function(e) {
									try {
										let e1 = e;
										throw haxe_Exception.thrown(e1.code == 0 ? e1.data : e1);
									} catch( _g ) {
										__t2();
									}
								};
								try {
									let this1 = _gthis.clients.newServer(attachReq.arguments.serverFolder);
									this1.eager();
									this1.handle(function(__t5) {
										try {
											let _g = tink_await_OutcomeTools.getOutcome(__t5);
											switch(_g._hx_index) {
											case 0:
												break;
											case 1:
												__t4(_g.failure);
												return;
											}
											timedout = false;
											__t1_break();
											return;
										} catch( _g ) {
											let _g1 = haxe_Exception.caught(_g).unwrap();
											__t4(_g1);
										}
									});
								} catch( _g ) {
									let _g1 = haxe_Exception.caught(_g).unwrap();
									__t4(_g1);
								}
								if(!((__doCount -= 1) != 0)) {
									break;
								}
							}
						}
					};
					let hrtime = process.hrtime();
					if(hrtime[0] + hrtime[1] / 1e9 < timeout) {
						__do();
					} else {
						__t1_break();
					}
				};
				__t1_continue();
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	makeFifosIfNotExist(input,output) {
		if(!sys_FileSystem.exists(input) && !sys_FileSystem.exists(output)) {
			js_node_ChildProcess.execSync("mkfifo " + input);
			js_node_ChildProcess.execSync("mkfifo " + output);
			js_node_Fs.chmodSync(input,"744");
			js_node_Fs.chmodSync(output,"722");
		}
	}
	readGmodBuffer(jsBuf,clientNo) {
		let messages = this.bytesProcessor.process(jsBuf,clientNo);
		let _g = 0;
		while(_g < messages.length) {
			let msg = messages[_g];
			++_g;
			this.processDebugeeMessage(msg,clientNo);
		}
		if(this.bytesProcessor.fillRequested) {
			this.clients.sendAnyRaw(clientNo,"\x04\r\n");
		}
	}
	processDebugeeMessage(debugeeMessage,threadId) {
		debugeeMessage.seq = 0;
		switch(debugeeMessage.type) {
		case "event":
			let cmd = debugeeMessage.event;
			haxe_Log.trace("recieved event from debugee, " + cmd,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 237, className : "gmdebug.dap.LuaDebugger", methodName : "processDebugeeMessage"});
			gmdebug_dap_EventIntercepter.event(debugeeMessage,threadId,this);
			this.sendEvent(debugeeMessage);
			break;
		case "gmdebug":
			let cmd1 = debugeeMessage.msg;
			haxe_Log.trace("recieved gmdebug from debugee, " + cmd1,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 246, className : "gmdebug.dap.LuaDebugger", methodName : "processDebugeeMessage"});
			this.processCustomMessages(debugeeMessage);
			break;
		case "response":
			let cmd2 = debugeeMessage.command;
			haxe_Log.trace("recieved response from debugee, " + cmd2,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 242, className : "gmdebug.dap.LuaDebugger", methodName : "processDebugeeMessage"});
			this.sendResponse(debugeeMessage);
			break;
		default:
			throw haxe_Exception.thrown("unhandled");
		}
	}
	shutdown() {
		let _g = this.dapMode;
		if(_g._hx_index == 1) {
			let _g1 = _g.child;
			_g1.write("quit\n");
			_g1.kill();
		}
		this.clients.disconnectAll();
		let dir = haxe_io_Path.join([this.serverFolder,"addons","debugee"]);
		if(js_node_Fs.existsSync(dir)) {
			js_node_Fs.rmdirSync(dir,{ recursive : true});
		}
		super.shutdown();
	}
	startServer(attachReq) {
		let _gthis = this;
		this.pokeServerNamedPipes(attachReq).handle(function(out) {
			switch(out._hx_index) {
			case 0:
				haxe_Log.trace("Attatch success",{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 278, className : "gmdebug.dap.LuaDebugger", methodName : "startServer"});
				let resp = gmdebug_composer_ComposeTools.compose(attachReq,"attach");
				haxe_Log.trace("sending from dap " + resp.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
				_gthis.sendResponse(resp);
				break;
			case 1:
				let _g = out.failure;
				haxe_Log.trace(_g.message,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 282, className : "gmdebug.dap.LuaDebugger", methodName : "startServer"});
				let resp1 = gmdebug_composer_ComposeTools.composeFail(attachReq,"attach fail " + (_g.data == null ? "null" : Std.string(_g.data)),{ id : 1, format : "Failed to attach to server " + _g.message});
				haxe_Log.trace("sending from dap " + resp1.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
				_gthis.sendResponse(resp1);
				break;
			}
		});
	}
	setClientLocations(a) {
		return this.clientLocations = a;
	}
	handleMessage(message) {
		if(message.type == "request") {
			haxe_Log.trace("recieved request from client " + message.command,{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 300, className : "gmdebug.dap.LuaDebugger", methodName : "handleMessage"});
			try {
				this.requestRouter.route(message);
			} catch( _g ) {
				let e = haxe_Exception.caught(_g);
				haxe_Log.trace("FAIL!! XD " + e.toString(),{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 305, className : "gmdebug.dap.LuaDebugger", methodName : "handleMessage"});
				let fail = gmdebug_composer_ComposeTools.composeFail(message,e.get_message(),{ id : 15, format : e.toString()});
				haxe_Log.trace("sending from dap " + fail.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
				this.sendResponse(fail);
			}
		} else {
			haxe_Log.trace("Not handlin that...",{ fileName : "src/gmdebug/dap/LuaDebugger.hx", lineNumber : 314, className : "gmdebug.dap.LuaDebugger", methodName : "handleMessage"});
		}
	}
}
gmdebug_dap_LuaDebugger.__name__ = true;
gmdebug_dap_LuaDebugger.__super__ = vscode_debugAdapter_DebugSession;
Object.assign(gmdebug_dap_LuaDebugger.prototype, {
	__class__: gmdebug_dap_LuaDebugger
	,commMethod: null
	,clientFiles: null
	,dapMode: null
	,serverFolder: null
	,clientsTaken: null
	,programs: null
	,shouldAutoConnect: null
	,requestRouter: null
	,clientLocations: null
	,bytesProcessor: null
	,prevRequests: null
	,clients: null
});
var gmdebug_dap_DapMode = $hxEnums["gmdebug.dap.DapMode"] = { __ename__:true,__constructs__:null
	,ATTACH: {_hx_name:"ATTACH",_hx_index:0,__enum__:"gmdebug.dap.DapMode",toString:$estr}
	,LAUNCH: ($_=function(child) { return {_hx_index:1,child:child,__enum__:"gmdebug.dap.DapMode",toString:$estr}; },$_._hx_name="LAUNCH",$_.__params__ = ["child"],$_)
};
gmdebug_dap_DapMode.__constructs__ = [gmdebug_dap_DapMode.ATTACH,gmdebug_dap_DapMode.LAUNCH];
class gmdebug_dap_Main {
	static main() {
		let args = process.argv.slice(2).slice(2);
		let port = 0;
		let _g = 0;
		while(_g < args.length) {
			let arg = args[_g];
			++_g;
			let portMatch = new EReg("^--server=(\\d{4,5})$","");
			if(portMatch.match(arg)) {
				port = Std.parseInt(portMatch.matched(0));
			}
		}
		if(port > 0) {
			let server = js_node_Net.createServer(function(socket) {
				socket.on("end",function() {
					haxe_Log.trace("Closed",{ fileName : "src/gmdebug/dap/Main.hx", lineNumber : 29, className : "gmdebug.dap.Main", methodName : "main"});
				});
				let session = new gmdebug_dap_LuaDebugger(false,true);
				session.setRunAsServer(true);
				session.start(socket,socket);
			});
			server.listen(4555,"localhost");
		} else {
			let session = new gmdebug_dap_LuaDebugger(false);
			process.on("SIGTRM",function() {
				session.shutdown();
			});
			session.start(process.stdin,process.stdout);
			haxe_Log.trace = function(v,infos) {
				let str = haxe_Log.formatOutput(v,infos);
				console.error(str);
			};
		}
	}
}
gmdebug_dap_Main.__name__ = true;
class gmdebug_dap_PipeSocket {
	constructor(locs,readFunc) {
		this.aquired = false;
		this.locs = locs;
		this.readFunc = readFunc;
	}
	isReady() {
		return sys_FileSystem.exists(this.locs.client_ready);
	}
	aquire() {
		let _gthis = this;
		return tink_core_Future.irreversible(function(__return) {
			try {
				if(!_gthis.isReady()) {
					__return(tink_core_Outcome.Failure(tink_await_Error.fromAny("Client not ready yet...")));
					return;
				}
				_gthis.makeFifosIfNotExist(_gthis.locs.read,_gthis.locs.write);
				_gthis.aquireReadSocket(_gthis.locs.read).handle(function(__t9) {
					try {
						let __t9_result;
						let _g = tink_await_OutcomeTools.getOutcome(__t9);
						switch(_g._hx_index) {
						case 0:
							__t9_result = _g.data;
							break;
						case 1:
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
							return;
						}
						_gthis.readS = __t9_result;
						_gthis.aquireWriteSocket(_gthis.locs.write).handle(function(__t10) {
							try {
								let __t10_result;
								let _g = tink_await_OutcomeTools.getOutcome(__t10);
								switch(_g._hx_index) {
								case 0:
									__t10_result = _g.data;
									break;
								case 1:
									__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
									return;
								}
								_gthis.writeS = __t10_result;
								js_node_Fs.writeFileSync(_gthis.locs.ready,"");
								_gthis.writeS.write("\x04\r\n");
								_gthis.readS.on("data",_gthis.readFunc);
								_gthis.aquired = true;
								haxe_Log.trace("Aquired socket...",{ fileName : "src/gmdebug/dap/PipeSocket.hx", lineNumber : 51, className : "gmdebug.dap.PipeSocket", methodName : "aquire"});
								__return(tink_core_Outcome.Success(null));
								return;
							} catch( _g ) {
								let _g1 = haxe_Exception.caught(_g).unwrap();
								__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
							}
						});
					} catch( _g ) {
						let _g1 = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
					}
				});
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	makeFifosIfNotExist(input,output) {
		if(!sys_FileSystem.exists(input) && !sys_FileSystem.exists(output)) {
			js_node_ChildProcess.execSync("mkfifo " + input);
			js_node_ChildProcess.execSync("mkfifo " + output);
			js_node_Fs.chmodSync(input,"744");
			js_node_Fs.chmodSync(output,"722");
		}
	}
	aquireReadSocket(out) {
		return tink_core_Future.irreversible(function(__return) {
			try {
				let open = js_node_util_Promisify(js_node_Fs.open);
				tink_core_Future.ofJsPromise(open(out,js_node_Fs.constants.O_RDONLY | js_node_Fs.constants.O_NONBLOCK)).handle(function(__t11) {
					try {
						let __t11_result;
						let _g = tink_await_OutcomeTools.getOutcome(__t11);
						switch(_g._hx_index) {
						case 0:
							__t11_result = _g.data;
							break;
						case 1:
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
							return;
						}
						let fd = __t11_result;
						__return(tink_core_Outcome.Success(new js_node_net_Socket({ fd : fd, writable : false})));
						return;
					} catch( _g ) {
						let _g1 = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
					}
				});
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	aquireWriteSocket(inp) {
		return tink_core_Future.irreversible(function(__return) {
			try {
				let open = js_node_util_Promisify(js_node_Fs.open);
				tink_core_Future.ofJsPromise(open(inp,js_node_Fs.constants.O_RDWR | js_node_Fs.constants.O_NONBLOCK)).handle(function(__t12) {
					try {
						let __t12_result;
						let _g = tink_await_OutcomeTools.getOutcome(__t12);
						switch(_g._hx_index) {
						case 0:
							__t12_result = _g.data;
							break;
						case 1:
							__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g.failure)));
							return;
						}
						let fd = __t12_result;
						haxe_Log.trace(fd,{ fileName : "src/gmdebug/dap/PipeSocket.hx", lineNumber : 73, className : "gmdebug.dap.PipeSocket", methodName : "aquireWriteSocket"});
						__return(tink_core_Outcome.Success(new js_node_net_Socket({ fd : fd, readable : false})));
						return;
					} catch( _g ) {
						let _g1 = haxe_Exception.caught(_g).unwrap();
						__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
					}
				});
			} catch( _g ) {
				let _g1 = haxe_Exception.caught(_g).unwrap();
				__return(tink_core_Outcome.Failure(tink_core_TypedError.asError(_g1)));
			}
		});
	}
	write(chunk) {
		this.writeS.write(chunk);
	}
	end() {
		this.readS.end();
		this.writeS.end();
		js_node_Fs.unlinkSync(this.locs.read);
		js_node_Fs.unlinkSync(this.locs.write);
	}
}
gmdebug_dap_PipeSocket.__name__ = true;
Object.assign(gmdebug_dap_PipeSocket.prototype, {
	__class__: gmdebug_dap_PipeSocket
	,writeS: null
	,readS: null
	,locs: null
	,aquired: null
	,readFunc: null
});
class gmdebug_dap_PreviousRequests {
	constructor() {
		this.prevRequestMap = new haxe_ds_StringMap();
	}
	update(req) {
		this.prevRequestMap.h[req.command] = req;
	}
	get(command) {
		return this.prevRequestMap.h[command];
	}
}
gmdebug_dap_PreviousRequests.__name__ = true;
Object.assign(gmdebug_dap_PreviousRequests.prototype, {
	__class__: gmdebug_dap_PreviousRequests
	,prevRequestMap: null
});
class gmdebug_dap_RequestRouter {
	constructor(luaDebug,clients,prevRequests) {
		this.luaDebug = luaDebug;
		this.clients = clients;
		this.prevRequests = prevRequests;
	}
	route(req) {
		let command = req.command;
		switch(command) {
		case "attach":
			this.h_attach(req);
			break;
		case "configurationDone":
			this.clients.sendServer(req);
			break;
		case "disconnect":
			this.h_disconnect(req);
			break;
		case "evaluate":
			this.h_evaluate(req);
			break;
		case "breakpointLocations":case "goto":case "gotoTargets":case "loadedSources":case "modules":
			this.clients.sendServer(req);
			break;
		case "initialize":
			this.h_initialize(req);
			break;
		case "launch":
			this.h_launch(req);
			break;
		case "scopes":
			this.h_scopes(req);
			break;
		case "setBreakpoints":
			this.prevRequests.update(req);
			this.clients.sendAll(req);
			break;
		case "setExceptionBreakpoints":
			this.prevRequests.update(req);
			this.clients.sendAll(req);
			break;
		case "setFunctionBreakpoints":
			this.prevRequests.update(req);
			this.clients.sendAll(req);
			break;
		case "continue":case "next":case "pause":case "stackTrace":case "stepIn":case "stepOut":
			let id = req.arguments.threadId;
			this.clients.sendAny(id,req);
			break;
		case "threads":
			this.h_threads(req);
			break;
		case "variables":
			this.h_variables(req);
			break;
		}
	}
	h_threads(req) {
		let threadArr = [{ name : "Server", id : 0}];
		let _g = 0;
		let _g1 = this.clients.getClients();
		while(_g < _g1.length) {
			let cl = _g1[_g];
			++_g;
			threadArr.push({ name : cl.gmodName, id : cl.clID});
		}
		let _this = gmdebug_composer_ComposeTools.compose(req,"threads",{ threads : threadArr});
		let luaDebug = this.luaDebug;
		haxe_Log.trace("sending from dap " + _this.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
		luaDebug.sendResponse(_this);
	}
	h_disconnect(req) {
		this.clients.sendAll(req);
		let _this = gmdebug_composer_ComposeTools.compose(req,"disconnect");
		let luaDebug = this.luaDebug;
		haxe_Log.trace("sending from dap " + _this.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
		luaDebug.sendResponse(_this);
		this.luaDebug.shutdown();
	}
	h_variables(req) {
		let ref = req.arguments.variablesReference;
		if(ref <= 0) {
			haxe_Log.trace("invalid variable reference",{ fileName : "src/gmdebug/dap/RequestRouter.hx", lineNumber : 97, className : "gmdebug.dap.RequestRouter", methodName : "h_variables"});
			let _this = gmdebug_composer_ComposeTools.compose(req,"variables",{ variables : []});
			let luaDebug = this.luaDebug;
			haxe_Log.trace("sending from dap " + _this.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
			luaDebug.sendResponse(_this);
			return;
		}
		let _g = gmdebug_VariableReference.getValue(ref);
		switch(_g._hx_index) {
		case 0:
			this.clients.sendAny(_g.clientID,req);
			break;
		case 1:
			this.clients.sendAny(_g.clientID,req);
			break;
		case 2:
			this.clients.sendAny(_g.clientID,req);
			break;
		}
	}
	h_evaluate(req) {
		let expr = req.arguments.expression;
		if(expr.charAt(0) == "/") {
			let _g = this.luaDebug.dapMode;
			if(_g._hx_index == 1) {
				let actual = HxOverrides.substr(expr,1,null);
				_g.child.write(actual + "\n");
				let _this = gmdebug_composer_ComposeTools.compose(req,"evaluate",{ result : "", variablesReference : 0});
				let luaDebug = this.luaDebug;
				haxe_Log.trace("sending from dap " + _this.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
				luaDebug.sendResponse(_this);
				return;
			}
		}
		let _g = req.arguments.frameId;
		let client = _g == null ? 0 : gmdebug_FrameID.getValue(_g).clientID;
		this.clients.sendAny(client,req);
	}
	h_initialize(req) {
		let response = { seq : 0, request_seq : req.seq, command : "initialize", type : "response", body : { }, success : true};
		response.body.supportsConfigurationDoneRequest = true;
		response.body.supportsFunctionBreakpoints = true;
		response.body.supportsConditionalBreakpoints = true;
		response.body.supportsEvaluateForHovers = true;
		response.body.supportsLoadedSourcesRequest = true;
		response.body.supportsFunctionBreakpoints = true;
		response.body.supportsDelayedStackTraceLoading = true;
		response.body.supportsBreakpointLocationsRequest = false;
		this.luaDebug.sendResponse(response);
	}
	h_launch(req) {
		let serverFolder = req.arguments.serverFolder;
		let serverFolderResult = this.validateServerFolder(serverFolder);
		if(serverFolderResult != haxe_ds_Option.None) {
			gmdebug_dap_DapFailureTools.sendError(serverFolderResult,req,this.luaDebug);
			return;
		}
		let programPath;
		let _g = req.arguments.programPath;
		if(_g == null) {
			let _this = gmdebug_composer_ComposeTools.composeFail(req,"Gmdebug requires the property \"programPath\" to be specified when launching.",{ id : 2, format : "Gmdebug requires the property \"programPath\" to be specified when launching"});
			let luaDebug = this.luaDebug;
			haxe_Log.trace("sending from dap " + _this.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
			luaDebug.sendResponse(_this);
			return;
		} else {
			programPath = _g == "auto" ? "" + serverFolder + "/../srcds_run" : _g;
		}
		let programPathResult = this.validateProgramPath(programPath);
		if(programPathResult != haxe_ds_Option.None) {
			gmdebug_dap_DapFailureTools.sendError(programPathResult,req,this.luaDebug);
			return;
		}
		let value = req.arguments.autoConnectLocalGmodClient;
		this.luaDebug.shouldAutoConnect = value == null ? false : value;
		let childProcess = new gmdebug_dap_LaunchProcess(programPath,this.luaDebug,req.arguments.programArgs);
		if(req.arguments.noDebug) {
			this.luaDebug.dapMode = gmdebug_dap_DapMode.LAUNCH(childProcess);
			this.luaDebug.serverFolder = haxe_io_Path.addTrailingSlash(req.arguments.serverFolder);
			let comp = gmdebug_composer_ComposeTools.compose(req,"launch",{ });
			let luaDebug = this.luaDebug;
			haxe_Log.trace("sending from dap " + comp.command,{ fileName : "src/gmdebug/composer/ComposedResponse.hx", lineNumber : 52, className : "gmdebug.composer.ComposedResponse", methodName : "send"});
			luaDebug.sendResponse(comp);
			return;
		}
		this.generateInitFiles(serverFolder);
		this.copyLuaFiles(serverFolder);
		let value1 = req.arguments.clientFolders;
		let clientFolders = value1 == null ? [] : value1;
		let _g1_current = 0;
		let _g1_array = clientFolders;
		while(_g1_current < _g1_array.length) {
			let _g2_value = _g1_array[_g1_current];
			let _g2_key = _g1_current++;
			let clientFolderResult = this.validateClientFolder(_g2_value);
			if(clientFolderResult != haxe_ds_Option.None) {
				gmdebug_dap_DapFailureTools.sendError(clientFolderResult,req,this.luaDebug);
				return;
			}
			clientFolders[_g2_key] = haxe_io_Path.addTrailingSlash(_g2_value);
		}
		let serverSlash = haxe_io_Path.addTrailingSlash(req.arguments.serverFolder);
		this.luaDebug.serverFolder = serverSlash;
		this.luaDebug.setClientLocations(clientFolders);
		this.luaDebug.dapMode = gmdebug_dap_DapMode.LAUNCH(childProcess);
		this.luaDebug.startServer(req);
	}
	h_scopes(req) {
		let client = gmdebug_FrameID.getValue(req.arguments.frameId).clientID;
		this.clients.sendAny(client,req);
	}
	generateInitFiles(serverFolder) {
		let initFile = haxe_io_Path.join([serverFolder,"lua","includes","init.lua"]);
		let backupFile = haxe_io_Path.join(["generated","debugee","lua","includes","init_backup.lua"]);
		let initContents;
		if(sys_FileSystem.exists(initFile)) {
			initContents = js_node_Fs.readFileSync(initFile,{ encoding : "utf8"});
		} else if(sys_FileSystem.exists(backupFile)) {
			initContents = js_node_Fs.readFileSync(backupFile,{ encoding : "utf8"});
		} else {
			throw haxe_Exception.thrown("Could not find real, or backup file >=(");
		}
		let appendFile = haxe_io_Path.join(["generated","debugee","lua","includes","init_attach.lua"]);
		haxe_Log.trace(process.cwd(),{ fileName : "src/gmdebug/dap/RequestRouter.hx", lineNumber : 221, className : "gmdebug.dap.RequestRouter", methodName : "generateInitFiles"});
		haxe_Log.trace(process.cwd(),{ fileName : "src/gmdebug/dap/RequestRouter.hx", lineNumber : 222, className : "gmdebug.dap.RequestRouter", methodName : "generateInitFiles"});
		haxe_Log.trace(appendFile,{ fileName : "src/gmdebug/dap/RequestRouter.hx", lineNumber : 223, className : "gmdebug.dap.RequestRouter", methodName : "generateInitFiles"});
		let appendContents;
		if(sys_FileSystem.exists(appendFile)) {
			appendContents = js_node_Fs.readFileSync(appendFile,{ encoding : "utf8"});
		} else {
			throw haxe_Exception.thrown("Could not find append file...");
		}
		let ourInitFile = haxe_io_Path.join(["generated","debugee","lua","includes","init.lua"]);
		js_node_Fs.writeFileSync(ourInitFile,initContents + appendContents);
	}
	copyLuaFiles(serverFolder) {
		let addonFolder = haxe_io_Path.join([serverFolder,"addons"]);
		js_node_ChildProcess.execSync("cp -r generated/debugee " + addonFolder);
	}
	h_attach(req) {
		let serverFolder = req.arguments.serverFolder;
		let serverFolderResult = this.validateServerFolder(serverFolder);
		if(serverFolderResult != haxe_ds_Option.None) {
			gmdebug_dap_DapFailureTools.sendError(serverFolderResult,req,this.luaDebug);
			return;
		}
		let value = req.arguments.clientFolders;
		let clientFolders = value == null ? [] : value;
		let _g_current = 0;
		let _g_array = clientFolders;
		while(_g_current < _g_array.length) {
			let _g1_value = _g_array[_g_current];
			let _g1_key = _g_current++;
			let clientFolderResult = this.validateClientFolder(_g1_value);
			if(clientFolderResult != haxe_ds_Option.None) {
				gmdebug_dap_DapFailureTools.sendError(clientFolderResult,req,this.luaDebug);
				return;
			}
			clientFolders[_g1_key] = haxe_io_Path.addTrailingSlash(_g1_value);
		}
		let serverSlash = haxe_io_Path.addTrailingSlash(req.arguments.serverFolder);
		this.luaDebug.serverFolder = serverSlash;
		this.luaDebug.setClientLocations(clientFolders);
		this.luaDebug.startServer(req);
	}
	validateProgramPath(programPath) {
		if(programPath == null) {
			return haxe_ds_Option.Some({ id : 2, message : "Gmdebug requires the property \"programPath\" to be specified when launching"});
		} else if(!js_node_Fs.existsSync(programPath)) {
			return haxe_ds_Option.Some({ id : 4, message : "The program specified by \"programPath\" does not exist!"});
		} else if(!js_node_Fs.statSync(programPath).isFile()) {
			return haxe_ds_Option.Some({ id : 5, message : "The program specified by \"programPath\" is not a file."});
		} else {
			return haxe_ds_Option.None;
		}
	}
	validateServerFolder(serverFolder) {
		if(serverFolder == null) {
			return haxe_ds_Option.Some({ id : 2, message : "Gmdebug requires the property \"serverFolder\" to be specified."});
		} else {
			let addonFolder = js_node_Path.join(serverFolder,"addons");
			if(!haxe_io_Path.isAbsolute(serverFolder)) {
				return haxe_ds_Option.Some({ id : 3, message : "Gmdebug requires the property \"serverFolder\" to be an absolute path (i.e from root folder)."});
			} else if(!js_node_Fs.existsSync(serverFolder)) {
				return haxe_ds_Option.Some({ id : 4, message : "The \"serverFolder\" path does not exist!"});
			} else if(!js_node_Fs.statSync(serverFolder).isDirectory()) {
				return haxe_ds_Option.Some({ id : 5, message : "The \"serverFolder\" path is not a directory."});
			} else if(!js_node_Fs.existsSync(addonFolder) || !js_node_Fs.statSync(addonFolder).isDirectory()) {
				return haxe_ds_Option.Some({ id : 6, message : "\"serverFolder\" does not seem to be a garrysmod directory. (looking for \"addons\" folder)"});
			} else {
				return haxe_ds_Option.None;
			}
		}
	}
	validateClientFolder(folder) {
		let addonFolder = js_node_Path.join(folder,"addons");
		js_node_Path.join(folder,"data","gmdebug");
		if(!haxe_io_Path.isAbsolute(folder)) {
			return haxe_ds_Option.Some({ id : 8, message : "Gmdebug requires client folder: " + folder + " to be an absolute path (i.e from root folder)."});
		} else if(!js_node_Fs.existsSync(folder)) {
			return haxe_ds_Option.Some({ id : 9, message : "The client folder: " + folder + " does not exist!"});
		} else if(!js_node_Fs.statSync(folder).isDirectory()) {
			return haxe_ds_Option.Some({ id : 10, message : "The client folder: " + folder + " is not a directory."});
		} else if(!js_node_Fs.existsSync(addonFolder) || !js_node_Fs.statSync(addonFolder).isDirectory()) {
			return haxe_ds_Option.Some({ id : 11, message : "The client folder: " + folder + " does not seem to be a garrysmod directory. (looking for \"addons\" folder)"});
		} else {
			return haxe_ds_Option.None;
		}
	}
}
gmdebug_dap_RequestRouter.__name__ = true;
Object.assign(gmdebug_dap_RequestRouter.prototype, {
	__class__: gmdebug_dap_RequestRouter
	,luaDebug: null
	,clients: null
	,prevRequests: null
});
class gmdebug_dap_Server extends gmdebug_dap_BaseConnected {
	constructor(fs,clID) {
		super(fs,clID);
	}
}
gmdebug_dap_Server.__name__ = true;
gmdebug_dap_Server.__super__ = gmdebug_dap_BaseConnected;
Object.assign(gmdebug_dap_Server.prototype, {
	__class__: gmdebug_dap_Server
});
var gmdebug_lib_js_Ip = require("ip");
var haxe_StackItem = $hxEnums["haxe.StackItem"] = { __ename__:true,__constructs__:null
	,CFunction: {_hx_name:"CFunction",_hx_index:0,__enum__:"haxe.StackItem",toString:$estr}
	,Module: ($_=function(m) { return {_hx_index:1,m:m,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="Module",$_.__params__ = ["m"],$_)
	,FilePos: ($_=function(s,file,line,column) { return {_hx_index:2,s:s,file:file,line:line,column:column,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="FilePos",$_.__params__ = ["s","file","line","column"],$_)
	,Method: ($_=function(classname,method) { return {_hx_index:3,classname:classname,method:method,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="Method",$_.__params__ = ["classname","method"],$_)
	,LocalFunction: ($_=function(v) { return {_hx_index:4,v:v,__enum__:"haxe.StackItem",toString:$estr}; },$_._hx_name="LocalFunction",$_.__params__ = ["v"],$_)
};
haxe_StackItem.__constructs__ = [haxe_StackItem.CFunction,haxe_StackItem.Module,haxe_StackItem.FilePos,haxe_StackItem.Method,haxe_StackItem.LocalFunction];
class haxe_Exception extends Error {
	constructor(message,previous,native) {
		super(message);
		this.message = message;
		this.__previousException = previous;
		this.__nativeException = native != null ? native : this;
	}
	unwrap() {
		return this.__nativeException;
	}
	toString() {
		return this.get_message();
	}
	get_message() {
		return this.message;
	}
	get_native() {
		return this.__nativeException;
	}
	static caught(value) {
		if(((value) instanceof haxe_Exception)) {
			return value;
		} else if(((value) instanceof Error)) {
			return new haxe_Exception(value.message,null,value);
		} else {
			return new haxe_ValueException(value,null,value);
		}
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
haxe_Exception.__super__ = Error;
Object.assign(haxe_Exception.prototype, {
	__class__: haxe_Exception
	,__skipStack: null
	,__nativeException: null
	,__previousException: null
});
class haxe_Log {
	static formatOutput(v,infos) {
		let str = Std.string(v);
		if(infos == null) {
			return str;
		}
		let pstr = infos.fileName + ":" + infos.lineNumber;
		if(infos.customParams != null) {
			let _g = 0;
			let _g1 = infos.customParams;
			while(_g < _g1.length) {
				let v = _g1[_g];
				++_g;
				str += ", " + Std.string(v);
			}
		}
		return pstr + ": " + str;
	}
	static trace(v,infos) {
		let str = haxe_Log.formatOutput(v,infos);
		if(typeof(console) != "undefined" && console.log != null) {
			console.log(str);
		}
	}
}
haxe_Log.__name__ = true;
class haxe_ValueException extends haxe_Exception {
	constructor(value,previous,native) {
		super(String(value),previous,native);
		this.value = value;
	}
	unwrap() {
		return this.value;
	}
}
haxe_ValueException.__name__ = true;
haxe_ValueException.__super__ = haxe_Exception;
Object.assign(haxe_ValueException.prototype, {
	__class__: haxe_ValueException
	,value: null
});
class haxe_ds_IntMap {
	constructor() {
		this.h = { };
	}
	remove(key) {
		if(!this.h.hasOwnProperty(key)) {
			return false;
		}
		delete(this.h[key]);
		return true;
	}
}
haxe_ds_IntMap.__name__ = true;
Object.assign(haxe_ds_IntMap.prototype, {
	__class__: haxe_ds_IntMap
	,h: null
});
var haxe_ds_Option = $hxEnums["haxe.ds.Option"] = { __ename__:true,__constructs__:null
	,Some: ($_=function(v) { return {_hx_index:0,v:v,__enum__:"haxe.ds.Option",toString:$estr}; },$_._hx_name="Some",$_.__params__ = ["v"],$_)
	,None: {_hx_name:"None",_hx_index:1,__enum__:"haxe.ds.Option",toString:$estr}
};
haxe_ds_Option.__constructs__ = [haxe_ds_Option.Some,haxe_ds_Option.None];
class haxe_ds_StringMap {
	constructor() {
		this.h = Object.create(null);
	}
}
haxe_ds_StringMap.__name__ = true;
Object.assign(haxe_ds_StringMap.prototype, {
	__class__: haxe_ds_StringMap
	,h: null
});
class haxe_exceptions_PosException extends haxe_Exception {
	constructor(message,previous,pos) {
		super(message,previous);
		if(pos == null) {
			this.posInfos = { fileName : "(unknown)", lineNumber : 0, className : "(unknown)", methodName : "(unknown)"};
		} else {
			this.posInfos = pos;
		}
	}
	toString() {
		return "" + super.toString() + " in " + this.posInfos.className + "." + this.posInfos.methodName + " at " + this.posInfos.fileName + ":" + this.posInfos.lineNumber;
	}
}
haxe_exceptions_PosException.__name__ = true;
haxe_exceptions_PosException.__super__ = haxe_Exception;
Object.assign(haxe_exceptions_PosException.prototype, {
	__class__: haxe_exceptions_PosException
	,posInfos: null
});
class haxe_exceptions_NotImplementedException extends haxe_exceptions_PosException {
	constructor(message,previous,pos) {
		if(message == null) {
			message = "Not implemented";
		}
		super(message,previous,pos);
	}
}
haxe_exceptions_NotImplementedException.__name__ = true;
haxe_exceptions_NotImplementedException.__super__ = haxe_exceptions_PosException;
Object.assign(haxe_exceptions_NotImplementedException.prototype, {
	__class__: haxe_exceptions_NotImplementedException
});
class haxe_format_JsonParser {
	constructor(str) {
		this.str = str;
		this.pos = 0;
	}
	doParse() {
		let result = this.parseRec();
		let c;
		while(true) {
			c = this.str.charCodeAt(this.pos++);
			if(!(c == c)) {
				break;
			}
			switch(c) {
			case 9:case 10:case 13:case 32:
				break;
			default:
				this.invalidChar();
			}
		}
		return result;
	}
	parseRec() {
		while(true) {
			let c = this.str.charCodeAt(this.pos++);
			switch(c) {
			case 9:case 10:case 13:case 32:
				break;
			case 34:
				return this.parseString();
			case 45:case 48:case 49:case 50:case 51:case 52:case 53:case 54:case 55:case 56:case 57:
				let c1 = c;
				let start = this.pos - 1;
				let minus = c == 45;
				let digit = !minus;
				let zero = c == 48;
				let point = false;
				let e = false;
				let pm = false;
				let end = false;
				while(true) {
					c1 = this.str.charCodeAt(this.pos++);
					switch(c1) {
					case 43:case 45:
						if(!e || pm) {
							this.invalidNumber(start);
						}
						digit = false;
						pm = true;
						break;
					case 46:
						if(minus || point || e) {
							this.invalidNumber(start);
						}
						digit = false;
						point = true;
						break;
					case 48:
						if(zero && !point) {
							this.invalidNumber(start);
						}
						if(minus) {
							minus = false;
							zero = true;
						}
						digit = true;
						break;
					case 49:case 50:case 51:case 52:case 53:case 54:case 55:case 56:case 57:
						if(zero && !point) {
							this.invalidNumber(start);
						}
						if(minus) {
							minus = false;
						}
						digit = true;
						zero = false;
						break;
					case 69:case 101:
						if(minus || zero || e) {
							this.invalidNumber(start);
						}
						digit = false;
						e = true;
						break;
					default:
						if(!digit) {
							this.invalidNumber(start);
						}
						this.pos--;
						end = true;
					}
					if(end) {
						break;
					}
				}
				let f = parseFloat(HxOverrides.substr(this.str,start,this.pos - start));
				if(point) {
					return f;
				} else {
					let i = f | 0;
					if(i == f) {
						return i;
					} else {
						return f;
					}
				}
				break;
			case 91:
				let arr = [];
				let comma = null;
				while(true) {
					let c = this.str.charCodeAt(this.pos++);
					switch(c) {
					case 9:case 10:case 13:case 32:
						break;
					case 44:
						if(comma) {
							comma = false;
						} else {
							this.invalidChar();
						}
						break;
					case 93:
						if(comma == false) {
							this.invalidChar();
						}
						return arr;
					default:
						if(comma) {
							this.invalidChar();
						}
						this.pos--;
						arr.push(this.parseRec());
						comma = true;
					}
				}
				break;
			case 102:
				let save = this.pos;
				if(this.str.charCodeAt(this.pos++) != 97 || this.str.charCodeAt(this.pos++) != 108 || this.str.charCodeAt(this.pos++) != 115 || this.str.charCodeAt(this.pos++) != 101) {
					this.pos = save;
					this.invalidChar();
				}
				return false;
			case 110:
				let save1 = this.pos;
				if(this.str.charCodeAt(this.pos++) != 117 || this.str.charCodeAt(this.pos++) != 108 || this.str.charCodeAt(this.pos++) != 108) {
					this.pos = save1;
					this.invalidChar();
				}
				return null;
			case 116:
				let save2 = this.pos;
				if(this.str.charCodeAt(this.pos++) != 114 || this.str.charCodeAt(this.pos++) != 117 || this.str.charCodeAt(this.pos++) != 101) {
					this.pos = save2;
					this.invalidChar();
				}
				return true;
			case 123:
				let obj = { };
				let field = null;
				let comma1 = null;
				while(true) {
					let c = this.str.charCodeAt(this.pos++);
					switch(c) {
					case 9:case 10:case 13:case 32:
						break;
					case 34:
						if(field != null || comma1) {
							this.invalidChar();
						}
						field = this.parseString();
						break;
					case 44:
						if(comma1) {
							comma1 = false;
						} else {
							this.invalidChar();
						}
						break;
					case 58:
						if(field == null) {
							this.invalidChar();
						}
						obj[field] = this.parseRec();
						field = null;
						comma1 = true;
						break;
					case 125:
						if(field != null || comma1 == false) {
							this.invalidChar();
						}
						return obj;
					default:
						this.invalidChar();
					}
				}
				break;
			default:
				this.invalidChar();
			}
		}
	}
	parseString() {
		let start = this.pos;
		let buf = null;
		let prev = -1;
		while(true) {
			let c = this.str.charCodeAt(this.pos++);
			if(c == 34) {
				break;
			}
			if(c == 92) {
				if(buf == null) {
					buf = new StringBuf();
				}
				let s = this.str;
				let len = this.pos - start - 1;
				buf.b += len == null ? HxOverrides.substr(s,start,null) : HxOverrides.substr(s,start,len);
				c = this.str.charCodeAt(this.pos++);
				if(c != 117 && prev != -1) {
					buf.b += String.fromCodePoint(65533);
					prev = -1;
				}
				switch(c) {
				case 34:case 47:case 92:
					buf.b += String.fromCodePoint(c);
					break;
				case 98:
					buf.b += String.fromCodePoint(8);
					break;
				case 102:
					buf.b += String.fromCodePoint(12);
					break;
				case 110:
					buf.b += String.fromCodePoint(10);
					break;
				case 114:
					buf.b += String.fromCodePoint(13);
					break;
				case 116:
					buf.b += String.fromCodePoint(9);
					break;
				case 117:
					let uc = Std.parseInt("0x" + HxOverrides.substr(this.str,this.pos,4));
					this.pos += 4;
					if(prev != -1) {
						if(uc < 56320 || uc > 57343) {
							buf.b += String.fromCodePoint(65533);
							prev = -1;
						} else {
							buf.b += String.fromCodePoint(((prev - 55296 << 10) + (uc - 56320) + 65536));
							prev = -1;
						}
					} else if(uc >= 55296 && uc <= 56319) {
						prev = uc;
					} else {
						buf.b += String.fromCodePoint(uc);
					}
					break;
				default:
					throw haxe_Exception.thrown("Invalid escape sequence \\" + String.fromCodePoint(c) + " at position " + (this.pos - 1));
				}
				start = this.pos;
			} else if(c != c) {
				throw haxe_Exception.thrown("Unclosed string");
			}
		}
		if(prev != -1) {
			buf.b += String.fromCodePoint(65533);
			prev = -1;
		}
		if(buf == null) {
			return HxOverrides.substr(this.str,start,this.pos - start - 1);
		} else {
			let s = this.str;
			let len = this.pos - start - 1;
			buf.b += len == null ? HxOverrides.substr(s,start,null) : HxOverrides.substr(s,start,len);
			return buf.b;
		}
	}
	invalidChar() {
		this.pos--;
		throw haxe_Exception.thrown("Invalid char " + this.str.charCodeAt(this.pos) + " at position " + this.pos);
	}
	invalidNumber(start) {
		throw haxe_Exception.thrown("Invalid number at position " + start + ": " + HxOverrides.substr(this.str,start,this.pos - start));
	}
}
haxe_format_JsonParser.__name__ = true;
Object.assign(haxe_format_JsonParser.prototype, {
	__class__: haxe_format_JsonParser
	,str: null
	,pos: null
});
class haxe_format_JsonPrinter {
	constructor(replacer,space) {
		this.replacer = replacer;
		this.indent = space;
		this.pretty = space != null;
		this.nind = 0;
		this.buf = new StringBuf();
	}
	write(k,v) {
		if(this.replacer != null) {
			v = this.replacer(k,v);
		}
		let _g = Type.typeof(v);
		switch(_g._hx_index) {
		case 0:
			this.buf.b += "null";
			break;
		case 1:
			this.buf.b += Std.string(v);
			break;
		case 2:
			let v1 = isFinite(v) ? Std.string(v) : "null";
			this.buf.b += Std.string(v1);
			break;
		case 3:
			this.buf.b += Std.string(v);
			break;
		case 4:
			this.fieldsString(v,Reflect.fields(v));
			break;
		case 5:
			this.buf.b += "\"<fun>\"";
			break;
		case 6:
			let c = _g.c;
			if(c == String) {
				this.quote(v);
			} else if(c == Array) {
				let v1 = v;
				this.buf.b += String.fromCodePoint(91);
				let len = v1.length;
				let last = len - 1;
				let _g = 0;
				let _g1 = len;
				while(_g < _g1) {
					let i = _g++;
					if(i > 0) {
						this.buf.b += String.fromCodePoint(44);
					} else {
						this.nind++;
					}
					if(this.pretty) {
						this.buf.b += String.fromCodePoint(10);
					}
					if(this.pretty) {
						this.buf.b += Std.string(StringTools.lpad("",this.indent,this.nind * this.indent.length));
					}
					this.write(i,v1[i]);
					if(i == last) {
						this.nind--;
						if(this.pretty) {
							this.buf.b += String.fromCodePoint(10);
						}
						if(this.pretty) {
							this.buf.b += Std.string(StringTools.lpad("",this.indent,this.nind * this.indent.length));
						}
					}
				}
				this.buf.b += String.fromCodePoint(93);
			} else if(c == haxe_ds_StringMap) {
				let v1 = v;
				let o = { };
				let h = v1.h;
				let _g_keys = Object.keys(h);
				let _g_length = _g_keys.length;
				let _g_current = 0;
				while(_g_current < _g_length) {
					let k = _g_keys[_g_current++];
					o[k] = v1.h[k];
				}
				let v2 = o;
				this.fieldsString(v2,Reflect.fields(v2));
			} else if(c == Date) {
				let v1 = v;
				this.quote(HxOverrides.dateStr(v1));
			} else {
				this.classString(v);
			}
			break;
		case 7:
			let i = v._hx_index;
			this.buf.b += Std.string(i);
			break;
		case 8:
			this.buf.b += "\"???\"";
			break;
		}
	}
	classString(v) {
		this.fieldsString(v,Type.getInstanceFields(js_Boot.getClass(v)));
	}
	fieldsString(v,fields) {
		this.buf.b += String.fromCodePoint(123);
		let len = fields.length;
		let last = len - 1;
		let first = true;
		let _g = 0;
		let _g1 = len;
		while(_g < _g1) {
			let i = _g++;
			let f = fields[i];
			let value = Reflect.field(v,f);
			if(Reflect.isFunction(value)) {
				continue;
			}
			if(first) {
				this.nind++;
				first = false;
			} else {
				this.buf.b += String.fromCodePoint(44);
			}
			if(this.pretty) {
				this.buf.b += String.fromCodePoint(10);
			}
			if(this.pretty) {
				this.buf.b += Std.string(StringTools.lpad("",this.indent,this.nind * this.indent.length));
			}
			this.quote(f);
			this.buf.b += String.fromCodePoint(58);
			if(this.pretty) {
				this.buf.b += String.fromCodePoint(32);
			}
			this.write(f,value);
			if(i == last) {
				this.nind--;
				if(this.pretty) {
					this.buf.b += String.fromCodePoint(10);
				}
				if(this.pretty) {
					this.buf.b += Std.string(StringTools.lpad("",this.indent,this.nind * this.indent.length));
				}
			}
		}
		this.buf.b += String.fromCodePoint(125);
	}
	quote(s) {
		this.buf.b += String.fromCodePoint(34);
		let i = 0;
		let length = s.length;
		while(i < length) {
			let c = s.charCodeAt(i++);
			switch(c) {
			case 8:
				this.buf.b += "\\b";
				break;
			case 9:
				this.buf.b += "\\t";
				break;
			case 10:
				this.buf.b += "\\n";
				break;
			case 12:
				this.buf.b += "\\f";
				break;
			case 13:
				this.buf.b += "\\r";
				break;
			case 34:
				this.buf.b += "\\\"";
				break;
			case 92:
				this.buf.b += "\\\\";
				break;
			default:
				this.buf.b += String.fromCodePoint(c);
			}
		}
		this.buf.b += String.fromCodePoint(34);
	}
	static print(o,replacer,space) {
		let printer = new haxe_format_JsonPrinter(replacer,space);
		printer.write("",o);
		return printer.buf.b;
	}
}
haxe_format_JsonPrinter.__name__ = true;
Object.assign(haxe_format_JsonPrinter.prototype, {
	__class__: haxe_format_JsonPrinter
	,buf: null
	,replacer: null
	,indent: null
	,pretty: null
	,nind: null
});
class haxe_io_Bytes {
	constructor(data) {
		this.length = data.byteLength;
		this.b = new Uint8Array(data);
		this.b.bufferValue = data;
		data.hxBytes = this;
		data.bytes = this.b;
	}
	blit(pos,src,srcpos,len) {
		if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		if(srcpos == 0 && len == src.b.byteLength) {
			this.b.set(src.b,pos);
		} else {
			this.b.set(src.b.subarray(srcpos,srcpos + len),pos);
		}
	}
	sub(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		return new haxe_io_Bytes(this.b.buffer.slice(pos + this.b.byteOffset,pos + this.b.byteOffset + len));
	}
	getString(pos,len,encoding) {
		if(pos < 0 || len < 0 || pos + len > this.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		if(encoding == null) {
			encoding = haxe_io_Encoding.UTF8;
		}
		let s = "";
		let b = this.b;
		let i = pos;
		let max = pos + len;
		switch(encoding._hx_index) {
		case 0:
			while(i < max) {
				let c = b[i++];
				if(c < 128) {
					if(c == 0) {
						break;
					}
					s += String.fromCodePoint(c);
				} else if(c < 224) {
					let code = (c & 63) << 6 | b[i++] & 127;
					s += String.fromCodePoint(code);
				} else if(c < 240) {
					let c2 = b[i++];
					let code = (c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127;
					s += String.fromCodePoint(code);
				} else {
					let c2 = b[i++];
					let c3 = b[i++];
					let u = (c & 15) << 18 | (c2 & 127) << 12 | (c3 & 127) << 6 | b[i++] & 127;
					s += String.fromCodePoint(u);
				}
			}
			break;
		case 1:
			while(i < max) {
				let c = b[i++] | b[i++] << 8;
				s += String.fromCodePoint(c);
			}
			break;
		}
		return s;
	}
	toString() {
		return this.getString(0,this.length);
	}
	static ofString(s,encoding) {
		if(encoding == haxe_io_Encoding.RawNative) {
			let buf = new Uint8Array(s.length << 1);
			let _g = 0;
			let _g1 = s.length;
			while(_g < _g1) {
				let i = _g++;
				let c = s.charCodeAt(i);
				buf[i << 1] = c & 255;
				buf[i << 1 | 1] = c >> 8;
			}
			return new haxe_io_Bytes(buf.buffer);
		}
		let a = [];
		let i = 0;
		while(i < s.length) {
			let c = s.charCodeAt(i++);
			if(55296 <= c && c <= 56319) {
				c = c - 55232 << 10 | s.charCodeAt(i++) & 1023;
			}
			if(c <= 127) {
				a.push(c);
			} else if(c <= 2047) {
				a.push(192 | c >> 6);
				a.push(128 | c & 63);
			} else if(c <= 65535) {
				a.push(224 | c >> 12);
				a.push(128 | c >> 6 & 63);
				a.push(128 | c & 63);
			} else {
				a.push(240 | c >> 18);
				a.push(128 | c >> 12 & 63);
				a.push(128 | c >> 6 & 63);
				a.push(128 | c & 63);
			}
		}
		return new haxe_io_Bytes(new Uint8Array(a).buffer);
	}
}
haxe_io_Bytes.__name__ = true;
Object.assign(haxe_io_Bytes.prototype, {
	__class__: haxe_io_Bytes
	,length: null
	,b: null
});
class haxe_io_BytesBuffer {
	constructor() {
		this.pos = 0;
		this.size = 0;
	}
	addByte(byte) {
		if(this.pos == this.size) {
			this.grow(1);
		}
		this.view.setUint8(this.pos++,byte);
	}
	grow(delta) {
		let req = this.pos + delta;
		let nsize = this.size == 0 ? 16 : this.size;
		while(nsize < req) nsize = nsize * 3 >> 1;
		let nbuf = new ArrayBuffer(nsize);
		let nu8 = new Uint8Array(nbuf);
		if(this.size > 0) {
			nu8.set(this.u8);
		}
		this.size = nsize;
		this.buffer = nbuf;
		this.u8 = nu8;
		this.view = new DataView(this.buffer);
	}
	getBytes() {
		if(this.size == 0) {
			return new haxe_io_Bytes(new ArrayBuffer(0));
		}
		let b = new haxe_io_Bytes(this.buffer);
		b.length = this.pos;
		return b;
	}
}
haxe_io_BytesBuffer.__name__ = true;
Object.assign(haxe_io_BytesBuffer.prototype, {
	__class__: haxe_io_BytesBuffer
	,buffer: null
	,view: null
	,u8: null
	,pos: null
	,size: null
});
class haxe_io_BytesInput extends haxe_io_Input {
	constructor(b,pos,len) {
		super();
		if(pos == null) {
			pos = 0;
		}
		if(len == null) {
			len = b.length - pos;
		}
		if(pos < 0 || len < 0 || pos + len > b.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		this.b = b.b;
		this.pos = pos;
		this.len = len;
		this.totlen = len;
	}
	set_position(p) {
		if(p < 0) {
			p = 0;
		} else if(p > this.totlen) {
			p = this.totlen;
		}
		this.len = this.totlen - p;
		return this.pos = p;
	}
	readByte() {
		if(this.len == 0) {
			throw haxe_Exception.thrown(new haxe_io_Eof());
		}
		this.len--;
		return this.b[this.pos++];
	}
	readBytes(buf,pos,len) {
		if(pos < 0 || len < 0 || pos + len > buf.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		if(this.len == 0 && len > 0) {
			throw haxe_Exception.thrown(new haxe_io_Eof());
		}
		if(this.len < len) {
			len = this.len;
		}
		let b1 = this.b;
		let b2 = buf.b;
		let _g = 0;
		let _g1 = len;
		while(_g < _g1) {
			let i = _g++;
			b2[pos + i] = b1[this.pos + i];
		}
		this.pos += len;
		this.len -= len;
		return len;
	}
}
haxe_io_BytesInput.__name__ = true;
haxe_io_BytesInput.__super__ = haxe_io_Input;
Object.assign(haxe_io_BytesInput.prototype, {
	__class__: haxe_io_BytesInput
	,b: null
	,pos: null
	,len: null
	,totlen: null
});
var haxe_io_Encoding = $hxEnums["haxe.io.Encoding"] = { __ename__:true,__constructs__:null
	,UTF8: {_hx_name:"UTF8",_hx_index:0,__enum__:"haxe.io.Encoding",toString:$estr}
	,RawNative: {_hx_name:"RawNative",_hx_index:1,__enum__:"haxe.io.Encoding",toString:$estr}
};
haxe_io_Encoding.__constructs__ = [haxe_io_Encoding.UTF8,haxe_io_Encoding.RawNative];
class haxe_io_Eof {
	constructor() {
	}
	toString() {
		return "Eof";
	}
}
haxe_io_Eof.__name__ = true;
Object.assign(haxe_io_Eof.prototype, {
	__class__: haxe_io_Eof
});
var haxe_io_Error = $hxEnums["haxe.io.Error"] = { __ename__:true,__constructs__:null
	,Blocked: {_hx_name:"Blocked",_hx_index:0,__enum__:"haxe.io.Error",toString:$estr}
	,Overflow: {_hx_name:"Overflow",_hx_index:1,__enum__:"haxe.io.Error",toString:$estr}
	,OutsideBounds: {_hx_name:"OutsideBounds",_hx_index:2,__enum__:"haxe.io.Error",toString:$estr}
	,Custom: ($_=function(e) { return {_hx_index:3,e:e,__enum__:"haxe.io.Error",toString:$estr}; },$_._hx_name="Custom",$_.__params__ = ["e"],$_)
};
haxe_io_Error.__constructs__ = [haxe_io_Error.Blocked,haxe_io_Error.Overflow,haxe_io_Error.OutsideBounds,haxe_io_Error.Custom];
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
	,array: null
	,current: null
});
class js_Boot {
	static getClass(o) {
		if(o == null) {
			return null;
		} else if(((o) instanceof Array)) {
			return Array;
		} else {
			let cl = o.__class__;
			if(cl != null) {
				return cl;
			}
			let name = js_Boot.__nativeClassName(o);
			if(name != null) {
				return js_Boot.__resolveNativeClass(name);
			}
			return null;
		}
	}
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
			if(o.__enum__) {
				let e = $hxEnums[o.__enum__];
				let con = e.__constructs__[o._hx_index];
				let n = con._hx_name;
				if(con.__params__) {
					s = s + "\t";
					return n + "(" + ((function($this) {
						var $r;
						let _g = [];
						{
							let _g1 = 0;
							let _g2 = con.__params__;
							while(true) {
								if(!(_g1 < _g2.length)) {
									break;
								}
								let p = _g2[_g1];
								_g1 = _g1 + 1;
								_g.push(js_Boot.__string_rec(o[p],s));
							}
						}
						$r = _g;
						return $r;
					}(this))).join(",") + ")";
				} else {
					return n;
				}
			}
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
	static __nativeClassName(o) {
		let name = js_Boot.__toStr.call(o).slice(8,-1);
		if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") {
			return null;
		}
		return name;
	}
	static __resolveNativeClass(name) {
		return $global[name];
	}
}
js_Boot.__name__ = true;
var js_node_ChildProcess = require("child_process");
var js_node_Fs = require("fs");
var js_node_Net = require("net");
var js_node_Path = require("path");
class js_node_buffer__$Buffer_Helper {
	static bytesOfBuffer(b) {
		let o = Object.create(haxe_io_Bytes.prototype);
		o.length = b.byteLength;
		o.b = b;
		b.bufferValue = b;
		b.hxBytes = o;
		b.bytes = b;
		return o;
	}
}
js_node_buffer__$Buffer_Helper.__name__ = true;
var js_node_net_Socket = require("net").Socket;
var js_node_util_Promisify = require("util").promisify;
class sys_FileSystem {
	static exists(path) {
		try {
			js_node_Fs.accessSync(path);
			return true;
		} catch( _g ) {
			return false;
		}
	}
}
sys_FileSystem.__name__ = true;
class tink_await_Error {
	static fromAny(any) {
		if(((any) instanceof tink_core_TypedError)) {
			return any;
		} else {
			return tink_core_TypedError.withData(0,"Unexpected Error",any,{ fileName : "tink/await/Error.hx", lineNumber : 12, className : "tink.await._Error.Error_Impl_", methodName : "fromAny"});
		}
	}
}
class tink_await_OutcomeTools {
	static getOutcome(outcome,value) {
		if(outcome == null) {
			return tink_core_Outcome.Success(value);
		} else {
			switch(outcome._hx_index) {
			case 0:
				return outcome;
			case 1:
				let _g = outcome.failure;
				if(((_g) instanceof tink_core_TypedError)) {
					return outcome;
				} else {
					return tink_core_Outcome.Failure(tink_await_Error.fromAny(_g));
				}
				break;
			}
		}
	}
}
tink_await_OutcomeTools.__name__ = true;
class tink_core_Callback {
	static invoke(this1,data) {
		if(tink_core_Callback.depth < 500) {
			tink_core_Callback.depth++;
			this1(data);
			tink_core_Callback.depth--;
		} else {
			tink_core_Callback.defer(function() {
				this1(data);
			});
		}
	}
	static defer(f) {
		process.nextTick(f);
	}
}
class tink_core__$Callback_ListCell {
	constructor(cb,list) {
		if(cb == null) {
			throw haxe_Exception.thrown("callback expected but null received");
		}
		this.cb = cb;
		this.list = list;
	}
	cancel() {
		if(this.list != null) {
			let list = this.list;
			this.cb = null;
			this.list = null;
			if(--list.used <= list.cells.length >> 1) {
				list.compact();
			}
		}
	}
}
tink_core__$Callback_ListCell.__name__ = true;
Object.assign(tink_core__$Callback_ListCell.prototype, {
	__class__: tink_core__$Callback_ListCell
	,cb: null
	,list: null
});
class tink_core_SimpleDisposable {
	constructor(dispose) {
		if(tink_core_SimpleDisposable._hx_skip_constructor) {
			return;
		}
		this._hx_constructor(dispose);
	}
	_hx_constructor(dispose) {
		this.disposeHandlers = [];
		this.f = dispose;
	}
	dispose() {
		let _g = this.disposeHandlers;
		if(_g != null) {
			this.disposeHandlers = null;
			let f = this.f;
			this.f = tink_core_SimpleDisposable.noop;
			f();
			let _g1 = 0;
			while(_g1 < _g.length) {
				let h = _g[_g1];
				++_g1;
				h();
			}
		}
	}
	static noop() {
	}
}
tink_core_SimpleDisposable.__name__ = true;
Object.assign(tink_core_SimpleDisposable.prototype, {
	__class__: tink_core_SimpleDisposable
	,f: null
	,disposeHandlers: null
});
class tink_core_CallbackList extends tink_core_SimpleDisposable {
	constructor(destructive) {
		tink_core_SimpleDisposable._hx_skip_constructor = true;
		super();
		tink_core_SimpleDisposable._hx_skip_constructor = false;
		this._hx_constructor(destructive);
	}
	_hx_constructor(destructive) {
		if(destructive == null) {
			destructive = false;
		}
		this.onfill = function() {
		};
		this.ondrain = function() {
		};
		this.busy = false;
		this.queue = [];
		this.used = 0;
		let _gthis = this;
		super._hx_constructor(function() {
			if(!_gthis.busy) {
				_gthis.destroy();
			}
		});
		this.destructive = destructive;
		this.cells = [];
	}
	destroy() {
		let _g = 0;
		let _g1 = this.cells;
		while(_g < _g1.length) {
			let c = _g1[_g];
			++_g;
			c.cb = null;
			c.list = null;
		}
		this.queue = null;
		this.cells = null;
		if(this.used > 0) {
			this.used = 0;
			let fn = this.ondrain;
			if(tink_core_Callback.depth < 500) {
				tink_core_Callback.depth++;
				fn();
				tink_core_Callback.depth--;
			} else {
				tink_core_Callback.defer(fn);
			}
		}
	}
	invoke(data) {
		let _gthis = this;
		if(tink_core_Callback.depth < 500) {
			tink_core_Callback.depth++;
			if(_gthis.disposeHandlers != null) {
				if(_gthis.busy) {
					if(_gthis.destructive != true) {
						let _g = $bind(_gthis,_gthis.invoke);
						let data1 = data;
						let tmp = function() {
							_g(data1);
						};
						_gthis.queue.push(tmp);
					}
				} else {
					_gthis.busy = true;
					if(_gthis.destructive) {
						_gthis.dispose();
					}
					let length = _gthis.cells.length;
					let _g = 0;
					while(_g < length) {
						let i = _g++;
						let _this = _gthis.cells[i];
						if(_this.list != null) {
							_this.cb(data);
						}
					}
					_gthis.busy = false;
					if(_gthis.disposeHandlers == null) {
						_gthis.destroy();
					} else {
						if(_gthis.used < _gthis.cells.length) {
							_gthis.compact();
						}
						if(_gthis.queue.length > 0) {
							(_gthis.queue.shift())();
						}
					}
				}
			}
			tink_core_Callback.depth--;
		} else {
			tink_core_Callback.defer(function() {
				if(_gthis.disposeHandlers != null) {
					if(_gthis.busy) {
						if(_gthis.destructive != true) {
							let _g = $bind(_gthis,_gthis.invoke);
							let data1 = data;
							let tmp = function() {
								_g(data1);
							};
							_gthis.queue.push(tmp);
						}
					} else {
						_gthis.busy = true;
						if(_gthis.destructive) {
							_gthis.dispose();
						}
						let length = _gthis.cells.length;
						let _g = 0;
						while(_g < length) {
							let i = _g++;
							let _this = _gthis.cells[i];
							if(_this.list != null) {
								_this.cb(data);
							}
						}
						_gthis.busy = false;
						if(_gthis.disposeHandlers == null) {
							_gthis.destroy();
						} else {
							if(_gthis.used < _gthis.cells.length) {
								_gthis.compact();
							}
							if(_gthis.queue.length > 0) {
								(_gthis.queue.shift())();
							}
						}
					}
				}
			});
		}
	}
	compact() {
		if(this.busy) {
			return;
		} else if(this.used == 0) {
			this.resize(0);
			let fn = this.ondrain;
			if(tink_core_Callback.depth < 500) {
				tink_core_Callback.depth++;
				fn();
				tink_core_Callback.depth--;
			} else {
				tink_core_Callback.defer(fn);
			}
		} else {
			let compacted = 0;
			let _g = 0;
			let _g1 = this.cells.length;
			while(_g < _g1) {
				let i = _g++;
				let _g1 = this.cells[i];
				if(_g1.cb != null) {
					if(compacted != i) {
						this.cells[compacted] = _g1;
					}
					if(++compacted == this.used) {
						break;
					}
				}
			}
			this.resize(this.used);
		}
	}
	resize(length) {
		this.cells.length = length;
	}
}
tink_core_CallbackList.__name__ = true;
tink_core_CallbackList.__super__ = tink_core_SimpleDisposable;
Object.assign(tink_core_CallbackList.prototype, {
	__class__: tink_core_CallbackList
	,destructive: null
	,cells: null
	,used: null
	,queue: null
	,busy: null
	,ondrain: null
	,onfill: null
});
class tink_core_TypedError {
	constructor(code,message,pos) {
		if(code == null) {
			code = 500;
		}
		this.isTinkError = true;
		this.code = code;
		this.message = message;
		this.pos = pos;
		this.exceptionStack = [];
		this.callStack = [];
	}
	printPos() {
		return this.pos.className + "." + this.pos.methodName + ":" + this.pos.lineNumber;
	}
	toString() {
		let ret = "Error#" + this.code + ": " + this.message;
		if(this.pos != null) {
			ret += " @ " + this.printPos();
		}
		return ret;
	}
	static withData(code,message,data,pos) {
		return tink_core_TypedError.typed(code,message,data,pos);
	}
	static typed(code,message,data,pos) {
		let ret = new tink_core_TypedError(code,message,pos);
		ret.data = data;
		return ret;
	}
	static asError(v) {
		if(v != null && v.isTinkError) {
			return v;
		} else {
			return null;
		}
	}
}
tink_core_TypedError.__name__ = true;
Object.assign(tink_core_TypedError.prototype, {
	__class__: tink_core_TypedError
	,message: null
	,code: null
	,data: null
	,pos: null
	,callStack: null
	,exceptionStack: null
	,isTinkError: null
});
class tink_core__$Lazy_LazyConst {
	constructor(value) {
		this.value = value;
	}
	get() {
		return this.value;
	}
	compute() {
	}
}
tink_core__$Lazy_LazyConst.__name__ = true;
Object.assign(tink_core__$Lazy_LazyConst.prototype, {
	__class__: tink_core__$Lazy_LazyConst
	,value: null
});
class tink_core_Future {
	static ofJsPromise(promise) {
		return tink_core_Future.irreversible(function(cb) {
			promise.then(function(a) {
				let _g = cb;
				let a1 = tink_core_Outcome.Success(a);
				tink_core_Callback.defer(function() {
					_g(a1);
				});
			},function(e) {
				cb(tink_core_Outcome.Failure(tink_core_TypedError.withData(null,e.message,e,{ fileName : "tink/core/Future.hx", lineNumber : 158, className : "tink.core._Future.Future_Impl_", methodName : "ofJsPromise"})));
			});
		});
	}
	static irreversible(init) {
		return new tink_core__$Future_SuspendableFuture(function($yield) {
			init($yield);
			return null;
		});
	}
}
var tink_core_FutureStatus = $hxEnums["tink.core.FutureStatus"] = { __ename__:true,__constructs__:null
	,Suspended: {_hx_name:"Suspended",_hx_index:0,__enum__:"tink.core.FutureStatus",toString:$estr}
	,Awaited: {_hx_name:"Awaited",_hx_index:1,__enum__:"tink.core.FutureStatus",toString:$estr}
	,EagerlyAwaited: {_hx_name:"EagerlyAwaited",_hx_index:2,__enum__:"tink.core.FutureStatus",toString:$estr}
	,Ready: ($_=function(result) { return {_hx_index:3,result:result,__enum__:"tink.core.FutureStatus",toString:$estr}; },$_._hx_name="Ready",$_.__params__ = ["result"],$_)
	,NeverEver: {_hx_name:"NeverEver",_hx_index:4,__enum__:"tink.core.FutureStatus",toString:$estr}
};
tink_core_FutureStatus.__constructs__ = [tink_core_FutureStatus.Suspended,tink_core_FutureStatus.Awaited,tink_core_FutureStatus.EagerlyAwaited,tink_core_FutureStatus.Ready,tink_core_FutureStatus.NeverEver];
class tink_core__$Future_SuspendableFuture {
	constructor(wakeup) {
		this.status = tink_core_FutureStatus.Suspended;
		this.wakeup = wakeup;
		this.callbacks = new tink_core_CallbackList(true);
		let _gthis = this;
		this.callbacks.ondrain = function() {
			if(_gthis.status == tink_core_FutureStatus.Awaited) {
				_gthis.status = tink_core_FutureStatus.Suspended;
				let this1 = _gthis.link;
				if(this1 != null) {
					this1.cancel();
				}
				_gthis.link = null;
			}
		};
		this.callbacks.onfill = function() {
			if(_gthis.status == tink_core_FutureStatus.Suspended) {
				_gthis.status = tink_core_FutureStatus.Awaited;
				_gthis.arm();
			}
		};
	}
	trigger(value) {
		if(this.status._hx_index != 3) {
			this.status = tink_core_FutureStatus.Ready(new tink_core__$Lazy_LazyConst(value));
			let link = this.link;
			this.link = null;
			this.wakeup = null;
			this.callbacks.invoke(value);
			if(link != null) {
				link.cancel();
			}
		}
	}
	handle(callback) {
		let _g = this.status;
		if(_g._hx_index == 3) {
			tink_core_Callback.invoke(callback,tink_core_Lazy.get(_g.result));
			return null;
		} else {
			let _this = this.callbacks;
			if(_this.disposeHandlers == null) {
				return null;
			} else {
				let node = new tink_core__$Callback_ListCell(callback,_this);
				_this.cells.push(node);
				if(_this.used++ == 0) {
					let fn = _this.onfill;
					if(tink_core_Callback.depth < 500) {
						tink_core_Callback.depth++;
						fn();
						tink_core_Callback.depth--;
					} else {
						tink_core_Callback.defer(fn);
					}
				}
				return node;
			}
		}
	}
	arm() {
		let _gthis = this;
		this.link = this.wakeup(function(x) {
			_gthis.trigger(x);
		});
	}
	eager() {
		switch(this.status._hx_index) {
		case 0:
			this.status = tink_core_FutureStatus.EagerlyAwaited;
			this.arm();
			break;
		case 1:
			this.status = tink_core_FutureStatus.EagerlyAwaited;
			break;
		default:
		}
	}
}
tink_core__$Future_SuspendableFuture.__name__ = true;
Object.assign(tink_core__$Future_SuspendableFuture.prototype, {
	__class__: tink_core__$Future_SuspendableFuture
	,callbacks: null
	,status: null
	,link: null
	,wakeup: null
});
class tink_core_Lazy {
	static get(this1) {
		this1.compute();
		return this1.get();
	}
}
var tink_core_Outcome = $hxEnums["tink.core.Outcome"] = { __ename__:true,__constructs__:null
	,Success: ($_=function(data) { return {_hx_index:0,data:data,__enum__:"tink.core.Outcome",toString:$estr}; },$_._hx_name="Success",$_.__params__ = ["data"],$_)
	,Failure: ($_=function(failure) { return {_hx_index:1,failure:failure,__enum__:"tink.core.Outcome",toString:$estr}; },$_._hx_name="Failure",$_.__params__ = ["failure"],$_)
};
tink_core_Outcome.__constructs__ = [tink_core_Outcome.Success,tink_core_Outcome.Failure];
function $getIterator(o) { if( o instanceof Array ) return new haxe_iterators_ArrayIterator(o); else return o.iterator(); }
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $global.$haxeUID++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = m.bind(o); o.hx__closures__[m.__id__] = f; } return f; }
$global.$haxeUID |= 0;
if(typeof(performance) != "undefined" ? typeof(performance.now) == "function" : false) {
	HxOverrides.now = performance.now.bind(performance);
}
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
{
	String.prototype.__class__ = String;
	String.__name__ = true;
	Array.__name__ = true;
	Date.prototype.__class__ = Date;
	Date.__name__ = "Date";
}
js_Boot.__toStr = ({ }).toString;
gmdebug_Cross.FOLDER = "gmdebug";
gmdebug_Cross.CLIENT_READY = haxe_io_Path.join([gmdebug_Cross.FOLDER,"clientready.dat"]);
gmdebug_Cross.INPUT = haxe_io_Path.join([gmdebug_Cross.FOLDER,"in.dat"]);
gmdebug_Cross.OUTPUT = haxe_io_Path.join([gmdebug_Cross.FOLDER,"out.dat"]);
gmdebug_Cross.READY = haxe_io_Path.join([gmdebug_Cross.FOLDER,"ready.dat"]);
gmdebug_Cross.DATA = "data";
gmdebug_composer_ComposedProtocolMessage._hx_skip_constructor = false;
gmdebug_dap_ClientStorage.SERVER_ID = 0;
gmdebug_dap_LuaDebugger.SERVER_TIMEOUT = 20;
tink_core_Callback.depth = 0;
tink_core_SimpleDisposable._hx_skip_constructor = false;
gmdebug_dap_Main.main();
})(typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);

//# sourceMappingURL=main.js.map