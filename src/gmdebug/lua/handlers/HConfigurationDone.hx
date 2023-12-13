package gmdebug.lua.handlers;

typedef InitHConfigurationDone = {
	debugee:Debugee
}

class HConfigurationDone implements IHandler<ConfigurationDoneRequest> {
	final debugee:Debugee;

	public function new(init:InitHConfigurationDone) {
		debugee = init.debugee;
	}

	public function handle(configRequest:ConfigurationDoneRequest) {
		var rep = configRequest.compose(configurationDone, {});
		debugee.sendMessage(rep);
		return CONFIG_DONE;
	}
}
