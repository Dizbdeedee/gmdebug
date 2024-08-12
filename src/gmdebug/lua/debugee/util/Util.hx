package gmdebug.lua.debugee.util;

function isLan() {
	return Gmod.GetConVar("sv_lan")
		.GetBool();
}
