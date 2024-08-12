package test;

import gmdebug.js.dap.LuaDebugger;
import gmdebug.protocol.composer.ComposedRequest;
import gmdebug.protocol.composer.RequestString;
import gmdebug.protocol.DebugProtocol;
import utest.Assert;

class TestHelper {

    public static function ok(x:Response<Dynamic>) {
        Assert.isTrue(x.success);
    }

    public static function is<T:Response<Dynamic>>(x:T,string:RequestString<Dynamic,T>) {
        Assert.equals(string,x.command);
    }

    public static function send(x:ComposedRequest<Dynamic,Dynamic>,luaDebug:LuaDebugger) {
        luaDebug.handleMessage(x);
    }


}