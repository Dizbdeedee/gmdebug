package gmdebug;

enum abstract GmDebugError(Int) to Int {
    var INVALID;
    var GMOD_UNSPECIFIED_ERROR;
    var DEBUGGER_UNSPECIFIED_ERROR;
    var DEBUGGER_NO_ATTACH;
    var GMOD_EVALUATION_FAIL;
    var GMOD_SERVER_FAIL_CONNECT;
    var GMOD_CLIENT_FAIL_CONNECT;
    // var DEBUGGER_INVALID_CLIENTFOLDER;
    var DEBUGGER_INVALID_COPYFOLDER;
    // var DEBUGGER_INVALID_PROGRAMPATH;
    var DEBUGGER_INVALID_PROGRAMPATH_UNSPECIFIFED;
    var DEBUGGER_INVALID_PROGRAMPATH_NOTEXIST;
    var DEBUGGER_INVALID_PROGRAMPATH_NOTFILE;
    var DEBUGGER_INVALID_SERVERFOLDER_UNSPECIFIED;
    var DEBUGGER_INVALID_SERVERFOLDER_NOTABSOLUTE;
    var DEBUGGER_INVALID_SERVERFOLDER_NOTEXIST;
    var DEBUGGER_INVALID_SERVERFOLDER_NOTDIR;
    var DEBUGGER_INVALID_SERVERFOLDER_NOTGMOD;
    var DEBUGGER_INVALID_CLIENTFOLDER_UNSPECIFIED;
    var DEBUGGER_INVALID_CLIENTFOLDER_NOTABSOLUTE;
    var DEBUGGER_INVALID_CLIENTFOLDER_NOTEXIST;
    var DEBUGGER_INVALID_CLIENTFOLDER_NOTGMOD;
    var DEBUGGER_INVALID_CLIENTFOLDER_NOTDIR;
}

var GMDEBUG_ERROR_STRINGS = [
    GMOD_UNSPECIFIED_ERROR => "Uncaught gmod error {err}",
    DEBUGGER_UNSPECIFIED_ERROR => "Uncaught debugger error {err}",
    GMOD_EVALUATION_FAIL => "Evaluation fail: {err}",
    DEBUGGER_NO_ATTACH => "Gmdebug does not currently support attach requests",
    GMOD_SERVER_FAIL_CONNECT => "Failed to connect to server",
    GMOD_CLIENT_FAIL_CONNECT => "Failed to connect to client",
    DEBUGGER_INVALID_PROGRAMPATH_UNSPECIFIFED => "Gmdebug requires the property \"programPath\" to be specified when launching",
    DEBUGGER_INVALID_PROGRAMPATH_NOTEXIST => "The program specified by \"programPath\" does not exist",
    DEBUGGER_INVALID_PROGRAMPATH_NOTFILE => "The program specified by \"programPath\" is not a file",
    DEBUGGER_INVALID_SERVERFOLDER_UNSPECIFIED => "Gmdebug requires the property \"serverFolder\" to be specified",
    DEBUGGER_INVALID_SERVERFOLDER_NOTABSOLUTE => "Gmdebug requires the property \"serverFolder\" to be an absolute path (i.e from root folder)",
    DEBUGGER_INVALID_SERVERFOLDER_NOTEXIST => "The \"serverFolder\" path does not exist",
    DEBUGGER_INVALID_SERVERFOLDER_NOTDIR => "The \"serverFolder\" path is not a directory",
    DEBUGGER_INVALID_SERVERFOLDER_NOTGMOD => "\"serverFolder\" does not seem to be a garrysmod directory. (looking for \"addons\" folder)",
    DEBUGGER_INVALID_CLIENTFOLDER_UNSPECIFIED => "If you wish to debug clients, you must specify clientFolder first, or add the option nodebugClient into your launch options",
    DEBUGGER_INVALID_CLIENTFOLDER_NOTABSOLUTE => "Gmdebug requires client folder: {folder} to be an absolute path (i.e from root folder)",
    DEBUGGER_INVALID_CLIENTFOLDER_NOTEXIST => "The client folder: {folder} does not exist!",
    DEBUGGER_INVALID_CLIENTFOLDER_NOTDIR => "The client folder: {folder} is not a directory",
    DEBUGGER_INVALID_CLIENTFOLDER_NOTGMOD => "The client folder: {folder} does not seem to be a garrysmod directory. (looking for \"addons\" folder)",
    DEBUGGER_INVALID_COPYFOLDER => "If you wish to copy your addon to the server on debug, specify both addonName and copyAddonBaseFolder or add the option noCopy into your launch options"
];
