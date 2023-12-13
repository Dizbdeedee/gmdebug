package gmdebug.lua.util;

function isLan() {
	return Gmod.GetConVar("sv_lan")
		.GetBool();
}
