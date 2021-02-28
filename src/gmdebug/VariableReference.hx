package gmdebug;

enum VariableReferenceVal {
	Child(clientID:Int, ref:Int);
	FrameLocal(clientID:Int, frameID:Int, ref:FrameLocalScope);
	Global(clientID:Int, ref:ScopeConsts);
}

enum abstract VariableRefBit(Int) {
	var Child;
	var FrameLocal;
	var Global;
}

abstract VariableReference(Int) from Int to Int {
	static var clientID:Int = 15;

	public function getValue():VariableReferenceVal {
		final maskClientID = 0xF;
		final maskFrameID = 0x1FFFF;
		final clientID = (this >>> 25) & maskClientID;
		final ref:VariableRefBit = cast(this >>> 29 & 3);
		return switch (ref) {
			case Child:
				Child(clientID, this & 0xFFFFFF); // shave 26 bits off, ignore first 2
			case FrameLocal:
				FrameLocal(clientID, (this >>> 8) & maskFrameID, this & 0xFF);
			case Global:
				Global(clientID, this & 0xFFFFFF);
		}
	}

	public static function encode(x:VariableReferenceVal):VariableReference {
		var val = x.getIndex() << 29;
		return switch (x) {
			case Child(clientID, ref):
				val |= clientID << 25;
				val | ref++;
			case FrameLocal(clientID, frame, ref):
				val |= clientID << 25;
				val |= frame << 8;
				val | ref++;
			case Global(clientID, ref):
				val |= clientID << 25;
				val | ref++;
		}
	}
}

enum abstract ScopeConsts(Int) to Int from Int {
	var Globals;
	var Players;
	var Entities;
	var Enums;
}

enum abstract FrameLocalScope(Int) to Int from Int {
	var Arguments;
	var Locals;
	var Upvalues;
	var Fenv;
}