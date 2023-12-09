package gmdebug.lua;

import haxe.Constraints.Function;
import haxe.ds.ObjectMap;
import gmdebug.lua.handlers.IHandler;
import gmod.Gmod;
import gmod.stringtypes.Hook.GMHook;
import gmod.libs.HookLib;
import haxe.io.Path as HxPath;
import gmdebug.lua.DebugLoop.SourceInfo;
import gmdebug.composer.*;
using gmod.helpers.WeakTools;
using Safety;
using Lambda;

#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end

typedef InitSourceContainer = {
    debugee : Debugee
}

class SourceContainer {

    final uniqueSources:Map<String, Null<Source>> = [];

    public var sources:Array<Source> = [];

    public var sourceCache:ObjectMap<Function,SourceInfo>;

    final debugee:Debugee;

    public function new(initSourceContainer:InitSourceContainer) {
        HookLib.Add(GMHook.Think, "gmdebug-source-get", () -> {
            if (Gmod.CurTime() > readSourceTime) {
                readSourceTime = Gmod.CurTime() + 1;
                readSourceInfo();
            }
        });
        sourceCache = makeSourceCache();
        debugee = initSourceContainer.debugee;
    }

    function makeSourceCache() {
        final sc = new haxe.ds.ObjectMap<haxe.Constraints.Function, SourceInfo>();
        sc.setWeakKeysM();
        return sc;
    }

    function readSourceInfo() {
        if (debugee.dest == "")
            return;
        for (si in sourceCache) {
            if (!uniqueSources.exists(si.source)) {
                final result = infoToSource(si);
                if (result != null) {
                    debugee.sendMessage(new ComposedEvent(loadedSource, {
                        reason: New,
                        source: result
                    }));
                    sources.push(result);
                }
                uniqueSources.set(si.source, result);
            }
        }
    }

    var readSourceTime:Float = 0;

    function infoToSource(info:SourceInfo):Null<Source> {
        return switch (info.source) {
            case src if (Util.isCSource(src)):
                null;
            case src:
                final pathStr = src; //NORMAL PATH
                final path = new HxPath(pathStr);
                {
                    name: path.file,
                    path: path.toString(),
                };
        }
    }
}
