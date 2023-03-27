package gmdebug.lib.js;


typedef SudoPromptOptions = {
    ?name : String,
    ?icns : String
}


@:jsRequire("sudo-prompt")
extern class SudoPrompt {
    static function exec(command:String,options:SudoPromptOptions,handler:(?error:Any,stdout:String,stderr:String) -> Void):Void;
}