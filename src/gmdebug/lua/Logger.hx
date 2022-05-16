package gmdebug.lua;

import gmod.libs.FileLib;

class Logger {

    static var logfile:gmod.gclass.File;

    public static function init() {
        final _logfile = FileLib.Open("log.dat",write,DATA);
        if (_logfile != null) {
            logfile = _logfile;
        }
    }

    public static function log(s:String) {
        logfile.Write(Gmod.SysTime() + ": ");
        logfile.Write(s + "\n");
        logfile.Flush();
    }
    

}