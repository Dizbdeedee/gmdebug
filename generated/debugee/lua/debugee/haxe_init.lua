--gmod haxe environment patch
local haxeEnv = {}
local _hx_exports = {}
_G.HAXE_debugee = haxeEnv 
setmetatable(_hx_exports,{__index = _G,__newindex = _G})
setmetatable(haxeEnv,{__index = _G})
setfenv(1,haxeEnv) --if using more than one project + dce, global collisions and missing indexes will ensue. dont want that --build ident: Foxtrot Juliett
local _hx_hidden = {__id__=true, hx__closures=true, super=true, prototype=true, __fields__=true, __ifields__=true, __class__=true, __properties__=true, __fields__=true, __name__=true}

_hx_array_mt = {
    __newindex = function(t,k,v)
        local len = t.length
        t.length =  k >= len and (k + 1) or len
        rawset(t,k,v)
    end
}

function _hx_is_array(o)
    return type(o) == "table"
        and o.__enum__ == nil
        and getmetatable(o) == _hx_array_mt
end



function _hx_tab_array(tab, length)
    tab.length = length
    return setmetatable(tab, _hx_array_mt)
end



function _hx_print_class(obj, depth)
    local first = true
    local result = ''
    for k,v in pairs(obj) do
        if _hx_hidden[k] == nil then
            if first then
                first = false
            else
                result = result .. ', '
            end
            if _hx_hidden[k] == nil then
                result = result .. k .. ':' .. _hx_tostring(v, depth+1)
            end
        end
    end
    return '{ ' .. result .. ' }'
end

function _hx_print_enum(o, depth)
    if o.length == 2 then
        return o[0]
    else
        local str = o[0] .. "("
        for i = 2, (o.length-1) do
            if i ~= 2 then
                str = str .. "," .. _hx_tostring(o[i], depth+1)
            else
                str = str .. _hx_tostring(o[i], depth+1)
            end
        end
        return str .. ")"
    end
end

function _hx_tostring(obj, depth)
    if depth == nil then
        depth = 0
    elseif depth > 5 then
        return "<...>"
    end

    local tstr = _G.type(obj)
    if tstr == "string" then return obj
    elseif tstr == "nil" then return "null"
    elseif tstr == "number" then
        if obj == _G.math.POSITIVE_INFINITY then return "Infinity"
        elseif obj == _G.math.NEGATIVE_INFINITY then return "-Infinity"
        elseif obj == 0 then return "0"
        elseif obj ~= obj then return "NaN"
        else return _G.tostring(obj)
        end
    elseif tstr == "boolean" then return _G.tostring(obj)
    elseif tstr == "userdata" then
        local mt = _G.getmetatable(obj)
        if mt ~= nil and mt.__tostring ~= nil then
            return _G.tostring(obj)
        else
            return "<userdata>"
        end
    elseif tstr == "function" then return "<function>"
    elseif tstr == "thread" then return "<thread>"
    elseif tstr == "table" then
        if obj.__enum__ ~= nil then
            return _hx_print_enum(obj, depth)
        elseif obj.toString ~= nil and not _hx_is_array(obj) then return obj:toString()
        elseif _hx_is_array(obj) then
            if obj.length > 5 then
                return "[...]"
            else
                local str = ""
                for i=0, (obj.length-1) do
                    if i == 0 then
                        str = str .. _hx_tostring(obj[i], depth+1)
                    else
                        str = str .. "," .. _hx_tostring(obj[i], depth+1)
                    end
                end
                return "[" .. str .. "]"
            end
        elseif obj.__class__ ~= nil then
            return _hx_print_class(obj, depth)
        else
            local buffer = {}
            local ref = obj
            if obj.__fields__ ~= nil then
                ref = obj.__fields__
            end
            for k,v in pairs(ref) do
                if _hx_hidden[k] == nil then
                    _G.table.insert(buffer, _hx_tostring(k, depth+1) .. ' : ' .. _hx_tostring(obj[k], depth+1))
                end
            end

            return "{ " .. table.concat(buffer, ", ") .. " }"
        end
    else
        _G.error("Unknown Lua type", 0)
        return ""
    end
end

function _hx_error(obj)
    if obj.value then
        _G.print("runtime error:\n " .. _hx_tostring(obj.value));
    else
        _G.print("runtime error:\n " .. tostring(obj));
    end

    if _G.debug and _G.debug.traceback then
        _G.print(debug.traceback());
    end
end


local function _hx_obj_newindex(t,k,v)
    t.__fields__[k] = true
    rawset(t,k,v)
end

local _hx_obj_mt = {__newindex=_hx_obj_newindex, __tostring=_hx_tostring}

local function _hx_a(...)
  local __fields__ = {};
  local ret = {__fields__ = __fields__};
  local max = select('#',...);
  local tab = {...};
  local cur = 1;
  while cur < max do
    local v = tab[cur];
    __fields__[v] = true;
    ret[v] = tab[cur+1];
    cur = cur + 2
  end
  return setmetatable(ret, _hx_obj_mt)
end

local function _hx_e()
  return setmetatable({__fields__ = {}}, _hx_obj_mt)
end

local function _hx_o(obj)
  return setmetatable(obj, _hx_obj_mt)
end

local function _hx_new(prototype)
  return setmetatable({__fields__ = {}}, {__newindex=_hx_obj_newindex, __index=prototype, __tostring=_hx_tostring})
end

function _hx_field_arr(obj)
    res = {}
    idx = 0
    if obj.__fields__ ~= nil then
        obj = obj.__fields__
    end
    for k,v in pairs(obj) do
        if _hx_hidden[k] == nil then
            res[idx] = k
            idx = idx + 1
        end
    end
    return _hx_tab_array(res, idx)
end

local _hxClasses = {}
local Int = _hx_e();
local Dynamic = _hx_e();
local Float = _hx_e();
local Bool = _hx_e();
local Class = _hx_e();
local Enum = _hx_e();

--gmodhaxe print patch

_hx_print_2 = function(str)
    local len = #str
    if (len > 1000) then
        --print("splitting")
        for i=0,len - 1,1000 do
            local p = math.min(i + 1000,len)
            print(string.sub(str,i + 1,p))
        end
    else
        ---print("not splitting")
        print(str)
    end
end or (function() end)

function _hx_print_class(obj, depth)
    local first = true
    local result = ''
    local x = 0
    for k,v in pairs(obj) do
        if _hx_hidden[k] == nil then
            x = x + 1;
            if x > 5 then result = result .. ', <...>' break end
            if first then
                first = false
            else
                result = result .. ', '
            end
            if _hx_hidden[k] == nil then
                result = result .. k .. ':' .. _hx_tostring(v, depth+1)
            end
        end
    end
    return '{ ' .. result .. ' }'
end

function _hx_tostring(obj, depth)
    if depth == nil then
        depth = 0
    elseif depth > 5 then
        return "<...>"
    end

    local tstr = _G.type(obj)
    if tstr == "string" then return obj
    elseif tstr == "nil" then return "null"
    elseif tstr == "number" then
        if obj == _G.math.POSITIVE_INFINITY then return "Infinity"
        elseif obj == _G.math.NEGATIVE_INFINITY then return "-Infinity"
        elseif obj == 0 then return "0"
        elseif obj ~= obj then return "NaN"
        else return _G.tostring(obj)
        end
    elseif tstr == "boolean" then return _G.tostring(obj)
    elseif tstr == "userdata" then
        local mt = _G.getmetatable(obj)
        if mt ~= nil and mt.__tostring ~= nil then
            return _G.tostring(obj)
        else
            return "<userdata>"
        end
    elseif tstr == "function" then return "<function>"
    elseif tstr == "thread" then return "<thread>"
    elseif tstr == "table" then
        if obj.__enum__ ~= nil then
            return _hx_print_enum(obj, depth)
        elseif obj.toString ~= nil and not _hx_is_array(obj) then return obj:toString()
        elseif _hx_is_array(obj) then
            if obj.length > 5 then
                return "[...]"
            else
                str = ""
                for i=0, (obj.length-1) do
                    if i == 0 then
                        str = str .. _hx_tostring(obj[i], depth+1)
                    else
                        str = str .. "," .. _hx_tostring(obj[i], depth+1)
                    end
                end
                return "[" .. str .. "]"
            end
        elseif obj.__class__ ~= nil then
            return _hx_print_class(obj, depth)
        else
            first = true
            buffer = {}
            for k,v in pairs(obj) do
                if _hx_hidden[k] == nil then
                    _G.table.insert(buffer, _hx_tostring(k, depth+1) .. ' : ' .. _hx_tostring(obj[k], depth+1))
                end
            end
            return "{ " .. table.concat(buffer, ", ") .. " }"
        end
    else
        if (_G.TypeID(obj) == _G.TYPE_NONE) then
          _G.error("Unknown lua type")
          return ""
        else
          return _G.tostring(obj)
        end
    end
end

if not _G._oldRequire then
    _G._oldRequire = _G.require
end

-- haxe is a little too eager to require modules sometimes, so this prevents script shutdown
-- TODO figure out a way to make this not affect global workspace
_G.require = function (str)
   local val,rtn = xpcall(_G._oldRequire,function (err) print("Failed to load module:" .. str .. " but did not halt" ) end,str)
   if val then
	  print("require loaded " .. str) return _G[str]
   end
end


local _hx_obj_mt = {__newindex=_hx_obj_newindex, __tostring=_hx_tostring}
--end

local _hx_exports = _hx_exports or {}
local Array = _hx_e()
local Date = _hx_e()
local Lambda = _hx_e()
local LuaLambdaKeys = _hx_e()
local Math = _hx_e()
local Reflect = _hx_e()
local String = _hx_e()
local Std = _hx_e()
local StringBuf = _hx_e()
local StringTools = _hx_e()
local Sys = _hx_e()
local ValueType = _hx_e()
local Type = _hx_e()
__haxe_io_Path = _hx_e()
__gmdebug_Cross = _hx_e()
__gmdebug_MessageResult = _hx_e()
__gmdebug__FrameID_FrameID_Impl_ = _hx_e()
__gmdebug_VariableReferenceVal = _hx_e()
__gmdebug__VariableReference_VariableReference_Impl_ = _hx_e()
__gmdebug_composer_ComposeTools = _hx_e()
__gmdebug_composer_ComposedProtocolMessage = _hx_e()
__gmdebug_composer_ComposedEvent = _hx_e()
__gmdebug_composer_ComposedGmDebugMessage = _hx_e()
__gmdebug_composer_ComposedResponse = _hx_e()
__gmdebug_lua_CustomHandlers = _hx_e()
__gmdebug_lua__DebugHook_DDebugHook = _hx_e()
__gmdebug_lua_CatchOut = _hx_e()
__haxe_IMap = _hx_e()
__haxe_ds_ObjectMap = _hx_e()
__haxe_ds_Option = _hx_e()
__gmdebug_lua_DebugLoop = _hx_e()
__gmdebug_lua_ProfilingState = _hx_e()
__gmdebug_lua_DebugLoopProfile = _hx_e()
__gmdebug_lua_RecursiveGuard = _hx_e()
__gmdebug_lua_Debugee = _hx_e()
__gmdebug_lua_DebugState = _hx_e()
__gmdebug_lua_RecvMessageResult = _hx_e()
__gmod_helpers_WeakTools = _hx_e()
__gmdebug_lua_Exceptions = _hx_e()
__gmdebug_lua__GmodPath_GmodPath_Impl_ = _hx_e()
__gmdebug_lua_HandlerContainer = _hx_e()
__gmdebug_lua_Outputter = _hx_e()
__gmdebug_lua_SourceContainer = _hx_e()
__gmdebug_lua_StackConst = _hx_e()
__gmdebug_lua_Start = _hx_e()
__gmdebug_lua_CompileResult = _hx_e()
__gmdebug_lua_RunResult = _hx_e()
__gmdebug_lua_Util = _hx_e()
__gmdebug_lua_handlers_IHandler = _hx_e()
__gmdebug_lua_handlers_HConfigurationDone = _hx_e()
__gmdebug_lua_handlers_HContinue = _hx_e()
__gmdebug_lua_handlers_HDisconnect = _hx_e()
__gmdebug_lua_handlers_HEvaluate = _hx_e()
__gmdebug_lua_handlers_HLoadedSources = _hx_e()
__gmdebug_lua_handlers_HNext = _hx_e()
__gmdebug_lua_handlers_HPause = _hx_e()
__gmdebug_lua_handlers_HScopes = _hx_e()
__gmdebug_lua_handlers_HSetBreakpoints = _hx_e()
__gmdebug_lua_handlers_HSetExceptionBreakpoints = _hx_e()
__gmdebug_lua_handlers_HSetFunctionBreakpoints = _hx_e()
__gmdebug_lua_handlers_HStackTrace = _hx_e()
__gmdebug_lua_handlers_HStepIn = _hx_e()
__gmdebug_lua_handlers_HStepOut = _hx_e()
__gmdebug_lua_handlers_HVariables = _hx_e()
__gmdebug_lua_handlers_FakeChild = _hx_e()
__gmdebug_lua_handlers_HandlerResponse = _hx_e()
__gmdebug_lua_io_DebugIO = _hx_e()
__gmdebug_lua_io_PipeSocket = _hx_e()
__haxe_io_Input = _hx_e()
__gmdebug_lua_io_PipeInput = _hx_e()
__haxe_io_Output = _hx_e()
__gmdebug_lua_io_PipeOutput = _hx_e()
__gmdebug_lua_managers_BreakpointManager = _hx_e()
__gmdebug_lua_managers_LineStatus = _hx_e()
__gmdebug_lua_managers_Breakpoint = _hx_e()
__gmdebug_lua_managers_BreakpointType = _hx_e()
__gmdebug_lua_managers_FunctionBreakpointManager = _hx_e()
__gmdebug_lua_managers_VariableManager = _hx_e()
__gmdebug_lua_util__Util_Util_Fields_ = _hx_e()
__gmod_helpers_macros_include_Build = _hx_e()
__gmod_helpers_macros_include___ForceExpose = _hx_e()
__haxe_StackItem = _hx_e()
__haxe__CallStack_CallStack_Impl_ = _hx_e()
__haxe_EntryPoint = _hx_e()
__haxe_Exception = _hx_e()
__haxe_Json = _hx_e()
__haxe_Log = _hx_e()
__haxe_MainEvent = _hx_e()
__haxe_MainLoop = _hx_e()
__haxe_NativeStackTrace = _hx_e()
__haxe_ValueException = _hx_e()
__haxe_ds_IntMap = _hx_e()
__haxe_ds_StringMap = _hx_e()
__haxe_exceptions_PosException = _hx_e()
__haxe_exceptions_NotImplementedException = _hx_e()
__haxe_format_JsonParser = _hx_e()
__haxe_format_JsonPrinter = _hx_e()
__haxe_io_Bytes = _hx_e()
__haxe_io_BytesBuffer = _hx_e()
__haxe_io_Encoding = _hx_e()
__haxe_io_Eof = _hx_e()
__haxe_io_Error = _hx_e()
__haxe_iterators_ArrayIterator = _hx_e()
__haxe_iterators_ArrayKeyValueIterator = _hx_e()
__lua_Boot = _hx_e()
__lua_UserData = _hx_e()
__lua_Thread = _hx_e()
__safety_SafetyException = _hx_e()
__safety_NullPointerException = _hx_e()
__tink_core_Annex = _hx_e()
__tink_json_BasicWriter = _hx_e()
__tink_json_Writer45 = _hx_e()
__tink_json_Writer46 = _hx_e()
__tink_json_Writer47 = _hx_e()
__tink_json_Writer48 = _hx_e()

local _hx_bind, _hx_bit, _hx_staticToInstance, _hx_funcToField, _hx_maxn, _hx_print, _hx_apply_self, _hx_box_mr, _hx_bit_clamp, _hx_table, _hx_bit_raw
local _hx_pcall_default = {};
local _hx_pcall_break = {};

Array.new = function() 
  local self = _hx_new(Array.prototype)
  Array.super(self)
  return self
end
Array.super = function(self) 
  _hx_tab_array(self, 0);
end
Array.__name__ = true
Array.prototype = _hx_e();
Array.prototype.length= nil;
Array.prototype.concat = function(self,a) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  while (_g1 < self.length) do 
    local i = self[_g1];
    _g1 = _g1 + 1;
    _g:push(i);
  end;
  local _g1 = 0;
  while (_g1 < a.length) do 
    local i = a[_g1];
    _g1 = _g1 + 1;
    _g:push(i);
  end;
  do return _g end
end
Array.prototype.join = function(self,sep) 
  local tbl = ({});
  local _g_current = 0;
  while (_g_current < self.length) do 
    _g_current = _g_current + 1;
    _G.table.insert(tbl, Std.string(self[_g_current - 1]));
  end;
  do return _G.table.concat(tbl, sep) end
end
Array.prototype.pop = function(self) 
  if (self.length == 0) then 
    do return nil end;
  end;
  local ret = self[self.length - 1];
  self[self.length - 1] = nil;
  self.length = self.length - 1;
  do return ret end
end
Array.prototype.push = function(self,x) 
  self[self.length] = x;
  do return self.length end
end
Array.prototype.reverse = function(self) 
  local tmp;
  local i = 0;
  while (i < Std.int(self.length / 2)) do 
    tmp = self[i];
    self[i] = self[(self.length - i) - 1];
    self[(self.length - i) - 1] = tmp;
    i = i + 1;
  end;
end
Array.prototype.shift = function(self) 
  if (self.length == 0) then 
    do return nil end;
  end;
  local ret = self[0];
  if (self.length == 1) then 
    self[0] = nil;
  else
    if (self.length > 1) then 
      self[0] = self[1];
      _G.table.remove(self, 1);
    end;
  end;
  local tmp = self;
  tmp.length = tmp.length - 1;
  do return ret end
end
Array.prototype.slice = function(self,pos,_end) 
  if ((_end == nil) or (_end > self.length)) then 
    _end = self.length;
  else
    if (_end < 0) then 
      _end = _G.math.fmod((self.length - (_G.math.fmod(-_end, self.length))), self.length);
    end;
  end;
  if (pos < 0) then 
    pos = _G.math.fmod((self.length - (_G.math.fmod(-pos, self.length))), self.length);
  end;
  if ((pos > _end) or (pos > self.length)) then 
    do return _hx_tab_array({}, 0) end;
  end;
  local ret = _hx_tab_array({}, 0);
  local _g = pos;
  local _g1 = _end;
  while (_g < _g1) do 
    _g = _g + 1;
    ret:push(self[_g - 1]);
  end;
  do return ret end
end
Array.prototype.sort = function(self,f) 
  local i = 0;
  local l = self.length;
  while (i < l) do 
    local swap = false;
    local j = 0;
    local max = (l - i) - 1;
    while (j < max) do 
      if (f(self[j], self[j + 1]) > 0) then 
        local tmp = self[j + 1];
        self[j + 1] = self[j];
        self[j] = tmp;
        swap = true;
      end;
      j = j + 1;
    end;
    if (not swap) then 
      break;
    end;
    i = i + 1;
  end;
end
Array.prototype.splice = function(self,pos,len) 
  if ((len < 0) or (pos > self.length)) then 
    do return _hx_tab_array({}, 0) end;
  else
    if (pos < 0) then 
      pos = self.length - (_G.math.fmod(-pos, self.length));
    end;
  end;
  len = Math.min(len, self.length - pos);
  local ret = _hx_tab_array({}, 0);
  local _g = pos;
  local _g1 = pos + len;
  while (_g < _g1) do 
    _g = _g + 1;
    local i = _g - 1;
    ret:push(self[i]);
    self[i] = self[i + len];
  end;
  local _g = pos + len;
  local _g1 = self.length;
  while (_g < _g1) do 
    _g = _g + 1;
    local i = _g - 1;
    self[i] = self[i + len];
  end;
  self.length = self.length - len;
  do return ret end
end
Array.prototype.toString = function(self) 
  local tbl = ({});
  _G.table.insert(tbl, "[");
  _G.table.insert(tbl, self:join(","));
  _G.table.insert(tbl, "]");
  do return _G.table.concat(tbl, "") end
end
Array.prototype.unshift = function(self,x) 
  local len = self.length;
  local _g = 0;
  while (_g < len) do 
    _g = _g + 1;
    local i = _g - 1;
    self[len - i] = self[(len - i) - 1];
  end;
  self[0] = x;
end
Array.prototype.insert = function(self,pos,x) 
  if (pos > self.length) then 
    pos = self.length;
  end;
  if (pos < 0) then 
    pos = self.length + pos;
    if (pos < 0) then 
      pos = 0;
    end;
  end;
  local cur_len = self.length;
  while (cur_len > pos) do 
    self[cur_len] = self[cur_len - 1];
    cur_len = cur_len - 1;
  end;
  self[pos] = x;
end
Array.prototype.remove = function(self,x) 
  local _g = 0;
  local _g1 = self.length;
  while (_g < _g1) do 
    _g = _g + 1;
    local i = _g - 1;
    if (self[i] == x) then 
      local _g = i;
      local _g1 = self.length - 1;
      while (_g < _g1) do 
        _g = _g + 1;
        local j = _g - 1;
        self[j] = self[j + 1];
      end;
      self[self.length - 1] = nil;
      self.length = self.length - 1;
      do return true end;
    end;
  end;
  do return false end
end
Array.prototype.contains = function(self,x) 
  local _g = 0;
  local _g1 = self.length;
  while (_g < _g1) do 
    _g = _g + 1;
    if (self[_g - 1] == x) then 
      do return true end;
    end;
  end;
  do return false end
end
Array.prototype.indexOf = function(self,x,fromIndex) 
  local _end = self.length;
  if (fromIndex == nil) then 
    fromIndex = 0;
  else
    if (fromIndex < 0) then 
      fromIndex = self.length + fromIndex;
      if (fromIndex < 0) then 
        fromIndex = 0;
      end;
    end;
  end;
  local _g = fromIndex;
  while (_g < _end) do 
    _g = _g + 1;
    local i = _g - 1;
    if (x == self[i]) then 
      do return i end;
    end;
  end;
  do return -1 end
end
Array.prototype.lastIndexOf = function(self,x,fromIndex) 
  if ((fromIndex == nil) or (fromIndex >= self.length)) then 
    fromIndex = self.length - 1;
  else
    if (fromIndex < 0) then 
      fromIndex = self.length + fromIndex;
      if (fromIndex < 0) then 
        do return -1 end;
      end;
    end;
  end;
  local i = fromIndex;
  while (i >= 0) do 
    if (self[i] == x) then 
      do return i end;
    else
      i = i - 1;
    end;
  end;
  do return -1 end
end
Array.prototype.copy = function(self) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  while (_g1 < self.length) do 
    local i = self[_g1];
    _g1 = _g1 + 1;
    _g:push(i);
  end;
  do return _g end
end
Array.prototype.map = function(self,f) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  while (_g1 < self.length) do 
    local i = self[_g1];
    _g1 = _g1 + 1;
    _g:push(f(i));
  end;
  do return _g end
end
Array.prototype.filter = function(self,f) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  while (_g1 < self.length) do 
    local i = self[_g1];
    _g1 = _g1 + 1;
    if (f(i)) then 
      _g:push(i);
    end;
  end;
  do return _g end
end
Array.prototype.iterator = function(self) 
  do return __haxe_iterators_ArrayIterator.new(self) end
end
Array.prototype.keyValueIterator = function(self) 
  do return __haxe_iterators_ArrayKeyValueIterator.new(self) end
end
Array.prototype.resize = function(self,len) 
  if (self.length < len) then 
    self.length = len;
  else
    if (self.length > len) then 
      local _g = len;
      local _g1 = self.length;
      while (_g < _g1) do 
        _g = _g + 1;
        self[_g - 1] = nil;
      end;
      self.length = len;
    end;
  end;
end

Array.prototype.__class__ =  Array

Date.new = function(year,month,day,hour,min,sec) 
  local self = _hx_new(Date.prototype)
  Date.super(self,year,month,day,hour,min,sec)
  return self
end
Date.super = function(self,year,month,day,hour,min,sec) 
  self.t = _G.os.time(_hx_o({__fields__={year=true,month=true,day=true,hour=true,min=true,sec=true},year=year,month=month + 1,day=day,hour=hour,min=min,sec=sec}));
  self.d = _G.os.date("*t", self.t);
  self.dUTC = _G.os.date("!*t", self.t);
end
Date.__name__ = true
Date.prototype = _hx_e();
Date.prototype.d= nil;
Date.prototype.dUTC= nil;
Date.prototype.t= nil;
Date.prototype.getHours = function(self) 
  do return self.d.hour end
end
Date.prototype.getMinutes = function(self) 
  do return self.d.min end
end
Date.prototype.getSeconds = function(self) 
  do return self.d.sec end
end
Date.prototype.getFullYear = function(self) 
  do return self.d.year end
end
Date.prototype.getMonth = function(self) 
  do return self.d.month - 1 end
end
Date.prototype.getDate = function(self) 
  do return self.d.day end
end

Date.prototype.__class__ =  Date

Lambda.new = {}
Lambda.__name__ = true
Lambda.has = function(it,elt) 
  local x = it:iterator();
  while (x:hasNext()) do 
    if (x:next() == elt) then 
      do return true end;
    end;
  end;
  do return false end;
end

LuaLambdaKeys.new = {}
LuaLambdaKeys.__name__ = true
LuaLambdaKeys.fold = function(it,f,first) 
  local x = it;
  local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(x);
  local _g_lnext = _hx_1_p_next;
  local _hx_2_init_index, _hx_2_init_value = _g_lnext(x, _hx_1_p_index);
  local _g_nextV = _hx_2_init_value;
  local _g_nextI = _hx_2_init_index;
  while (_g_nextV ~= nil) do 
    local i = _g_nextI;
    local _hx_3_nextResult_index, _hx_3_nextResult_value = _g_lnext(x, _g_nextI);
    _g_nextI = _hx_3_nextResult_index;
    _g_nextV = _hx_3_nextResult_value;
    first = f(i, first);
  end;
  do return first end;
end

Math.new = {}
Math.__name__ = true
Math.isNaN = function(f) 
  do return f ~= f end;
end
Math.isFinite = function(f) 
  if (f > -_G.math.huge) then 
    do return f < _G.math.huge end;
  else
    do return false end;
  end;
end
Math.max = function(a,b) 
  if (Math.isNaN(a) or Math.isNaN(b)) then 
    do return (0/0) end;
  else
    do return _G.math.max(a, b) end;
  end;
end
Math.min = function(a,b) 
  if (Math.isNaN(a) or Math.isNaN(b)) then 
    do return (0/0) end;
  else
    do return _G.math.min(a, b) end;
  end;
end

Reflect.new = {}
Reflect.__name__ = true
Reflect.field = function(o,field) 
  if (_G.type(o) == "string") then 
    if (field == "length") then 
      do return _hx_wrap_if_string_field(o,'length') end;
    else
      do return String.prototype[field] end;
    end;
  else
    local _hx_status, _hx_result = pcall(function() 
    
        do return o[field] end;
      return _hx_pcall_default
    end)
    if not _hx_status and _hx_result == "_hx_pcall_break" then
    elseif not _hx_status then 
      local _g = _hx_result;
      do return nil end;
    elseif _hx_result ~= _hx_pcall_default then
      return _hx_result
    end;
  end;
end
Reflect.fields = function(o) 
  local _hx_continue_1 = false;
  while (true) do repeat 
    if (_G.type(o) == "string") then 
      o = String.prototype;
      break;
    else
      do return _hx_field_arr(o) end;
    end;until true
    if _hx_continue_1 then 
    _hx_continue_1 = false;
    break;
    end;
    
  end;
end
Reflect.isFunction = function(f) 
  if (_G.type(f) == "function") then 
    do return not ((function() 
      local _hx_1
      if (_G.type(f) ~= "table") then 
      _hx_1 = false; else 
      _hx_1 = f.__name__; end
      return _hx_1
    end )() or (function() 
      local _hx_2
      if (_G.type(f) ~= "table") then 
      _hx_2 = false; else 
      _hx_2 = f.__ename__; end
      return _hx_2
    end )()) end;
  else
    do return false end;
  end;
end

String.new = function(string) 
  local self = _hx_new(String.prototype)
  String.super(self,string)
  self = string
  return self
end
String.super = function(self,string) 
end
String.__name__ = true
String.__index = function(s,k) 
  if (k == "length") then 
    do return _G.string.len(s) end;
  else
    local o = String.prototype;
    local field = k;
    if ((function() 
      local _hx_1
      if ((_G.type(o) == "string") and ((String.prototype[field] ~= nil) or (field == "length"))) then 
      _hx_1 = true; elseif (o.__fields__ ~= nil) then 
      _hx_1 = o.__fields__[field] ~= nil; else 
      _hx_1 = o[field] ~= nil; end
      return _hx_1
    end )()) then 
      do return String.prototype[k] end;
    else
      if (String.__oldindex ~= nil) then 
        if (_G.type(String.__oldindex) == "function") then 
          do return String.__oldindex(s, k) end;
        else
          if (_G.type(String.__oldindex) == "table") then 
            do return String.__oldindex[k] end;
          end;
        end;
        do return nil end;
      else
        do return nil end;
      end;
    end;
  end;
end
String.indexOfEmpty = function(s,startIndex) 
  local length = _G.string.len(s);
  if (startIndex < 0) then 
    startIndex = length + startIndex;
    if (startIndex < 0) then 
      startIndex = 0;
    end;
  end;
  if (startIndex > length) then 
    do return length end;
  else
    do return startIndex end;
  end;
end
String.fromCharCode = function(code) 
  do return _G.string.char(code) end;
end
String.prototype = _hx_e();
String.prototype.length= nil;
String.prototype.toUpperCase = function(self) 
  do return _G.string.upper(self) end
end
String.prototype.toLowerCase = function(self) 
  do return _G.string.lower(self) end
end
String.prototype.indexOf = function(self,str,startIndex) 
  if (startIndex == nil) then 
    startIndex = 1;
  else
    startIndex = startIndex + 1;
  end;
  if (str == "") then 
    do return String.indexOfEmpty(self, startIndex - 1) end;
  end;
  local r = _G.string.find(self, str, startIndex, true);
  if ((r ~= nil) and (r > 0)) then 
    do return r - 1 end;
  else
    do return -1 end;
  end;
end
String.prototype.lastIndexOf = function(self,str,startIndex) 
  local ret = -1;
  if (startIndex == nil) then 
    startIndex = #self;
  end;
  while (true) do 
    local startIndex1 = ret + 1;
    if (startIndex1 == nil) then 
      startIndex1 = 1;
    else
      startIndex1 = startIndex1 + 1;
    end;
    local p;
    if (str == "") then 
      p = String.indexOfEmpty(self, startIndex1 - 1);
    else
      local r = _G.string.find(self, str, startIndex1, true);
      p = (function() 
        local _hx_1
        if ((r ~= nil) and (r > 0)) then 
        _hx_1 = r - 1; else 
        _hx_1 = -1; end
        return _hx_1
      end )();
    end;
    if (((p == -1) or (p > startIndex)) or (p == ret)) then 
      break;
    end;
    ret = p;
  end;
  do return ret end
end
String.prototype.split = function(self,delimiter) 
  local idx = 1;
  local ret = _hx_tab_array({}, 0);
  while (idx ~= nil) do 
    local newidx = 0;
    if (#delimiter > 0) then 
      newidx = _G.string.find(self, delimiter, idx, true);
    else
      if (idx >= #self) then 
        newidx = nil;
      else
        newidx = idx + 1;
      end;
    end;
    if (newidx ~= nil) then 
      ret:push(_G.string.sub(self, idx, newidx - 1));
      idx = newidx + #delimiter;
    else
      ret:push(_G.string.sub(self, idx, #self));
      idx = nil;
    end;
  end;
  do return ret end
end
String.prototype.toString = function(self) 
  do return self end
end
String.prototype.substring = function(self,startIndex,endIndex) 
  if (endIndex == nil) then 
    endIndex = #self;
  end;
  if (endIndex < 0) then 
    endIndex = 0;
  end;
  if (startIndex < 0) then 
    startIndex = 0;
  end;
  if (endIndex < startIndex) then 
    do return _G.string.sub(self, endIndex + 1, startIndex) end;
  else
    do return _G.string.sub(self, startIndex + 1, endIndex) end;
  end;
end
String.prototype.charAt = function(self,index) 
  do return _G.string.sub(self, index + 1, index + 1) end
end
String.prototype.charCodeAt = function(self,index) 
  do return _G.string.byte(self, index + 1) end
end
String.prototype.substr = function(self,pos,len) 
  if ((len == nil) or (len > (pos + #self))) then 
    len = #self;
  else
    if (len < 0) then 
      len = #self + len;
    end;
  end;
  if (pos < 0) then 
    pos = #self + pos;
  end;
  if (pos < 0) then 
    pos = 0;
  end;
  do return _G.string.sub(self, pos + 1, pos + len) end
end

String.prototype.__class__ =  String

Std.new = {}
Std.__name__ = true
Std.string = function(s) 
  do return _hx_tostring(s, 0) end;
end
Std.int = function(x) 
  if (not Math.isFinite(x) or Math.isNaN(x)) then 
    do return 0 end;
  else
    do return _hx_bit_clamp(x) end;
  end;
end
Std.parseInt = function(x) 
  if (x == nil) then 
    do return nil end;
  end;
  local hexMatch = _G.string.match(x, "^[ \t\r\n]*([%-+]*0[xX][%da-fA-F]*)");
  if (hexMatch ~= nil) then 
    local sign;
    local _g = _G.string.byte(hexMatch, 1);
    if (_g) == 43 then 
      sign = 1;
    elseif (_g) == 45 then 
      sign = -1;else
    sign = 0; end;
    local pos = (function() 
      local _hx_1
      if (sign == 0) then 
      _hx_1 = 2; else 
      _hx_1 = 3; end
      return _hx_1
    end )();
    local len = nil;
    len = #hexMatch;
    if (pos < 0) then 
      pos = #hexMatch + pos;
    end;
    if (pos < 0) then 
      pos = 0;
    end;
    do return (function() 
      local _hx_2
      if (sign == -1) then 
      _hx_2 = -1; else 
      _hx_2 = 1; end
      return _hx_2
    end )() * _G.tonumber(_G.string.sub(hexMatch, pos + 1, pos + len), 16) end;
  else
    local intMatch = _G.string.match(x, "^ *[%-+]?%d*");
    if (intMatch ~= nil) then 
      do return _G.tonumber(intMatch) end;
    else
      do return nil end;
    end;
  end;
end
Std.parseFloat = function(x) 
  if ((x == nil) or (x == "")) then 
    do return (0/0) end;
  end;
  local digitMatch = _G.string.match(x, "^ *[%.%-+]?[0-9]%d*");
  if (digitMatch == nil) then 
    do return (0/0) end;
  end;
  local pos = #digitMatch;
  local len = nil;
  if ((len == nil) or (len > (pos + #x))) then 
    len = #x;
  else
    if (len < 0) then 
      len = #x + len;
    end;
  end;
  if (pos < 0) then 
    pos = #x + pos;
  end;
  if (pos < 0) then 
    pos = 0;
  end;
  x = _G.string.sub(x, pos + 1, pos + len);
  local decimalMatch = _G.string.match(x, "^%.%d*");
  if (decimalMatch == nil) then 
    decimalMatch = "";
  end;
  local pos = #decimalMatch;
  local len = nil;
  if ((len == nil) or (len > (pos + #x))) then 
    len = #x;
  else
    if (len < 0) then 
      len = #x + len;
    end;
  end;
  if (pos < 0) then 
    pos = #x + pos;
  end;
  if (pos < 0) then 
    pos = 0;
  end;
  x = _G.string.sub(x, pos + 1, pos + len);
  local eMatch = _G.string.match(x, "^[eE][+%-]?%d+");
  if (eMatch == nil) then 
    eMatch = "";
  end;
  local result = _G.tonumber(Std.string(Std.string(digitMatch) .. Std.string(decimalMatch)) .. Std.string(eMatch));
  if (result ~= nil) then 
    do return result end;
  else
    do return (0/0) end;
  end;
end

StringBuf.new = function() 
  local self = _hx_new(StringBuf.prototype)
  StringBuf.super(self)
  return self
end
StringBuf.super = function(self) 
  self.b = ({});
  self.length = 0;
end
StringBuf.__name__ = true
StringBuf.prototype = _hx_e();
StringBuf.prototype.b= nil;
StringBuf.prototype.length= nil;

StringBuf.prototype.__class__ =  StringBuf

StringTools.new = {}
StringTools.__name__ = true
StringTools.lpad = function(s,c,l) 
  if (#c <= 0) then 
    do return s end;
  end;
  local buf_b = ({});
  local buf_length = 0;
  l = l - #s;
  while (buf_length < l) do 
    local str = Std.string(c);
    _G.table.insert(buf_b, str);
    buf_length = buf_length + #str;
  end;
  _G.table.insert(buf_b, Std.string(s));
  do return _G.table.concat(buf_b) end;
end
StringTools.replace = function(s,sub,by) 
  local idx = 1;
  local ret = _hx_tab_array({}, 0);
  while (idx ~= nil) do 
    local newidx = 0;
    if (#sub > 0) then 
      newidx = _G.string.find(s, sub, idx, true);
    else
      if (idx >= #s) then 
        newidx = nil;
      else
        newidx = idx + 1;
      end;
    end;
    if (newidx ~= nil) then 
      ret:push(_G.string.sub(s, idx, newidx - 1));
      idx = newidx + #sub;
    else
      ret:push(_G.string.sub(s, idx, #s));
      idx = nil;
    end;
  end;
  do return ret:join(by) end;
end

Sys.new = {}
Sys.__name__ = true
Sys.time = function() 
  do return _G.SysTime() end;
end
_hxClasses["ValueType"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"},9)}
ValueType = _hxClasses["ValueType"];
ValueType.TNull = _hx_tab_array({[0]="TNull",0,__enum__ = ValueType},2)

ValueType.TInt = _hx_tab_array({[0]="TInt",1,__enum__ = ValueType},2)

ValueType.TFloat = _hx_tab_array({[0]="TFloat",2,__enum__ = ValueType},2)

ValueType.TBool = _hx_tab_array({[0]="TBool",3,__enum__ = ValueType},2)

ValueType.TObject = _hx_tab_array({[0]="TObject",4,__enum__ = ValueType},2)

ValueType.TFunction = _hx_tab_array({[0]="TFunction",5,__enum__ = ValueType},2)

ValueType.TClass = function(c) local _x = _hx_tab_array({[0]="TClass",6,c,__enum__=ValueType}, 3); return _x; end 
ValueType.TEnum = function(e) local _x = _hx_tab_array({[0]="TEnum",7,e,__enum__=ValueType}, 3); return _x; end 
ValueType.TUnknown = _hx_tab_array({[0]="TUnknown",8,__enum__ = ValueType},2)


Type.new = {}
Type.__name__ = true
Type.getClass = function(o) 
  if (o == nil) then 
    do return nil end;
  end;
  local o = o;
  if (__lua_Boot.__instanceof(o, Array)) then 
    do return Array end;
  else
    if (__lua_Boot.__instanceof(o, String)) then 
      do return String end;
    else
      local cl = o.__class__;
      if (cl ~= nil) then 
        do return cl end;
      else
        do return nil end;
      end;
    end;
  end;
end
Type.getInstanceFields = function(c) 
  local p = c.prototype;
  local a = _hx_tab_array({}, 0);
  while (p ~= nil) do 
    local _g = 0;
    local _g1 = Reflect.fields(p);
    while (_g < _g1.length) do 
      local f = _g1[_g];
      _g = _g + 1;
      if (not Lambda.has(a, f)) then 
        a:push(f);
      end;
    end;
    local mt = _G.getmetatable(p);
    if ((mt ~= nil) and (mt.__index ~= nil)) then 
      p = mt.__index;
    else
      p = nil;
    end;
  end;
  do return a end;
end
Type.typeof = function(v) 
  local _g = _G.type(v);
  if (_g) == "boolean" then 
    do return ValueType.TBool end;
  elseif (_g) == "function" then 
    if ((function() 
      local _hx_1
      if (_G.type(v) ~= "table") then 
      _hx_1 = false; else 
      _hx_1 = v.__name__; end
      return _hx_1
    end )() or (function() 
      local _hx_2
      if (_G.type(v) ~= "table") then 
      _hx_2 = false; else 
      _hx_2 = v.__ename__; end
      return _hx_2
    end )()) then 
      do return ValueType.TObject end;
    end;
    do return ValueType.TFunction end;
  elseif (_g) == "nil" then 
    do return ValueType.TNull end;
  elseif (_g) == "number" then 
    if (_G.math.ceil(v) == (_G.math.fmod(v, 2147483648.0))) then 
      do return ValueType.TInt end;
    end;
    do return ValueType.TFloat end;
  elseif (_g) == "string" then 
    do return ValueType.TClass(String) end;
  elseif (_g) == "table" then 
    local e = v.__enum__;
    if (e ~= nil) then 
      do return ValueType.TEnum(e) end;
    end;
    local c;
    if (__lua_Boot.__instanceof(v, Array)) then 
      c = Array;
    else
      if (__lua_Boot.__instanceof(v, String)) then 
        c = String;
      else
        local cl = v.__class__;
        c = (function() 
          local _hx_3
          if (cl ~= nil) then 
          _hx_3 = cl; else 
          _hx_3 = nil; end
          return _hx_3
        end )();
      end;
    end;
    if (c ~= nil) then 
      do return ValueType.TClass(c) end;
    end;
    do return ValueType.TObject end;else
  do return ValueType.TUnknown end; end;
end

__haxe_io_Path.new = function(path) 
  local self = _hx_new(__haxe_io_Path.prototype)
  __haxe_io_Path.super(self,path)
  return self
end
__haxe_io_Path.super = function(self,path) 
  local path1 = path;
  if (path1) == "." or (path1) == ".." then 
    self.dir = path;
    self.file = "";
    do return end; end;
  local startIndex = nil;
  local ret = -1;
  startIndex = #path;
  while (true) do 
    local startIndex1 = ret + 1;
    if (startIndex1 == nil) then 
      startIndex1 = 1;
    else
      startIndex1 = startIndex1 + 1;
    end;
    local r = _G.string.find(path, "/", startIndex1, true);
    local p = (function() 
      local _hx_1
      if ((r ~= nil) and (r > 0)) then 
      _hx_1 = r - 1; else 
      _hx_1 = -1; end
      return _hx_1
    end )();
    if (((p == -1) or (p > startIndex)) or (p == ret)) then 
      break;
    end;
    ret = p;
  end;
  local c1 = ret;
  local startIndex = nil;
  local ret = -1;
  startIndex = #path;
  while (true) do 
    local startIndex1 = ret + 1;
    if (startIndex1 == nil) then 
      startIndex1 = 1;
    else
      startIndex1 = startIndex1 + 1;
    end;
    local r = _G.string.find(path, "\\", startIndex1, true);
    local p = (function() 
      local _hx_2
      if ((r ~= nil) and (r > 0)) then 
      _hx_2 = r - 1; else 
      _hx_2 = -1; end
      return _hx_2
    end )();
    if (((p == -1) or (p > startIndex)) or (p == ret)) then 
      break;
    end;
    ret = p;
  end;
  local c2 = ret;
  if (c1 < c2) then 
    local len = c2;
    if ((c2 == nil) or (c2 > #path)) then 
      len = #path;
    else
      if (c2 < 0) then 
        len = #path + c2;
      end;
    end;
    self.dir = _G.string.sub(path, 1, len);
    local pos = c2 + 1;
    local len = nil;
    len = #path;
    if (pos < 0) then 
      pos = #path + pos;
    end;
    if (pos < 0) then 
      pos = 0;
    end;
    path = _G.string.sub(path, pos + 1, pos + len);
    self.backslash = true;
  else
    if (c2 < c1) then 
      local len = c1;
      if ((c1 == nil) or (c1 > #path)) then 
        len = #path;
      else
        if (c1 < 0) then 
          len = #path + c1;
        end;
      end;
      self.dir = _G.string.sub(path, 1, len);
      local pos = c1 + 1;
      local len = nil;
      len = #path;
      if (pos < 0) then 
        pos = #path + pos;
      end;
      if (pos < 0) then 
        pos = 0;
      end;
      path = _G.string.sub(path, pos + 1, pos + len);
    else
      self.dir = nil;
    end;
  end;
  local startIndex = nil;
  local ret = -1;
  startIndex = #path;
  while (true) do 
    local startIndex1 = ret + 1;
    if (startIndex1 == nil) then 
      startIndex1 = 1;
    else
      startIndex1 = startIndex1 + 1;
    end;
    local r = _G.string.find(path, ".", startIndex1, true);
    local p = (function() 
      local _hx_3
      if ((r ~= nil) and (r > 0)) then 
      _hx_3 = r - 1; else 
      _hx_3 = -1; end
      return _hx_3
    end )();
    if (((p == -1) or (p > startIndex)) or (p == ret)) then 
      break;
    end;
    ret = p;
  end;
  local cp = ret;
  if (cp ~= -1) then 
    local pos = cp + 1;
    local len = nil;
    len = #path;
    if (pos < 0) then 
      pos = #path + pos;
    end;
    if (pos < 0) then 
      pos = 0;
    end;
    self.ext = _G.string.sub(path, pos + 1, pos + len);
    local len = cp;
    if ((cp == nil) or (cp > #path)) then 
      len = #path;
    else
      if (cp < 0) then 
        len = #path + cp;
      end;
    end;
    self.file = _G.string.sub(path, 1, len);
  else
    self.ext = nil;
    self.file = path;
  end;
end
__haxe_io_Path.__name__ = true
__haxe_io_Path.directory = function(path) 
  local s = __haxe_io_Path.new(path);
  if (s.dir == nil) then 
    do return "" end;
  end;
  do return s.dir end;
end
__haxe_io_Path.join = function(paths) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  while (_g1 < paths.length) do 
    local i = paths[_g1];
    _g1 = _g1 + 1;
    if ((i ~= nil) and (i ~= "")) then 
      _g:push(i);
    end;
  end;
  if (_g.length == 0) then 
    do return "" end;
  end;
  local path = _g[0];
  local _g1 = 1;
  local _g2 = _g.length;
  while (_g1 < _g2) do 
    _g1 = _g1 + 1;
    path = __haxe_io_Path.addTrailingSlash(path);
    path = Std.string(path) .. Std.string(_g[_g1 - 1]);
  end;
  do return __haxe_io_Path.normalize(path) end;
end
__haxe_io_Path.normalize = function(path) 
  local idx = 1;
  local ret = _hx_tab_array({}, 0);
  while (idx ~= nil) do 
    local newidx = 0;
    if (#"\\" > 0) then 
      newidx = _G.string.find(path, "\\", idx, true);
    else
      if (idx >= #path) then 
        newidx = nil;
      else
        newidx = idx + 1;
      end;
    end;
    if (newidx ~= nil) then 
      ret:push(_G.string.sub(path, idx, newidx - 1));
      idx = newidx + #"\\";
    else
      ret:push(_G.string.sub(path, idx, #path));
      idx = nil;
    end;
  end;
  path = ret:join("/");
  if (path == "/") then 
    do return "/" end;
  end;
  local target = _hx_tab_array({}, 0);
  local _g = 0;
  local idx = 1;
  local ret = _hx_tab_array({}, 0);
  while (idx ~= nil) do 
    local newidx = 0;
    if (#"/" > 0) then 
      newidx = _G.string.find(path, "/", idx, true);
    else
      if (idx >= #path) then 
        newidx = nil;
      else
        newidx = idx + 1;
      end;
    end;
    if (newidx ~= nil) then 
      ret:push(_G.string.sub(path, idx, newidx - 1));
      idx = newidx + #"/";
    else
      ret:push(_G.string.sub(path, idx, #path));
      idx = nil;
    end;
  end;
  while (_g < ret.length) do 
    local token = ret[_g];
    _g = _g + 1;
    if (((token == "..") and (target.length > 0)) and (target[target.length - 1] ~= "..")) then 
      target:pop();
    else
      if (token == "") then 
        if ((target.length > 0) or (_G.string.byte(path, 1) == 47)) then 
          target:push(token);
        end;
      else
        if (token ~= ".") then 
          target:push(token);
        end;
      end;
    end;
  end;
  local tmp = target:join("/");
  local acc_b = ({});
  local colon = false;
  local slashes = false;
  local _g = 0;
  local _g1 = #tmp;
  while (_g < _g1) do 
    _g = _g + 1;
    local _g = _G.string.byte(tmp, (_g - 1) + 1);
    if (_g) == 47 then 
      if (not colon) then 
        slashes = true;
      else
        colon = false;
        if (slashes) then 
          _G.table.insert(acc_b, "/");
          slashes = false;
        end;
        _G.table.insert(acc_b, _G.string.char(_g));
      end;
    elseif (_g) == 58 then 
      _G.table.insert(acc_b, ":");
      colon = true;else
    colon = false;
    if (slashes) then 
      _G.table.insert(acc_b, "/");
      slashes = false;
    end;
    _G.table.insert(acc_b, _G.string.char(_g)); end;
  end;
  do return _G.table.concat(acc_b) end;
end
__haxe_io_Path.addTrailingSlash = function(path) 
  if (#path == 0) then 
    do return "/" end;
  end;
  local startIndex = nil;
  local ret = -1;
  startIndex = #path;
  while (true) do 
    local startIndex1 = ret + 1;
    if (startIndex1 == nil) then 
      startIndex1 = 1;
    else
      startIndex1 = startIndex1 + 1;
    end;
    local r = _G.string.find(path, "/", startIndex1, true);
    local p = (function() 
      local _hx_1
      if ((r ~= nil) and (r > 0)) then 
      _hx_1 = r - 1; else 
      _hx_1 = -1; end
      return _hx_1
    end )();
    if (((p == -1) or (p > startIndex)) or (p == ret)) then 
      break;
    end;
    ret = p;
  end;
  local c1 = ret;
  local startIndex = nil;
  local ret = -1;
  startIndex = #path;
  while (true) do 
    local startIndex1 = ret + 1;
    if (startIndex1 == nil) then 
      startIndex1 = 1;
    else
      startIndex1 = startIndex1 + 1;
    end;
    local r = _G.string.find(path, "\\", startIndex1, true);
    local p = (function() 
      local _hx_2
      if ((r ~= nil) and (r > 0)) then 
      _hx_2 = r - 1; else 
      _hx_2 = -1; end
      return _hx_2
    end )();
    if (((p == -1) or (p > startIndex)) or (p == ret)) then 
      break;
    end;
    ret = p;
  end;
  local c2 = ret;
  if (c1 < c2) then 
    if (c2 ~= (#path - 1)) then 
      do return Std.string(path) .. Std.string("\\") end;
    else
      do return path end;
    end;
  else
    if (c1 ~= (#path - 1)) then 
      do return Std.string(path) .. Std.string("/") end;
    else
      do return path end;
    end;
  end;
end
__haxe_io_Path.prototype = _hx_e();
__haxe_io_Path.prototype.dir= nil;
__haxe_io_Path.prototype.file= nil;
__haxe_io_Path.prototype.ext= nil;
__haxe_io_Path.prototype.backslash= nil;
__haxe_io_Path.prototype.toString = function(self) 
  do return Std.string(Std.string(((function() 
    local _hx_1
    if (self.dir == nil) then 
    _hx_1 = ""; else 
    _hx_1 = Std.string(self.dir) .. Std.string(((function() 
      local _hx_2
      if (self.backslash) then 
      _hx_2 = "\\"; else 
      _hx_2 = "/"; end
      return _hx_2
    end )())); end
    return _hx_1
  end )())) .. Std.string(self.file)) .. Std.string(((function() 
    local _hx_3
    if (self.ext == nil) then 
    _hx_3 = ""; else 
    _hx_3 = Std.string(".") .. Std.string(self.ext); end
    return _hx_3
  end )())) end
end

__haxe_io_Path.prototype.__class__ =  __haxe_io_Path

__gmdebug_Cross.new = {}
__gmdebug_Cross.__name__ = true
__gmdebug_Cross.readHeader = function(x) 
  local raw_content = x:readLine();
  local skip = 0;
  local onlySkipped = true;
  local _g = 0;
  local _g1 = #raw_content;
  while (_g < _g1) do 
    _g = _g + 1;
    if (_G.string.byte(raw_content, (_g - 1) + 1) == 4) then 
      skip = skip + 1;
    else
      onlySkipped = false;
      break;
    end;
  end;
  if (onlySkipped) then 
    do return nil end;
  end;
  if (skip > 0) then 
    local pos = skip;
    local len = nil;
    len = #raw_content;
    if (pos < 0) then 
      pos = #raw_content + pos;
    end;
    if (pos < 0) then 
      pos = 0;
    end;
    raw_content = _G.string.sub(raw_content, pos + 1, pos + len);
  end;
  local len = nil;
  len = #raw_content;
  local content_length = Std.parseInt(_G.string.sub(raw_content, 16, 15 + len));
  x:readLine();
  do return content_length end;
end
__gmdebug_Cross.recvMessage = function(x) 
  local len = __gmdebug_Cross.readHeader(x);
  if (len == nil) then 
    do return __gmdebug_MessageResult.ACK end;
  end;
  do return __gmdebug_MessageResult.MESSAGE(__haxe_Json.parse(x:readString(len, __haxe_io_Encoding.UTF8))) end;
end
_hxClasses["gmdebug.MessageResult"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="ACK","MESSAGE"},2)}
__gmdebug_MessageResult = _hxClasses["gmdebug.MessageResult"];
__gmdebug_MessageResult.ACK = _hx_tab_array({[0]="ACK",0,__enum__ = __gmdebug_MessageResult},2)

__gmdebug_MessageResult.MESSAGE = function(x) local _x = _hx_tab_array({[0]="MESSAGE",1,x,__enum__=__gmdebug_MessageResult}, 3); return _x; end 

__gmdebug__FrameID_FrameID_Impl_.new = {}
__gmdebug__FrameID_FrameID_Impl_.__name__ = true
__gmdebug__FrameID_FrameID_Impl_.getValue = function(this1) 
  do return _hx_o({__fields__={clientID=true,actualFrame=true},clientID=_hx_bit.rshift(this1,27),actualFrame=_hx_bit.band(this1,134217727)}) end;
end
_hxClasses["gmdebug.VariableReferenceVal"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="Child","FrameLocal","Global"},3)}
__gmdebug_VariableReferenceVal = _hxClasses["gmdebug.VariableReferenceVal"];
__gmdebug_VariableReferenceVal.Child = function(clientID,ref) local _x = _hx_tab_array({[0]="Child",0,clientID,ref,__enum__=__gmdebug_VariableReferenceVal}, 4); return _x; end 
__gmdebug_VariableReferenceVal.FrameLocal = function(clientID,frameID,ref) local _x = _hx_tab_array({[0]="FrameLocal",1,clientID,frameID,ref,__enum__=__gmdebug_VariableReferenceVal}, 5); return _x; end 
__gmdebug_VariableReferenceVal.Global = function(clientID,ref) local _x = _hx_tab_array({[0]="Global",2,clientID,ref,__enum__=__gmdebug_VariableReferenceVal}, 4); return _x; end 

__gmdebug__VariableReference_VariableReference_Impl_.new = {}
__gmdebug__VariableReference_VariableReference_Impl_.__name__ = true
__gmdebug__VariableReference_VariableReference_Impl_.getValue = function(this1) 
  local clientID = _hx_bit.band(_hx_bit.rshift(this1,25),15);
  local ref = _hx_bit.band(_hx_bit.rshift(this1,29),3);
  if (ref) == 0 then 
    do return __gmdebug_VariableReferenceVal.Child(clientID, _hx_bit.band(this1,16777215)) end;
  elseif (ref) == 1 then 
    do return __gmdebug_VariableReferenceVal.FrameLocal(clientID, _hx_bit.band(_hx_bit.rshift(this1,8),131071), _hx_bit.band(this1,255)) end;
  elseif (ref) == 2 then 
    do return __gmdebug_VariableReferenceVal.Global(clientID, _hx_bit.band(this1,16777215)) end; end;
end
__gmdebug__VariableReference_VariableReference_Impl_.encode = function(x) 
  local val = _hx_bit.lshift(x[1],29);
  local tmp = x[1];
  if (tmp) == 0 then 
    local _g = x[3];
    local ref = _g;
    val = _hx_bit.bor(val,_hx_bit.lshift(x[2],25));
    ref = _g + 1;
    do return _hx_bit.bor(val,ref - 1) end;
  elseif (tmp) == 1 then 
    local _g = x[4];
    local ref = _g;
    val = _hx_bit.bor(val,_hx_bit.lshift(x[2],25));
    val = _hx_bit.bor(val,_hx_bit.lshift(x[3],8));
    ref = _g + 1;
    do return _hx_bit.bor(val,ref - 1) end;
  elseif (tmp) == 2 then 
    local _g = x[3];
    local ref = _g;
    val = _hx_bit.bor(val,_hx_bit.lshift(x[2],25));
    ref = _g + 1;
    do return _hx_bit.bor(val,ref - 1) end; end;
end

__gmdebug_composer_ComposeTools.new = {}
__gmdebug_composer_ComposeTools.__name__ = true
__gmdebug_composer_ComposeTools.compose = function(req,str,body) 
  local response = __gmdebug_composer_ComposedResponse.new(req, body);
  response.success = true;
  do return response end;
end
__gmdebug_composer_ComposeTools.composeFail = function(req,rawerror,error) 
  local response = __gmdebug_composer_ComposedResponse.new(req, error);
  response.message = rawerror;
  response.success = false;
  do return response end;
end

__gmdebug_composer_ComposedProtocolMessage.new = function(_type) 
  local self = _hx_new(__gmdebug_composer_ComposedProtocolMessage.prototype)
  __gmdebug_composer_ComposedProtocolMessage.super(self,_type)
  return self
end
__gmdebug_composer_ComposedProtocolMessage.super = function(self,_type) 
  self.type = _type;
end
__gmdebug_composer_ComposedProtocolMessage.__name__ = true
__gmdebug_composer_ComposedProtocolMessage.prototype = _hx_e();
__gmdebug_composer_ComposedProtocolMessage.prototype.type= nil;

__gmdebug_composer_ComposedProtocolMessage.prototype.__class__ =  __gmdebug_composer_ComposedProtocolMessage

__gmdebug_composer_ComposedEvent.new = function(str,body) 
  local self = _hx_new(__gmdebug_composer_ComposedEvent.prototype)
  __gmdebug_composer_ComposedEvent.super(self,str,body)
  return self
end
__gmdebug_composer_ComposedEvent.super = function(self,str,body) 
  __gmdebug_composer_ComposedProtocolMessage.super(self,"event");
  self.event = str;
  self.body = body;
end
__gmdebug_composer_ComposedEvent.__name__ = true
__gmdebug_composer_ComposedEvent.prototype = _hx_e();
__gmdebug_composer_ComposedEvent.prototype.event= nil;
__gmdebug_composer_ComposedEvent.prototype.body= nil;

__gmdebug_composer_ComposedEvent.prototype.__class__ =  __gmdebug_composer_ComposedEvent
__gmdebug_composer_ComposedEvent.__super__ = __gmdebug_composer_ComposedProtocolMessage
setmetatable(__gmdebug_composer_ComposedEvent.prototype,{__index=__gmdebug_composer_ComposedProtocolMessage.prototype})

__gmdebug_composer_ComposedGmDebugMessage.new = function(msg,body) 
  local self = _hx_new(__gmdebug_composer_ComposedGmDebugMessage.prototype)
  __gmdebug_composer_ComposedGmDebugMessage.super(self,msg,body)
  return self
end
__gmdebug_composer_ComposedGmDebugMessage.super = function(self,msg,body) 
  __gmdebug_composer_ComposedProtocolMessage.super(self,"gmdebug");
  self.msg = msg;
  self.body = body;
end
__gmdebug_composer_ComposedGmDebugMessage.__name__ = true
__gmdebug_composer_ComposedGmDebugMessage.prototype = _hx_e();
__gmdebug_composer_ComposedGmDebugMessage.prototype.msg= nil;
__gmdebug_composer_ComposedGmDebugMessage.prototype.body= nil;

__gmdebug_composer_ComposedGmDebugMessage.prototype.__class__ =  __gmdebug_composer_ComposedGmDebugMessage
__gmdebug_composer_ComposedGmDebugMessage.__super__ = __gmdebug_composer_ComposedProtocolMessage
setmetatable(__gmdebug_composer_ComposedGmDebugMessage.prototype,{__index=__gmdebug_composer_ComposedProtocolMessage.prototype})

__gmdebug_composer_ComposedResponse.new = function(req,body) 
  local self = _hx_new(__gmdebug_composer_ComposedResponse.prototype)
  __gmdebug_composer_ComposedResponse.super(self,req,body)
  return self
end
__gmdebug_composer_ComposedResponse.super = function(self,req,body) 
  self.success = true;
  __gmdebug_composer_ComposedProtocolMessage.super(self,"response");
  self.request_seq = _hx_funcToField(req.seq);
  self.command = _hx_funcToField(req.command);
  self.body = body;
end
__gmdebug_composer_ComposedResponse.__name__ = true
__gmdebug_composer_ComposedResponse.prototype = _hx_e();
__gmdebug_composer_ComposedResponse.prototype.request_seq= nil;
__gmdebug_composer_ComposedResponse.prototype.success= nil;
__gmdebug_composer_ComposedResponse.prototype.command= nil;
__gmdebug_composer_ComposedResponse.prototype.message= nil;
__gmdebug_composer_ComposedResponse.prototype.body= nil;

__gmdebug_composer_ComposedResponse.prototype.__class__ =  __gmdebug_composer_ComposedResponse
__gmdebug_composer_ComposedResponse.__super__ = __gmdebug_composer_ComposedProtocolMessage
setmetatable(__gmdebug_composer_ComposedResponse.prototype,{__index=__gmdebug_composer_ComposedProtocolMessage.prototype})

__gmdebug_lua_CustomHandlers.new = function(initCustomHandlers) 
  local self = _hx_new(__gmdebug_lua_CustomHandlers.prototype)
  __gmdebug_lua_CustomHandlers.super(self,initCustomHandlers)
  return self
end
__gmdebug_lua_CustomHandlers.super = function(self,initCustomHandlers) 
  self.debugee = _hx_funcToField(initCustomHandlers.debugee);
end
__gmdebug_lua_CustomHandlers.__name__ = true
__gmdebug_lua_CustomHandlers.prototype = _hx_e();
__gmdebug_lua_CustomHandlers.prototype.debugee= nil;
__gmdebug_lua_CustomHandlers.prototype.handle = function(self,x) 
  local _g = x.msg;
  if (_g) == 0 or (_g) == 1 or (_g) == 4 then 
    _G.error(__haxe_Exception.thrown("dur"),0);
  elseif (_g) == 2 then 
    self:h_clientID(x);
  elseif (_g) == 3 then 
    self:h_initalInfo(x); end;
end
__gmdebug_lua_CustomHandlers.prototype.h_clientID = function(self,x) 
  __haxe_Log.trace(Std.string("recieved id ") .. Std.string(x.body.id), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/CustomHandlers.hx",lineNumber=33,className="gmdebug.lua.CustomHandlers",methodName="h_clientID"}));
  self.debugee.clientID = _hx_funcToField(x.body.id);
end
__gmdebug_lua_CustomHandlers.prototype.h_initalInfo = function(self,x) 
  self.debugee.dest = _hx_funcToField(x.body.location);
  if (x.body.dapMode == "Launch") then 
    local _this = self.debugee;
    __haxe_Json.stringify(__gmdebug_composer_ComposedGmDebugMessage.new(4, _hx_o({__fields__={ip=true,isLan=true},ip=_G.game.GetIPAddress(),isLan=__gmdebug_lua_util__Util_Util_Fields_.isLan()})));
    local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
    _this.socket.output:writeString(str);
    _this.socket.output:flush();
    self.debugee.dapMode = "Launch";
  else
    self.debugee.dapMode = "Attach";
  end;
end

__gmdebug_lua_CustomHandlers.prototype.__class__ =  __gmdebug_lua_CustomHandlers

__gmdebug_lua__DebugHook_DDebugHook.new = {}
_hx_exports["DebugHook"] = __gmdebug_lua__DebugHook_DDebugHook
__gmdebug_lua__DebugHook_DDebugHook.__name__ = true
__gmdebug_lua__DebugHook_DDebugHook.getHooks = function() 
  local value = _G.DebugHook.hooks;
  if (value == nil) then 
    do return __haxe_ds_StringMap.new() end;
  else
    do return value end;
  end;
end
__gmdebug_lua__DebugHook_DDebugHook.addHook = function(ident,fun,str) 
  if (str == nil) then 
    str = "";
  end;
  if (fun == nil) then 
    fun = function(a,b) 
      do return end;
    end;
  end;
  if (__gmdebug_lua__DebugHook_DDebugHook.hooks.h[ident] == nil) then 
    local value = _hx_o({__fields__={flagsMap=true,fun=true},flagsMap=__haxe_ds_IntMap.new(),fun=fun});
    local _this = __gmdebug_lua__DebugHook_DDebugHook.hooks;
    if (value == nil) then 
      _this.h[ident] = __haxe_ds_StringMap.tnull;
    else
      _this.h[ident] = value;
    end;
  end;
  local ret = __gmdebug_lua__DebugHook_DDebugHook.hooks.h[ident];
  if (ret == __haxe_ds_StringMap.tnull) then 
    ret = nil;
  end;
  ret.fun = fun;
  local ret = __gmdebug_lua__DebugHook_DDebugHook.hooks.h[ident];
  if (ret == __haxe_ds_StringMap.tnull) then 
    ret = nil;
  end;
  local flagMap = ret.flagsMap;
  local r = _G.string.find(str, "l", 1, true);
  if ((function() 
    local _hx_1
    if ((r ~= nil) and (r > 0)) then 
    _hx_1 = r - 1; else 
    _hx_1 = -1; end
    return _hx_1
  end )() ~= -1) then 
    flagMap.h[0] = true;
  else
    flagMap.h[0] = false;
  end;
  local r = _G.string.find(str, "c", 1, true);
  if ((function() 
    local _hx_2
    if ((r ~= nil) and (r > 0)) then 
    _hx_2 = r - 1; else 
    _hx_2 = -1; end
    return _hx_2
  end )() ~= -1) then 
    flagMap.h[1] = true;
  else
    flagMap.h[1] = false;
  end;
  local lineSet = false;
  local callSet = false;
  local map = __gmdebug_lua__DebugHook_DDebugHook.hooks:iterator();
  while (map:hasNext()) do 
    local map = map:next();
    local ret = map.flagsMap.h[0];
    if (ret == __haxe_ds_IntMap.tnull) then 
      ret = nil;
    end;
    if (ret) then 
      lineSet = true;
    end;
    local ret = map.flagsMap.h[1];
    if (ret == __haxe_ds_IntMap.tnull) then 
      ret = nil;
    end;
    if (ret) then 
      callSet = true;
    end;
  end;
  if (lineSet) then 
    if (callSet) then 
      debug.sethook(__gmdebug_lua__DebugHook_DDebugHook.hookFun, "cl");
    else
      debug.sethook(__gmdebug_lua__DebugHook_DDebugHook.hookFun, "l");
    end;
  else
    if (callSet) then 
      debug.sethook(__gmdebug_lua__DebugHook_DDebugHook.hookFun, "c");
    else
      debug.sethook();
    end;
  end;
end
__gmdebug_lua__DebugHook_DDebugHook.hookFun = function(cur,currentLine) 
  local funHook = __gmdebug_lua__DebugHook_DDebugHook.hooks:iterator();
  while (funHook:hasNext()) do 
    local funHook = funHook:next();
    local map = funHook.flagsMap;
    local tmp;
    if (cur == "line") then 
      local ret = map.h[0];
      if (ret == __haxe_ds_IntMap.tnull) then 
        ret = nil;
      end;
      tmp = ret;
    else
      tmp = false;
    end;
    if (tmp) then 
      funHook.fun(cur, currentLine);
    else
      local tmp;
      if (cur == "call") then 
        local ret = map.h[1];
        if (ret == __haxe_ds_IntMap.tnull) then 
          ret = nil;
        end;
        tmp = ret;
      else
        tmp = false;
      end;
      if (tmp) then 
        funHook.fun(cur, currentLine);
      end;
    end;
  end;
end
_hxClasses["gmdebug.lua.CatchOut"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="NONE","OUT"},2)}
__gmdebug_lua_CatchOut = _hxClasses["gmdebug.lua.CatchOut"];
__gmdebug_lua_CatchOut.NONE = _hx_tab_array({[0]="NONE",0,__enum__ = __gmdebug_lua_CatchOut},2)

__gmdebug_lua_CatchOut.OUT = function(outFunc) local _x = _hx_tab_array({[0]="OUT",1,outFunc,__enum__=__gmdebug_lua_CatchOut}, 3); return _x; end 

__haxe_IMap.new = {}
__haxe_IMap.__name__ = true
__haxe_IMap.prototype = _hx_e();
__haxe_IMap.prototype.get= nil;
__haxe_IMap.prototype.keys= nil;

__haxe_IMap.prototype.__class__ =  __haxe_IMap

__haxe_ds_ObjectMap.new = function() 
  local self = _hx_new(__haxe_ds_ObjectMap.prototype)
  __haxe_ds_ObjectMap.super(self)
  return self
end
__haxe_ds_ObjectMap.super = function(self) 
  self.h = ({});
  self.k = ({});
end
__haxe_ds_ObjectMap.__name__ = true
__haxe_ds_ObjectMap.__interfaces__ = {__haxe_IMap}
__haxe_ds_ObjectMap.prototype = _hx_e();
__haxe_ds_ObjectMap.prototype.h= nil;
__haxe_ds_ObjectMap.prototype.k= nil;
__haxe_ds_ObjectMap.prototype.get = function(self,key) 
  do return self.h[key] end
end
__haxe_ds_ObjectMap.prototype.remove = function(self,key) 
  if (self.k[key] == nil) then 
    do return false end;
  end;
  self.k[key] = nil;
  self.h[key] = nil;
  do return true end
end
__haxe_ds_ObjectMap.prototype.keys = function(self) 
  local _gthis = self;
  local cur = next(self.h, nil);
  do return _hx_o({__fields__={next=true,hasNext=true},next=function(self) 
    local ret = cur;
    cur = next(_gthis.k, cur);
    do return ret end;
  end,hasNext=function(self) 
    do return cur ~= nil end;
  end}) end
end
__haxe_ds_ObjectMap.prototype.iterator = function(self) 
  local _gthis = self;
  local itr = self:keys();
  do return _hx_o({__fields__={hasNext=true,next=true},hasNext=function(_,...) return _hx_bind(itr,itr.hasNext)(...) end,next=function(self) 
    do return _gthis.h[itr:next()] end;
  end}) end
end

__haxe_ds_ObjectMap.prototype.__class__ =  __haxe_ds_ObjectMap
_hxClasses["haxe.ds.Option"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="Some","None"},2)}
__haxe_ds_Option = _hxClasses["haxe.ds.Option"];
__haxe_ds_Option.Some = function(v) local _x = _hx_tab_array({[0]="Some",0,v,__enum__=__haxe_ds_Option}, 3); return _x; end 
__haxe_ds_Option.None = _hx_tab_array({[0]="None",1,__enum__ = __haxe_ds_Option},2)


__gmdebug_lua_DebugLoop.new = {}
__gmdebug_lua_DebugLoop.__name__ = true
__gmdebug_lua_DebugLoop.init = function(initDebugLoop) 
  __gmdebug_lua_DebugLoop.bm = initDebugLoop.bm;
  __gmdebug_lua_DebugLoop.sc = initDebugLoop.sc;
  __gmdebug_lua_DebugLoop.debugee = initDebugLoop.debugee;
  __gmdebug_lua_DebugLoop.fbm = initDebugLoop.fbm;
end
__gmdebug_lua_DebugLoop.debugloop = function(cur,currentLine) 
  if (__gmdebug_lua_DebugLoop.debugee.pollActive or __gmdebug_lua_DebugLoop.debugee.tracebackActive) then 
    do return end;
  end;
  if (cur == "call") then 
    if (__gmdebug_lua_DebugLoop.curCheckStack >= __gmdebug_lua_DebugLoop.nextCheckStack) then 
      local min = 0;
      local max = __gmdebug_lua_DebugLoop.STACK_LIMIT;
      local middle = _G.math.floor((max - min) / 2);
      while (true) do 
        if (_G.debug.getinfo(middle) == nil) then 
          max = middle;
          middle = _G.math.floor((max - min) / 2) + min;
        else
          min = middle;
          middle = _G.math.floor((max - min) / 2) + min;
        end;
        if (middle == min) then 
          break;
        end;
      end;
      local len = middle;
      local locals;
      if (len > __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL) then 
        local locals1;
        if (__gmdebug_lua_DebugLoop.previousLength ~= nil) then 
          if (len < __gmdebug_lua_DebugLoop.previousLength) then 
            local stackDiff = __gmdebug_lua_DebugLoop.previousLength - len;
            local locals = 0;
            local _g = __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL - stackDiff;
            local _g1 = __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL;
            while (_g < _g1) do 
              _g = _g + 1;
              local sindex = _g - 1;
              if (_G.debug.getinfo(sindex) == nil) then 
                break;
              end;
              local locals1 = 0;
              local _g = 1;
              local _g1 = __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC;
              while (_g < _g1) do 
                _g = _g + 1;
                local _hx_1__local_a, _hx_1__local_b = _G.debug.getlocal(sindex, _g - 1);
                if (_hx_1__local_a == nil) then 
                  break;
                else
                  if (_G.string.sub(_hx_1__local_a, 1, 1) ~= "(") then 
                    locals1 = locals1 + 1;
                  end;
                end;
              end;
              locals = locals + locals1;
              locals = locals + 1;
            end;
            local locals2 = __gmdebug_lua_DebugLoop;
            locals2.tailLength = locals2.tailLength - stackDiff;
            local locals2 = __gmdebug_lua_DebugLoop;
            locals2.tailLocals = locals2.tailLocals - locals;
            locals1 = __gmdebug_lua_DebugLoop.tailLocals;
          else
            local stackDiff = len - __gmdebug_lua_DebugLoop.previousLength;
            local locals = 0;
            local _g = __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL;
            local _g1 = __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL + stackDiff;
            while (_g < _g1) do 
              _g = _g + 1;
              local sindex = _g - 1;
              if (_G.debug.getinfo(sindex) == nil) then 
                break;
              end;
              local locals1 = 0;
              local _g = 1;
              local _g1 = __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC;
              while (_g < _g1) do 
                _g = _g + 1;
                local _hx_2__local_a, _hx_2__local_b = _G.debug.getlocal(sindex, _g - 1);
                if (_hx_2__local_a == nil) then 
                  break;
                else
                  if (_G.string.sub(_hx_2__local_a, 1, 1) ~= "(") then 
                    locals1 = locals1 + 1;
                  end;
                end;
              end;
              locals = locals + locals1;
              locals = locals + 1;
            end;
            local locals2 = __gmdebug_lua_DebugLoop;
            locals2.tailLength = locals2.tailLength + stackDiff;
            local locals2 = __gmdebug_lua_DebugLoop;
            locals2.tailLocals = locals2.tailLocals + locals;
            locals1 = __gmdebug_lua_DebugLoop.tailLocals;
          end;
        else
          local stackDiff = len - __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL;
          local locals = 0;
          local _g = __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL;
          local _g1 = __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL + stackDiff;
          while (_g < _g1) do 
            _g = _g + 1;
            local sindex = _g - 1;
            if (_G.debug.getinfo(sindex) == nil) then 
              break;
            end;
            local locals1 = 0;
            local _g = 1;
            local _g1 = __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC;
            while (_g < _g1) do 
              _g = _g + 1;
              local _hx_3__local_a, _hx_3__local_b = _G.debug.getlocal(sindex, _g - 1);
              if (_hx_3__local_a == nil) then 
                break;
              else
                if (_G.string.sub(_hx_3__local_a, 1, 1) ~= "(") then 
                  locals1 = locals1 + 1;
                end;
              end;
            end;
            locals = locals + locals1;
            locals = locals + 1;
          end;
          __gmdebug_lua_DebugLoop.tailLength = stackDiff;
          __gmdebug_lua_DebugLoop.tailLocals = locals
          locals1 = __gmdebug_lua_DebugLoop.tailLocals;
        end;
        __gmdebug_lua_DebugLoop.previousLength = len;
        locals = locals1;
      else
        __gmdebug_lua_DebugLoop.previousLength = nil;
        local locals1 = 0;
        local _g = 1;
        local _g1 = __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL;
        while (_g < _g1) do 
          _g = _g + 1;
          local sindex = _g - 1;
          if (_G.debug.getinfo(sindex) == nil) then 
            break;
          end;
          local locals = 0;
          local _g = 1;
          local _g1 = __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC;
          while (_g < _g1) do 
            _g = _g + 1;
            local _hx_4__local_a, _hx_4__local_b = _G.debug.getlocal(sindex, _g - 1);
            if (_hx_4__local_a == nil) then 
              break;
            else
              if (_G.string.sub(_hx_4__local_a, 1, 1) ~= "(") then 
                locals = locals + 1;
              end;
            end;
          end;
          locals1 = locals1 + locals;
          locals1 = locals1 + 1;
        end;
        locals = locals1;
      end;
      __gmdebug_lua_DebugLoop.nextCheckStack = Math.max(_G.math.floor((__gmdebug_lua_DebugLoop.STACK_DEBUG_LIMIT - locals) / __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC) - 1, 0);
      if ((__gmdebug_lua_DebugLoop.nextCheckStack <= 5) and (__gmdebug_lua_DebugLoop.supressCheckStack == __haxe_ds_Option.None)) then 
        __gmdebug_lua_DebugLoop.debugee:startHaltLoop("exception", __gmdebug_lua_StackConst.STEP_DEBUG_LOOP, "Possible stack overflow detected...");
        __gmdebug_lua_DebugLoop.supressCheckStack = __haxe_ds_Option.Some(6);
      end;
      local _g = __gmdebug_lua_DebugLoop.supressCheckStack;
      if (_g[1] == 0) then 
        if (__gmdebug_lua_DebugLoop.nextCheckStack > _g[2]) then 
          __gmdebug_lua_DebugLoop.supressCheckStack = __haxe_ds_Option.None;
        end;
      end;
      __gmdebug_lua_DebugLoop.curCheckStack = 0;
    else
      __gmdebug_lua_DebugLoop.curCheckStack = __gmdebug_lua_DebugLoop.curCheckStack + 1;
    end;
  end;
  local func = _G.debug.getinfo(3, "f").func;
  local result = __gmdebug_lua_DebugLoop.sc.sourceCache.h[func];
  local sinfo;
  if (result ~= nil) then 
    sinfo = result;
  else
    local tmp = _G.debug.getinfo(3, "S");
    local _this = __gmdebug_lua_DebugLoop.sc.sourceCache;
    _this.h[func] = tmp;
    _this.k[func] = true;
    sinfo = tmp;
  end;
  if (((__gmdebug_lua_Exceptions.exceptFuncs ~= nil) and (func ~= nil)) and (__gmdebug_lua_Exceptions.exceptFuncs.k[func] ~= nil)) then 
    do return end;
  end;
  local stepping;
  local _g = __gmdebug_lua_DebugLoop.debugee.state;
  if (_g == nil) then 
    stepping = false;
  else
    local stepping1 = _g[1];
    if (stepping1) == 0 then 
      stepping = false;
    elseif (stepping1) == 1 then 
      local target = _g[2];
      if ((target == nil) or (__gmdebug_lua_DebugLoop.debugee:get_stackHeight() <= target)) then 
        __haxe_Log.trace(Std.string(Std.string(Std.string("stepped ") .. Std.string(target)) .. Std.string(" ")) .. Std.string(__gmdebug_lua_DebugLoop.debugee:get_stackHeight()), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/DebugLoop.hx",lineNumber=181,className="gmdebug.lua.DebugLoop",methodName="debug_step"}));
        __gmdebug_lua_DebugLoop.debugee.state = __gmdebug_lua_DebugState.WAIT;
        _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "c");
        __gmdebug_lua_DebugLoop.lineSteppin = false;
        __gmdebug_lua_DebugLoop.debugee:startHaltLoop("step", __gmdebug_lua_StackConst.STEP_DEBUG_LOOP);
        stepping = true;
      else
        stepping = true;
      end;
    elseif (stepping1) == 2 then 
      local _g1 = _g[2];
      local outFunc = _g1;
      if ((outFunc == func) and (currentLine == _g[3])) then 
        __gmdebug_lua_DebugLoop.debugee.state = __gmdebug_lua_DebugState.WAIT;
        _G.print(outFunc, func);
        _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "c");
        __gmdebug_lua_DebugLoop.lineSteppin = false;
        __gmdebug_lua_DebugLoop.debugee:startHaltLoop("step", __gmdebug_lua_StackConst.STEP_DEBUG_LOOP);
        stepping = true;
      else
        local outFunc = _g1;
        if ((outFunc ~= func) and (__gmdebug_lua_DebugLoop.debugee:get_stackHeight() <= _g[4])) then 
          __gmdebug_lua_DebugLoop.debugee.state = __gmdebug_lua_DebugState.WAIT;
          _G.print(outFunc, func);
          _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "c");
          __gmdebug_lua_DebugLoop.lineSteppin = false;
          __gmdebug_lua_DebugLoop.debugee:startHaltLoop("step", __gmdebug_lua_StackConst.STEP_DEBUG_LOOP);
          stepping = true;
        else
          _G.print(_g1, func, currentLine);
          stepping = true;
        end;
      end; end;
  end;
  local bpValid = (__gmdebug_lua_DebugLoop.bm ~= nil) and __gmdebug_lua_DebugLoop.bm:valid();
  if (not stepping and bpValid) then 
    if (((sinfo ~= nil) and (__gmdebug_lua_DebugLoop.highestStackHeight ~= nil)) and (__gmdebug_lua_DebugLoop.escapeHatch ~= nil)) then 
      if (not __gmdebug_lua_DebugLoop.lineSteppin and __gmdebug_lua_DebugLoop.bm:breakpointWithinRange(__gmdebug_lua__GmodPath_GmodPath_Impl_.gPath(sinfo.source), sinfo.linedefined, sinfo.lastlinedefined)) then 
        local sh;
        if (func ~= __gmdebug_lua_DebugLoop.prevFunc) then 
          __gmdebug_lua_DebugLoop.prevStackHeight = __gmdebug_lua_DebugLoop.debugee:get_stackHeight();
          sh = __gmdebug_lua_DebugLoop.prevStackHeight;
        else
          sh = __gmdebug_lua_DebugLoop.prevStackHeight;
        end;
        if (sh <= __gmdebug_lua_DebugLoop.highestStackHeight) then 
          _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "cl");
          __gmdebug_lua_DebugLoop.lineSteppin = true;
          __gmdebug_lua_DebugLoop.highestStackHeight = sh;
        end;
      else
        local tmp;
        if (cur == "line") then 
          local tmp1;
          if (func ~= __gmdebug_lua_DebugLoop.prevFunc) then 
            __gmdebug_lua_DebugLoop.prevStackHeight = __gmdebug_lua_DebugLoop.debugee:get_stackHeight();
            tmp1 = __gmdebug_lua_DebugLoop.prevStackHeight;
          else
            tmp1 = __gmdebug_lua_DebugLoop.prevStackHeight;
          end;
          tmp = tmp1 == __gmdebug_lua_StackConst.MIN_HEIGHT_OUT;
        else
          tmp = false;
        end;
        if (tmp and (__gmdebug_lua_DebugLoop.escapeHatch == __gmdebug_lua_CatchOut.NONE)) then 
          __gmdebug_lua_DebugLoop.escapeHatch = __gmdebug_lua_CatchOut.OUT(func);
        else
          local tmp;
          if (cur == "line") then 
            local sh;
            if (func ~= __gmdebug_lua_DebugLoop.prevFunc) then 
              __gmdebug_lua_DebugLoop.prevStackHeight = __gmdebug_lua_DebugLoop.debugee:get_stackHeight();
              sh = __gmdebug_lua_DebugLoop.prevStackHeight;
            else
              sh = __gmdebug_lua_DebugLoop.prevStackHeight;
            end;
            local _g = __gmdebug_lua_DebugLoop.escapeHatch;
            tmp = (sh < __gmdebug_lua_DebugLoop.highestStackHeight) or ((_g[1] == 1) and (_g[2] ~= func));
          else
            tmp = false;
          end;
          if (tmp) then 
            __gmdebug_lua_DebugLoop.escapeHatch = __gmdebug_lua_CatchOut.NONE;
            _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "c");
            __gmdebug_lua_DebugLoop.lineSteppin = false;
            __gmdebug_lua_DebugLoop.highestStackHeight = _G.math.huge;
          end;
        end;
      end;
    end;
  end;
  if ((cur == "line") and bpValid) then 
    local _g = __gmdebug_lua_DebugLoop.bm:getBreakpointForLine(__gmdebug_lua__GmodPath_GmodPath_Impl_.gPath(sinfo.source), currentLine);
    if (_g ~= nil) then 
      local _g1 = _g.breakpointType;
      local _g = _g.id;
      local tmp = _g1[1];
      if (tmp) == 0 then 
      elseif (tmp) == 1 then 
        __gmdebug_lua_DebugLoop.debugee:startHaltLoop("breakpoint", __gmdebug_lua_StackConst.STEP_DEBUG_LOOP);
      elseif (tmp) == 2 then 
        local condFunc = _g1[2];
        local bpID = _g;
        _G.setfenv(condFunc, __gmdebug_lua_handlers_HEvaluate.createEvalEnvironment(4));
        local _g = __gmdebug_lua_Util.runCompiledFunction(condFunc);
        local tmp = _g[1];
        if (tmp) == 0 then 
          local message = _G.string.gsub(_g[2], "^%[string %\"X%\"%]%:%d+%: ", "");
          local resp = __gmdebug_composer_ComposedEvent.new("breakpoint", _hx_o({__fields__={reason=true,breakpoint=true},reason="changed",breakpoint=_hx_o({__fields__={id=true,verified=true,message=true},id=bpID,verified=false,message=Std.string("Errored on run: ") .. Std.string(message)})}));
          _G.print(Std.string(Std.string(Std.string(Std.string("Conditional breakpoint in file ") .. Std.string(sinfo.short_src)) .. Std.string(":")) .. Std.string(currentLine)) .. Std.string(" failed!"));
          _G.print(Std.string("Error: ") .. Std.string(message));
          local _this = __gmdebug_lua_DebugLoop.debugee;
          __haxe_Json.stringify(resp);
          local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
          _this.socket.output:writeString(str);
          _this.socket.output:flush();
        elseif (tmp) == 1 then 
          if (_g[2]) then 
            __gmdebug_lua_DebugLoop.debugee:startHaltLoop("breakpoint", __gmdebug_lua_StackConst.STEP_DEBUG_LOOP);
          end; end; end;
    end;
  end;
  if (cur == "call") then 
    __gmdebug_lua_DebugLoop.currentFunc = nil;
  end;
  if (((func ~= nil) and (__gmdebug_lua_DebugLoop.fbm ~= nil)) and (__gmdebug_lua_DebugLoop.currentFunc == nil)) then 
    if (__gmdebug_lua_DebugLoop.fbm.functionBP.k[func] ~= nil) then 
      __gmdebug_lua_DebugLoop.debugee:startHaltLoop("function breakpoint", __gmdebug_lua_StackConst.STEP_DEBUG_LOOP);
    end;
    __gmdebug_lua_DebugLoop.currentFunc = func;
  end;
end
_hxClasses["gmdebug.lua.ProfilingState"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="NOT_PROFILING","PROFILING","PROFILE_FINISHED"},3)}
__gmdebug_lua_ProfilingState = _hxClasses["gmdebug.lua.ProfilingState"];
__gmdebug_lua_ProfilingState.NOT_PROFILING = _hx_tab_array({[0]="NOT_PROFILING",0,__enum__ = __gmdebug_lua_ProfilingState},2)

__gmdebug_lua_ProfilingState.PROFILING = _hx_tab_array({[0]="PROFILING",1,__enum__ = __gmdebug_lua_ProfilingState},2)

__gmdebug_lua_ProfilingState.PROFILE_FINISHED = _hx_tab_array({[0]="PROFILE_FINISHED",2,__enum__ = __gmdebug_lua_ProfilingState},2)


__gmdebug_lua_DebugLoopProfile.new = {}
__gmdebug_lua_DebugLoopProfile.__name__ = true
__gmdebug_lua_DebugLoopProfile.beginProfiling = function() 
  __gmdebug_lua_DebugLoopProfile.pass = 0;
  __gmdebug_lua_DebugLoopProfile.totalProfileTime = _G.SysTime();
  __gmdebug_lua_DebugLoopProfile.cumulativeTime = 0.0;
  __gmdebug_lua_DebugLoopProfile.profileState = __gmdebug_lua_ProfilingState.PROFILING;
end
__gmdebug_lua_DebugLoopProfile.report = function() 
  if (__gmdebug_lua_DebugLoopProfile.profileState ~= __gmdebug_lua_ProfilingState.PROFILE_FINISHED) then 
    do return end;
  end;
  local avg = __haxe_ds_StringMap.new();
  __haxe_Log.trace("report", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/DebugLoopProfile.hx",lineNumber=31,className="gmdebug.lua.DebugLoopProfile",methodName="report"}));
  local _g = 0;
  local _g1 = __gmdebug_lua_DebugLoopProfile.finish;
  while (_g < _g1.length) do 
    local pass = _g1[_g];
    _g = _g + 1;
    local map = pass;
    local _g_keys = map:keys();
    while (_g_keys:hasNext()) do 
      local key = _g_keys:next();
      local _g1_value = map:get(key);
      local ret = avg.h[key];
      if (ret == __haxe_ds_StringMap.tnull) then 
        ret = nil;
      end;
      local value = ret;
      local value = (function() 
        local _hx_1
        if (value == nil) then 
        _hx_1 = 0.0; else 
        _hx_1 = value; end
        return _hx_1
      end )() + _g1_value;
      if (value == nil) then 
        avg.h[key] = __haxe_ds_StringMap.tnull;
      else
        avg.h[key] = value;
      end;
    end;
  end;
  local map = avg;
  local _g2_keys = map:keys();
  while (_g2_keys:hasNext()) do 
    local key = _g2_keys:next();
    local _g3_value = map:get(key);
    __haxe_Log.trace(Std.string(Std.string(Std.string("average ") .. Std.string(key)) .. Std.string(" : ")) .. Std.string(_g3_value), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/DebugLoopProfile.hx",lineNumber=38,className="gmdebug.lua.DebugLoopProfile",methodName="report"}));
  end;
  __haxe_Log.trace(Std.string(Std.string(Std.string("Cumulative time ") .. Std.string(__gmdebug_lua_DebugLoopProfile.cumulativeTime)) .. Std.string(" / Total time ")) .. Std.string(__gmdebug_lua_DebugLoopProfile.totalProfileTime), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/DebugLoopProfile.hx",lineNumber=40,className="gmdebug.lua.DebugLoopProfile",methodName="report"}));
  local percent = _G.math.Round((__gmdebug_lua_DebugLoopProfile.cumulativeTime / __gmdebug_lua_DebugLoopProfile.totalProfileTime) * 100, 3);
  __haxe_Log.trace(Std.string("Overall runtime impact ") .. Std.string(percent), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/DebugLoopProfile.hx",lineNumber=42,className="gmdebug.lua.DebugLoopProfile",methodName="report"}));
  __gmdebug_lua_DebugLoopProfile.profileState = __gmdebug_lua_ProfilingState.NOT_PROFILING;
end
_hxClasses["gmdebug.lua.RecursiveGuard"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="NONE","TRACEBACK","POLL"},3)}
__gmdebug_lua_RecursiveGuard = _hxClasses["gmdebug.lua.RecursiveGuard"];
__gmdebug_lua_RecursiveGuard.NONE = _hx_tab_array({[0]="NONE",0,__enum__ = __gmdebug_lua_RecursiveGuard},2)

__gmdebug_lua_RecursiveGuard.TRACEBACK = _hx_tab_array({[0]="TRACEBACK",1,__enum__ = __gmdebug_lua_RecursiveGuard},2)

__gmdebug_lua_RecursiveGuard.POLL = _hx_tab_array({[0]="POLL",2,__enum__ = __gmdebug_lua_RecursiveGuard},2)


__gmdebug_lua_Debugee.new = function() 
  local self = _hx_new(__gmdebug_lua_Debugee.prototype)
  __gmdebug_lua_Debugee.super(self)
  return self
end
__gmdebug_lua_Debugee.super = function(self) 
  self.ignores = __haxe_ds_StringMap.new();
  self.TIMEOUT_CONFIG = 5;
  self.TIMEOUT_CONNECT = 10;
  self.pollActive = false;
  self.dest = "";
  self.hooksActive = false;
  self.tracebackActive = false;
  self.recursiveGuard = __gmdebug_lua_RecursiveGuard.NONE;
  self.pauseLoopActive = false;
  self.socketActive = false;
  self.state = __gmdebug_lua_DebugState.WAIT;
  self.clientID = 0;
  self.POLL_TIME = 0.1;
  local _gthis = self;
  local fun = nil;
  local str = nil;
  _G.DebugHook.addHook("gmdebug", fun, str);
  if (_G.previousSocket ~= nil) then 
    _G.previousSocket:close();
  end;
  self.vm = __gmdebug_lua_managers_VariableManager.new(_hx_o({__fields__={debugee=true},debugee=self}));
  self.sc = __gmdebug_lua_SourceContainer.new(_hx_o({__fields__={debugee=true},debugee=self}));
  self.customHandlers = __gmdebug_lua_CustomHandlers.new(_hx_o({__fields__={debugee=true},debugee=self}));
  self.outputter = __gmdebug_lua_Outputter.new(_hx_o({__fields__={vm=true,debugee=true},vm=self.vm,debugee=self}));
  self.bm = __gmdebug_lua_managers_BreakpointManager.new(_hx_o({__fields__={debugee=true},debugee=self}));
  self.fbm = __gmdebug_lua_managers_FunctionBreakpointManager.new();
  self.hc = __gmdebug_lua_HandlerContainer.new(_hx_o({__fields__={vm=true,debugee=true,fbm=true,bm=true},vm=self.vm,debugee=self,fbm=self.fbm,bm=self.bm}));
  __gmdebug_lua_DebugLoop.init(_hx_o({__fields__={bm=true,debugee=true,fbm=true,sc=true},bm=self.bm,debugee=self,fbm=self.fbm,sc=self.sc}));
  _G.file.CreateDir("gmdebug");
  _G.game.ConsoleCommand("sv_timeout 999999\n");
  __haxe_Log.trace("before socketactive", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=310,className="gmdebug.lua.Debugee",methodName="new"}));
  while (not self.socketActive) do 
    local _hx_status, _hx_result = pcall(function() 
    
        self:start();
      return _hx_pcall_default
    end)
    if not _hx_status and _hx_result == "_hx_pcall_break" then
      break
    elseif not _hx_status then 
      local _g = _hx_result;
      local _g = __haxe_Exception.caught(_g);
      _G.file.Write("deth.txt", _g:details());
      local value = self.socket;
      if (value ~= nil) then 
        value:close();
      end;
      self:set_socket(nil);
      __haxe_Log.trace(_g:details(), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=318,className="gmdebug.lua.Debugee",methodName="new"}));
      self.socketActive = false;
      break;
    elseif _hx_result ~= _hx_pcall_default then
      return _hx_result
    end;
  end;
  _G.timer.Create("report-profling", 3, 0, function() 
    __gmdebug_lua_DebugLoopProfile.report();
  end);
  local pollTime = 0.0;
  _G.hook.Add("Think", "gmdebug-poll", function() 
    if (_G.CurTime() > pollTime) then 
      pollTime = _G.CurTime() + _gthis.POLL_TIME;
      _gthis.pollActive = true;
      _gthis:poll();
      _gthis.pollActive = false;
    end;
  end);
end
__gmdebug_lua_Debugee.__name__ = true
__gmdebug_lua_Debugee.prototype = _hx_e();
__gmdebug_lua_Debugee.prototype.POLL_TIME= nil;
__gmdebug_lua_Debugee.prototype.clientID= nil;
__gmdebug_lua_Debugee.prototype.state= nil;
__gmdebug_lua_Debugee.prototype.socketActive= nil;
__gmdebug_lua_Debugee.prototype.pauseLoopActive= nil;
__gmdebug_lua_Debugee.prototype.dapMode= nil;
__gmdebug_lua_Debugee.prototype.baseDepth= nil;
__gmdebug_lua_Debugee.prototype.recursiveGuard= nil;
__gmdebug_lua_Debugee.prototype.get_stackHeight = function(self) 
  local _g = 1;
  while (_g < 999999) do 
    _g = _g + 1;
    local i = _g - 1;
    if (_G.debug.getinfo(i + 1, "") == nil) then 
      do return i end;
    end;
  end;
  _G.error(__haxe_Exception.thrown("No stack height"),0);
end
__gmdebug_lua_Debugee.prototype.tracebackActive= nil;
__gmdebug_lua_Debugee.prototype.hooksActive= nil;
__gmdebug_lua_Debugee.prototype.socket= nil;
__gmdebug_lua_Debugee.prototype.dest= nil;
__gmdebug_lua_Debugee.prototype.set_socket = function(self,sock) 
  _G.previousSocket = sock;
  self.socket = sock do return self.socket end
end
__gmdebug_lua_Debugee.prototype.pollActive= nil;
__gmdebug_lua_Debugee.prototype.outputter= nil;
__gmdebug_lua_Debugee.prototype.sc= nil;
__gmdebug_lua_Debugee.prototype.vm= nil;
__gmdebug_lua_Debugee.prototype.hc= nil;
__gmdebug_lua_Debugee.prototype.bm= nil;
__gmdebug_lua_Debugee.prototype.fbm= nil;
__gmdebug_lua_Debugee.prototype.customHandlers= nil;
__gmdebug_lua_Debugee.prototype.TIMEOUT_CONNECT= nil;
__gmdebug_lua_Debugee.prototype.TIMEOUT_CONFIG= nil;
__gmdebug_lua_Debugee.prototype.start = function(self) 
  if (self.socketActive) then 
    do return false end;
  end;
  local tmp;
  local _hx_status, _hx_result = pcall(function() 
  
      tmp = __gmdebug_lua_io_PipeSocket.new();
    return _hx_pcall_default
  end)
  if not _hx_status and _hx_result == "_hx_pcall_break" then
  elseif not _hx_status then 
    local _g = _hx_result;
    self:set_socket(nil);
    do return false end;
  elseif _hx_result ~= _hx_pcall_default then
    return _hx_result
  end;
  self:set_socket(tmp);
  __haxe_Log.trace("Connected to server...", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=129,className="gmdebug.lua.Debugee",methodName="start"}));
  self.socketActive = true;
  __haxe_Json.stringify(__gmdebug_composer_ComposedEvent.new("initialized"));
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  self.socket.output:writeString(str);
  self.socket.output:flush();
  self:hookPlayer();
  __haxe_Json.stringify(__gmdebug_composer_ComposedEvent.new("continued", _hx_o({__fields__={threadId=true,allThreadsContinued=true},threadId=0,allThreadsContinued=true})));
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  self.socket.output:writeString(str);
  self.socket.output:flush();
  if (not self:startLoop()) then 
    __haxe_Log.trace("Failed to setup debugger after timeout", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=142,className="gmdebug.lua.Debugee",methodName="start"}));
    do return false end;
  end;
  _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "c");
  __gmdebug_lua_Exceptions.tryHooks();
  _G.__gmdebugTraceback = _hx_bind(self,self.traceback);
  self.hooksActive = true;
  do return true end
end
__gmdebug_lua_Debugee.prototype.send = function(self,data) 
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  self.socket.output:writeString(str);
  self.socket.output:flush();
end
__gmdebug_lua_Debugee.prototype.sendMessage = function(self,message) 
  __haxe_Json.stringify(message);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  self.socket.output:writeString(str);
  self.socket.output:flush();
end
__gmdebug_lua_Debugee.prototype.ignores= nil;
__gmdebug_lua_Debugee.prototype.checkIgnoreError = function(self,_err) 
  do return self.ignores.h[_err] ~= nil end
end
__gmdebug_lua_Debugee.prototype.ignoreError = function(self,_err) 
  self.ignores.h[_err] = true;
end
__gmdebug_lua_Debugee.prototype.hookPlayer = function(self) 
  local _gthis = self;
  local x = ({});
  local _g_tbl = x;
  local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(x);
  local _g_lnext = _hx_1_p_next;
  local _hx_2_init_index, _hx_2_init_value = _g_lnext(_g_tbl, _hx_1_p_index);
  local _g_nextV = _hx_2_init_value;
  local _g_i = _hx_2_init_index;
  while (_g_nextV ~= nil) do 
    local v = _g_nextV;
    local _hx_3_nextResult_index, _hx_3_nextResult_value = _g_lnext(_g_tbl, _g_i);
    _g_i = _hx_3_nextResult_index;
    _g_nextV = _hx_3_nextResult_value;
    __haxe_Log.trace(v, _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=178,className="gmdebug.lua.Debugee",methodName="hookPlayer"}));
  end;
  _G.hook.Add("PlayerDisconnected", "gmdebug-byeplayer", function(ply) 
    __haxe_Json.stringify(__gmdebug_composer_ComposedGmDebugMessage.new(1, _hx_o({__fields__={playerID=true},playerID=ply:UserID()})));
    local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
    _gthis.socket.output:writeString(str);
    _gthis.socket.output:flush();
  end);
  local x = _G.player.GetAll();
  local ply_tbl = x;
  local _hx_4_p_next, _hx_4_p_table, _hx_4_p_index = _G.ipairs(x);
  local ply_lnext = _hx_4_p_next;
  local _hx_5_init_index, _hx_5_init_value = ply_lnext(ply_tbl, _hx_4_p_index);
  local ply_nextV = _hx_5_init_value;
  local ply_i = _hx_5_init_index;
  while (ply_nextV ~= nil) do 
    local v = ply_nextV;
    local _hx_6_nextResult_index, _hx_6_nextResult_value = ply_lnext(ply_tbl, ply_i);
    ply_i = _hx_6_nextResult_index;
    ply_nextV = _hx_6_nextResult_value;
    local ply = v;
    __haxe_Json.stringify(__gmdebug_composer_ComposedGmDebugMessage.new(0, _hx_o({__fields__={name=true,playerID=true},name=ply:Name(),playerID=ply:UserID()})));
    local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
    self.socket.output:writeString(str);
    self.socket.output:flush();
  end;
end
__gmdebug_lua_Debugee.prototype.traceback = function(self,err) 
  if (self.pollActive) then 
    do return err end;
  end;
  if (self.ignores.h[err] ~= nil) then 
    do return err end;
  end;
  if (self.pauseLoopActive or self.tracebackActive) then 
    __haxe_Log.trace(Std.string(Std.string(Std.string("traceback failed... ") .. Std.string(Std.string(self.pauseLoopActive))) .. Std.string(" ")) .. Std.string(Std.string(self.tracebackActive)), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=206,className="gmdebug.lua.Debugee",methodName="traceback"}));
    do return err end;
  end;
  if (not self.hooksActive or not self.socketActive) then 
    do return err end;
  end;
  self.tracebackActive = true;
  if (__lua_Boot.__instanceof(err, __haxe_Exception)) then 
    self:startHaltLoop("exception", __gmdebug_lua_StackConst.EXCEPT, err:get_message());
  else
    self:startHaltLoop("exception", __gmdebug_lua_StackConst.EXCEPT, _G.tostring(err));
  end;
  self.tracebackActive = false;
  do return _G.debug.traceback(err) end
end
__gmdebug_lua_Debugee.prototype.parseInput = function(self,x) 
  self.socket.output:writeString("\004");
  self.socket.output:flush();
  do return __gmdebug_Cross.recvMessage(x) end
end
__gmdebug_lua_Debugee.prototype.recvMessage = function(self) 
  local _hx_status, _hx_result = pcall(function() 
  
      local x = self.socket.input;
      self.socket.output:writeString("\004");
      self.socket.output:flush();
      local _g = __gmdebug_Cross.recvMessage(x);
      local tmp = _g[1];
      if (tmp) == 0 then 
        do return __gmdebug_lua_RecvMessageResult.ACK end;
      elseif (tmp) == 1 then 
        do return __gmdebug_lua_RecvMessageResult.MESSAGE(_g[2]) end; end;
    return _hx_pcall_default
  end)
  if not _hx_status and _hx_result == "_hx_pcall_break" then
  elseif not _hx_status then 
    local _g = _hx_result;
    local _g1 = __haxe_Exception.caught(_g):unwrap();
    if (__lua_Boot.__instanceof(_g1, String)) then 
      local e = _g1;
      if (e == "Error : timeout") then 
        do return __gmdebug_lua_RecvMessageResult.TIMEOUT end;
      else
        do return __gmdebug_lua_RecvMessageResult.ERROR(e) end;
      end;
    else
      _G.error(_g,0);
    end;
  elseif _hx_result ~= _hx_pcall_default then
    return _hx_result
  end;
end
__gmdebug_lua_Debugee.prototype.poll = function(self) 
  if (self.socket == nil) then 
    do return end;
  end;
  local _hx_status, _hx_result = pcall(function() 
  
      local msg;
      local _g = self:recvMessage();
      local msg1 = _g[1];
      if (msg1) == 0 or (msg1) == 1 then 
        do return end;
      elseif (msg1) == 2 then 
        _G.error(__haxe_Exception.thrown(_g[2]),0);
      elseif (msg1) == 3 then 
        msg = _g[2]; end;
      local tmp = self:chooseHandler(msg)[1];
      if (tmp) == 0 or (tmp) == 1 or (tmp) == 3 then 
      elseif (tmp) == 2 then 
        self:abortDebugee(); end;
    return _hx_pcall_default
  end)
  if not _hx_status and _hx_result == "_hx_pcall_break" then
  elseif not _hx_status then 
    local _g = _hx_result;
    local _g = __haxe_Exception.caught(_g);
    __haxe_Log.trace(_g:toString(), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=262,className="gmdebug.lua.Debugee",methodName="poll"}));
  elseif _hx_result ~= _hx_pcall_default then
    return _hx_result
  end;
end
__gmdebug_lua_Debugee.prototype.normalPath = function(self,x) 
  if (_G.string.sub(x, 1, 1) == "@") then 
    local len = nil;
    len = #x;
    x = _G.string.sub(x, 2, 1 + len);
  end;
  x = Std.string(Std.string("") .. Std.string(self.dest)) .. Std.string(x);
  do return x end
end
__gmdebug_lua_Debugee.prototype.startHaltLoop = function(self,reason,bd,txt) 
  if (self.pauseLoopActive) then 
    do return end;
  end;
  self.pauseLoopActive = true;
  self.baseDepth = bd;
  __haxe_Json.stringify(__gmdebug_composer_ComposedEvent.new("stopped", _hx_o({__fields__={threadId=true,allThreadsStopped=true,reason=true,text=true},threadId=self.clientID,allThreadsStopped=false,reason=reason,text=txt})));
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  self.socket.output:writeString(str);
  self.socket.output:flush();
  __haxe_Log.trace("HALT LOOP", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=358,className="gmdebug.lua.Debugee",methodName="startHaltLoop"}));
  self:haltLoop();
end
__gmdebug_lua_Debugee.prototype.abortDebugee = function(self) 
  local fun = nil;
  local str = nil;
  _G.DebugHook.addHook("gmdebug", fun, str);
  local value = self.socket;
  if (value ~= nil) then 
    value:close();
    self:set_socket(nil);
  end;
  self.hooksActive = false;
  self:set_socket(nil);
  self.socketActive = false;
  __haxe_Log.trace("Debugging aborted", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Debugee.hx",lineNumber=381,className="gmdebug.lua.Debugee",methodName="abortDebugee"}));
  __gmdebug_lua_Exceptions.unhookGamemodeHooks();
  __gmdebug_lua_Exceptions.unhookEntityHooks();
end
__gmdebug_lua_Debugee.prototype.startLoop = function(self) 
  local success = false;
  local timeoutTime = _G.SysTime() + self.TIMEOUT_CONFIG;
  local _hx_continue_1 = false;
  while (_G.SysTime() < timeoutTime) do repeat 
    local msg;
    local _g = self:recvMessage();
    local msg1 = _g[1];
    if (msg1) == 0 or (msg1) == 1 then 
      break;
    elseif (msg1) == 2 then 
      _G.error(__haxe_Exception.thrown(_g[2]),0);
    elseif (msg1) == 3 then 
      msg = _g[2]; end;
    local tmp = self:chooseHandler(msg)[1];
    if (tmp) == 0 or (tmp) == 1 then 
    elseif (tmp) == 2 then 
      self:abortDebugee();
      success = false;
      _hx_continue_1 = true;break;
    elseif (tmp) == 3 then 
      success = true;
      _hx_continue_1 = true;break; end;until true
    if _hx_continue_1 then 
    _hx_continue_1 = false;
    break;
    end;
    
  end;
  do return success end
end
__gmdebug_lua_Debugee.prototype.haltLoop = function(self) 
  local _hx_continue_1 = false;
  while (true) do repeat 
    local msg;
    local _g = self:recvMessage();
    local msg1 = _g[1];
    if (msg1) == 0 or (msg1) == 1 then 
      break;
    elseif (msg1) == 2 then 
      _G.error(__haxe_Exception.thrown(_g[2]),0);
    elseif (msg1) == 3 then 
      msg = _g[2]; end;
    local tmp = self:chooseHandler(msg)[1];
    if (tmp) == 0 or (tmp) == 3 then 
    elseif (tmp) == 1 then 
      _hx_continue_1 = true;break;
    elseif (tmp) == 2 then 
      self:abortDebugee();
      _hx_continue_1 = true;break; end;until true
    if _hx_continue_1 then 
    _hx_continue_1 = false;
    break;
    end;
    
  end;
  self.pauseLoopActive = false;
end
__gmdebug_lua_Debugee.prototype.chooseHandler = function(self,incoming) 
  local _g = incoming.type;
  if (_g == nil) then 
    _G.error(__haxe_Exception.thrown("message sent to us had a null type"),0);
  else
    if (_g) == "gmdebug" then 
      self.customHandlers:handle(incoming);
      do return __gmdebug_lua_handlers_HandlerResponse.WAIT end;
    elseif (_g) == "request" then 
      do return self.hc:handlers(incoming) end;else
    _G.error(__haxe_Exception.thrown("message sent to us had an unknown type"),0); end;
  end;
end
__gmdebug_lua_Debugee.prototype.fullPathToGmod = function(self,fullPath) 
  local value = self.dest;
  local tmp;
  if (value == "") then 
    tmp = String.indexOfEmpty(fullPath, 0);
  else
    local r = _G.string.find(fullPath, value, 1, true);
    tmp = (function() 
      local _hx_1
      if ((r ~= nil) and (r > 0)) then 
      _hx_1 = r - 1; else 
      _hx_1 = -1; end
      return _hx_1
    end )();
  end;
  if (tmp ~= -1) then 
    local result = StringTools.replace(fullPath, self.dest, "");
    result = Std.string("@") .. Std.string(result);
    do return __haxe_ds_Option.Some(result) end;
  else
    do return __haxe_ds_Option.None end;
  end;
end

__gmdebug_lua_Debugee.prototype.__class__ =  __gmdebug_lua_Debugee
_hxClasses["gmdebug.lua.DebugState"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="WAIT","STEP","OUT"},3)}
__gmdebug_lua_DebugState = _hxClasses["gmdebug.lua.DebugState"];
__gmdebug_lua_DebugState.WAIT = _hx_tab_array({[0]="WAIT",0,__enum__ = __gmdebug_lua_DebugState},2)

__gmdebug_lua_DebugState.STEP = function(targetHeight) local _x = _hx_tab_array({[0]="STEP",1,targetHeight,__enum__=__gmdebug_lua_DebugState}, 3); return _x; end 
__gmdebug_lua_DebugState.OUT = function(outFunc,lowestLine,targetHeight) local _x = _hx_tab_array({[0]="OUT",2,outFunc,lowestLine,targetHeight,__enum__=__gmdebug_lua_DebugState}, 5); return _x; end 
_hxClasses["gmdebug.lua.RecvMessageResult"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="TIMEOUT","ACK","ERROR","MESSAGE"},4)}
__gmdebug_lua_RecvMessageResult = _hxClasses["gmdebug.lua.RecvMessageResult"];
__gmdebug_lua_RecvMessageResult.TIMEOUT = _hx_tab_array({[0]="TIMEOUT",0,__enum__ = __gmdebug_lua_RecvMessageResult},2)

__gmdebug_lua_RecvMessageResult.ACK = _hx_tab_array({[0]="ACK",1,__enum__ = __gmdebug_lua_RecvMessageResult},2)

__gmdebug_lua_RecvMessageResult.ERROR = function(s) local _x = _hx_tab_array({[0]="ERROR",2,s,__enum__=__gmdebug_lua_RecvMessageResult}, 3); return _x; end 
__gmdebug_lua_RecvMessageResult.MESSAGE = function(msg) local _x = _hx_tab_array({[0]="MESSAGE",3,msg,__enum__=__gmdebug_lua_RecvMessageResult}, 3); return _x; end 

__gmod_helpers_WeakTools.new = {}
__gmod_helpers_WeakTools.__name__ = true
__gmod_helpers_WeakTools.setWeakKeys = function(table) 
  local prevMeta = _G.getmetatable(table);
  if (prevMeta == nil) then 
    prevMeta = ({});
    _G.setmetatable(table, prevMeta);
  end;
  prevMeta.__mode = "k";
end
__gmod_helpers_WeakTools.setWeakKeyValues = function(table) 
  local prevMeta = _G.getmetatable(table);
  if (prevMeta == nil) then 
    prevMeta = ({});
    _G.setmetatable(table, prevMeta);
  end;
  prevMeta.__mode = "kv";
end
__gmod_helpers_WeakTools.setWeakKeysM = function(objMap) 
  __gmod_helpers_WeakTools.setWeakKeys(objMap.h);
  __gmod_helpers_WeakTools.setWeakKeys(objMap.k);
end
__gmod_helpers_WeakTools.setWeakKeyValuesM = function(objMap) 
  __gmod_helpers_WeakTools.setWeakKeyValues(objMap.h);
  __gmod_helpers_WeakTools.setWeakKeys(objMap.k);
end

__gmdebug_lua_Exceptions.new = {}
__gmdebug_lua_Exceptions.__name__ = true
__gmdebug_lua_Exceptions.getexceptFuncs = function() 
  if (_G.__exceptFuncs == nil) then 
    _G.__exceptFuncs = __haxe_ds_ObjectMap.new();
  end;
  __gmod_helpers_WeakTools.setWeakKeyValuesM(_G.__exceptFuncs);
  do return _G.__exceptFuncs end;
end
__gmdebug_lua_Exceptions.tryHooks = function() 
  __gmdebug_lua_Exceptions.unhookGamemodeHooks();
  __gmdebug_lua_Exceptions.unhookEntityHooks();
  __gmdebug_lua_Exceptions.unhookInclude();
  __gmdebug_lua_Exceptions.hookGamemodeHooks();
  __gmdebug_lua_Exceptions.hookEntityHooks();
  __gmdebug_lua_Exceptions.hookInclude();
  local key = nil;
  __haxe_Log.trace(__gmdebug_lua_Exceptions.exceptFuncs.k[key] ~= nil, _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Exceptions.hx",lineNumber=41,className="gmdebug.lua.Exceptions",methodName="tryHooks"}));
end
__gmdebug_lua_Exceptions.addExcept = function(x) 
  local func = function (...) local success,vargs = xpcall(x,_G.__gmdebugTraceback,...) if success then return vargs else print("baddy bad!") error(vargs,99) end end;
  local _this = __gmdebug_lua_Exceptions.exceptFuncs;
  _this.h[func] = x;
  _this.k[func] = true;
  do return func end;
end
__gmdebug_lua_Exceptions.getOldFunc = function(hook) 
  do return __gmdebug_lua_Exceptions.exceptFuncs.h[hook] end;
end
__gmdebug_lua_Exceptions.hookGamemodeHooks = function() 
  local x = _G.hook.GetTable();
  local _g_tbl = x;
  local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(x);
  local _g_lnext = _hx_1_p_next;
  local _hx_2_init_index, _hx_2_init_value = _g_lnext(_g_tbl, _hx_1_p_index);
  local _g_nextV = _hx_2_init_value;
  local _g_nextI = _hx_2_init_index;
  while (_g_nextV ~= nil) do 
    local v = _g_nextV;
    local i = _g_nextI;
    local _hx_3_nextResult_index, _hx_3_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
    _g_nextI = _hx_3_nextResult_index;
    _g_nextV = _hx_3_nextResult_value;
    local _g1_key = i;
    local _g1_value = v;
    local hookname = _g1_key;
    local hook = _g1_value;
    local x = hook;
    local _g2_tbl = x;
    local _hx_4_p_next, _hx_4_p_table, _hx_4_p_index = _G.pairs(x);
    local _g2_lnext = _hx_4_p_next;
    local _hx_5_init_index, _hx_5_init_value = _g2_lnext(_g2_tbl, _hx_4_p_index);
    local _g2_nextV = _hx_5_init_value;
    local _g2_nextI = _hx_5_init_index;
    while (_g2_nextV ~= nil) do 
      local v = _g2_nextV;
      local i = _g2_nextI;
      local _hx_6_nextResult_index, _hx_6_nextResult_value = _g2_lnext(_g2_tbl, _g2_nextI);
      _g2_nextI = _hx_6_nextResult_index;
      _g2_nextV = _hx_6_nextResult_value;
      local _g3_key = i;
      local _g3_value = v;
      local ident = _g3_key;
      local hooks = _g3_value;
      local x = hooks;
      if ((_G.type(x) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[x] == nil)) then 
        _G.hook.Add(hookname, ident, __gmdebug_lua_Exceptions.addExcept(hooks));
      end;
    end;
  end;
  if (_G.GAMEMODE ~= nil) then 
    local x = _G.GAMEMODE;
    local _g_tbl = x;
    local _hx_7_p_next, _hx_7_p_table, _hx_7_p_index = _G.pairs(x);
    local _g_lnext = _hx_7_p_next;
    local _hx_8_init_index, _hx_8_init_value = _g_lnext(_g_tbl, _hx_7_p_index);
    local _g_nextV = _hx_8_init_value;
    local _g_nextI = _hx_8_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_9_nextResult_index, _hx_9_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
      _g_nextI = _hx_9_nextResult_index;
      _g_nextV = _hx_9_nextResult_value;
      local _g1_key = i;
      local _g1_value = v;
      local ind = _g1_key;
      local gm = _g1_value;
      local x = gm;
      if ((_G.type(x) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[x] == nil)) then 
        _G.GAMEMODE[ind] = __gmdebug_lua_Exceptions.addExcept(gm);
      end;
    end;
  end;
  _G.__oldGamemodeRegister = _G.gamemode.Register;
  _G.gamemode.Register = function(gm,name,derived) 
    local x = gm;
    local _g_tbl = x;
    local _hx_10_p_next, _hx_10_p_table, _hx_10_p_index = _G.pairs(x);
    local _g_lnext = _hx_10_p_next;
    local _hx_11_init_index, _hx_11_init_value = _g_lnext(_g_tbl, _hx_10_p_index);
    local _g_nextV = _hx_11_init_value;
    local _g_nextI = _hx_11_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_12_nextResult_index, _hx_12_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
      _g_nextI = _hx_12_nextResult_index;
      _g_nextV = _hx_12_nextResult_value;
      local _g1_key = i;
      local _g1_value = v;
      local ind = _g1_key;
      local val = _g1_value;
      local x = val;
      if ((_G.type(x) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[x] == nil)) then 
        gm[ind] = __gmdebug_lua_Exceptions.addExcept(val);
      end;
    end;
    _G.__oldGamemodeRegister(gm, name, derived);
  end;
end
__gmdebug_lua_Exceptions.hookInclude = function() 
  _G.__oldInclude = _G.include;
  _G.include = function(str) 
    local info = _G.debug.getinfo(2, "S");
    local _this = info.source;
    local startIndex = 1;
    local endIndex = nil;
    if (endIndex == nil) then 
      endIndex = #_this;
    end;
    if (endIndex < 0) then 
      endIndex = 0;
    end;
    if (startIndex < 0) then 
      startIndex = 0;
    end;
    local currentPath = (function() 
      local _hx_1
      if (endIndex < startIndex) then 
      _hx_1 = _G.string.sub(_this, endIndex + 1, startIndex); else 
      _hx_1 = _G.string.sub(_this, startIndex + 1, endIndex); end
      return _hx_1
    end )();
    local currentDir = __haxe_io_Path.directory(currentPath);
    local findPth = __haxe_io_Path.join(_hx_tab_array({[0]=currentDir, str}, 2));
    local relative = _G.file.Exists(findPth, "GAME");
    local nonrelative = _G.file.Exists(str, "LUA");
    __haxe_Log.trace(Std.string(Std.string(Std.string(Std.string(Std.string("path: ") .. Std.string(str)) .. Std.string(" relative: ")) .. Std.string(Std.string(relative))) .. Std.string(" nonrelative: ")) .. Std.string(Std.string(nonrelative)), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/Exceptions.hx",lineNumber=101,className="gmdebug.lua.Exceptions",methodName="hookInclude"}));
    do return _G.__oldInclude(str) end;
  end;
end
__gmdebug_lua_Exceptions.unhookInclude = function() 
  if (_G.__oldInclude ~= nil) then 
    _G.include = _G.__oldInclude;
  end;
end
__gmdebug_lua_Exceptions.hookEntityHooks = function() 
  local x = _G.scripted_ents.GetList();
  local entName_tbl = x;
  local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(x);
  local entName_lnext = _hx_1_p_next;
  local _hx_2_init_index, _hx_2_init_value = entName_lnext(entName_tbl, _hx_1_p_index);
  local entName_nextV = _hx_2_init_value;
  local entName_nextI = _hx_2_init_index;
  while (entName_nextV ~= nil) do 
    local i = entName_nextI;
    local _hx_3_nextResult_index, _hx_3_nextResult_value = entName_lnext(entName_tbl, entName_nextI);
    entName_nextI = _hx_3_nextResult_index;
    entName_nextV = _hx_3_nextResult_value;
    local entName = i;
    local entTbl = _G.scripted_ents.GetStored(entName);
    local x = entTbl.t;
    local _g1_tbl = x;
    local _hx_4_p_next, _hx_4_p_table, _hx_4_p_index = _G.pairs(x);
    local _g1_lnext = _hx_4_p_next;
    local _hx_5_init_index, _hx_5_init_value = _g1_lnext(_g1_tbl, _hx_4_p_index);
    local _g1_nextV = _hx_5_init_value;
    local _g1_nextI = _hx_5_init_index;
    while (_g1_nextV ~= nil) do 
      local v = _g1_nextV;
      local i = _g1_nextI;
      local _hx_6_nextResult_index, _hx_6_nextResult_value = _g1_lnext(_g1_tbl, _g1_nextI);
      _g1_nextI = _hx_6_nextResult_index;
      _g1_nextV = _hx_6_nextResult_value;
      local _g2_key = i;
      local _g2_value = v;
      local ind = _g2_key;
      local val = _g2_value;
      if ((_G.type(val) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[val] == nil)) then 
        entTbl.t[ind] = __gmdebug_lua_Exceptions.addExcept(val);
      end;
    end;
  end;
  _G.__oldEntityRegister = _G.scripted_ents.Register;
  _G.scripted_ents.Register = function(ENT,name) 
    local x = ENT;
    local _g_tbl = x;
    local _hx_7_p_next, _hx_7_p_table, _hx_7_p_index = _G.pairs(x);
    local _g_lnext = _hx_7_p_next;
    local _hx_8_init_index, _hx_8_init_value = _g_lnext(_g_tbl, _hx_7_p_index);
    local _g_nextV = _hx_8_init_value;
    local _g_nextI = _hx_8_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_9_nextResult_index, _hx_9_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
      _g_nextI = _hx_9_nextResult_index;
      _g_nextV = _hx_9_nextResult_value;
      local _g1_key = i;
      local _g1_value = v;
      local ind = _g1_key;
      local val = _g1_value;
      local x = val;
      if ((_G.type(x) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[x] == nil)) then 
        ENT[ind] = __gmdebug_lua_Exceptions.addExcept(val);
      end;
    end;
    _G.__oldEntityRegister(ENT, name);
  end;
end
__gmdebug_lua_Exceptions.unhookGamemodeHooks = function() 
  local x = _G.hook.GetTable();
  local _g_tbl = x;
  local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(x);
  local _g_lnext = _hx_1_p_next;
  local _hx_2_init_index, _hx_2_init_value = _g_lnext(_g_tbl, _hx_1_p_index);
  local _g_nextV = _hx_2_init_value;
  local _g_nextI = _hx_2_init_index;
  while (_g_nextV ~= nil) do 
    local v = _g_nextV;
    local i = _g_nextI;
    local _hx_3_nextResult_index, _hx_3_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
    _g_nextI = _hx_3_nextResult_index;
    _g_nextV = _hx_3_nextResult_value;
    local _g1_key = i;
    local _g1_value = v;
    local hookname = _g1_key;
    local hook = _g1_value;
    local x = hook;
    local _g2_tbl = x;
    local _hx_4_p_next, _hx_4_p_table, _hx_4_p_index = _G.pairs(x);
    local _g2_lnext = _hx_4_p_next;
    local _hx_5_init_index, _hx_5_init_value = _g2_lnext(_g2_tbl, _hx_4_p_index);
    local _g2_nextV = _hx_5_init_value;
    local _g2_nextI = _hx_5_init_index;
    while (_g2_nextV ~= nil) do 
      local v = _g2_nextV;
      local i = _g2_nextI;
      local _hx_6_nextResult_index, _hx_6_nextResult_value = _g2_lnext(_g2_tbl, _g2_nextI);
      _g2_nextI = _hx_6_nextResult_index;
      _g2_nextV = _hx_6_nextResult_value;
      local _g3_key = i;
      local _g3_value = v;
      local ident = _g3_key;
      local hooks = _g3_value;
      local x = hooks;
      if ((_G.type(x) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[x] ~= nil)) then 
        _G.hook.Add(hookname, ident, __gmdebug_lua_Exceptions.getOldFunc(hooks));
        __gmdebug_lua_Exceptions.exceptFuncs:remove(hooks);
      end;
    end;
  end;
  if (_G.GAMEMODE ~= nil) then 
    local x = _G.GAMEMODE;
    local _g_tbl = x;
    local _hx_7_p_next, _hx_7_p_table, _hx_7_p_index = _G.pairs(x);
    local _g_lnext = _hx_7_p_next;
    local _hx_8_init_index, _hx_8_init_value = _g_lnext(_g_tbl, _hx_7_p_index);
    local _g_nextV = _hx_8_init_value;
    local _g_nextI = _hx_8_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_9_nextResult_index, _hx_9_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
      _g_nextI = _hx_9_nextResult_index;
      _g_nextV = _hx_9_nextResult_value;
      local _g1_key = i;
      local _g1_value = v;
      local ind = _g1_key;
      local gm = _g1_value;
      local x = gm;
      if ((_G.type(x) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[x] ~= nil)) then 
        _G.GAMEMODE[ind] = __gmdebug_lua_Exceptions.getOldFunc(gm);
        __gmdebug_lua_Exceptions.exceptFuncs:remove(gm);
      end;
    end;
  end;
  if (_G.__oldGamemodeRegister ~= nil) then 
    _G.gamemode.Register = _G.__oldGamemodeRegister;
  end;
end
__gmdebug_lua_Exceptions.unhookEntityHooks = function() 
  local x = _G.scripted_ents.GetList();
  local entName_tbl = x;
  local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(x);
  local entName_lnext = _hx_1_p_next;
  local _hx_2_init_index, _hx_2_init_value = entName_lnext(entName_tbl, _hx_1_p_index);
  local entName_nextV = _hx_2_init_value;
  local entName_nextI = _hx_2_init_index;
  while (entName_nextV ~= nil) do 
    local i = entName_nextI;
    local _hx_3_nextResult_index, _hx_3_nextResult_value = entName_lnext(entName_tbl, entName_nextI);
    entName_nextI = _hx_3_nextResult_index;
    entName_nextV = _hx_3_nextResult_value;
    local entName = i;
    local entTbl = _G.scripted_ents.GetStored(entName);
    local x = entTbl.t;
    local _g1_tbl = x;
    local _hx_4_p_next, _hx_4_p_table, _hx_4_p_index = _G.pairs(x);
    local _g1_lnext = _hx_4_p_next;
    local _hx_5_init_index, _hx_5_init_value = _g1_lnext(_g1_tbl, _hx_4_p_index);
    local _g1_nextV = _hx_5_init_value;
    local _g1_nextI = _hx_5_init_index;
    while (_g1_nextV ~= nil) do 
      local v = _g1_nextV;
      local i = _g1_nextI;
      local _hx_6_nextResult_index, _hx_6_nextResult_value = _g1_lnext(_g1_tbl, _g1_nextI);
      _g1_nextI = _hx_6_nextResult_index;
      _g1_nextV = _hx_6_nextResult_value;
      local _g2_key = i;
      local _g2_value = v;
      local ind = _g2_key;
      local val = _g2_value;
      if ((_G.type(val) == "function") and (__gmdebug_lua_Exceptions.exceptFuncs.k[val] ~= nil)) then 
        entTbl.t[ind] = __gmdebug_lua_Exceptions.getOldFunc(val);
        __gmdebug_lua_Exceptions.exceptFuncs:remove(val);
      end;
    end;
  end;
  if (_G.__oldEntityRegister ~= nil) then 
    _G.scripted_ents.Register = _G.__oldEntityRegister;
  end;
end

__gmdebug_lua__GmodPath_GmodPath_Impl_.new = {}
__gmdebug_lua__GmodPath_GmodPath_Impl_.__name__ = true
__gmdebug_lua__GmodPath_GmodPath_Impl_.gPath = function(x) 
  do return x end;
end

__gmdebug_lua_HandlerContainer.new = function(initHandlerContainer) 
  local self = _hx_new(__gmdebug_lua_HandlerContainer.prototype)
  __gmdebug_lua_HandlerContainer.super(self,initHandlerContainer)
  return self
end
__gmdebug_lua_HandlerContainer.super = function(self,initHandlerContainer) 
  self.handlerMap = __haxe_ds_StringMap.new();
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HContinue.new(initHandlerContainer);
  if (value == nil) then 
    _this.h._continue = __haxe_ds_StringMap.tnull;
  else
    _this.h._continue = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HDisconnect.new();
  if (value == nil) then 
    _this.h.disconnect = __haxe_ds_StringMap.tnull;
  else
    _this.h.disconnect = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HStackTrace.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.stackTrace = __haxe_ds_StringMap.tnull;
  else
    _this.h.stackTrace = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HNext.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.next = __haxe_ds_StringMap.tnull;
  else
    _this.h.next = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HPause.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.pause = __haxe_ds_StringMap.tnull;
  else
    _this.h.pause = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HStepIn.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.stepIn = __haxe_ds_StringMap.tnull;
  else
    _this.h.stepIn = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HStepOut.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.stepOut = __haxe_ds_StringMap.tnull;
  else
    _this.h.stepOut = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HVariables.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.variables = __haxe_ds_StringMap.tnull;
  else
    _this.h.variables = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HSetBreakpoints.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.setBreakpoints = __haxe_ds_StringMap.tnull;
  else
    _this.h.setBreakpoints = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HSetFunctionBreakpoints.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.setFunctionBreakpoints = __haxe_ds_StringMap.tnull;
  else
    _this.h.setFunctionBreakpoints = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HSetExceptionBreakpoints.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.setExceptionBreakpoints = __haxe_ds_StringMap.tnull;
  else
    _this.h.setExceptionBreakpoints = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HEvaluate.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.evaluate = __haxe_ds_StringMap.tnull;
  else
    _this.h.evaluate = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HConfigurationDone.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.configurationDone = __haxe_ds_StringMap.tnull;
  else
    _this.h.configurationDone = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HScopes.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.scopes = __haxe_ds_StringMap.tnull;
  else
    _this.h.scopes = value;
  end;
  local _this = self.handlerMap;
  local value = __gmdebug_lua_handlers_HLoadedSources.new(initHandlerContainer);
  if (value == nil) then 
    _this.h.loadedSources = __haxe_ds_StringMap.tnull;
  else
    _this.h.loadedSources = value;
  end;
end
__gmdebug_lua_HandlerContainer.__name__ = true
__gmdebug_lua_HandlerContainer.prototype = _hx_e();
__gmdebug_lua_HandlerContainer.prototype.handlerMap= nil;
__gmdebug_lua_HandlerContainer.prototype.handlers = function(self,req) 
  local result;
  if (req.command == "continue") then 
    local ret = self.handlerMap.h._continue;
    if (ret == __haxe_ds_StringMap.tnull) then 
      ret = nil;
    end;
    result = ret;
  else
    local ret = self.handlerMap.h[req.command];
    if (ret == __haxe_ds_StringMap.tnull) then 
      ret = nil;
    end;
    result = ret;
  end;
  if (result == nil) then 
    __haxe_Log.trace(Std.string("No such command ") .. Std.string(req.command), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/HandlerContainer.hx",lineNumber=55,className="gmdebug.lua.HandlerContainer",methodName="handlers"}));
    _G.error(__haxe_Exception.new(Std.string("No such command ") .. Std.string(req.command)),0);
  end;
  do return result:handle(req) end
end

__gmdebug_lua_HandlerContainer.prototype.__class__ =  __gmdebug_lua_HandlerContainer

__gmdebug_lua_Outputter.new = function(initOutputter) 
  local self = _hx_new(__gmdebug_lua_Outputter.prototype)
  __gmdebug_lua_Outputter.super(self,initOutputter)
  return self
end
__gmdebug_lua_Outputter.super = function(self,initOutputter) 
  self.vm = _hx_funcToField(initOutputter.vm);
  self.debugee = _hx_funcToField(initOutputter.debugee);
end
__gmdebug_lua_Outputter.__name__ = true
__gmdebug_lua_Outputter.prototype = _hx_e();
__gmdebug_lua_Outputter.prototype.vm= nil;
__gmdebug_lua_Outputter.prototype.debugee= nil;

__gmdebug_lua_Outputter.prototype.__class__ =  __gmdebug_lua_Outputter

__gmdebug_lua_SourceContainer.new = function(initSourceContainer) 
  local self = _hx_new(__gmdebug_lua_SourceContainer.prototype)
  __gmdebug_lua_SourceContainer.super(self,initSourceContainer)
  return self
end
__gmdebug_lua_SourceContainer.super = function(self,initSourceContainer) 
  self.readSourceTime = 0;
  self.sources = _hx_tab_array({}, 0);
  self.uniqueSources = __haxe_ds_StringMap.new();
  local _gthis = self;
  _G.hook.Add("Think", "gmdebug-source-get", function() 
    if (_G.CurTime() > _gthis.readSourceTime) then 
      local tmp = _G.CurTime();
      _gthis.readSourceTime = tmp + 1;
      _gthis:readSourceInfo();
    end;
  end);
  self.sourceCache = self:makeSourceCache();
  self.debugee = _hx_funcToField(initSourceContainer.debugee);
end
__gmdebug_lua_SourceContainer.__name__ = true
__gmdebug_lua_SourceContainer.prototype = _hx_e();
__gmdebug_lua_SourceContainer.prototype.uniqueSources= nil;
__gmdebug_lua_SourceContainer.prototype.sources= nil;
__gmdebug_lua_SourceContainer.prototype.sourceCache= nil;
__gmdebug_lua_SourceContainer.prototype.debugee= nil;
__gmdebug_lua_SourceContainer.prototype.makeSourceCache = function(self) 
  local sc = __haxe_ds_ObjectMap.new();
  __gmod_helpers_WeakTools.setWeakKeysM(sc);
  do return sc end
end
__gmdebug_lua_SourceContainer.prototype.readSourceInfo = function(self) 
  if (self.debugee.dest == "") then 
    do return end;
  end;
  local si = self.sourceCache:iterator();
  while (si:hasNext()) do 
    local si = si:next();
    if (self.uniqueSources.h[si.source] == nil) then 
      local result = self:infoToSource(si);
      if (result ~= nil) then 
        local _this = self.debugee;
        __haxe_Json.stringify(__gmdebug_composer_ComposedEvent.new("loadedSource", _hx_o({__fields__={reason=true,source=true},reason="new",source=result})));
        local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
        _this.socket.output:writeString(str);
        _this.socket.output:flush();
        self.sources:push(result);
      end;
      local key = si.source;
      local _this = self.uniqueSources;
      if (result == nil) then 
        _this.h[key] = __haxe_ds_StringMap.tnull;
      else
        _this.h[key] = result;
      end;
    end;
  end;
end
__gmdebug_lua_SourceContainer.prototype.readSourceTime= nil;
__gmdebug_lua_SourceContainer.prototype.infoToSource = function(self,info) 
  local _g = info.source;
  if (_g == "=[C]") then 
    do return nil end;
  else
    local path = __haxe_io_Path.new(self.debugee:normalPath(_g));
    do return _hx_o({__fields__={name=true,path=true},name=path.file,path=path:toString()}) end;
  end;
end

__gmdebug_lua_SourceContainer.prototype.__class__ =  __gmdebug_lua_SourceContainer

__gmdebug_lua_StackConst.new = {}
__gmdebug_lua_StackConst.__name__ = true

__gmdebug_lua_Start.new = {}
__gmdebug_lua_Start.__name__ = true
__gmdebug_lua_Start.main = function() 
  __gmdebug_lua_Debugee.new();
end
_hxClasses["gmdebug.lua.CompileResult"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="Error","Success"},2)}
__gmdebug_lua_CompileResult = _hxClasses["gmdebug.lua.CompileResult"];
__gmdebug_lua_CompileResult.Error = function(err) local _x = _hx_tab_array({[0]="Error",0,err,__enum__=__gmdebug_lua_CompileResult}, 3); return _x; end 
__gmdebug_lua_CompileResult.Success = function(compiledFunc) local _x = _hx_tab_array({[0]="Success",1,compiledFunc,__enum__=__gmdebug_lua_CompileResult}, 3); return _x; end 
_hxClasses["gmdebug.lua.RunResult"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="Error","Success"},2)}
__gmdebug_lua_RunResult = _hxClasses["gmdebug.lua.RunResult"];
__gmdebug_lua_RunResult.Error = function(err) local _x = _hx_tab_array({[0]="Error",0,err,__enum__=__gmdebug_lua_RunResult}, 3); return _x; end 
__gmdebug_lua_RunResult.Success = function(dyn) local _x = _hx_tab_array({[0]="Success",1,dyn,__enum__=__gmdebug_lua_RunResult}, 3); return _x; end 

__gmdebug_lua_Util.new = {}
__gmdebug_lua_Util.__name__ = true
__gmdebug_lua_Util.compileString = function(eval,errorPrefix) 
  local _g = __gmdebug_lua_Util.runCompiledFunction(_G.CompileString, eval, errorPrefix, false);
  local tmp = _g[1];
  if (tmp) == 0 then 
    do return __gmdebug_lua_CompileResult.Error(_g[2]) end;
  elseif (tmp) == 1 then 
    local _g = _g[2];
    if (_G.type(_g) == "string") then 
      do return __gmdebug_lua_CompileResult.Error(_g) end;
    else
      do return __gmdebug_lua_CompileResult.Success(_g) end;
    end; end;
end
__gmdebug_lua_Util.runCompiledFunction = function(compiledFunc,a,b,c,d,e) 
  local _hx_1_runResult_status, _hx_1_runResult_value = _G.pcall(compiledFunc, a, b, c, d, e);
  if (_hx_1_runResult_status) then 
    do return __gmdebug_lua_RunResult.Success(_hx_1_runResult_value) end;
  else
    do return __gmdebug_lua_RunResult.Error(_hx_1_runResult_value) end;
  end;
end

__gmdebug_lua_handlers_IHandler.new = {}
__gmdebug_lua_handlers_IHandler.__name__ = true
__gmdebug_lua_handlers_IHandler.prototype = _hx_e();
__gmdebug_lua_handlers_IHandler.prototype.handle= nil;

__gmdebug_lua_handlers_IHandler.prototype.__class__ =  __gmdebug_lua_handlers_IHandler

__gmdebug_lua_handlers_HConfigurationDone.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HConfigurationDone.prototype)
  __gmdebug_lua_handlers_HConfigurationDone.super(self,init)
  return self
end
__gmdebug_lua_handlers_HConfigurationDone.super = function(self,init) 
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HConfigurationDone.__name__ = true
__gmdebug_lua_handlers_HConfigurationDone.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HConfigurationDone.prototype = _hx_e();
__gmdebug_lua_handlers_HConfigurationDone.prototype.debugee= nil;
__gmdebug_lua_handlers_HConfigurationDone.prototype.handle = function(self,configRequest) 
  local rep = __gmdebug_composer_ComposeTools.compose(configRequest, "configurationDone", _hx_e());
  local _this = self.debugee;
  __haxe_Json.stringify(rep);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.CONFIG_DONE end
end

__gmdebug_lua_handlers_HConfigurationDone.prototype.__class__ =  __gmdebug_lua_handlers_HConfigurationDone

__gmdebug_lua_handlers_HContinue.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HContinue.prototype)
  __gmdebug_lua_handlers_HContinue.super(self,init)
  return self
end
__gmdebug_lua_handlers_HContinue.super = function(self,init) 
  self.variableManager = _hx_funcToField(init.vm);
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HContinue.__name__ = true
__gmdebug_lua_handlers_HContinue.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HContinue.prototype = _hx_e();
__gmdebug_lua_handlers_HContinue.prototype.variableManager= nil;
__gmdebug_lua_handlers_HContinue.prototype.debugee= nil;
__gmdebug_lua_handlers_HContinue.prototype.handle = function(self,contReq) 
  local resp = __gmdebug_composer_ComposeTools.compose(contReq, "_continue", _hx_o({__fields__={allThreadsContinued=true},allThreadsContinued=false}));
  local _this = self.debugee;
  __haxe_Json.stringify(resp);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  self.variableManager:resetVariables();
  do return __gmdebug_lua_handlers_HandlerResponse.CONTINUE end
end

__gmdebug_lua_handlers_HContinue.prototype.__class__ =  __gmdebug_lua_handlers_HContinue

__gmdebug_lua_handlers_HDisconnect.new = function() 
  local self = _hx_new(__gmdebug_lua_handlers_HDisconnect.prototype)
  __gmdebug_lua_handlers_HDisconnect.super(self)
  return self
end
__gmdebug_lua_handlers_HDisconnect.super = function(self) 
end
__gmdebug_lua_handlers_HDisconnect.__name__ = true
__gmdebug_lua_handlers_HDisconnect.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HDisconnect.prototype = _hx_e();
__gmdebug_lua_handlers_HDisconnect.prototype.handle = function(self,stepIn) 
  do return __gmdebug_lua_handlers_HandlerResponse.DISCONNECT end
end

__gmdebug_lua_handlers_HDisconnect.prototype.__class__ =  __gmdebug_lua_handlers_HDisconnect

__gmdebug_lua_handlers_HEvaluate.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HEvaluate.prototype)
  __gmdebug_lua_handlers_HEvaluate.super(self,init)
  return self
end
__gmdebug_lua_handlers_HEvaluate.super = function(self,init) 
  self.variableManager = _hx_funcToField(init.vm);
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HEvaluate.__name__ = true
__gmdebug_lua_handlers_HEvaluate.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HEvaluate.createEvalEnvironment = function(stackLevel) 
  local env = ({});
  local unsettables = ({});
  local set = function(k,v) 
    unsettables[k] = v;
  end;
  local info = _G.debug.getinfo(stackLevel, "f");
  local fenv = _G;
  if ((info ~= nil) and (info.func ~= nil)) then 
    local _g = 1;
    while (_g < 9999) do 
      _g = _g + 1;
      local i = _g - 1;
      local func = info.func;
      local _hx_1_upv_a, _hx_1_upv_b = _G.debug.getupvalue(func, i);
      if (_hx_1_upv_a == nil) then 
        break;
      end;
      set(_hx_1_upv_a, _hx_1_upv_b);
    end;
    local func = info.func;
    local value = _G.debug.getfenv(func);
    local defaultValue = _G;
    fenv = (function() 
      local _hx_2
      if (value == nil) then 
      _hx_2 = defaultValue; else 
      _hx_2 = value; end
      return _hx_2
    end )();
  end;
  local _g = 1;
  while (_g < 9999) do 
    _g = _g + 1;
    local i = _g - 1;
    local _hx_3_lcl_a, _hx_3_lcl_b = _G.debug.getlocal(stackLevel, i);
    if (_hx_3_lcl_a == nil) then 
      break;
    end;
    set(_hx_3_lcl_a, _hx_3_lcl_b);
  end;
  local metatable = ({});
  metatable.__newindex = function(t,k,v) 
    if (_G.rawget(unsettables, k) ~= nil) then 
      _G.error("Cannot alter upvalues and locals", 2);
    else
      fenv[k] = v;
    end;
  end;
  metatable.__index = unsettables;
  local unsetmeta = ({});
  unsetmeta.__index = function(t,k) 
    if (k == "_G") then 
      do return _G end;
    else
      do return fenv[k] end;
    end;
  end;
  _G.setmetatable(env, metatable);
  _G.setmetatable(unsettables, unsetmeta);
  do return env end;
end
__gmdebug_lua_handlers_HEvaluate.prototype = _hx_e();
__gmdebug_lua_handlers_HEvaluate.prototype.variableManager= nil;
__gmdebug_lua_handlers_HEvaluate.prototype.debugee= nil;
__gmdebug_lua_handlers_HEvaluate.prototype.processCommands = function(self,x) 
  if (x == "profile") then 
    __gmdebug_lua_DebugLoopProfile.beginProfiling();
  end;
end
__gmdebug_lua_handlers_HEvaluate.prototype.handle = function(self,evalReq) 
  local args = evalReq.arguments;
  local fid = args.frameId;
  if (_G.string.sub(args.expression, 1, 1) == "#") then 
    local _this = args.expression;
    local pos = 1;
    local len = nil;
    if ((len == nil) or (len > (pos + #_this))) then 
      len = #_this;
    else
      if (len < 0) then 
        len = #_this + len;
      end;
    end;
    if (pos < 0) then 
      pos = #_this + pos;
    end;
    if (pos < 0) then 
      pos = 0;
    end;
    self:processCommands(_G.string.sub(_this, pos + 1, pos + len));
  end;
  local expr = args.expression;
  local expr1;
  if (_G.string.sub(expr, 1, 1) == "!") then 
    local pos = 1;
    local len = nil;
    if ((len == nil) or (len > (pos + #expr))) then 
      len = #expr;
    else
      if (len < 0) then 
        len = #expr + len;
      end;
    end;
    if (pos < 0) then 
      pos = #expr + pos;
    end;
    if (pos < 0) then 
      pos = 0;
    end;
    expr1 = _G.string.sub(expr, pos + 1, pos + len);
  else
    expr1 = Std.string(Std.string("return ( ") .. Std.string(expr)) .. Std.string(" )");
  end;
  if (args.context == "hover") then 
    expr1 = _G.string.gsub(expr1, ":", ".");
  end;
  __haxe_Log.trace(Std.string("expr : ") .. Std.string(expr1), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/handlers/HEvaluate.hx",lineNumber=102,className="gmdebug.lua.handlers.HEvaluate",methodName="handle"}));
  local resp;
  local _g = __gmdebug_lua_Util.compileString(expr1, "GmDebug");
  local resp1 = _g[1];
  if (resp1) == 0 then 
    resp = __gmdebug_composer_ComposeTools.composeFail(evalReq, _G.string.gsub(_g[2], "^%[string %\"X%\"%]%:%d+%: ", ""));
  elseif (resp1) == 1 then 
    local func = _g[2];
    if (fid ~= nil) then 
      _G.setfenv(func, __gmdebug_lua_handlers_HEvaluate.createEvalEnvironment(__gmdebug__FrameID_FrameID_Impl_.getValue(fid).actualFrame + 2));
    end;
    local _g = __gmdebug_lua_Util.runCompiledFunction(func);
    local resp1 = _g[1];
    if (resp1) == 0 then 
      resp = __gmdebug_composer_ComposeTools.composeFail(evalReq, _G.string.gsub(_g[2], "^%[string %\"X%\"%]%:%d+%: ", ""));
    elseif (resp1) == 1 then 
      local item = self.variableManager:genvar(_hx_o({__fields__={name=true,value=true},name="",value=_g[2]}));
      resp = __gmdebug_composer_ComposeTools.compose(evalReq, "evaluate", _hx_o({__fields__={result=true,type=true,variablesReference=true},result=item.value,type=item.type,variablesReference=item.variablesReference})); end; end;
  local _this = self.debugee;
  __haxe_Json.stringify(resp);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HEvaluate.prototype.__class__ =  __gmdebug_lua_handlers_HEvaluate

__gmdebug_lua_handlers_HLoadedSources.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HLoadedSources.prototype)
  __gmdebug_lua_handlers_HLoadedSources.super(self,init)
  return self
end
__gmdebug_lua_handlers_HLoadedSources.super = function(self,init) 
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HLoadedSources.__name__ = true
__gmdebug_lua_handlers_HLoadedSources.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HLoadedSources.prototype = _hx_e();
__gmdebug_lua_handlers_HLoadedSources.prototype.debugee= nil;
__gmdebug_lua_handlers_HLoadedSources.prototype.handle = function(self,load) 
  local resp = __gmdebug_composer_ComposeTools.compose(load, "loadedSources", _hx_o({__fields__={sources=true},sources=_hx_tab_array({}, 0)}));
  local _this = self.debugee;
  __haxe_Json.stringify(resp);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HLoadedSources.prototype.__class__ =  __gmdebug_lua_handlers_HLoadedSources

__gmdebug_lua_handlers_HNext.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HNext.prototype)
  __gmdebug_lua_handlers_HNext.super(self,init)
  return self
end
__gmdebug_lua_handlers_HNext.super = function(self,init) 
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HNext.__name__ = true
__gmdebug_lua_handlers_HNext.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HNext.prototype = _hx_e();
__gmdebug_lua_handlers_HNext.prototype.debugee= nil;
__gmdebug_lua_handlers_HNext.prototype.handle = function(self,nextReq) 
  local resp = __gmdebug_composer_ComposeTools.compose(nextReq, "next");
  local tarheight = self.debugee:get_stackHeight() - __gmdebug_lua_StackConst.STEP;
  __haxe_Log.trace(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string("targeting ") .. Std.string(tarheight)) .. Std.string(" - (")) .. Std.string(self.debugee:get_stackHeight())) .. Std.string(" ")) .. Std.string(__gmdebug_lua_StackConst.STEP)) .. Std.string(")"), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/handlers/HNext.hx",lineNumber=18,className="gmdebug.lua.handlers.HNext",methodName="handle"}));
  self.debugee.state = __gmdebug_lua_DebugState.STEP(tarheight);
  local _this = self.debugee;
  __haxe_Json.stringify(resp);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "cl");
  __gmdebug_lua_DebugLoop.lineSteppin = true;
  do return __gmdebug_lua_handlers_HandlerResponse.CONTINUE end
end

__gmdebug_lua_handlers_HNext.prototype.__class__ =  __gmdebug_lua_handlers_HNext

__gmdebug_lua_handlers_HPause.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HPause.prototype)
  __gmdebug_lua_handlers_HPause.super(self,init)
  return self
end
__gmdebug_lua_handlers_HPause.super = function(self,init) 
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HPause.__name__ = true
__gmdebug_lua_handlers_HPause.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HPause.prototype = _hx_e();
__gmdebug_lua_handlers_HPause.prototype.debugee= nil;
__gmdebug_lua_handlers_HPause.prototype.handle = function(self,pauseReq) 
  local rep = __gmdebug_composer_ComposeTools.compose(pauseReq, "pause", _hx_e());
  local _this = self.debugee;
  __haxe_Json.stringify(rep);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  self.debugee:startHaltLoop("pause", __gmdebug_lua_StackConst.PAUSE);
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HPause.prototype.__class__ =  __gmdebug_lua_handlers_HPause

__gmdebug_lua_handlers_HScopes.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HScopes.prototype)
  __gmdebug_lua_handlers_HScopes.super(self,init)
  return self
end
__gmdebug_lua_handlers_HScopes.super = function(self,init) 
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HScopes.__name__ = true
__gmdebug_lua_handlers_HScopes.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HScopes.prototype = _hx_e();
__gmdebug_lua_handlers_HScopes.prototype.debugee= nil;
__gmdebug_lua_handlers_HScopes.prototype.handle = function(self,scopeReq) 
  local value = scopeReq.arguments;
  local args;
  if (value == nil) then 
    _G.error(__safety_NullPointerException.new("Null pointer in .sure() call"),0);
  else
    args = value;
  end;
  local frameInfo = __gmdebug__FrameID_FrameID_Impl_.getValue(args.frameId);
  local info = _G.debug.getinfo(frameInfo.actualFrame + 1, "fuS");
  local arguments = _hx_o({__fields__={name=true,presentationHint=true,variablesReference=true,expensive=true},name="Arguments",presentationHint="arguments",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.FrameLocal(self.debugee.clientID, frameInfo.actualFrame, 0)),expensive=false});
  local locals;
  if (info == nil) then 
    locals = nil;
  else
    local _g = info.activelines;
    local _g = info.currentline;
    local _g = info.func;
    local _g = info.isvararg;
    local _g = info.lastlinedefined;
    local _g1 = info.linedefined;
    local _g2 = info.name;
    local _g2 = info.namewhat;
    local _g2 = info.nparams;
    local _g2 = info.nups;
    local _g2 = info.short_src;
    local _g2 = info.source;
    local _g2 = info.what;
    if ((_g == nil) and (_g1 == nil)) then 
      locals = _hx_o({__fields__={name=true,presentationHint=true,variablesReference=true,expensive=true},name="Locals",presentationHint="locals",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.FrameLocal(self.debugee.clientID, frameInfo.actualFrame, 1)),expensive=false});
    else
      local lld = _g;
      local ld = _g1;
      locals = _hx_o({__fields__={name=true,presentationHint=true,variablesReference=true,expensive=true,line=true,endLine=true,column=true,endColumn=true},name="Locals",presentationHint="locals",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.FrameLocal(self.debugee.clientID, frameInfo.actualFrame, 1)),expensive=false,line=ld,endLine=lld,column=1,endColumn=99999});
    end;
  end;
  local upvalues = _hx_o({__fields__={name=true,variablesReference=true,expensive=true},name="Upvalues",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.FrameLocal(self.debugee.clientID, frameInfo.actualFrame, 2)),expensive=false});
  local globals = _hx_o({__fields__={name=true,variablesReference=true,expensive=true},name="Globals",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.Global(self.debugee.clientID, 0)),expensive=true});
  local players = _hx_o({__fields__={name=true,variablesReference=true,expensive=true},name="Players",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.Global(self.debugee.clientID, 1)),expensive=true});
  local entities = _hx_o({__fields__={name=true,variablesReference=true,expensive=true},name="Entities",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.Global(self.debugee.clientID, 2)),expensive=true});
  local enums = _hx_o({__fields__={name=true,variablesReference=true,expensive=true},name="Enums",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.Global(self.debugee.clientID, 3)),expensive=true});
  local env = _hx_o({__fields__={name=true,variablesReference=true,expensive=true},name="Function Environment",variablesReference=__gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.FrameLocal(self.debugee.clientID, frameInfo.actualFrame, 3)),expensive=true});
  local hasFenv;
  if ((info ~= nil) and (info.func ~= nil)) then 
    local func = info.func;
    hasFenv = _G.debug.getfenv(func) ~= _G;
  else
    hasFenv = false;
  end;
  local resp;
  if (info == nil) then 
    _G.print("No info?!", frameInfo.actualFrame + 1);
    resp = _hx_tab_array({[0]=globals, entities, players, enums}, 4);
  else
    local _g = info.activelines;
    local _g = info.currentline;
    local _g = info.func;
    local _g = info.isvararg;
    local _g = info.lastlinedefined;
    local _g = info.linedefined;
    local _g = info.name;
    local _g = info.namewhat;
    local _g = info.nparams;
    local _g = info.nups;
    local _g = info.short_src;
    local _g = info.source;
    local _g = info.what;
    if (_g) == "C" then 
      resp = _hx_tab_array({[0]=arguments, locals, globals, entities, players, enums}, 6);
    elseif (_g) == "Lua" then 
      resp = (function() 
        local _hx_1
        if (hasFenv) then 
        _hx_1 = _hx_tab_array({[0]=arguments, locals, upvalues, env, globals, entities, players, enums}, 8); else 
        _hx_1 = _hx_tab_array({[0]=arguments, locals, upvalues, globals, entities, players, enums}, 7); end
        return _hx_1
      end )();
    elseif (_g) == "main" then 
      resp = _hx_tab_array({[0]=locals, upvalues, env, globals, entities, players, enums}, 7);else
    _G.print("OH GOD", info.what);
    resp = _hx_tab_array({[0]=globals, entities, players, enums}, 4); end;
  end;
  local resp = __gmdebug_composer_ComposeTools.compose(scopeReq, "scopes", _hx_o({__fields__={scopes=true},scopes=resp}));
  local js = __tink_json_Writer45.new():write(resp);
  local _this = self.debugee;
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HScopes.prototype.__class__ =  __gmdebug_lua_handlers_HScopes

__gmdebug_lua_handlers_HSetBreakpoints.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HSetBreakpoints.prototype)
  __gmdebug_lua_handlers_HSetBreakpoints.super(self,init)
  return self
end
__gmdebug_lua_handlers_HSetBreakpoints.super = function(self,init) 
  self.bm = _hx_funcToField(init.bm);
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HSetBreakpoints.__name__ = true
__gmdebug_lua_handlers_HSetBreakpoints.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HSetBreakpoints.prototype = _hx_e();
__gmdebug_lua_handlers_HSetBreakpoints.prototype.bm= nil;
__gmdebug_lua_handlers_HSetBreakpoints.prototype.debugee= nil;
__gmdebug_lua_handlers_HSetBreakpoints.prototype.handle = function(self,req) 
  local args = req.arguments;
  local bpResponse = _hx_tab_array({}, 0);
  self.bm:clearBreakpoints(args.source.path);
  if (args.breakpoints ~= nil) then 
    local _g = 0;
    local _g1 = args.breakpoints;
    while (_g < _g1.length) do 
      local bp = _g1[_g];
      _g = _g + 1;
      local breakPoint = self.bm:newBreakpoint(args.source, bp);
      bpResponse:push(_hx_o({__fields__={line=true,message=true,verified=true},line=breakPoint.line,message=breakPoint.message,verified=breakPoint.verified}));
    end;
  end;
  local resp = __gmdebug_composer_ComposeTools.compose(req, "setBreakpoints", _hx_o({__fields__={breakpoints=true},breakpoints=bpResponse}));
  __tink_json_Writer46.new():write(resp);
  local _this = self.debugee;
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HSetBreakpoints.prototype.__class__ =  __gmdebug_lua_handlers_HSetBreakpoints

__gmdebug_lua_handlers_HSetExceptionBreakpoints.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HSetExceptionBreakpoints.prototype)
  __gmdebug_lua_handlers_HSetExceptionBreakpoints.super(self,init)
  return self
end
__gmdebug_lua_handlers_HSetExceptionBreakpoints.super = function(self,init) 
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HSetExceptionBreakpoints.__name__ = true
__gmdebug_lua_handlers_HSetExceptionBreakpoints.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HSetExceptionBreakpoints.prototype = _hx_e();
__gmdebug_lua_handlers_HSetExceptionBreakpoints.prototype.debugee= nil;
__gmdebug_lua_handlers_HSetExceptionBreakpoints.prototype.handle = function(self,x) 
  local resp = __gmdebug_composer_ComposeTools.compose(x, "setExceptionBreakpoints");
  local gamemodeSet = false;
  local entitiesSet = false;
  local _g = 0;
  local _g1 = x.arguments.filters;
  while (_g < _g1.length) do 
    local filter = _g1[_g];
    _g = _g + 1;
    local filter = filter;
    if (filter) == "entities" then 
      __gmdebug_lua_Exceptions.hookEntityHooks();
      entitiesSet = true;
    elseif (filter) == "gamemode" then 
      __gmdebug_lua_Exceptions.hookGamemodeHooks();
      gamemodeSet = true; end;
  end;
  if (not gamemodeSet) then 
    __gmdebug_lua_Exceptions.unhookGamemodeHooks();
  end;
  if (not entitiesSet) then 
    __gmdebug_lua_Exceptions.unhookEntityHooks();
  end;
  local _this = self.debugee;
  __haxe_Json.stringify(resp);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HSetExceptionBreakpoints.prototype.__class__ =  __gmdebug_lua_handlers_HSetExceptionBreakpoints

__gmdebug_lua_handlers_HSetFunctionBreakpoints.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HSetFunctionBreakpoints.prototype)
  __gmdebug_lua_handlers_HSetFunctionBreakpoints.super(self,init)
  return self
end
__gmdebug_lua_handlers_HSetFunctionBreakpoints.super = function(self,init) 
  self.fbm = _hx_funcToField(init.fbm);
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HSetFunctionBreakpoints.__name__ = true
__gmdebug_lua_handlers_HSetFunctionBreakpoints.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HSetFunctionBreakpoints.prototype = _hx_e();
__gmdebug_lua_handlers_HSetFunctionBreakpoints.prototype.fbm= nil;
__gmdebug_lua_handlers_HSetFunctionBreakpoints.prototype.debugee= nil;
__gmdebug_lua_handlers_HSetFunctionBreakpoints.prototype.handle = function(self,req) 
  local _this = self.fbm.functionBP;
  _this.h = ({});
  _this.k = ({});
  local bpResponse = _hx_tab_array({}, 0);
  local _g = 0;
  local _g1 = req.arguments.breakpoints;
  while (_g < _g1.length) do 
    local fbp = _g1[_g];
    _g = _g + 1;
    local expr = fbp.name;
    local eval;
    if (_G.string.sub(expr, 1, 1) == "!") then 
      local pos = 1;
      local len = nil;
      if ((len == nil) or (len > (pos + #expr))) then 
        len = #expr;
      else
        if (len < 0) then 
          len = #expr + len;
        end;
      end;
      if (pos < 0) then 
        pos = #expr + pos;
      end;
      if (pos < 0) then 
        pos = 0;
      end;
      eval = _G.string.sub(expr, pos + 1, pos + len);
    else
      eval = Std.string(Std.string("return ( ") .. Std.string(expr)) .. Std.string(" )");
    end;
    local resp;
    local _g = __gmdebug_lua_Util.compileString(eval, "gmdebug FuncBp:");
    local resp1 = _g[1];
    if (resp1) == 0 then 
      resp = _hx_o({__fields__={verified=true,message=true},verified=false,message="Failed to compile"});
    elseif (resp1) == 1 then 
      local _hx_tmp = __gmdebug_lua_Util.runCompiledFunction(_g[2]);
      local resp1 = _hx_tmp[1];
      if (resp1) == 0 then 
        resp = _hx_o({__fields__={verified=true,message=true},verified=false,message="Failed to run"});
      elseif (resp1) == 1 then 
        local _g = _hx_tmp[2];
        if (_G.type(_g) ~= "function") then 
          resp = _hx_o({__fields__={verified=true,message=true},verified=false,message="Result is not a function"});
        else
          local _this = self.fbm.functionBP;
          local key = _g;
          _this.h[key] = true;
          _this.k[key] = true;
          resp = _hx_o({__fields__={verified=true},verified=true});
        end; end; end;
    bpResponse:push(resp);
  end;
  local resp = __gmdebug_composer_ComposeTools.compose(req, "setFunctionBreakpoints", _hx_o({__fields__={breakpoints=true},breakpoints=bpResponse}));
  local _this = self.debugee;
  __haxe_Json.stringify(resp);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HSetFunctionBreakpoints.prototype.__class__ =  __gmdebug_lua_handlers_HSetFunctionBreakpoints

__gmdebug_lua_handlers_HStackTrace.new = function(init) 
  local self = _hx_new(__gmdebug_lua_handlers_HStackTrace.prototype)
  __gmdebug_lua_handlers_HStackTrace.super(self,init)
  return self
end
__gmdebug_lua_handlers_HStackTrace.super = function(self,init) 
  self.debugee = _hx_funcToField(init.debugee);
end
__gmdebug_lua_handlers_HStackTrace.__name__ = true
__gmdebug_lua_handlers_HStackTrace.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HStackTrace.prototype = _hx_e();
__gmdebug_lua_handlers_HStackTrace.prototype.debugee= nil;
__gmdebug_lua_handlers_HStackTrace.prototype.handle = function(self,x) 
  local args = x.arguments;
  if (not self.debugee.pauseLoopActive) then 
    local response = __gmdebug_composer_ComposeTools.compose(x, "stackTrace", _hx_o({__fields__={stackFrames=true,totalFrames=true},stackFrames=_hx_tab_array({}, 0),totalFrames=0}));
    __tink_json_Writer48.new():write(response);
    local _this = self.debugee;
    local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
    _this.socket.output:writeString(str);
    _this.socket.output:flush();
    local _this = self.debugee;
    __haxe_Json.stringify(__gmdebug_composer_ComposedEvent.new("continued", _hx_o({__fields__={threadId=true,allThreadsContinued=true},threadId=self.debugee.clientID,allThreadsContinued=false})));
    local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
    _this.socket.output:writeString(str);
    _this.socket.output:flush();
    do return __gmdebug_lua_handlers_HandlerResponse.WAIT end;
  end;
  local min = 0;
  local max = __gmdebug_lua_DebugLoop.STACK_LIMIT;
  local middle = _G.math.floor((max - min) / 2);
  while (true) do 
    if (_G.debug.getinfo(middle) == nil) then 
      max = middle;
      middle = _G.math.floor((max - min) / 2) + min;
    else
      min = middle;
      middle = _G.math.floor((max - min) / 2) + min;
    end;
    if (middle == min) then 
      break;
    end;
  end;
  local len = middle - self.debugee.baseDepth;
  local firstFrame;
  local _g = args.startFrame;
  if (_g == nil) then 
    local value = self.debugee.baseDepth;
    if (value == nil) then 
      _G.error(__safety_NullPointerException.new("Null pointer in .sure() call"),0);
    else
      firstFrame = value;
    end;
  else
    local value = self.debugee.baseDepth;
    local firstFrame1;
    if (value == nil) then 
      _G.error(__safety_NullPointerException.new("Null pointer in .sure() call"),0);
    else
      firstFrame1 = value;
    end;
    firstFrame = _g + firstFrame1;
  end;
  local _g = args.levels;
  local stackFrames = _hx_tab_array({}, 0);
  local _g1 = firstFrame;
  local _g = (function() 
    local _hx_1
    if (_g == nil) then 
    _hx_1 = 9999; elseif (_g == 0) then 
    _hx_1 = 9999; else 
    _hx_1 = firstFrame + _g; end
    return _hx_1
  end )();
  while (_g1 < _g) do 
    _g1 = _g1 + 1;
    local i = _g1 - 1;
    local info = _G.debug.getinfo(i + 1, "lnSfu");
    if (info == nil) then 
      break;
    end;
    local src;
    if (_G.string.sub(info.source, 1, 1) == "@") then 
      local _this = info.source;
      local pos = 1;
      local len = nil;
      if ((len == nil) or (len > (pos + #_this))) then 
        len = #_this;
      else
        if (len < 0) then 
          len = #_this + len;
        end;
      end;
      if (pos < 0) then 
        pos = #_this + pos;
      end;
      if (pos < 0) then 
        pos = 0;
      end;
      src = _G.string.sub(_this, pos + 1, pos + len);
    else
      src = info.source;
    end;
    local args = "";
    if (info.nparams > 0) then 
      args = "(";
      local _g = 0;
      local _g1 = info.nparams;
      while (_g < _g1) do 
        _g = _g + 1;
        local _hx_2_lcl_a, _hx_2_lcl_b = _G.debug.getlocal(i + 1, (_g - 1) + 1);
        local val;
        local _g = _G.type(_hx_2_lcl_b);
        if (_g) == "string" then 
          val = Std.string(Std.string("\"") .. Std.string(Std.string(_hx_2_lcl_b))) .. Std.string("\"");
        elseif (_g) == "table" then 
          val = "table";else
        val = _G.tostring(_hx_2_lcl_b); end;
        args = Std.string(args) .. Std.string((Std.string(Std.string(Std.string(Std.string("") .. Std.string(_hx_2_lcl_a)) .. Std.string("=")) .. Std.string(val)) .. Std.string(",")));
      end;
      local _g = 1;
      while (_g < 9999) do 
        _g = _g + 1;
        local _hx_3_lcl_a, _hx_3_lcl_b = _G.debug.getlocal(i + 1, -(_g - 1));
        if (_hx_3_lcl_a == nil) then 
          break;
        end;
        local val;
        local _g = _G.type(_hx_3_lcl_b);
        if (_g) == "string" then 
          val = Std.string(Std.string("\"") .. Std.string(Std.string(_hx_3_lcl_b))) .. Std.string("\"");
        elseif (_g) == "table" then 
          val = "table";else
        val = _G.tostring(_hx_3_lcl_b); end;
        args = Std.string(args) .. Std.string((Std.string(Std.string(Std.string(Std.string("") .. Std.string(_hx_3_lcl_a)) .. Std.string("=")) .. Std.string(val)) .. Std.string(",")));
      end;
      local pos = 0;
      local len = #args - 1;
      if ((len == nil) or (len > (pos + #args))) then 
        len = #args;
      else
        if (len < 0) then 
          len = #args + len;
        end;
      end;
      if (pos < 0) then 
        pos = #args + pos;
      end;
      if (pos < 0) then 
        pos = 0;
      end;
      args = Std.string(_G.string.sub(args, pos + 1, pos + len)) .. Std.string(")");
    end;
    local _g = info.name;
    local _g1 = info.namewhat;
    local name = (function() 
      local _hx_4
      if (_g == nil) then 
      _hx_4 = (function() 
        local _hx_5
        if (_g1 == "") then 
        _hx_5 = Std.string("anonymous function ") .. Std.string(args); else 
        _hx_5 = Std.string(Std.string(Std.string(Std.string(Std.string("[") .. Std.string(_g1)) .. Std.string("] ")) .. Std.string(_g)) .. Std.string(" ")) .. Std.string(args); end
        return _hx_5
      end )(); else 
      _hx_4 = Std.string(Std.string(Std.string(Std.string(Std.string("[") .. Std.string(_g1)) .. Std.string("] ")) .. Std.string(_g)) .. Std.string(" ")) .. Std.string(args); end
      return _hx_4
    end )();
    local path;
    local hint;
    local line;
    local column;
    local endLine = nil;
    local endColumn = nil;
    if (src == "=[C]") then 
      hint = "deemphasize";
      path = nil;
      line = 0;
      column = 0;
    else
      local len = len;
      if (((len > 80) and (i > 45)) and ((i - 5) < (len - 40))) then 
        path = self.debugee:normalPath(src);
        hint = "deemphasize";
        line = info.currentline;
        column = 1;
        endLine = info.lastlinedefined;
        endColumn = 99999;
      else
        path = self.debugee:normalPath(src);
        hint = nil;
        line = info.currentline;
        column = 1;
        endLine = info.lastlinedefined;
        endColumn = 99999;
      end;
    end;
    hint = "normal";
    if ((info.func ~= nil) and (__gmdebug_lua_Exceptions.exceptFuncs.k[info.func] ~= nil)) then 
      line = 0;
      path = nil;
      column = 0;
      hint = "deemphasize";
      name = "Exception catcher";
    else
      hint = "normal";
    end;
    local value = self.debugee.clientID;
    local clientID;
    if (value == nil) then 
      _G.error(__safety_NullPointerException.new("Null pointer in .sure() call"),0);
    else
      clientID = value;
    end;
    local target = _hx_bit.bor(_hx_bit.lshift(clientID,27),i);
    local target1;
    if (path == nil) then 
      target1 = nil;
    else
      local path = path;
      local idx = 1;
      local ret = _hx_tab_array({}, 0);
      while (idx ~= nil) do 
        local newidx = 0;
        if (#"/" > 0) then 
          newidx = _G.string.find(path, "/", idx, true);
        else
          if (idx >= #path) then 
            newidx = nil;
          else
            newidx = idx + 1;
          end;
        end;
        if (newidx ~= nil) then 
          ret:push(_G.string.sub(path, idx, newidx - 1));
          idx = newidx + #"/";
        else
          ret:push(_G.string.sub(path, idx, #path));
          idx = nil;
        end;
      end;
      local pth = ret;
      target1 = _hx_o({__fields__={name=true,path=true,presentationHint=true},name=pth[pth.length - 1],path=path,presentationHint=hint});
    end;
    local target = _hx_o({__fields__={id=true,name=true,source=true,line=true,column=true,endLine=true,endColumn=true},id=target,name=name,source=target1,line=line,column=column,endLine=endLine,endColumn=endColumn});
    if (path ~= nil) then 
      target.source.path = path;
    end;
    stackFrames:push(target);
  end;
  local response = __gmdebug_composer_ComposeTools.compose(x, "stackTrace", _hx_o({__fields__={stackFrames=true,totalFrames=true},stackFrames=stackFrames,totalFrames=len}));
  __tink_json_Writer48.new():write(response);
  local _this = self.debugee;
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HStackTrace.prototype.__class__ =  __gmdebug_lua_handlers_HStackTrace

__gmdebug_lua_handlers_HStepIn.new = function(initHStepIn) 
  local self = _hx_new(__gmdebug_lua_handlers_HStepIn.prototype)
  __gmdebug_lua_handlers_HStepIn.super(self,initHStepIn)
  return self
end
__gmdebug_lua_handlers_HStepIn.super = function(self,initHStepIn) 
  self.debugee = _hx_funcToField(initHStepIn.debugee);
end
__gmdebug_lua_handlers_HStepIn.__name__ = true
__gmdebug_lua_handlers_HStepIn.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HStepIn.prototype = _hx_e();
__gmdebug_lua_handlers_HStepIn.prototype.debugee= nil;
__gmdebug_lua_handlers_HStepIn.prototype.handle = function(self,stepInReq) 
  self.debugee.state = __gmdebug_lua_DebugState.STEP(nil);
  local rep = __gmdebug_composer_ComposeTools.compose(stepInReq, "stepIn");
  local _this = self.debugee;
  __haxe_Json.stringify(rep);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "cl");
  __gmdebug_lua_DebugLoop.lineSteppin = true;
  do return __gmdebug_lua_handlers_HandlerResponse.CONTINUE end
end

__gmdebug_lua_handlers_HStepIn.prototype.__class__ =  __gmdebug_lua_handlers_HStepIn

__gmdebug_lua_handlers_HStepOut.new = function(initHStepOut) 
  local self = _hx_new(__gmdebug_lua_handlers_HStepOut.prototype)
  __gmdebug_lua_handlers_HStepOut.super(self,initHStepOut)
  return self
end
__gmdebug_lua_handlers_HStepOut.super = function(self,initHStepOut) 
  self.debugee = _hx_funcToField(initHStepOut.debugee);
end
__gmdebug_lua_handlers_HStepOut.__name__ = true
__gmdebug_lua_handlers_HStepOut.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HStepOut.prototype = _hx_e();
__gmdebug_lua_handlers_HStepOut.prototype.debugee= nil;
__gmdebug_lua_handlers_HStepOut.prototype.handle = function(self,stepOutReq) 
  local tarheight = (self.debugee:get_stackHeight() - __gmdebug_lua_StackConst.STEP) - 1;
  __haxe_Log.trace(Std.string(Std.string(Std.string(Std.string(Std.string("stepOut ") .. Std.string(Std.string(tarheight < __gmdebug_lua_StackConst.MIN_HEIGHT))) .. Std.string(" : ")) .. Std.string(tarheight)) .. Std.string(" ")) .. Std.string(__gmdebug_lua_StackConst.MIN_HEIGHT), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/handlers/HStepOut.hx",lineNumber=20,className="gmdebug.lua.handlers.HStepOut",methodName="handle"}));
  if (tarheight <= __gmdebug_lua_StackConst.MIN_HEIGHT) then 
    local info = _G.debug.getinfo(self.debugee.baseDepth + 1, "fLSl");
    local func = info.func;
    __haxe_Log.trace(Std.string("") .. Std.string(info.source), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/handlers/HStepOut.hx",lineNumber=24,className="gmdebug.lua.handlers.HStepOut",methodName="handle"}));
    local lowest = LuaLambdaKeys.fold(info.activelines, function(line,res) 
      if (line < res) then 
        do return line end;
      else
        do return res end;
      end;
    end, _G.math.huge);
    __haxe_Log.trace(Std.string("lowest ") .. Std.string(lowest), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/handlers/HStepOut.hx",lineNumber=33,className="gmdebug.lua.handlers.HStepOut",methodName="handle"}));
    self.debugee.state = __gmdebug_lua_DebugState.OUT(func, lowest - 1, tarheight + 1);
  else
    self.debugee.state = __gmdebug_lua_DebugState.STEP(tarheight);
  end;
  _G.DebugHook.addHook("gmdebug", __gmdebug_lua_DebugLoop.debugloop, "cl");
  __gmdebug_lua_DebugLoop.lineSteppin = true;
  local stepoutResp = __gmdebug_composer_ComposeTools.compose(stepOutReq, "stepOut");
  local _this = self.debugee;
  __haxe_Json.stringify(stepoutResp);
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.CONTINUE end
end

__gmdebug_lua_handlers_HStepOut.prototype.__class__ =  __gmdebug_lua_handlers_HStepOut

__gmdebug_lua_handlers_HVariables.new = function(initHVariables) 
  local self = _hx_new(__gmdebug_lua_handlers_HVariables.prototype)
  __gmdebug_lua_handlers_HVariables.super(self,initHVariables)
  return self
end
__gmdebug_lua_handlers_HVariables.super = function(self,initHVariables) 
  self.debugee = _hx_funcToField(initHVariables.debugee);
  self.variableManager = _hx_funcToField(initHVariables.vm);
end
__gmdebug_lua_handlers_HVariables.__name__ = true
__gmdebug_lua_handlers_HVariables.__interfaces__ = {__gmdebug_lua_handlers_IHandler}
__gmdebug_lua_handlers_HVariables.prototype = _hx_e();
__gmdebug_lua_handlers_HVariables.prototype.variableManager= nil;
__gmdebug_lua_handlers_HVariables.prototype.debugee= nil;
__gmdebug_lua_handlers_HVariables.prototype.realChild = function(self,storedvar,addVars) 
  local _g = _G.TypeID(storedvar);
  if (_g) == _G.TYPE_ENTITY then 
    local ent = storedvar;
    local tbl = storedvar:GetTable();
    addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true},name="(position)",value=ent:GetPos(),virtual=true}));
    addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true},name="(angle)",value=ent:GetAngles(),virtual=true}));
    addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true},name="(model)",value=ent:GetModel(),virtual=true}));
    local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(tbl);
    local _g_lnext = _hx_1_p_next;
    local _hx_2_init_index, _hx_2_init_value = _g_lnext(tbl, _hx_1_p_index);
    local _g_nextV = _hx_2_init_value;
    local _g_nextI = _hx_2_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_3_nextResult_index, _hx_3_nextResult_value = _g_lnext(tbl, _g_nextI);
      _g_nextI = _hx_3_nextResult_index;
      _g_nextV = _hx_3_nextResult_value;
      addVars:push(_hx_o({__fields__={name=true,value=true},name=i,value=v}));
    end;
  elseif (_g) == _G.TYPE_FUNCTION then 
    local info = _G.debug.getinfo(storedvar, "S");
    addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true,noquote=true},name="(source)",value=_G.tostring(info.short_src),virtual=true,noquote=true}));
    addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true},name="(line)",value=info.linedefined,virtual=true}));
    local fenv = _G.debug.getfenv(storedvar);
    if (fenv ~= nil) then 
      addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true},name="(fenv)",value=fenv,virtual=true}));
    end;
    if (debug.getupvalue(storedvar, 1) ~= nil) then 
      addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true},name="(upvalues)",value=self:generateFakeChild(storedvar, __gmdebug_lua_handlers_FakeChild.Upvalues),virtual=true}));
    end;
  elseif (_g) == _G.TYPE_TABLE then 
    local x = storedvar;
    local _hx_4_p_next, _hx_4_p_table, _hx_4_p_index = _G.pairs(x);
    local _g_lnext = _hx_4_p_next;
    local _hx_5_init_index, _hx_5_init_value = _g_lnext(x, _hx_4_p_index);
    local _g_nextV = _hx_5_init_value;
    local _g_nextI = _hx_5_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_6_nextResult_index, _hx_6_nextResult_value = _g_lnext(x, _g_nextI);
      _g_nextI = _hx_6_nextResult_index;
      _g_nextV = _hx_6_nextResult_value;
      addVars:push(_hx_o({__fields__={name=true,value=true},name=i,value=v}));
    end;else end;
end
__gmdebug_lua_handlers_HVariables.prototype.fakeChild = function(self,realChild,type,addVars) 
  local _g = 1;
  while (_g < 9999) do 
    _g = _g + 1;
    local _hx_1_upv_a, _hx_1_upv_b = _G.debug.getupvalue(realChild, _g - 1);
    if (_hx_1_upv_a == nil) then 
      break;
    end;
    addVars:push(_hx_o({__fields__={name=true,value=true},name=_hx_1_upv_a,value=_hx_1_upv_b}));
  end;
end
__gmdebug_lua_handlers_HVariables.prototype.generateFakeChild = function(self,child,type) 
  local tab = ({});
  local meta = ({});
  local fakechild = ({});
  _G.setmetatable(tab, meta);
  meta.__gmdebugFakeChild = fakechild;
  fakechild.child = child;
  fakechild.type = type;
  do return tab end
end
__gmdebug_lua_handlers_HVariables.prototype.child = function(self,ref) 
  local addVars = _hx_tab_array({}, 0);
  local storedvar = self.variableManager:getVar(ref);
  if (storedvar == nil) then 
    __haxe_Log.trace(Std.string("Variable requested with nothing stored! ") .. Std.string(ref), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/handlers/HVariables.hx",lineNumber=95,className="gmdebug.lua.handlers.HVariables",methodName="child"}));
  end;
  local mt = _G.debug.getmetatable(storedvar);
  if (mt ~= nil) then 
    if (mt.__gmdebugFakeChild ~= nil) then 
      self:fakeChild(mt.__gmdebugFakeChild.child, mt.__gmdebugFakeChild.type, addVars);
    else
      addVars:push(_hx_o({__fields__={name=true,value=true,virtual=true},name="(metatable)",value=mt,virtual=true}));
      self:realChild(storedvar, addVars);
    end;
  else
    self:realChild(storedvar, addVars);
  end;
  do return addVars end
end
__gmdebug_lua_handlers_HVariables.prototype.frameLocal = function(self,frame,scope) 
  local addVars = _hx_tab_array({}, 0);
  if (scope) == 0 then 
    local _g = 1;
    local _g1 = _G.debug.getinfo(frame + 2, "u").nparams + 1;
    while (_g < _g1) do 
      _g = _g + 1;
      local _hx_1_result_a, _hx_1_result_b = _G.debug.getlocal(frame + 2, _g - 1);
      if (_hx_1_result_a == nil) then 
        break;
      end;
      addVars:push(_hx_o({__fields__={name=true,value=true},name=_hx_1_result_a,value=_hx_1_result_b}));
    end;
    local _g = 1;
    while (_g < 9999) do 
      _g = _g + 1;
      local _hx_2_result_a, _hx_2_result_b = _G.debug.getlocal(frame + 2, -(_g - 1));
      if (_hx_2_result_a == nil) then 
        break;
      end;
      addVars:push(_hx_o({__fields__={name=true,value=true},name=_hx_2_result_a,value=_hx_2_result_b}));
    end;
  elseif (scope) == 1 then 
    local _g = 1;
    while (_g < 9999) do 
      _g = _g + 1;
      local _hx_3_result_a, _hx_3_result_b = _G.debug.getlocal(frame + 2, _g - 1);
      if (_hx_3_result_a == nil) then 
        break;
      end;
      addVars:push(_hx_o({__fields__={name=true,value=true},name=_hx_3_result_a,value=_hx_3_result_b}));
    end;
    local _g = 1;
    while (_g < 9999) do 
      _g = _g + 1;
      local _hx_4_result_a, _hx_4_result_b = _G.debug.getlocal(frame + 2, -(_g - 1));
      if (_hx_4_result_a == nil) then 
        break;
      end;
      addVars:push(_hx_o({__fields__={name=true,value=true},name=_hx_4_result_a,value=_hx_4_result_b}));
    end;
  elseif (scope) == 2 then 
    local info = _G.debug.getinfo(frame + 2, "f");
    if ((info ~= nil) and (info.func ~= nil)) then 
      local _g = 1;
      while (_g < 9999) do 
        _g = _g + 1;
        local _hx_5_upv_a, _hx_5_upv_b = _G.debug.getupvalue(info.func, _g - 1);
        if (_hx_5_upv_a == nil) then 
          break;
        end;
        addVars:push(_hx_o({__fields__={name=true,value=true},name=_hx_5_upv_a,value=_hx_5_upv_b}));
      end;
    end;
  elseif (scope) == 3 then 
    local info = _G.debug.getinfo(frame + 2, "f");
    if ((info ~= nil) and (info.func ~= nil)) then 
      local tbl = _G.debug.getfenv(info.func);
      local _hx_6_p_next, _hx_6_p_table, _hx_6_p_index = _G.pairs(tbl);
      local _g_lnext = _hx_6_p_next;
      local _hx_7_init_index, _hx_7_init_value = _g_lnext(tbl, _hx_6_p_index);
      local _g_nextV = _hx_7_init_value;
      local _g_nextI = _hx_7_init_index;
      while (_g_nextV ~= nil) do 
        local v = _g_nextV;
        local i = _g_nextI;
        local _hx_8_nextResult_index, _hx_8_nextResult_value = _g_lnext(tbl, _g_nextI);
        _g_nextI = _hx_8_nextResult_index;
        _g_nextV = _hx_8_nextResult_value;
        addVars:push(_hx_o({__fields__={name=true,value=true},name=i,value=v}));
      end;
    end; end;
  do return addVars end
end
__gmdebug_lua_handlers_HVariables.prototype.global = function(self,scope) 
  local addVars = _hx_tab_array({}, 0);
  local scope = scope;
  if (scope) == 0 then 
    local _g = _G;
    local sort = _hx_tab_array({}, 0);
    addVars:push(_hx_o({__fields__={name=true,value=true},name="_G",value=""}));
    local x = _g;
    local _g_tbl = x;
    local _hx_1_p_next, _hx_1_p_table, _hx_1_p_index = _G.pairs(x);
    local _g_lnext = _hx_1_p_next;
    local _hx_2_init_index, _hx_2_init_value = _g_lnext(_g_tbl, _hx_1_p_index);
    local _g_nextV = _hx_2_init_value;
    local _g_nextI = _hx_2_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_3_nextResult_index, _hx_3_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
      _g_nextI = _hx_3_nextResult_index;
      _g_nextV = _hx_3_nextResult_value;
      local _g1_key = i;
      local _g1_value = v;
      local i = _g1_key;
      local x = _g1_value;
      if (_G.type(i) == "string") then 
        if (not self:isEnum(i, x)) then 
          sort:push(i);
        end;
      end;
    end;
    local _g1 = 0;
    while (_g1 < sort.length) do 
      local index = sort[_g1];
      _g1 = _g1 + 1;
      if (_G.type(index) == "string") then 
        addVars:push(_hx_o({__fields__={name=true,value=true},name=index,value=Reflect.field(_g, index)}));
      end;
    end;
  elseif (scope) == 1 then 
    local x = _G.player.GetAll();
    local _g_tbl = x;
    local _hx_4_p_next, _hx_4_p_table, _hx_4_p_index = _G.ipairs(x);
    local _g_lnext = _hx_4_p_next;
    local _hx_5_init_index, _hx_5_init_value = _g_lnext(_g_tbl, _hx_4_p_index);
    local _g_nextV = _hx_5_init_value;
    local _g_nextI = _hx_5_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_6_nextResult_index, _hx_6_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
      _g_nextI = _hx_6_nextResult_index;
      _g_nextV = _hx_6_nextResult_value;
      local _g1_key = i;
      local _g1_value = v;
      local i = _g1_key;
      local ply = _g1_value;
      __haxe_Log.trace(Std.string(Std.string(Std.string("players ") .. Std.string(i)) .. Std.string(" ")) .. Std.string(Std.string(ply)), _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/handlers/HVariables.hx",lineNumber=201,className="gmdebug.lua.handlers.HVariables",methodName="global"}));
      addVars:push(_hx_o({__fields__={name=true,value=true},name=ply:GetName(),value=ply}));
    end;
  elseif (scope) == 2 then 
    local ents = _G.ents.GetAll();
    local _g = 1;
    local _g1 = _G.ents.GetCount();
    while (_g < _g1) do 
      _g = _g + 1;
      local i = _g - 1;
      local ent = ents[i];
      addVars:push(_hx_o({__fields__={name=true,value=true},name=ent:GetClass(),value=ent}));
    end;
  elseif (scope) == 3 then 
    local _g = _G;
    local x = _g;
    local _g_tbl = x;
    local _hx_7_p_next, _hx_7_p_table, _hx_7_p_index = _G.pairs(x);
    local _g_lnext = _hx_7_p_next;
    local _hx_8_init_index, _hx_8_init_value = _g_lnext(_g_tbl, _hx_7_p_index);
    local _g_nextV = _hx_8_init_value;
    local _g_nextI = _hx_8_init_index;
    while (_g_nextV ~= nil) do 
      local v = _g_nextV;
      local i = _g_nextI;
      local _hx_9_nextResult_index, _hx_9_nextResult_value = _g_lnext(_g_tbl, _g_nextI);
      _g_nextI = _hx_9_nextResult_index;
      _g_nextV = _hx_9_nextResult_value;
      local _g1_key = i;
      local _g1_value = v;
      local i = _g1_key;
      local x = _g1_value;
      if (_G.type(i) == "string") then 
        if (self:isEnum(i, x)) then 
          addVars:push(_hx_o({__fields__={name=true,value=true},name=i,value=x}));
        end;
      end;
    end;else
  _G.error(__haxe_Exception.thrown("Unhandled scope"),0); end;
  do return addVars end
end
__gmdebug_lua_handlers_HVariables.prototype.isEnum = function(self,index,value) 
  if ((_G.string.match(index, "%u", 1) ~= nil) and (_G.string.match(index, "%u", 2) ~= nil)) then 
    do return _G.type(value) == "number" end;
  else
    do return false end;
  end;
end
__gmdebug_lua_handlers_HVariables.prototype.fixupNames = function(self,variables) 
  local varnamecount_h = ({});
  local _g = 0;
  while (_g < variables.length) do 
    local v = variables[_g];
    _g = _g + 1;
    local ret = varnamecount_h[v.name];
    if (ret == __haxe_ds_StringMap.tnull) then 
      ret = nil;
    end;
    local count = ret;
    if (count ~= nil) then 
      local key = v.name;
      local value = count + 1;
      if (value == nil) then 
        varnamecount_h[key] = __haxe_ds_StringMap.tnull;
      else
        varnamecount_h[key] = value;
      end;
      v.name = Std.string(Std.string(Std.string(Std.string("") .. Std.string(v.name)) .. Std.string(" (")) .. Std.string(count)) .. Std.string(")");
    else
      varnamecount_h[v.name] = 1;
    end;
  end;
end
__gmdebug_lua_handlers_HVariables.prototype.handle = function(self,req) 
  local addVars;
  local _g = __gmdebug__VariableReference_VariableReference_Impl_.getValue(req.arguments.variablesReference);
  local addVars1 = _g[1];
  if (addVars1) == 0 then 
    addVars = self:child(_g[3]);
  elseif (addVars1) == 1 then 
    addVars = self:frameLocal(_g[3], _g[4]);
  elseif (addVars1) == 2 then 
    addVars = self:global(_g[3]); end;
  local f = (function() local __=self.variableManager; return _hx_bind(__,__.genvar) end)();
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = addVars;
  while (_g1 < _g2.length) do 
    local i = _g2[_g1];
    _g1 = _g1 + 1;
    _g:push(f(i));
  end;
  local variablesArr = _g;
  self:fixupNames(variablesArr);
  local resp = __gmdebug_composer_ComposeTools.compose(req, "variables", _hx_o({__fields__={variables=true},variables=variablesArr}));
  __tink_json_Writer47.new():write(resp);
  local _this = self.debugee;
  local str = "Content-Length: " .. _hx_wrap_if_string_field(json,'length') .. "\r\n\r\n" .. json;
  _this.socket.output:writeString(str);
  _this.socket.output:flush();
  do return __gmdebug_lua_handlers_HandlerResponse.WAIT end
end

__gmdebug_lua_handlers_HVariables.prototype.__class__ =  __gmdebug_lua_handlers_HVariables
_hxClasses["gmdebug.lua.handlers.FakeChild"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="Upvalues"},1)}
__gmdebug_lua_handlers_FakeChild = _hxClasses["gmdebug.lua.handlers.FakeChild"];
__gmdebug_lua_handlers_FakeChild.Upvalues = _hx_tab_array({[0]="Upvalues",0,__enum__ = __gmdebug_lua_handlers_FakeChild},2)

_hxClasses["gmdebug.lua.handlers.HandlerResponse"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="WAIT","CONTINUE","DISCONNECT","CONFIG_DONE"},4)}
__gmdebug_lua_handlers_HandlerResponse = _hxClasses["gmdebug.lua.handlers.HandlerResponse"];
__gmdebug_lua_handlers_HandlerResponse.WAIT = _hx_tab_array({[0]="WAIT",0,__enum__ = __gmdebug_lua_handlers_HandlerResponse},2)

__gmdebug_lua_handlers_HandlerResponse.CONTINUE = _hx_tab_array({[0]="CONTINUE",1,__enum__ = __gmdebug_lua_handlers_HandlerResponse},2)

__gmdebug_lua_handlers_HandlerResponse.DISCONNECT = _hx_tab_array({[0]="DISCONNECT",2,__enum__ = __gmdebug_lua_handlers_HandlerResponse},2)

__gmdebug_lua_handlers_HandlerResponse.CONFIG_DONE = _hx_tab_array({[0]="CONFIG_DONE",3,__enum__ = __gmdebug_lua_handlers_HandlerResponse},2)


__gmdebug_lua_io_DebugIO.new = {}
__gmdebug_lua_io_DebugIO.__name__ = true
__gmdebug_lua_io_DebugIO.prototype = _hx_e();
__gmdebug_lua_io_DebugIO.prototype.input= nil;
__gmdebug_lua_io_DebugIO.prototype.output= nil;
__gmdebug_lua_io_DebugIO.prototype.close= nil;

__gmdebug_lua_io_DebugIO.prototype.__class__ =  __gmdebug_lua_io_DebugIO

__gmdebug_lua_io_PipeSocket.new = function() 
  local self = _hx_new(__gmdebug_lua_io_PipeSocket.prototype)
  __gmdebug_lua_io_PipeSocket.super(self)
  return self
end
__gmdebug_lua_io_PipeSocket.super = function(self) 
  _G.file.Write(__gmdebug_Cross.CLIENT_READY, "");
  if (not _G.file.Exists(__gmdebug_Cross.READY, "DATA")) then 
    _G.error(__haxe_Exception.thrown("Other process is not ready."),0);
  end;
  _G.file.Delete(__gmdebug_Cross.READY);
  _G.file.Delete(__gmdebug_Cross.CLIENT_READY);
  self.input = __gmdebug_lua_io_PipeInput.new();
  self.output = __gmdebug_lua_io_PipeOutput.new();
end
__gmdebug_lua_io_PipeSocket.__name__ = true
__gmdebug_lua_io_PipeSocket.__interfaces__ = {__gmdebug_lua_io_DebugIO}
__gmdebug_lua_io_PipeSocket.prototype = _hx_e();
__gmdebug_lua_io_PipeSocket.prototype.input= nil;
__gmdebug_lua_io_PipeSocket.prototype.output= nil;
__gmdebug_lua_io_PipeSocket.prototype.close = function(self) 
  self.input:close();
  self.output:close();
end

__gmdebug_lua_io_PipeSocket.prototype.__class__ =  __gmdebug_lua_io_PipeSocket

__haxe_io_Input.new = {}
__haxe_io_Input.__name__ = true
__haxe_io_Input.prototype = _hx_e();
__haxe_io_Input.prototype.readByte = function(self) 
  _G.error(__haxe_exceptions_NotImplementedException.new(nil, nil, _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="haxe/io/Input.hx",lineNumber=53,className="haxe.io.Input",methodName="readByte"})),0);
end
__haxe_io_Input.prototype.readBytes = function(self,s,pos,len) 
  local k = len;
  local b = s.b;
  if (((pos < 0) or (len < 0)) or ((pos + len) > s.length)) then 
    _G.error(__haxe_Exception.thrown(__haxe_io_Error.OutsideBounds),0);
  end;
  local _hx_status, _hx_result = pcall(function() 
  
      while (k > 0) do 
        b[pos] = self:readByte();
        pos = pos + 1;
        k = k - 1;
      end;
    return _hx_pcall_default
  end)
  if not _hx_status and _hx_result == "_hx_pcall_break" then
  elseif not _hx_status then 
    local _g = _hx_result;
    if (not __lua_Boot.__instanceof(__haxe_Exception.caught(_g):unwrap(), __haxe_io_Eof)) then 
      _G.error(_g,0);
    end;
  elseif _hx_result ~= _hx_pcall_default then
    return _hx_result
  end;
  do return len - k end
end
__haxe_io_Input.prototype.close = function(self) 
end
__haxe_io_Input.prototype.readFullBytes = function(self,s,pos,len) 
  while (len > 0) do 
    local k = self:readBytes(s, pos, len);
    if (k == 0) then 
      _G.error(__haxe_Exception.thrown(__haxe_io_Error.Blocked),0);
    end;
    pos = pos + k;
    len = len - k;
  end;
end
__haxe_io_Input.prototype.readLine = function(self) 
  local buf = __haxe_io_BytesBuffer.new();
  local last;
  local s;
  local _hx_status, _hx_result = pcall(function() 
  
      while (true) do 
        last = self:readByte();
        if (not (last ~= 10)) then 
          break;
        end;
        buf.b:push(last);
      end;
      s = buf:getBytes():toString();
      if (_G.string.byte(s, (#s - 1) + 1) == 13) then 
        local len = -1;
        if (-1 > #s) then 
          len = #s;
        else
          len = #s + -1;
        end;
        s = _G.string.sub(s, 1, len);
      end;
    return _hx_pcall_default
  end)
  if not _hx_status and _hx_result == "_hx_pcall_break" then
  elseif not _hx_status then 
    local _g = _hx_result;
    local _g1 = __haxe_Exception.caught(_g):unwrap();
    if (__lua_Boot.__instanceof(_g1, __haxe_io_Eof)) then 
      s = buf:getBytes():toString();
      if (#s == 0) then 
        _G.error(__haxe_Exception.thrown(_g1),0);
      end;
    else
      _G.error(_g,0);
    end;
  elseif _hx_result ~= _hx_pcall_default then
    return _hx_result
  end;
  do return s end
end
__haxe_io_Input.prototype.readString = function(self,len,encoding) 
  local b = __haxe_io_Bytes.alloc(len);
  self:readFullBytes(b, 0, len);
  do return b:getString(0, len, encoding) end
end

__haxe_io_Input.prototype.__class__ =  __haxe_io_Input

__gmdebug_lua_io_PipeInput.new = function() 
  local self = _hx_new(__gmdebug_lua_io_PipeInput.prototype)
  __gmdebug_lua_io_PipeInput.super(self)
  return self
end
__gmdebug_lua_io_PipeInput.super = function(self) 
  __haxe_Log.trace("Input exists", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/io/PipeSocket.hx",lineNumber=40,className="gmdebug.lua.io.PipeInput",methodName="new"}));
  if (not _G.file.Exists(__gmdebug_Cross.INPUT, "DATA")) then 
    _G.error(__haxe_Exception.thrown("Input pipe does not exist"),0);
  end;
  __haxe_Log.trace("input open", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/io/PipeSocket.hx",lineNumber=44,className="gmdebug.lua.io.PipeInput",methodName="new"}));
  local f = _G.file.Open(__gmdebug_Cross.INPUT, "rb", "DATA");
  if (f == nil) then 
    _G.error(__haxe_Exception.thrown("Cannot open Input pipe for reading"),0);
  end;
  self.file = f;
end
__gmdebug_lua_io_PipeInput.__name__ = true
__gmdebug_lua_io_PipeInput.prototype = _hx_e();
__gmdebug_lua_io_PipeInput.prototype.file= nil;
__gmdebug_lua_io_PipeInput.prototype.readByte = function(self) 
  do return self.file:ReadByte() end
end

__gmdebug_lua_io_PipeInput.prototype.__class__ =  __gmdebug_lua_io_PipeInput
__gmdebug_lua_io_PipeInput.__super__ = __haxe_io_Input
setmetatable(__gmdebug_lua_io_PipeInput.prototype,{__index=__haxe_io_Input.prototype})

__haxe_io_Output.new = {}
__haxe_io_Output.__name__ = true
__haxe_io_Output.prototype = _hx_e();
__haxe_io_Output.prototype.writeByte = function(self,c) 
  _G.error(__haxe_exceptions_NotImplementedException.new(nil, nil, _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="haxe/io/Output.hx",lineNumber=47,className="haxe.io.Output",methodName="writeByte"})),0);
end
__haxe_io_Output.prototype.writeBytes = function(self,s,pos,len) 
  if (((pos < 0) or (len < 0)) or ((pos + len) > s.length)) then 
    _G.error(__haxe_Exception.thrown(__haxe_io_Error.OutsideBounds),0);
  end;
  local b = s.b;
  local k = len;
  while (k > 0) do 
    self:writeByte(b[pos]);
    pos = pos + 1;
    k = k - 1;
  end;
  do return len end
end
__haxe_io_Output.prototype.flush = function(self) 
end
__haxe_io_Output.prototype.writeFullBytes = function(self,s,pos,len) 
  while (len > 0) do 
    local k = self:writeBytes(s, pos, len);
    pos = pos + k;
    len = len - k;
  end;
end
__haxe_io_Output.prototype.writeString = function(self,s,encoding) 
  local b = __haxe_io_Bytes.ofString(s, encoding);
  self:writeFullBytes(b, 0, b.length);
end

__haxe_io_Output.prototype.__class__ =  __haxe_io_Output

__gmdebug_lua_io_PipeOutput.new = function() 
  local self = _hx_new(__gmdebug_lua_io_PipeOutput.prototype)
  __gmdebug_lua_io_PipeOutput.super(self)
  return self
end
__gmdebug_lua_io_PipeOutput.super = function(self) 
  __haxe_Log.trace("output open", _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="src/gmdebug/lua/io/PipeSocket.hx",lineNumber=64,className="gmdebug.lua.io.PipeOutput",methodName="new"}));
  local f = _G.file.Open(__gmdebug_Cross.OUTPUT, "w", "DATA");
  if (f == nil) then 
    _G.error(__haxe_Exception.thrown("Cannot open output pipe for reading"),0);
  end;
  self.file = f;
end
__gmdebug_lua_io_PipeOutput.__name__ = true
__gmdebug_lua_io_PipeOutput.prototype = _hx_e();
__gmdebug_lua_io_PipeOutput.prototype.file= nil;
__gmdebug_lua_io_PipeOutput.prototype.close = function(self) 
  self.file:Close();
end
__gmdebug_lua_io_PipeOutput.prototype.flush = function(self) 
  self.file:Flush();
end
__gmdebug_lua_io_PipeOutput.prototype.writeString = function(self,s,encoding) 
  self.file:Write(s);
end

__gmdebug_lua_io_PipeOutput.prototype.__class__ =  __gmdebug_lua_io_PipeOutput
__gmdebug_lua_io_PipeOutput.__super__ = __haxe_io_Output
setmetatable(__gmdebug_lua_io_PipeOutput.prototype,{__index=__haxe_io_Output.prototype})

__gmdebug_lua_managers_BreakpointManager.new = function(initBreakpointManager) 
  local self = _hx_new(__gmdebug_lua_managers_BreakpointManager.prototype)
  __gmdebug_lua_managers_BreakpointManager.super(self,initBreakpointManager)
  return self
end
__gmdebug_lua_managers_BreakpointManager.super = function(self,initBreakpointManager) 
  self.bpID = 0;
  self.breakpoints = __haxe_ds_StringMap.new();
  self.breakLocsCache = __haxe_ds_StringMap.new();
  self.debugee = _hx_funcToField(initBreakpointManager.debugee);
end
__gmdebug_lua_managers_BreakpointManager.__name__ = true
__gmdebug_lua_managers_BreakpointManager.prototype = _hx_e();
__gmdebug_lua_managers_BreakpointManager.prototype.breakLocsCache= nil;
__gmdebug_lua_managers_BreakpointManager.prototype.breakpoints= nil;
__gmdebug_lua_managers_BreakpointManager.prototype.bpID= nil;
__gmdebug_lua_managers_BreakpointManager.prototype.debugee= nil;
__gmdebug_lua_managers_BreakpointManager.prototype.clearBreakpoints = function(self,source) 
  local this1 = self.breakpoints;
  local key;
  local _g = self.debugee:fullPathToGmod(source);
  local key1 = _g[1];
  if (key1) == 0 then 
    key = _g[2];
  elseif (key1) == 1 then 
    key = source; end;
  local value = __haxe_ds_IntMap.new();
  local _this = this1;
  local key = key;
  if (value == nil) then 
    _this.h[key] = __haxe_ds_StringMap.tnull;
  else
    _this.h[key] = value;
  end;
end
__gmdebug_lua_managers_BreakpointManager.prototype.retrieveBreakpointTable = function(self,source) 
  local ret = self.breakpoints.h[source];
  if (ret == __haxe_ds_StringMap.tnull) then 
    ret = nil;
  end;
  local _g = ret;
  if (_g == nil) then 
    local map = __haxe_ds_IntMap.new();
    local _this = self.breakpoints;
    local key = source;
    if (map == nil) then 
      _this.h[key] = __haxe_ds_StringMap.tnull;
    else
      _this.h[key] = map;
    end;
    do return map end;
  else
    do return _g end;
  end;
end
__gmdebug_lua_managers_BreakpointManager.prototype.valid = function(self) 
  do return self.breakpoints ~= nil end
end
__gmdebug_lua_managers_BreakpointManager.prototype.breakpointWithinRange = function(self,source,min,max) 
  local ret = self.breakpoints.h[source];
  if (ret == __haxe_ds_StringMap.tnull) then 
    ret = nil;
  end;
  local bpTable = ret;
  if (bpTable == nil) then 
    do return false end;
  end;
  local k = bpTable:keys();
  while (k:hasNext()) do 
    local k = k:next();
    if ((k >= min) and (k <= max)) then 
      do return true end;
    end;
  end;
  do return false end
end
__gmdebug_lua_managers_BreakpointManager.prototype.getBreakpointForLine = function(self,source,line) 
  local ret = self.breakpoints.h[source];
  if (ret == __haxe_ds_StringMap.tnull) then 
    ret = nil;
  end;
  local bp = ret;
  if (bp == nil) then 
    do return nil end;
  else
    local ret = bp.h[line];
    if (ret == __haxe_ds_IntMap.tnull) then 
      ret = nil;
    end;
    do return ret end;
  end;
end
__gmdebug_lua_managers_BreakpointManager.prototype.newBreakpoint = function(self,source,bp) 
  local status;
  local _g = self.debugee:fullPathToGmod(source.path);
  local status1 = _g[1];
  if (status1) == 0 then 
    status = self:breakpointStatus(_g[2], bp.line);
  elseif (status1) == 1 then 
    status = __gmdebug_lua_managers_LineStatus.NOT_VISITED; end;
  local breakpoint = __gmdebug_lua_managers_Breakpoint.new((function() 
  local _hx_obj = self;
  local _hx_fld = 'bpID';
  local _ = _hx_obj[_hx_fld];
  _hx_obj[_hx_fld] = _hx_obj[_hx_fld]  + 1;
   return _;
   end)(), source, bp, status);
  if (breakpoint.breakpointType ~= __gmdebug_lua_managers_BreakpointType.INACTIVE) then 
    local source = source.path;
    local map;
    local _g = self.debugee:fullPathToGmod(source);
    local map1 = _g[1];
    if (map1) == 0 then 
      map = _g[2];
    elseif (map1) == 1 then 
      map = source; end;
    local map = self:retrieveBreakpointTable(map);
    local key = breakpoint.line;
    if (breakpoint == nil) then 
      map.h[key] = __haxe_ds_IntMap.tnull;
    else
      map.h[key] = breakpoint;
    end;
  end;
  do return breakpoint end
end
__gmdebug_lua_managers_BreakpointManager.prototype.breakpointStatus = function(self,path,line) 
  local ret = self.breakLocsCache.h[path];
  if (ret == __haxe_ds_StringMap.tnull) then 
    ret = nil;
  end;
  local possibles = ret;
  if (possibles == nil) then 
    do return __gmdebug_lua_managers_LineStatus.NOT_VISITED end;
  else
    local ret = possibles.h[line];
    if (ret == __haxe_ds_IntMap.tnull) then 
      ret = nil;
    end;
    local _hx_tmp = ret;
    if (_hx_tmp == nil) then 
      do return __gmdebug_lua_managers_LineStatus.UNKNOWN end;
    else
      if (_hx_tmp) then 
        do return __gmdebug_lua_managers_LineStatus.CONFIRMED end;
      else
        do return __gmdebug_lua_managers_LineStatus.NOT_ACTIVE end;
      end;
    end;
  end;
end

__gmdebug_lua_managers_BreakpointManager.prototype.__class__ =  __gmdebug_lua_managers_BreakpointManager
_hxClasses["gmdebug.lua.managers.LineStatus"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="UNKNOWN","NOT_ACTIVE","NOT_VISITED","CONFIRMED"},4)}
__gmdebug_lua_managers_LineStatus = _hxClasses["gmdebug.lua.managers.LineStatus"];
__gmdebug_lua_managers_LineStatus.UNKNOWN = _hx_tab_array({[0]="UNKNOWN",0,__enum__ = __gmdebug_lua_managers_LineStatus},2)

__gmdebug_lua_managers_LineStatus.NOT_ACTIVE = _hx_tab_array({[0]="NOT_ACTIVE",1,__enum__ = __gmdebug_lua_managers_LineStatus},2)

__gmdebug_lua_managers_LineStatus.NOT_VISITED = _hx_tab_array({[0]="NOT_VISITED",2,__enum__ = __gmdebug_lua_managers_LineStatus},2)

__gmdebug_lua_managers_LineStatus.CONFIRMED = _hx_tab_array({[0]="CONFIRMED",3,__enum__ = __gmdebug_lua_managers_LineStatus},2)


__gmdebug_lua_managers_Breakpoint.new = function(id,source,bp,ls) 
  local self = _hx_new(__gmdebug_lua_managers_Breakpoint.prototype)
  __gmdebug_lua_managers_Breakpoint.super(self,id,source,bp,ls)
  return self
end
__gmdebug_lua_managers_Breakpoint.super = function(self,id,source,bp,ls) 
  self.message = "";
  self.verified = false;
  self.id = id;
  self.path = _hx_funcToField(source.path);
  self.line = _hx_funcToField(bp.line);
  local tmp = ls[1];
  if (tmp) == 0 then 
    self.verified = true;
    self.message = "This breakpoint could not be confirmed.";
  elseif (tmp) == 1 then 
    self.verified = false;
    self.message = "Lua does not consider this an active line.";
  elseif (tmp) == 2 then 
    self.verified = true;
    self.message = "This file has not been visited by running code yet.";
  elseif (tmp) == 3 then 
    self.verified = true; end;
  local tmp;
  if (bp.condition == nil) then 
    tmp = __gmdebug_lua_managers_BreakpointType.NORMAL;
  else
    local expr = bp.condition;
    local eval;
    if (_G.string.sub(expr, 1, 1) == "!") then 
      local len = nil;
      len = #expr;
      eval = _G.string.sub(expr, 2, 1 + len);
    else
      eval = Std.string(Std.string("return ( ") .. Std.string(expr)) .. Std.string(" )");
    end;
    local _g = __gmdebug_lua_Util.compileString(eval, "Gmdebug Conditional BP: ");
    local tmp1 = _g[1];
    if (tmp1) == 0 then 
      self.verified = false;
      self.message = Std.string("Failed to compile condition ") .. Std.string(_g[2]);
      tmp = __gmdebug_lua_managers_BreakpointType.INACTIVE;
    elseif (tmp1) == 1 then 
      tmp = __gmdebug_lua_managers_BreakpointType.CONDITIONAL(_g[2]); end;
  end;
  self.breakpointType = tmp;
end
__gmdebug_lua_managers_Breakpoint.__name__ = true
__gmdebug_lua_managers_Breakpoint.prototype = _hx_e();
__gmdebug_lua_managers_Breakpoint.prototype.breakpointType= nil;
__gmdebug_lua_managers_Breakpoint.prototype.id= nil;
__gmdebug_lua_managers_Breakpoint.prototype.line= nil;
__gmdebug_lua_managers_Breakpoint.prototype.path= nil;
__gmdebug_lua_managers_Breakpoint.prototype.verified= nil;
__gmdebug_lua_managers_Breakpoint.prototype.message= nil;

__gmdebug_lua_managers_Breakpoint.prototype.__class__ =  __gmdebug_lua_managers_Breakpoint
_hxClasses["gmdebug.lua.managers.BreakpointType"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="INACTIVE","NORMAL","CONDITIONAL"},3)}
__gmdebug_lua_managers_BreakpointType = _hxClasses["gmdebug.lua.managers.BreakpointType"];
__gmdebug_lua_managers_BreakpointType.INACTIVE = _hx_tab_array({[0]="INACTIVE",0,__enum__ = __gmdebug_lua_managers_BreakpointType},2)

__gmdebug_lua_managers_BreakpointType.NORMAL = _hx_tab_array({[0]="NORMAL",1,__enum__ = __gmdebug_lua_managers_BreakpointType},2)

__gmdebug_lua_managers_BreakpointType.CONDITIONAL = function(condition) local _x = _hx_tab_array({[0]="CONDITIONAL",2,condition,__enum__=__gmdebug_lua_managers_BreakpointType}, 3); return _x; end 

__gmdebug_lua_managers_FunctionBreakpointManager.new = function() 
  local self = _hx_new(__gmdebug_lua_managers_FunctionBreakpointManager.prototype)
  __gmdebug_lua_managers_FunctionBreakpointManager.super(self)
  return self
end
__gmdebug_lua_managers_FunctionBreakpointManager.super = function(self) 
  self.functionBP = __haxe_ds_ObjectMap.new();
end
__gmdebug_lua_managers_FunctionBreakpointManager.__name__ = true
__gmdebug_lua_managers_FunctionBreakpointManager.prototype = _hx_e();
__gmdebug_lua_managers_FunctionBreakpointManager.prototype.functionBP= nil;

__gmdebug_lua_managers_FunctionBreakpointManager.prototype.__class__ =  __gmdebug_lua_managers_FunctionBreakpointManager

__gmdebug_lua_managers_VariableManager.new = function(initVariableManager) 
  local self = _hx_new(__gmdebug_lua_managers_VariableManager.prototype)
  __gmdebug_lua_managers_VariableManager.super(self,initVariableManager)
  return self
end
__gmdebug_lua_managers_VariableManager.super = function(self,initVariableManager) 
  self.storedVariables = _hx_tab_array({[0]=nil}, 1);
  self.debugee = _hx_funcToField(initVariableManager.debugee);
end
__gmdebug_lua_managers_VariableManager.__name__ = true
__gmdebug_lua_managers_VariableManager.prototype = _hx_e();
__gmdebug_lua_managers_VariableManager.prototype.storedVariables= nil;
__gmdebug_lua_managers_VariableManager.prototype.debugee= nil;
__gmdebug_lua_managers_VariableManager.prototype.resetVariables = function(self) 
  self.storedVariables = _hx_tab_array({[0]=nil}, 1);
end
__gmdebug_lua_managers_VariableManager.prototype.getVar = function(self,ind) 
  do return self.storedVariables[ind] end
end
__gmdebug_lua_managers_VariableManager.prototype.genvar = function(self,addv) 
  local name = Std.string(addv.name);
  local val = addv.value;
  local virtual = addv.virtual;
  local noquote = addv.noquote;
  local novalue = addv.novalue;
  local ty = _G.type(val);
  local id = _G.TypeID(val);
  local stringReplace;
  local _g = _G.type(val);
  if (_g) == "number" then 
    stringReplace = Std.string(val);
  elseif (_g) == "string" then 
    stringReplace = val;
  elseif (_g) == "table" then 
    stringReplace = "table";else
  stringReplace = _G.tostring(val); end;
  local obj;
  if (ty) == "string" then 
    obj = (function() 
      local _hx_1
      if (noquote == nil) then 
      _hx_1 = Std.string(Std.string("\"") .. Std.string(stringReplace)) .. Std.string("\""); elseif (novalue == nil) then 
      _hx_1 = stringReplace; elseif (novalue == true) then 
      _hx_1 = ""; else 
      _hx_1 = stringReplace; end
      return _hx_1
    end )();
  elseif (ty) == "table" then 
    obj = "table";else
  obj = (function() 
    local _hx_2
    if (novalue == nil) then 
    _hx_2 = stringReplace; elseif (novalue == true) then 
    _hx_2 = ""; else 
    _hx_2 = stringReplace; end
    return _hx_2
  end )(); end;
  local obj1;
  if (name == "_G") then 
    obj1 = 0;
  else
    if (id) == _G.TYPE_ENTITY then 
      obj1 = (function() 
        local _hx_3
        if (not _G.IsValid(val)) then 
        _hx_3 = 0; else 
        _hx_3 = __gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.Child(self.debugee.clientID, self.storedVariables:push(val) - 1)); end
        return _hx_3
      end )();
    elseif (id) == _G.TYPE_FUNCTION or (id) == _G.TYPE_TABLE or (id) == _G.TYPE_USERDATA then 
      obj1 = __gmdebug__VariableReference_VariableReference_Impl_.encode(__gmdebug_VariableReferenceVal.Child(self.debugee.clientID, self.storedVariables:push(val) - 1));else
    obj1 = 0; end;
  end;
  local obj = _hx_o({__fields__={name=true,type=true,value=true,variablesReference=true},name=name,type=ty,value=obj,variablesReference=obj1});
  if (id == _G.TYPE_FUNCTION) then 
    if (virtual == nil) then 
      obj.presentationHint = _hx_o({__fields__={kind=true,attributes=true,visibility=true},kind="method",attributes=nil,visibility="public"});
    else
      obj.presentationHint = _hx_o({__fields__={kind=true,attributes=true,visibility=true},kind="virtual",attributes=nil,visibility="internal"});
    end;
  else
    if (virtual ~= nil) then 
      obj.presentationHint = _hx_o({__fields__={kind=true,attributes=true,visibility=true},kind="virtual",attributes=nil,visibility="internal"});
    end;
  end;
  do return obj end
end

__gmdebug_lua_managers_VariableManager.prototype.__class__ =  __gmdebug_lua_managers_VariableManager

__gmdebug_lua_util__Util_Util_Fields_.new = {}
__gmdebug_lua_util__Util_Util_Fields_.__name__ = true
__gmdebug_lua_util__Util_Util_Fields_.isLan = function() 
  do return _G.GetConVar("sv_lan"):GetBool() end;
end

__gmod_helpers_macros_include_Build.new = {}
__gmod_helpers_macros_include_Build.__name__ = true

__gmod_helpers_macros_include___ForceExpose.new = {}
_hx_exports["__forceExpose"] = __gmod_helpers_macros_include___ForceExpose
__gmod_helpers_macros_include___ForceExpose.__name__ = true
_hxClasses["haxe.StackItem"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="CFunction","Module","FilePos","Method","LocalFunction"},5)}
__haxe_StackItem = _hxClasses["haxe.StackItem"];
__haxe_StackItem.CFunction = _hx_tab_array({[0]="CFunction",0,__enum__ = __haxe_StackItem},2)

__haxe_StackItem.Module = function(m) local _x = _hx_tab_array({[0]="Module",1,m,__enum__=__haxe_StackItem}, 3); return _x; end 
__haxe_StackItem.FilePos = function(s,file,line,column) local _x = _hx_tab_array({[0]="FilePos",2,s,file,line,column,__enum__=__haxe_StackItem}, 6); return _x; end 
__haxe_StackItem.Method = function(classname,method) local _x = _hx_tab_array({[0]="Method",3,classname,method,__enum__=__haxe_StackItem}, 4); return _x; end 
__haxe_StackItem.LocalFunction = function(v) local _x = _hx_tab_array({[0]="LocalFunction",4,v,__enum__=__haxe_StackItem}, 3); return _x; end 

__haxe__CallStack_CallStack_Impl_.new = {}
__haxe__CallStack_CallStack_Impl_.__name__ = true
__haxe__CallStack_CallStack_Impl_.toString = function(stack) 
  local b = StringBuf.new();
  local _g = 0;
  local _g1 = stack;
  while (_g < _g1.length) do 
    local s = _g1[_g];
    _g = _g + 1;
    _G.table.insert(b.b, "\nCalled from ");
    b.length = b.length + #"\nCalled from ";
    __haxe__CallStack_CallStack_Impl_.itemToString(b, s);
  end;
  do return _G.table.concat(b.b) end;
end
__haxe__CallStack_CallStack_Impl_.subtract = function(this1,stack) 
  local startIndex = -1;
  local i = -1;
  while (true) do 
    i = i + 1;
    if (not (i < this1.length)) then 
      break;
    end;
    local _g = 0;
    local _g1 = stack.length;
    while (_g < _g1) do 
      _g = _g + 1;
      if (__haxe__CallStack_CallStack_Impl_.equalItems(this1[i], stack[_g - 1])) then 
        if (startIndex < 0) then 
          startIndex = i;
        end;
        i = i + 1;
        if (i >= this1.length) then 
          break;
        end;
      else
        startIndex = -1;
      end;
    end;
    if (startIndex >= 0) then 
      break;
    end;
  end;
  if (startIndex >= 0) then 
    do return this1:slice(0, startIndex) end;
  else
    do return this1 end;
  end;
end
__haxe__CallStack_CallStack_Impl_.equalItems = function(item1,item2) 
  if (item1 == nil) then 
    if (item2 == nil) then 
      do return true end;
    else
      do return false end;
    end;
  else
    local tmp = item1[1];
    if (tmp) == 0 then 
      if (item2 == nil) then 
        do return false end;
      else
        if (item2[1] == 0) then 
          do return true end;
        else
          do return false end;
        end;
      end;
    elseif (tmp) == 1 then 
      if (item2 == nil) then 
        do return false end;
      else
        if (item2[1] == 1) then 
          do return item1[2] == item2[2] end;
        else
          do return false end;
        end;
      end;
    elseif (tmp) == 2 then 
      if (item2 == nil) then 
        do return false end;
      else
        if (item2[1] == 2) then 
          if (((item1[3] == item2[3]) and (item1[4] == item2[4])) and (item1[5] == item2[5])) then 
            do return __haxe__CallStack_CallStack_Impl_.equalItems(item1[2], item2[2]) end;
          else
            do return false end;
          end;
        else
          do return false end;
        end;
      end;
    elseif (tmp) == 3 then 
      if (item2 == nil) then 
        do return false end;
      else
        if (item2[1] == 3) then 
          if (item1[2] == item2[2]) then 
            do return item1[3] == item2[3] end;
          else
            do return false end;
          end;
        else
          do return false end;
        end;
      end;
    elseif (tmp) == 4 then 
      if (item2 == nil) then 
        do return false end;
      else
        if (item2[1] == 4) then 
          do return item1[2] == item2[2] end;
        else
          do return false end;
        end;
      end; end;
  end;
end
__haxe__CallStack_CallStack_Impl_.itemToString = function(b,s) 
  local tmp = s[1];
  if (tmp) == 0 then 
    _G.table.insert(b.b, "a C function");
    b.length = b.length + #"a C function";
  elseif (tmp) == 1 then 
    _G.table.insert(b.b, "module ");
    b.length = b.length + #"module ";
    local str = Std.string(s[2]);
    _G.table.insert(b.b, str);
    b.length = b.length + #str;
  elseif (tmp) == 2 then 
    local _g = s[2];
    local _g1 = s[5];
    if (_g ~= nil) then 
      __haxe__CallStack_CallStack_Impl_.itemToString(b, _g);
      _G.table.insert(b.b, " (");
      b.length = b.length + #" (";
    end;
    local str = Std.string(s[3]);
    _G.table.insert(b.b, str);
    b.length = b.length + #str;
    _G.table.insert(b.b, " line ");
    b.length = b.length + #" line ";
    local str = Std.string(s[4]);
    _G.table.insert(b.b, str);
    b.length = b.length + #str;
    if (_g1 ~= nil) then 
      _G.table.insert(b.b, " column ");
      b.length = b.length + #" column ";
      local str = Std.string(_g1);
      _G.table.insert(b.b, str);
      b.length = b.length + #str;
    end;
    if (_g ~= nil) then 
      _G.table.insert(b.b, ")");
      b.length = b.length + #")";
    end;
  elseif (tmp) == 3 then 
    local _g = s[2];
    local str = Std.string((function() 
      local _hx_1
      if (_g == nil) then 
      _hx_1 = "<unknown>"; else 
      _hx_1 = _g; end
      return _hx_1
    end )());
    _G.table.insert(b.b, str);
    b.length = b.length + #str;
    _G.table.insert(b.b, ".");
    b.length = b.length + #".";
    local str = Std.string(s[3]);
    _G.table.insert(b.b, str);
    b.length = b.length + #str;
  elseif (tmp) == 4 then 
    _G.table.insert(b.b, "local function #");
    b.length = b.length + #"local function #";
    local str = Std.string(s[2]);
    _G.table.insert(b.b, str);
    b.length = b.length + #str; end;
end

__haxe_EntryPoint.new = {}
__haxe_EntryPoint.__name__ = true
__haxe_EntryPoint.processEvents = function() 
  while (true) do 
    local f = __haxe_EntryPoint.pending:shift();
    if (f == nil) then 
      break;
    end;
    f();
  end;
  local time = __haxe_MainLoop.tick();
  if (not __haxe_MainLoop.hasEvents() and (__haxe_EntryPoint.threadCount == 0)) then 
    do return -1 end;
  end;
  do return time end;
end
__haxe_EntryPoint.run = function() 
  while (not (__haxe_EntryPoint.processEvents() < 0)) do 
  end;
end

__haxe_Exception.new = function(message,previous,native) 
  local self = _hx_new(__haxe_Exception.prototype)
  __haxe_Exception.super(self,message,previous,native)
  return self
end
__haxe_Exception.super = function(self,message,previous,native) 
  self.__skipStack = 0;
  self.__exceptionMessage = message;
  self.__previousException = previous;
  if (native ~= nil) then 
    self.__nativeException = native;
    self.__nativeStack = __haxe_NativeStackTrace.exceptionStack();
  else
    self.__nativeException = self;
    self.__nativeStack = __haxe_NativeStackTrace.callStack();
    self.__skipStack = 1;
  end;
end
__haxe_Exception.__name__ = true
__haxe_Exception.caught = function(value) 
  if (__lua_Boot.__instanceof(value, __haxe_Exception)) then 
    do return value end;
  else
    do return __haxe_ValueException.new(value, nil, value) end;
  end;
end
__haxe_Exception.thrown = function(value) 
  if (__lua_Boot.__instanceof(value, __haxe_Exception)) then 
    do return value:get_native() end;
  else
    local e = __haxe_ValueException.new(value);
    e.__skipStack = e.__skipStack + 1;
    do return e end;
  end;
end
__haxe_Exception.prototype = _hx_e();
__haxe_Exception.prototype.__exceptionMessage= nil;
__haxe_Exception.prototype.__exceptionStack= nil;
__haxe_Exception.prototype.__nativeStack= nil;
__haxe_Exception.prototype.__skipStack= nil;
__haxe_Exception.prototype.__nativeException= nil;
__haxe_Exception.prototype.__previousException= nil;
__haxe_Exception.prototype.unwrap = function(self) 
  do return self.__nativeException end
end
__haxe_Exception.prototype.toString = function(self) 
  do return self:get_message() end
end
__haxe_Exception.prototype.details = function(self) 
  if (self:get_previous() == nil) then 
    local tmp = Std.string("Exception: ") .. Std.string(self:toString());
    local tmp1 = self:get_stack();
    do return Std.string(tmp) .. Std.string(((function() 
      local _hx_1
      if (tmp1 == nil) then 
      _hx_1 = "null"; else 
      _hx_1 = _hx_wrap_if_string_field(__haxe__CallStack_CallStack_Impl_,'toString')(tmp1); end
      return _hx_1
    end )())) end;
  else
    local result = "";
    local e = self;
    local prev = nil;
    while (e ~= nil) do 
      if (prev == nil) then 
        local result1 = Std.string("Exception: ") .. Std.string(e:get_message());
        local tmp = e:get_stack();
        result = Std.string(Std.string(result1) .. Std.string(((function() 
          local _hx_2
          if (tmp == nil) then 
          _hx_2 = "null"; else 
          _hx_2 = _hx_wrap_if_string_field(__haxe__CallStack_CallStack_Impl_,'toString')(tmp); end
          return _hx_2
        end )()))) .. Std.string(result);
      else
        local prevStack = __haxe__CallStack_CallStack_Impl_.subtract(e:get_stack(), prev:get_stack());
        result = Std.string(Std.string(Std.string(Std.string("Exception: ") .. Std.string(e:get_message())) .. Std.string(((function() 
          local _hx_3
          if (prevStack == nil) then 
          _hx_3 = "null"; else 
          _hx_3 = _hx_wrap_if_string_field(__haxe__CallStack_CallStack_Impl_,'toString')(prevStack); end
          return _hx_3
        end )()))) .. Std.string("\n\nNext ")) .. Std.string(result);
      end;
      prev = e;
      e = e:get_previous();
    end;
    do return result end;
  end;
end
__haxe_Exception.prototype.__shiftStack = function(self) 
  self.__skipStack = self.__skipStack + 1;
end
__haxe_Exception.prototype.get_message = function(self) 
  do return self.__exceptionMessage end
end
__haxe_Exception.prototype.get_previous = function(self) 
  do return self.__previousException end
end
__haxe_Exception.prototype.get_native = function(self) 
  do return self.__nativeException end
end
__haxe_Exception.prototype.get_stack = function(self) 
  local _g = self.__exceptionStack;
  if (_g == nil) then 
    self.__exceptionStack = __haxe_NativeStackTrace.toHaxe(self.__nativeStack, self.__skipStack) do return self.__exceptionStack end;
  else
    do return _g end;
  end;
end

__haxe_Exception.prototype.__class__ =  __haxe_Exception

__haxe_Json.new = {}
__haxe_Json.__name__ = true
__haxe_Json.parse = function(text) 
  do return __haxe_format_JsonParser.new(text):doParse() end;
end
__haxe_Json.stringify = function(value,replacer,space) 
  do return __haxe_format_JsonPrinter.print(value, replacer, space) end;
end

__haxe_Log.new = {}
__haxe_Log.__name__ = true
__haxe_Log.formatOutput = function(v,infos) 
  local str = Std.string(v);
  if (infos == nil) then 
    do return str end;
  end;
  local pstr = Std.string(Std.string(infos.fileName) .. Std.string(":")) .. Std.string(infos.lineNumber);
  if (infos.customParams ~= nil) then 
    local _g = 0;
    local _g1 = infos.customParams;
    while (_g < _g1.length) do 
      local v = _g1[_g];
      _g = _g + 1;
      str = Std.string(str) .. Std.string((Std.string(", ") .. Std.string(Std.string(v))));
    end;
  end;
  do return Std.string(Std.string(pstr) .. Std.string(": ")) .. Std.string(str) end;
end
__haxe_Log.trace = function(v,infos) 
  local str = __haxe_Log.formatOutput(v, infos);
  _hx_print(str);
end

__haxe_MainEvent.new = function(f,p) 
  local self = _hx_new(__haxe_MainEvent.prototype)
  __haxe_MainEvent.super(self,f,p)
  return self
end
__haxe_MainEvent.super = function(self,f,p) 
  self.isBlocking = true;
  self.f = _hx_funcToField(f);
  self.priority = p;
  self.nextRun = -_G.math.huge;
end
__haxe_MainEvent.__name__ = true
__haxe_MainEvent.prototype = _hx_e();
__haxe_MainEvent.prototype.f= nil;
__haxe_MainEvent.prototype.prev= nil;
__haxe_MainEvent.prototype.next= nil;
__haxe_MainEvent.prototype.isBlocking= nil;
__haxe_MainEvent.prototype.nextRun= nil;
__haxe_MainEvent.prototype.priority= nil;

__haxe_MainEvent.prototype.__class__ =  __haxe_MainEvent

__haxe_MainLoop.new = {}
__haxe_MainLoop.__name__ = true
__haxe_MainLoop.hasEvents = function() 
  local p = __haxe_MainLoop.pending;
  while (p ~= nil) do 
    if (p.isBlocking) then 
      do return true end;
    end;
    p = p.next;
  end;
  do return false end;
end
__haxe_MainLoop.sortEvents = function() 
  local list = __haxe_MainLoop.pending;
  if (list == nil) then 
    do return end;
  end;
  local insize = 1;
  local nmerges;
  local psize = 0;
  local qsize = 0;
  local p;
  local q;
  local e;
  local tail;
  while (true) do 
    p = list;
    list = nil;
    tail = nil;
    nmerges = 0;
    while (p ~= nil) do 
      nmerges = nmerges + 1;
      q = p;
      psize = 0;
      local _g = 0;
      local _g1 = insize;
      while (_g < _g1) do 
        _g = _g + 1;
        psize = psize + 1;
        q = q.next;
        if (q == nil) then 
          break;
        end;
      end;
      qsize = insize;
      while ((psize > 0) or ((qsize > 0) and (q ~= nil))) do 
        if (psize == 0) then 
          e = q;
          q = q.next;
          qsize = qsize - 1;
        else
          if (((qsize == 0) or (q == nil)) or ((p.priority > q.priority) or ((p.priority == q.priority) and (p.nextRun <= q.nextRun)))) then 
            e = p;
            p = p.next;
            psize = psize - 1;
          else
            e = q;
            q = q.next;
            qsize = qsize - 1;
          end;
        end;
        if (tail ~= nil) then 
          tail.next = e;
        else
          list = e;
        end;
        e.prev = tail;
        tail = e;
      end;
      p = q;
    end;
    tail.next = nil;
    if (nmerges <= 1) then 
      break;
    end;
    insize = insize * 2;
  end;
  list.prev = nil;
  __haxe_MainLoop.pending = list;
end
__haxe_MainLoop.tick = function() 
  __haxe_MainLoop.sortEvents();
  local e = __haxe_MainLoop.pending;
  local now = Sys.time();
  local wait = 1e9;
  while (e ~= nil) do 
    local next = e.next;
    local wt = e.nextRun - now;
    if (wt <= 0) then 
      wait = 0;
      if (e.f ~= nil) then 
        e:f();
      end;
    else
      if (wait > wt) then 
        wait = wt;
      end;
    end;
    e = next;
  end;
  do return wait end;
end

__haxe_NativeStackTrace.new = {}
__haxe_NativeStackTrace.__name__ = true
__haxe_NativeStackTrace.saveStack = function(exception) 
end
__haxe_NativeStackTrace.callStack = function() 
  local _g = debug.traceback();
  if (_g == nil) then 
    do return _hx_tab_array({}, 0) end;
  else
    local idx = 1;
    local ret = _hx_tab_array({}, 0);
    while (idx ~= nil) do 
      local newidx = 0;
      if (#"\n" > 0) then 
        newidx = _G.string.find(_g, "\n", idx, true);
      else
        if (idx >= #_g) then 
          newidx = nil;
        else
          newidx = idx + 1;
        end;
      end;
      if (newidx ~= nil) then 
        ret:push(_G.string.sub(_g, idx, newidx - 1));
        idx = newidx + #"\n";
      else
        ret:push(_G.string.sub(_g, idx, #_g));
        idx = nil;
      end;
    end;
    do return ret:slice(3) end;
  end;
end
__haxe_NativeStackTrace.exceptionStack = function() 
  do return _hx_tab_array({}, 0) end;
end
__haxe_NativeStackTrace.toHaxe = function(native,skip) 
  if (skip == nil) then 
    skip = 0;
  end;
  local stack = _hx_tab_array({}, 0);
  local cnt = -1;
  local _g = 0;
  local _hx_continue_1 = false;
  while (_g < native.length) do repeat 
    local item = native[_g];
    _g = _g + 1;
    local len = nil;
    len = #item;
    local _this = _G.string.sub(item, 2, 1 + len);
    local idx = 1;
    local ret = _hx_tab_array({}, 0);
    while (idx ~= nil) do 
      local newidx = 0;
      if (#":" > 0) then 
        newidx = _G.string.find(_this, ":", idx, true);
      else
        if (idx >= #_this) then 
          newidx = nil;
        else
          newidx = idx + 1;
        end;
      end;
      if (newidx ~= nil) then 
        ret:push(_G.string.sub(_this, idx, newidx - 1));
        idx = newidx + #":";
      else
        ret:push(_G.string.sub(_this, idx, #_this));
        idx = nil;
      end;
    end;
    local file = ret[0];
    if (file == "[C]") then 
      break;
    end;
    cnt = cnt + 1;
    if (skip > cnt) then 
      break;
    end;
    local line = ret[1];
    local method;
    if (ret.length <= 2) then 
      method = nil;
    else
      local r = _G.string.find(ret[2], "'", 1, true);
      local methodPos = (function() 
        local _hx_1
        if ((r ~= nil) and (r > 0)) then 
        _hx_1 = r - 1; else 
        _hx_1 = -1; end
        return _hx_1
      end )();
      if (methodPos < 0) then 
        method = nil;
      else
        local _this = ret[2];
        local startIndex = methodPos + 1;
        local endIndex = #ret[2] - 1;
        if (endIndex == nil) then 
          endIndex = #_this;
        end;
        if (endIndex < 0) then 
          endIndex = 0;
        end;
        if (startIndex < 0) then 
          startIndex = 0;
        end;
        method = __haxe_StackItem.Method(nil, (function() 
          local _hx_2
          if (endIndex < startIndex) then 
          _hx_2 = _G.string.sub(_this, endIndex + 1, startIndex); else 
          _hx_2 = _G.string.sub(_this, startIndex + 1, endIndex); end
          return _hx_2
        end )());
      end;
    end;
    stack:push(__haxe_StackItem.FilePos(method, file, Std.parseInt(line)));until true
    if _hx_continue_1 then 
    _hx_continue_1 = false;
    break;
    end;
    
  end;
  do return stack end;
end

__haxe_ValueException.new = function(value,previous,native) 
  local self = _hx_new(__haxe_ValueException.prototype)
  __haxe_ValueException.super(self,value,previous,native)
  return self
end
__haxe_ValueException.super = function(self,value,previous,native) 
  __haxe_Exception.super(self,Std.string(value),previous,native);
  self.value = value;
  self.__skipStack = self.__skipStack + 1;
end
__haxe_ValueException.__name__ = true
__haxe_ValueException.prototype = _hx_e();
__haxe_ValueException.prototype.value= nil;
__haxe_ValueException.prototype.unwrap = function(self) 
  do return self.value end
end

__haxe_ValueException.prototype.__class__ =  __haxe_ValueException
__haxe_ValueException.__super__ = __haxe_Exception
setmetatable(__haxe_ValueException.prototype,{__index=__haxe_Exception.prototype})

__haxe_ds_IntMap.new = function() 
  local self = _hx_new(__haxe_ds_IntMap.prototype)
  __haxe_ds_IntMap.super(self)
  return self
end
__haxe_ds_IntMap.super = function(self) 
  self.h = ({});
end
__haxe_ds_IntMap.__name__ = true
__haxe_ds_IntMap.__interfaces__ = {__haxe_IMap}
__haxe_ds_IntMap.prototype = _hx_e();
__haxe_ds_IntMap.prototype.h= nil;
__haxe_ds_IntMap.prototype.get = function(self,key) 
  local ret = self.h[key];
  if (ret == __haxe_ds_IntMap.tnull) then 
    ret = nil;
  end;
  do return ret end
end
__haxe_ds_IntMap.prototype.keys = function(self) 
  local _gthis = self;
  local next = _G.next;
  local cur = next(self.h, nil);
  do return _hx_o({__fields__={next=true,hasNext=true},next=function(self) 
    local ret = cur;
    cur = next(_gthis.h, cur);
    do return ret end;
  end,hasNext=function(self) 
    do return cur ~= nil end;
  end}) end
end

__haxe_ds_IntMap.prototype.__class__ =  __haxe_ds_IntMap

__haxe_ds_StringMap.new = function() 
  local self = _hx_new(__haxe_ds_StringMap.prototype)
  __haxe_ds_StringMap.super(self)
  return self
end
__haxe_ds_StringMap.super = function(self) 
  self.h = ({});
end
__haxe_ds_StringMap.__name__ = true
__haxe_ds_StringMap.__interfaces__ = {__haxe_IMap}
__haxe_ds_StringMap.prototype = _hx_e();
__haxe_ds_StringMap.prototype.h= nil;
__haxe_ds_StringMap.prototype.get = function(self,key) 
  local ret = self.h[key];
  if (ret == __haxe_ds_StringMap.tnull) then 
    ret = nil;
  end;
  do return ret end
end
__haxe_ds_StringMap.prototype.keys = function(self) 
  local _gthis = self;
  local next = _G.next;
  local cur = next(self.h, nil);
  do return _hx_o({__fields__={next=true,hasNext=true},next=function(self) 
    local ret = cur;
    cur = next(_gthis.h, cur);
    do return ret end;
  end,hasNext=function(self) 
    do return cur ~= nil end;
  end}) end
end
__haxe_ds_StringMap.prototype.iterator = function(self) 
  local _gthis = self;
  local it = self:keys();
  do return _hx_o({__fields__={hasNext=true,next=true},hasNext=function(self) 
    do return it:hasNext() end;
  end,next=function(self) 
    do return _gthis.h[it:next()] end;
  end}) end
end

__haxe_ds_StringMap.prototype.__class__ =  __haxe_ds_StringMap

__haxe_exceptions_PosException.new = function(message,previous,pos) 
  local self = _hx_new(__haxe_exceptions_PosException.prototype)
  __haxe_exceptions_PosException.super(self,message,previous,pos)
  return self
end
__haxe_exceptions_PosException.super = function(self,message,previous,pos) 
  __haxe_Exception.super(self,message,previous);
  if (pos == nil) then 
    self.posInfos = _hx_o({__fields__={fileName=true,lineNumber=true,className=true,methodName=true},fileName="(unknown)",lineNumber=0,className="(unknown)",methodName="(unknown)"});
  else
    self.posInfos = pos;
  end;
  self.__skipStack = self.__skipStack + 1;
end
__haxe_exceptions_PosException.__name__ = true
__haxe_exceptions_PosException.prototype = _hx_e();
__haxe_exceptions_PosException.prototype.posInfos= nil;
__haxe_exceptions_PosException.prototype.toString = function(self) 
  do return Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string("") .. Std.string(__haxe_Exception.prototype.toString(self))) .. Std.string(" in ")) .. Std.string(self.posInfos.className)) .. Std.string(".")) .. Std.string(self.posInfos.methodName)) .. Std.string(" at ")) .. Std.string(self.posInfos.fileName)) .. Std.string(":")) .. Std.string(self.posInfos.lineNumber) end
end

__haxe_exceptions_PosException.prototype.__class__ =  __haxe_exceptions_PosException
__haxe_exceptions_PosException.__super__ = __haxe_Exception
setmetatable(__haxe_exceptions_PosException.prototype,{__index=__haxe_Exception.prototype})

__haxe_exceptions_NotImplementedException.new = function(message,previous,pos) 
  local self = _hx_new(__haxe_exceptions_NotImplementedException.prototype)
  __haxe_exceptions_NotImplementedException.super(self,message,previous,pos)
  return self
end
__haxe_exceptions_NotImplementedException.super = function(self,message,previous,pos) 
  if (message == nil) then 
    message = "Not implemented";
  end;
  __haxe_exceptions_PosException.super(self,message,previous,pos);
  self.__skipStack = self.__skipStack + 1;
end
__haxe_exceptions_NotImplementedException.__name__ = true
__haxe_exceptions_NotImplementedException.prototype = _hx_e();

__haxe_exceptions_NotImplementedException.prototype.__class__ =  __haxe_exceptions_NotImplementedException
__haxe_exceptions_NotImplementedException.__super__ = __haxe_exceptions_PosException
setmetatable(__haxe_exceptions_NotImplementedException.prototype,{__index=__haxe_exceptions_PosException.prototype})

__haxe_format_JsonParser.new = function(str) 
  local self = _hx_new(__haxe_format_JsonParser.prototype)
  __haxe_format_JsonParser.super(self,str)
  return self
end
__haxe_format_JsonParser.super = function(self,str) 
  self.str = str;
  self.pos = 0;
end
__haxe_format_JsonParser.__name__ = true
__haxe_format_JsonParser.prototype = _hx_e();
__haxe_format_JsonParser.prototype.str= nil;
__haxe_format_JsonParser.prototype.pos= nil;
__haxe_format_JsonParser.prototype.doParse = function(self) 
  local result = self:parseRec();
  local c;
  while (true) do 
    c = self:nextChar();
    if (not (c ~= nil)) then 
      break;
    end;
    if (c) == 9 or (c) == 10 or (c) == 13 or (c) == 32 then else
    self:invalidChar(); end;
  end;
  do return result end
end
__haxe_format_JsonParser.prototype.parseRec = function(self) 
  while (true) do 
    local c = self:nextChar();
    if (c) == 9 or (c) == 10 or (c) == 13 or (c) == 32 then 
    elseif (c) == 34 then 
      do return self:parseString() end;
    elseif (c) == 45 or (c) == 48 or (c) == 49 or (c) == 50 or (c) == 51 or (c) == 52 or (c) == 53 or (c) == 54 or (c) == 55 or (c) == 56 or (c) == 57 then 
      local c1 = c;
      local start = self.pos - 1;
      local minus = c == 45;
      local digit = not minus;
      local zero = c == 48;
      local point = false;
      local e = false;
      local pm = false;
      local _end = false;
      while (true) do 
        c1 = self:nextChar();
        local c = c1;
        if (c) == 43 or (c) == 45 then 
          if (not e or pm) then 
            self:invalidNumber(start);
          end;
          digit = false;
          pm = true;
        elseif (c) == 46 then 
          if ((minus or point) or e) then 
            self:invalidNumber(start);
          end;
          digit = false;
          point = true;
        elseif (c) == 48 then 
          if (zero and not point) then 
            self:invalidNumber(start);
          end;
          if (minus) then 
            minus = false;
            zero = true;
          end;
          digit = true;
        elseif (c) == 49 or (c) == 50 or (c) == 51 or (c) == 52 or (c) == 53 or (c) == 54 or (c) == 55 or (c) == 56 or (c) == 57 then 
          if (zero and not point) then 
            self:invalidNumber(start);
          end;
          if (minus) then 
            minus = false;
          end;
          digit = true;
          zero = false;
        elseif (c) == 69 or (c) == 101 then 
          if ((minus or zero) or e) then 
            self:invalidNumber(start);
          end;
          digit = false;
          e = true;else
        if (not digit) then 
          self:invalidNumber(start);
        end;
        self.pos = self.pos - 1;
        _end = true; end;
        if (_end) then 
          break;
        end;
      end;
      local _this = self.str;
      local pos = start;
      local len = self.pos - start;
      if ((len == nil) or (len > (start + #_this))) then 
        len = #_this;
      else
        if (len < 0) then 
          len = #_this + len;
        end;
      end;
      if (start < 0) then 
        pos = #_this + start;
      end;
      if (pos < 0) then 
        pos = 0;
      end;
      local f = Std.parseFloat(_G.string.sub(_this, pos + 1, pos + len));
      local i = Std.int(f);
      if (i == f) then 
        do return i end;
      else
        do return f end;
      end;
    elseif (c) == 91 then 
      local arr = _hx_tab_array({}, 0);
      local comma = nil;
      while (true) do 
        local c = self:nextChar();
        if (c) == 9 or (c) == 10 or (c) == 13 or (c) == 32 then 
        elseif (c) == 44 then 
          if (comma) then 
            comma = false;
          else
            self:invalidChar();
          end;
        elseif (c) == 93 then 
          if (comma == false) then 
            self:invalidChar();
          end;
          do return arr end;else
        if (comma) then 
          self:invalidChar();
        end;
        self.pos = self.pos - 1;
        arr:push(self:parseRec());
        comma = true; end;
      end;
    elseif (c) == 102 then 
      local save = self.pos;
      if ((((self:nextChar() ~= 97) or (self:nextChar() ~= 108)) or (self:nextChar() ~= 115)) or (self:nextChar() ~= 101)) then 
        self.pos = save;
        self:invalidChar();
      end;
      do return false end;
    elseif (c) == 110 then 
      local save = self.pos;
      if (((self:nextChar() ~= 117) or (self:nextChar() ~= 108)) or (self:nextChar() ~= 108)) then 
        self.pos = save;
        self:invalidChar();
      end;
      do return nil end;
    elseif (c) == 116 then 
      local save = self.pos;
      if (((self:nextChar() ~= 114) or (self:nextChar() ~= 117)) or (self:nextChar() ~= 101)) then 
        self.pos = save;
        self:invalidChar();
      end;
      do return true end;
    elseif (c) == 123 then 
      local obj = _hx_e();
      local field = nil;
      local comma = nil;
      while (true) do 
        local c = self:nextChar();
        if (c) == 9 or (c) == 10 or (c) == 13 or (c) == 32 then 
        elseif (c) == 34 then 
          if ((field ~= nil) or comma) then 
            self:invalidChar();
          end;
          field = self:parseString();
        elseif (c) == 44 then 
          if (comma) then 
            comma = false;
          else
            self:invalidChar();
          end;
        elseif (c) == 58 then 
          if (field == nil) then 
            self:invalidChar();
          end;
          obj[field] = self:parseRec();
          field = nil;
          comma = true;
        elseif (c) == 125 then 
          if ((field ~= nil) or (comma == false)) then 
            self:invalidChar();
          end;
          do return obj end;else
        self:invalidChar(); end;
      end;else
    self:invalidChar(); end;
  end;
end
__haxe_format_JsonParser.prototype.parseString = function(self) 
  local start = self.pos;
  local buf = nil;
  local prev = -1;
  while (true) do 
    local c = self:nextChar();
    if (c == 34) then 
      break;
    end;
    if (c == 92) then 
      if (buf == nil) then 
        buf = StringBuf.new();
      end;
      local s = self.str;
      local len = (self.pos - start) - 1;
      local part;
      if (len == nil) then 
        local pos = start;
        local len = nil;
        len = #s;
        if (pos < 0) then 
          pos = #s + pos;
        end;
        if (pos < 0) then 
          pos = 0;
        end;
        part = _G.string.sub(s, pos + 1, pos + len);
      else
        local pos = start;
        local len1 = len;
        if ((len == nil) or (len > (pos + #s))) then 
          len1 = #s;
        else
          if (len < 0) then 
            len1 = #s + len;
          end;
        end;
        if (pos < 0) then 
          pos = #s + pos;
        end;
        if (pos < 0) then 
          pos = 0;
        end;
        part = _G.string.sub(s, pos + 1, pos + len1);
      end;
      _G.table.insert(buf.b, part);
      local buf1 = buf;
      buf1.length = buf1.length + #part;
      c = self:nextChar();
      local c1 = c;
      if (c1) == 34 or (c1) == 47 or (c1) == 92 then 
        _G.table.insert(buf.b, _G.string.char(c));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 98 then 
        _G.table.insert(buf.b, _G.string.char(8));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 102 then 
        _G.table.insert(buf.b, _G.string.char(12));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 110 then 
        _G.table.insert(buf.b, _G.string.char(10));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 114 then 
        _G.table.insert(buf.b, _G.string.char(13));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 116 then 
        _G.table.insert(buf.b, _G.string.char(9));
        local buf = buf;
        buf.length = buf.length + 1;
      elseif (c1) == 117 then 
        local _this = self.str;
        local pos = self.pos;
        local len = 4;
        if (4 > (pos + #_this)) then 
          len = #_this;
        end;
        if (pos < 0) then 
          pos = #_this + pos;
        end;
        if (pos < 0) then 
          pos = 0;
        end;
        local uc = Std.parseInt(Std.string("0x") .. Std.string(_G.string.sub(_this, pos + 1, pos + len)));
        self.pos = self.pos + 4;
        if (prev ~= -1) then 
          if ((uc < 56320) or (uc > 57343)) then 
            _G.table.insert(buf.b, _G.string.char(65533));
            local buf = buf;
            buf.length = buf.length + 1;
            prev = -1;
          else
            _G.table.insert(buf.b, _G.string.char(((_hx_bit.lshift(prev - 55296,10)) + (uc - 56320)) + 65536));
            local buf = buf;
            buf.length = buf.length + 1;
            prev = -1;
          end;
        else
          if ((uc >= 55296) and (uc <= 56319)) then 
            prev = uc;
          else
            _G.table.insert(buf.b, _G.string.char(uc));
            local buf = buf;
            buf.length = buf.length + 1;
          end;
        end;else
      _G.error(__haxe_Exception.thrown(Std.string(Std.string(Std.string("Invalid escape sequence \\") .. Std.string(_G.string.char(c))) .. Std.string(" at position ")) .. Std.string((self.pos - 1))),0); end;
      start = self.pos;
    else
      if (c >= 128) then 
        self.pos = self.pos + 1;
        if (c >= 252) then 
          self.pos = self.pos + 4;
        else
          if (c >= 248) then 
            self.pos = self.pos + 3;
          else
            if (c >= 240) then 
              self.pos = self.pos + 2;
            else
              if (c >= 224) then 
                self.pos = self.pos + 1;
              end;
            end;
          end;
        end;
      else
        if (c == nil) then 
          _G.error(__haxe_Exception.thrown("Unclosed string"),0);
        end;
      end;
    end;
  end;
  if (buf == nil) then 
    local _this = self.str;
    local pos = start;
    local len = (self.pos - start) - 1;
    if ((len == nil) or (len > (pos + #_this))) then 
      len = #_this;
    else
      if (len < 0) then 
        len = #_this + len;
      end;
    end;
    if (pos < 0) then 
      pos = #_this + pos;
    end;
    if (pos < 0) then 
      pos = 0;
    end;
    do return _G.string.sub(_this, pos + 1, pos + len) end;
  else
    local s = self.str;
    local len = (self.pos - start) - 1;
    local part;
    if (len == nil) then 
      local pos = start;
      local len = nil;
      len = #s;
      if (pos < 0) then 
        pos = #s + pos;
      end;
      if (pos < 0) then 
        pos = 0;
      end;
      part = _G.string.sub(s, pos + 1, pos + len);
    else
      local pos = start;
      local len1 = len;
      if ((len == nil) or (len > (pos + #s))) then 
        len1 = #s;
      else
        if (len < 0) then 
          len1 = #s + len;
        end;
      end;
      if (pos < 0) then 
        pos = #s + pos;
      end;
      if (pos < 0) then 
        pos = 0;
      end;
      part = _G.string.sub(s, pos + 1, pos + len1);
    end;
    _G.table.insert(buf.b, part);
    local buf1 = buf;
    buf1.length = buf1.length + #part;
    do return _G.table.concat(buf.b) end;
  end;
end
__haxe_format_JsonParser.prototype.nextChar = function(self) 
  self.pos = self.pos + 1;
  do return _G.string.byte(self.str, self.pos) end
end
__haxe_format_JsonParser.prototype.invalidChar = function(self) 
  self.pos = self.pos - 1;
  _G.error(__haxe_Exception.thrown(Std.string(Std.string(Std.string("Invalid char ") .. Std.string(_G.string.byte(self.str, self.pos))) .. Std.string(" at position ")) .. Std.string(self.pos)),0);
end
__haxe_format_JsonParser.prototype.invalidNumber = function(self,start) 
  local _this = self.str;
  local pos = start;
  local len = self.pos - start;
  if ((len == nil) or (len > (start + #_this))) then 
    len = #_this;
  else
    if (len < 0) then 
      len = #_this + len;
    end;
  end;
  if (start < 0) then 
    pos = #_this + start;
  end;
  if (pos < 0) then 
    pos = 0;
  end;
  _G.error(__haxe_Exception.thrown(Std.string(Std.string(Std.string("Invalid number at position ") .. Std.string(start)) .. Std.string(": ")) .. Std.string(_G.string.sub(_this, pos + 1, pos + len))),0);
end

__haxe_format_JsonParser.prototype.__class__ =  __haxe_format_JsonParser

__haxe_format_JsonPrinter.new = function(replacer,space) 
  local self = _hx_new(__haxe_format_JsonPrinter.prototype)
  __haxe_format_JsonPrinter.super(self,replacer,space)
  return self
end
__haxe_format_JsonPrinter.super = function(self,replacer,space) 
  self.replacer = _hx_funcToField(replacer);
  self.indent = space;
  self.pretty = space ~= nil;
  self.nind = 0;
  self.buf = StringBuf.new();
end
__haxe_format_JsonPrinter.__name__ = true
__haxe_format_JsonPrinter.print = function(o,replacer,space) 
  local printer = __haxe_format_JsonPrinter.new(replacer, space);
  printer:write("", o);
  do return _G.table.concat(printer.buf.b) end;
end
__haxe_format_JsonPrinter.prototype = _hx_e();
__haxe_format_JsonPrinter.prototype.buf= nil;
__haxe_format_JsonPrinter.prototype.replacer= nil;
__haxe_format_JsonPrinter.prototype.indent= nil;
__haxe_format_JsonPrinter.prototype.pretty= nil;
__haxe_format_JsonPrinter.prototype.nind= nil;
__haxe_format_JsonPrinter.prototype.write = function(self,k,v) 
  if (self.replacer ~= nil) then 
    v = self:replacer(k, v);
  end;
  local _g = Type.typeof(v);
  local tmp = _g[1];
  if (tmp) == 0 then 
    local _this = self.buf;
    _G.table.insert(_this.b, "null");
    _this.length = _this.length + #"null";
  elseif (tmp) == 1 then 
    local _this = self.buf;
    local str = Std.string(v);
    _G.table.insert(_this.b, str);
    _this.length = _this.length + #str;
  elseif (tmp) == 2 then 
    local v = (function() 
      local _hx_1
      if (Math.isFinite(v)) then 
      _hx_1 = Std.string(v); else 
      _hx_1 = "null"; end
      return _hx_1
    end )();
    local _this = self.buf;
    local str = Std.string(v);
    _G.table.insert(_this.b, str);
    _this.length = _this.length + #str;
  elseif (tmp) == 3 then 
    local _this = self.buf;
    local str = Std.string(v);
    _G.table.insert(_this.b, str);
    _this.length = _this.length + #str;
  elseif (tmp) == 4 then 
    self:fieldsString(v, Reflect.fields(v));
  elseif (tmp) == 5 then 
    local _this = self.buf;
    _G.table.insert(_this.b, "\"<fun>\"");
    _this.length = _this.length + #"\"<fun>\"";
  elseif (tmp) == 6 then 
    local _g = _g[2];
    if (_g == String) then 
      self:quote(v);
    else
      if (_g == Array) then 
        local v = v;
        local _this = self.buf;
        _G.table.insert(_this.b, _G.string.char(91));
        _this.length = _this.length + 1;
        local len = v.length;
        local last = len - 1;
        local _g = 0;
        while (_g < len) do 
          _g = _g + 1;
          local i = _g - 1;
          if (i > 0) then 
            local _this = self.buf;
            _G.table.insert(_this.b, _G.string.char(44));
            _this.length = _this.length + 1;
          else
            self.nind = self.nind + 1;
          end;
          if (self.pretty) then 
            local _this = self.buf;
            _G.table.insert(_this.b, _G.string.char(10));
            _this.length = _this.length + 1;
          end;
          if (self.pretty) then 
            local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
            local _this = self.buf;
            local str = Std.string(v);
            _G.table.insert(_this.b, str);
            _this.length = _this.length + #str;
          end;
          self:write(i, v[i]);
          if (i == last) then 
            self.nind = self.nind - 1;
            if (self.pretty) then 
              local _this = self.buf;
              _G.table.insert(_this.b, _G.string.char(10));
              _this.length = _this.length + 1;
            end;
            if (self.pretty) then 
              local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
              local _this = self.buf;
              local str = Std.string(v);
              _G.table.insert(_this.b, str);
              _this.length = _this.length + #str;
            end;
          end;
        end;
        local _this = self.buf;
        _G.table.insert(_this.b, _G.string.char(93));
        _this.length = _this.length + 1;
      else
        if (_g == __haxe_ds_StringMap) then 
          local v = v;
          local o = _hx_e();
          local k = v:keys();
          while (k:hasNext()) do 
            local k = k:next();
            local ret = v.h[k];
            if (ret == __haxe_ds_StringMap.tnull) then 
              ret = nil;
            end;
            o[k] = ret;
          end;
          local v = o;
          self:fieldsString(v, Reflect.fields(v));
        else
          if (_g == Date) then 
            self:quote(__lua_Boot.dateStr(v));
          else
            self:classString(v);
          end;
        end;
      end;
    end;
  elseif (tmp) == 7 then 
    local _this = self.buf;
    local str = Std.string(v[1]);
    _G.table.insert(_this.b, str);
    _this.length = _this.length + #str;
  elseif (tmp) == 8 then 
    local _this = self.buf;
    _G.table.insert(_this.b, "\"???\"");
    _this.length = _this.length + #"\"???\""; end;
end
__haxe_format_JsonPrinter.prototype.classString = function(self,v) 
  self:fieldsString(v, Type.getInstanceFields(Type.getClass(v)));
end
__haxe_format_JsonPrinter.prototype.fieldsString = function(self,v,fields) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local len = fields.length;
  local last = len - 1;
  local first = true;
  local _g = 0;
  local _hx_continue_1 = false;
  while (_g < len) do repeat 
    _g = _g + 1;
    local i = _g - 1;
    local f = fields[i];
    local value = Reflect.field(v, f);
    if (Reflect.isFunction(value)) then 
      break;
    end;
    if (first) then 
      self.nind = self.nind + 1;
      first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    if (self.pretty) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(10));
      _this.length = _this.length + 1;
    end;
    if (self.pretty) then 
      local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
      local _this = self.buf;
      local str = Std.string(v);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
    self:quote(f);
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(58));
    _this.length = _this.length + 1;
    if (self.pretty) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(32));
      _this.length = _this.length + 1;
    end;
    self:write(f, value);
    if (i == last) then 
      self.nind = self.nind - 1;
      if (self.pretty) then 
        local _this = self.buf;
        _G.table.insert(_this.b, _G.string.char(10));
        _this.length = _this.length + 1;
      end;
      if (self.pretty) then 
        local v = StringTools.lpad("", self.indent, self.nind * #self.indent);
        local _this = self.buf;
        local str = Std.string(v);
        _G.table.insert(_this.b, str);
        _this.length = _this.length + #str;
      end;
    end;until true
    if _hx_continue_1 then 
    _hx_continue_1 = false;
    break;
    end;
    
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__haxe_format_JsonPrinter.prototype.quote = function(self,s) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(34));
  _this.length = _this.length + 1;
  local i = 0;
  local length = #s;
  while (i < length) do 
    i = i + 1;
    local c = _G.string.byte(s, (i - 1) + 1);
    if (c) == 8 then 
      local _this = self.buf;
      _G.table.insert(_this.b, "\\b");
      _this.length = _this.length + #"\\b";
    elseif (c) == 9 then 
      local _this = self.buf;
      _G.table.insert(_this.b, "\\t");
      _this.length = _this.length + #"\\t";
    elseif (c) == 10 then 
      local _this = self.buf;
      _G.table.insert(_this.b, "\\n");
      _this.length = _this.length + #"\\n";
    elseif (c) == 12 then 
      local _this = self.buf;
      _G.table.insert(_this.b, "\\f");
      _this.length = _this.length + #"\\f";
    elseif (c) == 13 then 
      local _this = self.buf;
      _G.table.insert(_this.b, "\\r");
      _this.length = _this.length + #"\\r";
    elseif (c) == 34 then 
      local _this = self.buf;
      _G.table.insert(_this.b, "\\\"");
      _this.length = _this.length + #"\\\"";
    elseif (c) == 92 then 
      local _this = self.buf;
      _G.table.insert(_this.b, "\\\\");
      _this.length = _this.length + #"\\\\";else
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(c));
    _this.length = _this.length + 1; end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(34));
  _this.length = _this.length + 1;
end

__haxe_format_JsonPrinter.prototype.__class__ =  __haxe_format_JsonPrinter

__haxe_io_Bytes.new = function(length,b) 
  local self = _hx_new(__haxe_io_Bytes.prototype)
  __haxe_io_Bytes.super(self,length,b)
  return self
end
__haxe_io_Bytes.super = function(self,length,b) 
  self.length = length;
  self.b = b;
end
__haxe_io_Bytes.__name__ = true
__haxe_io_Bytes.alloc = function(length) 
  local a = Array.new();
  local _g = 0;
  while (_g < length) do 
    _g = _g + 1;
    a:push(0);
  end;
  do return __haxe_io_Bytes.new(length, a) end;
end
__haxe_io_Bytes.ofString = function(s,encoding) 
  local _g = _hx_tab_array({}, 0);
  local _g1 = 0;
  local _g2 = _G.string.len(s);
  while (_g1 < _g2) do 
    _g1 = _g1 + 1;
    _g:push(_G.string.byte(s, (_g1 - 1) + 1));
  end;
  do return __haxe_io_Bytes.new(_g.length, _g) end;
end
__haxe_io_Bytes.prototype = _hx_e();
__haxe_io_Bytes.prototype.length= nil;
__haxe_io_Bytes.prototype.b= nil;
__haxe_io_Bytes.prototype.getString = function(self,pos,len,encoding) 
  local tmp = encoding == nil;
  if (((pos < 0) or (len < 0)) or ((pos + len) > self.length)) then 
    _G.error(__haxe_Exception.thrown(__haxe_io_Error.OutsideBounds),0);
  end;
  if ((self.b.length - pos) <= __lua_Boot.MAXSTACKSIZE) then 
    local _end = Math.min(self.b.length, pos + len) - 1;
    do return _G.string.char(_hx_table.unpack(self.b, pos, _end)) end;
  else
    local tbl = ({});
    local _g = pos;
    local _g1 = pos + len;
    while (_g < _g1) do 
      _g = _g + 1;
      local idx = _g - 1;
      _G.table.insert(tbl, _G.string.char(self.b[idx]));
    end;
    do return _G.table.concat(tbl, "") end;
  end;
end
__haxe_io_Bytes.prototype.toString = function(self) 
  do return self:getString(0, self.length) end
end

__haxe_io_Bytes.prototype.__class__ =  __haxe_io_Bytes

__haxe_io_BytesBuffer.new = function() 
  local self = _hx_new(__haxe_io_BytesBuffer.prototype)
  __haxe_io_BytesBuffer.super(self)
  return self
end
__haxe_io_BytesBuffer.super = function(self) 
  self.b = Array.new();
end
__haxe_io_BytesBuffer.__name__ = true
__haxe_io_BytesBuffer.prototype = _hx_e();
__haxe_io_BytesBuffer.prototype.b= nil;
__haxe_io_BytesBuffer.prototype.getBytes = function(self) 
  local bytes = __haxe_io_Bytes.new(self.b.length, self.b);
  self.b = nil;
  do return bytes end
end

__haxe_io_BytesBuffer.prototype.__class__ =  __haxe_io_BytesBuffer
_hxClasses["haxe.io.Encoding"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="UTF8","RawNative"},2)}
__haxe_io_Encoding = _hxClasses["haxe.io.Encoding"];
__haxe_io_Encoding.UTF8 = _hx_tab_array({[0]="UTF8",0,__enum__ = __haxe_io_Encoding},2)

__haxe_io_Encoding.RawNative = _hx_tab_array({[0]="RawNative",1,__enum__ = __haxe_io_Encoding},2)


__haxe_io_Eof.new = function() 
  local self = _hx_new(__haxe_io_Eof.prototype)
  __haxe_io_Eof.super(self)
  return self
end
__haxe_io_Eof.super = function(self) 
end
__haxe_io_Eof.__name__ = true
__haxe_io_Eof.prototype = _hx_e();
__haxe_io_Eof.prototype.toString = function(self) 
  do return "Eof" end
end

__haxe_io_Eof.prototype.__class__ =  __haxe_io_Eof
_hxClasses["haxe.io.Error"] = { __ename__ = true, __constructs__ = _hx_tab_array({[0]="Blocked","Overflow","OutsideBounds","Custom"},4)}
__haxe_io_Error = _hxClasses["haxe.io.Error"];
__haxe_io_Error.Blocked = _hx_tab_array({[0]="Blocked",0,__enum__ = __haxe_io_Error},2)

__haxe_io_Error.Overflow = _hx_tab_array({[0]="Overflow",1,__enum__ = __haxe_io_Error},2)

__haxe_io_Error.OutsideBounds = _hx_tab_array({[0]="OutsideBounds",2,__enum__ = __haxe_io_Error},2)

__haxe_io_Error.Custom = function(e) local _x = _hx_tab_array({[0]="Custom",3,e,__enum__=__haxe_io_Error}, 3); return _x; end 

__haxe_iterators_ArrayIterator.new = function(array) 
  local self = _hx_new(__haxe_iterators_ArrayIterator.prototype)
  __haxe_iterators_ArrayIterator.super(self,array)
  return self
end
__haxe_iterators_ArrayIterator.super = function(self,array) 
  self.current = 0;
  self.array = array;
end
__haxe_iterators_ArrayIterator.__name__ = true
__haxe_iterators_ArrayIterator.prototype = _hx_e();
__haxe_iterators_ArrayIterator.prototype.array= nil;
__haxe_iterators_ArrayIterator.prototype.current= nil;
__haxe_iterators_ArrayIterator.prototype.hasNext = function(self) 
  do return self.current < self.array.length end
end
__haxe_iterators_ArrayIterator.prototype.next = function(self) 
  do return self.array[(function() 
  local _hx_obj = self;
  local _hx_fld = 'current';
  local _ = _hx_obj[_hx_fld];
  _hx_obj[_hx_fld] = _hx_obj[_hx_fld]  + 1;
   return _;
   end)()] end
end

__haxe_iterators_ArrayIterator.prototype.__class__ =  __haxe_iterators_ArrayIterator

__haxe_iterators_ArrayKeyValueIterator.new = function(array) 
  local self = _hx_new(__haxe_iterators_ArrayKeyValueIterator.prototype)
  __haxe_iterators_ArrayKeyValueIterator.super(self,array)
  return self
end
__haxe_iterators_ArrayKeyValueIterator.super = function(self,array) 
  self.array = array;
end
__haxe_iterators_ArrayKeyValueIterator.__name__ = true
__haxe_iterators_ArrayKeyValueIterator.prototype = _hx_e();
__haxe_iterators_ArrayKeyValueIterator.prototype.array= nil;

__haxe_iterators_ArrayKeyValueIterator.prototype.__class__ =  __haxe_iterators_ArrayKeyValueIterator

__lua_Boot.new = {}
__lua_Boot.__name__ = true
__lua_Boot.__instanceof = function(o,cl) 
  if (cl == nil) then 
    do return false end;
  end;
  local cl1 = cl;
  if (cl1) == Array then 
    do return __lua_Boot.isArray(o) end;
  elseif (cl1) == Bool then 
    do return _G.type(o) == "boolean" end;
  elseif (cl1) == Dynamic then 
    do return o ~= nil end;
  elseif (cl1) == Float then 
    do return _G.type(o) == "number" end;
  elseif (cl1) == Int then 
    if (_G.type(o) == "number") then 
      do return _hx_bit_clamp(o) == o end;
    else
      do return false end;
    end;
  elseif (cl1) == String then 
    do return _G.type(o) == "string" end;
  elseif (cl1) == _G.table then 
    do return _G.type(o) == "table" end;
  elseif (cl1) == __lua_Thread then 
    do return _G.type(o) == "thread" end;
  elseif (cl1) == __lua_UserData then 
    do return _G.type(o) == "userdata" end;else
  if (((o ~= nil) and (_G.type(o) == "table")) and (_G.type(cl) == "table")) then 
    local tmp;
    if (__lua_Boot.__instanceof(o, Array)) then 
      tmp = Array;
    else
      if (__lua_Boot.__instanceof(o, String)) then 
        tmp = String;
      else
        local cl = o.__class__;
        tmp = (function() 
          local _hx_1
          if (cl ~= nil) then 
          _hx_1 = cl; else 
          _hx_1 = nil; end
          return _hx_1
        end )();
      end;
    end;
    if (__lua_Boot.extendsOrImplements(tmp, cl)) then 
      do return true end;
    end;
    if ((function() 
      local _hx_2
      if (cl == Class) then 
      _hx_2 = o.__name__ ~= nil; else 
      _hx_2 = false; end
      return _hx_2
    end )()) then 
      do return true end;
    end;
    if ((function() 
      local _hx_3
      if (cl == Enum) then 
      _hx_3 = o.__ename__ ~= nil; else 
      _hx_3 = false; end
      return _hx_3
    end )()) then 
      do return true end;
    end;
    do return o.__enum__ == cl end;
  else
    do return false end;
  end; end;
end
__lua_Boot.isArray = function(o) 
  if (_G.type(o) == "table") then 
    if ((o.__enum__ == nil) and (_G.getmetatable(o) ~= nil)) then 
      do return _G.getmetatable(o).__index == Array.prototype end;
    else
      do return false end;
    end;
  else
    do return false end;
  end;
end
__lua_Boot.dateStr = function(date) 
  local m = date:getMonth() + 1;
  local d = date:getDate();
  local h = date:getHours();
  local mi = date:getMinutes();
  local s = date:getSeconds();
  do return Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(Std.string(date:getFullYear()) .. Std.string("-")) .. Std.string(((function() 
    local _hx_1
    if (m < 10) then 
    _hx_1 = Std.string("0") .. Std.string(m); else 
    _hx_1 = Std.string("") .. Std.string(m); end
    return _hx_1
  end )()))) .. Std.string("-")) .. Std.string(((function() 
    local _hx_2
    if (d < 10) then 
    _hx_2 = Std.string("0") .. Std.string(d); else 
    _hx_2 = Std.string("") .. Std.string(d); end
    return _hx_2
  end )()))) .. Std.string(" ")) .. Std.string(((function() 
    local _hx_3
    if (h < 10) then 
    _hx_3 = Std.string("0") .. Std.string(h); else 
    _hx_3 = Std.string("") .. Std.string(h); end
    return _hx_3
  end )()))) .. Std.string(":")) .. Std.string(((function() 
    local _hx_4
    if (mi < 10) then 
    _hx_4 = Std.string("0") .. Std.string(mi); else 
    _hx_4 = Std.string("") .. Std.string(mi); end
    return _hx_4
  end )()))) .. Std.string(":")) .. Std.string(((function() 
    local _hx_5
    if (s < 10) then 
    _hx_5 = Std.string("0") .. Std.string(s); else 
    _hx_5 = Std.string("") .. Std.string(s); end
    return _hx_5
  end )())) end;
end
__lua_Boot.extendsOrImplements = function(cl1,cl2) 
  while (true) do 
    if ((cl1 == nil) or (cl2 == nil)) then 
      do return false end;
    else
      if (cl1 == cl2) then 
        do return true end;
      else
        if (cl1.__interfaces__ ~= nil) then 
          local intf = cl1.__interfaces__;
          local _g = 1;
          local _g1 = _hx_table.maxn(intf) + 1;
          while (_g < _g1) do 
            _g = _g + 1;
            local i = _g - 1;
            if (__lua_Boot.extendsOrImplements(intf[i], cl2)) then 
              do return true end;
            end;
          end;
        end;
      end;
    end;
    cl1 = cl1.__super__;
  end;
end

__lua_UserData.new = {}
__lua_UserData.__name__ = true

__lua_Thread.new = {}
__lua_Thread.__name__ = true

__safety_SafetyException.new = function(message,previous,native) 
  local self = _hx_new(__safety_SafetyException.prototype)
  __safety_SafetyException.super(self,message,previous,native)
  return self
end
__safety_SafetyException.super = function(self,message,previous,native) 
  __haxe_Exception.super(self,message,previous,native);
  self.__skipStack = self.__skipStack + 1;
end
__safety_SafetyException.__name__ = true
__safety_SafetyException.prototype = _hx_e();

__safety_SafetyException.prototype.__class__ =  __safety_SafetyException
__safety_SafetyException.__super__ = __haxe_Exception
setmetatable(__safety_SafetyException.prototype,{__index=__haxe_Exception.prototype})

__safety_NullPointerException.new = function(message,previous,native) 
  local self = _hx_new(__safety_NullPointerException.prototype)
  __safety_NullPointerException.super(self,message,previous,native)
  return self
end
__safety_NullPointerException.super = function(self,message,previous,native) 
  __safety_SafetyException.super(self,message,previous,native);
  self.__skipStack = self.__skipStack + 1;
end
__safety_NullPointerException.__name__ = true
__safety_NullPointerException.prototype = _hx_e();

__safety_NullPointerException.prototype.__class__ =  __safety_NullPointerException
__safety_NullPointerException.__super__ = __safety_SafetyException
setmetatable(__safety_NullPointerException.prototype,{__index=__safety_SafetyException.prototype})

__tink_core_Annex.new = function(target) 
  local self = _hx_new(__tink_core_Annex.prototype)
  __tink_core_Annex.super(self,target)
  return self
end
__tink_core_Annex.super = function(self,target) 
  self.target = target;
  self.registry = __haxe_ds_ObjectMap.new();
end
__tink_core_Annex.__name__ = true
__tink_core_Annex.prototype = _hx_e();
__tink_core_Annex.prototype.target= nil;
__tink_core_Annex.prototype.registry= nil;

__tink_core_Annex.prototype.__class__ =  __tink_core_Annex

__tink_json_BasicWriter.new = function() 
  local self = _hx_new(__tink_json_BasicWriter.prototype)
  __tink_json_BasicWriter.super(self)
  return self
end
__tink_json_BasicWriter.super = function(self) 
  self.plugins = __tink_core_Annex.new(self);
end
__tink_json_BasicWriter.__name__ = true
__tink_json_BasicWriter.prototype = _hx_e();
__tink_json_BasicWriter.prototype.plugins= nil;
__tink_json_BasicWriter.prototype.buf= nil;
__tink_json_BasicWriter.prototype.init = function(self) 
  self.buf = StringBuf.new();
end
__tink_json_BasicWriter.prototype.writeDynamic = function(self,value) 
  local s = __haxe_format_JsonPrinter.print(value);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
end

__tink_json_BasicWriter.prototype.__class__ =  __tink_json_BasicWriter

__tink_json_Writer45.new = function() 
  local self = _hx_new(__tink_json_Writer45.prototype)
  __tink_json_Writer45.super(self)
  return self
end
__tink_json_Writer45.super = function(self) 
  __tink_json_BasicWriter.super(self);
end
__tink_json_Writer45.__name__ = true
__tink_json_Writer45.prototype = _hx_e();
__tink_json_Writer45.prototype.process0 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.command;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"command\":");
  _this.length = _this.length + #"\"command\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.request_seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"request_seq\":");
  _this.length = _this.length + #"\"request_seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"seq\":");
  _this.length = _this.length + #"\"seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.success;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"success\":");
  _this.length = _this.length + #"\"success\":";
  local _this = self.buf;
  local str = (function() 
    local _hx_1
    if (value1) then 
    _hx_1 = "true"; else 
    _hx_1 = "false"; end
    return _hx_1
  end )();
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.type;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"type\":");
  _this.length = _this.length + #"\"type\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.body;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"body\":");
    _this.length = _this.length + #"\"body\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      self:process1(_g);
    end;
  end;
  local _g = value.message;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"message\":");
    _this.length = _this.length + #"\"message\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer45.prototype.process1 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value = value.scopes;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"scopes\":");
  _this.length = _this.length + #"\"scopes\":";
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(91));
  _this.length = _this.length + 1;
  local first = true;
  local _g = 0;
  while (_g < value.length) do 
    local value = value[_g];
    _g = _g + 1;
    if (first) then 
      first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    self:process2(value);
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(93));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer45.prototype.process2 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.expensive;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"expensive\":");
  _this.length = _this.length + #"\"expensive\":";
  local _this = self.buf;
  local str = (function() 
    local _hx_1
    if (value1) then 
    _hx_1 = "true"; else 
    _hx_1 = "false"; end
    return _hx_1
  end )();
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.name;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"name\":");
  _this.length = _this.length + #"\"name\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.variablesReference;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"variablesReference\":");
  _this.length = _this.length + #"\"variablesReference\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.column;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"column\":");
    _this.length = _this.length + #"\"column\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.endColumn;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"endColumn\":");
    _this.length = _this.length + #"\"endColumn\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.endLine;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"endLine\":");
    _this.length = _this.length + #"\"endLine\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.indexedVariables;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"indexedVariables\":");
    _this.length = _this.length + #"\"indexedVariables\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.line;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"line\":");
    _this.length = _this.length + #"\"line\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.namedVariables;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"namedVariables\":");
    _this.length = _this.length + #"\"namedVariables\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.presentationHint;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.source;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"source\":");
    _this.length = _this.length + #"\"source\":";
    self:process3(_g);
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer45.prototype.process3 = function(self,value) 
  local __first = true;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  if (value.adapterData ~= nil) then 
    __first = false;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"adapterData\":");
    _this.length = _this.length + #"\"adapterData\":";
    self:writeDynamic(value.adapterData);
  end;
  if (value.checksums ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"checksums\":");
    _this.length = _this.length + #"\"checksums\":";
    local value = value.checksums;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process4(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  if (value.name ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"name\":");
    _this.length = _this.length + #"\"name\":";
    local value = value.name;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.origin ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"origin\":");
    _this.length = _this.length + #"\"origin\":";
    local value = value.origin;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.path ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"path\":");
    _this.length = _this.length + #"\"path\":";
    local value = value.path;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.presentationHint ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    local value = value.presentationHint;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sourceReference ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sourceReference\":");
    _this.length = _this.length + #"\"sourceReference\":";
    local value = value.sourceReference;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sources ~= nil) then 
    if (not __first) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sources\":");
    _this.length = _this.length + #"\"sources\":";
    local value = value.sources;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process5(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer45.prototype.process4 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.algorithm;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"algorithm\":");
  _this.length = _this.length + #"\"algorithm\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value = value.checksum;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"checksum\":");
  _this.length = _this.length + #"\"checksum\":";
  local s = __haxe_format_JsonPrinter.print(value);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer45.prototype.process5 = function(self,value) 
  local __first = true;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  if (value.adapterData ~= nil) then 
    __first = false;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"adapterData\":");
    _this.length = _this.length + #"\"adapterData\":";
    self:writeDynamic(value.adapterData);
  end;
  if (value.checksums ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"checksums\":");
    _this.length = _this.length + #"\"checksums\":";
    local value = value.checksums;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process4(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  if (value.name ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"name\":");
    _this.length = _this.length + #"\"name\":";
    local value = value.name;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.origin ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"origin\":");
    _this.length = _this.length + #"\"origin\":";
    local value = value.origin;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.path ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"path\":");
    _this.length = _this.length + #"\"path\":";
    local value = value.path;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.presentationHint ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    local value = value.presentationHint;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sourceReference ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sourceReference\":");
    _this.length = _this.length + #"\"sourceReference\":";
    local value = value.sourceReference;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sources ~= nil) then 
    if (not __first) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sources\":");
    _this.length = _this.length + #"\"sources\":";
    local value = value.sources;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process5(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer45.prototype.write = function(self,value) 
  self:init();
  self:process0(value);
  do return _G.table.concat(self.buf.b) end
end

__tink_json_Writer45.prototype.__class__ =  __tink_json_Writer45
__tink_json_Writer45.__super__ = __tink_json_BasicWriter
setmetatable(__tink_json_Writer45.prototype,{__index=__tink_json_BasicWriter.prototype})

__tink_json_Writer46.new = function() 
  local self = _hx_new(__tink_json_Writer46.prototype)
  __tink_json_Writer46.super(self)
  return self
end
__tink_json_Writer46.super = function(self) 
  __tink_json_BasicWriter.super(self);
end
__tink_json_Writer46.__name__ = true
__tink_json_Writer46.prototype = _hx_e();
__tink_json_Writer46.prototype.process0 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.command;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"command\":");
  _this.length = _this.length + #"\"command\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.request_seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"request_seq\":");
  _this.length = _this.length + #"\"request_seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"seq\":");
  _this.length = _this.length + #"\"seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.success;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"success\":");
  _this.length = _this.length + #"\"success\":";
  local _this = self.buf;
  local str = (function() 
    local _hx_1
    if (value1) then 
    _hx_1 = "true"; else 
    _hx_1 = "false"; end
    return _hx_1
  end )();
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.type;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"type\":");
  _this.length = _this.length + #"\"type\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.body;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"body\":");
    _this.length = _this.length + #"\"body\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      self:process1(_g);
    end;
  end;
  local _g = value.message;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"message\":");
    _this.length = _this.length + #"\"message\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer46.prototype.process1 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value = value.breakpoints;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"breakpoints\":");
  _this.length = _this.length + #"\"breakpoints\":";
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(91));
  _this.length = _this.length + 1;
  local first = true;
  local _g = 0;
  while (_g < value.length) do 
    local value = value[_g];
    _g = _g + 1;
    if (first) then 
      first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    self:process2(value);
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(93));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer46.prototype.process2 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.verified;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"verified\":");
  _this.length = _this.length + #"\"verified\":";
  local _this = self.buf;
  local str = (function() 
    local _hx_1
    if (value1) then 
    _hx_1 = "true"; else 
    _hx_1 = "false"; end
    return _hx_1
  end )();
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.column;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"column\":");
    _this.length = _this.length + #"\"column\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.endColumn;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"endColumn\":");
    _this.length = _this.length + #"\"endColumn\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.endLine;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"endLine\":");
    _this.length = _this.length + #"\"endLine\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.id;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"id\":");
    _this.length = _this.length + #"\"id\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.instructionReference;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"instructionReference\":");
    _this.length = _this.length + #"\"instructionReference\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.line;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"line\":");
    _this.length = _this.length + #"\"line\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.message;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"message\":");
    _this.length = _this.length + #"\"message\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.offset;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"offset\":");
    _this.length = _this.length + #"\"offset\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.source;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"source\":");
    _this.length = _this.length + #"\"source\":";
    self:process3(_g);
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer46.prototype.process3 = function(self,value) 
  local __first = true;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  if (value.adapterData ~= nil) then 
    __first = false;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"adapterData\":");
    _this.length = _this.length + #"\"adapterData\":";
    self:writeDynamic(value.adapterData);
  end;
  if (value.checksums ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"checksums\":");
    _this.length = _this.length + #"\"checksums\":";
    local value = value.checksums;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process4(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  if (value.name ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"name\":");
    _this.length = _this.length + #"\"name\":";
    local value = value.name;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.origin ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"origin\":");
    _this.length = _this.length + #"\"origin\":";
    local value = value.origin;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.path ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"path\":");
    _this.length = _this.length + #"\"path\":";
    local value = value.path;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.presentationHint ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    local value = value.presentationHint;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sourceReference ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sourceReference\":");
    _this.length = _this.length + #"\"sourceReference\":";
    local value = value.sourceReference;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sources ~= nil) then 
    if (not __first) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sources\":");
    _this.length = _this.length + #"\"sources\":";
    local value = value.sources;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process5(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer46.prototype.process4 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.algorithm;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"algorithm\":");
  _this.length = _this.length + #"\"algorithm\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value = value.checksum;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"checksum\":");
  _this.length = _this.length + #"\"checksum\":";
  local s = __haxe_format_JsonPrinter.print(value);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer46.prototype.process5 = function(self,value) 
  local __first = true;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  if (value.adapterData ~= nil) then 
    __first = false;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"adapterData\":");
    _this.length = _this.length + #"\"adapterData\":";
    self:writeDynamic(value.adapterData);
  end;
  if (value.checksums ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"checksums\":");
    _this.length = _this.length + #"\"checksums\":";
    local value = value.checksums;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process4(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  if (value.name ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"name\":");
    _this.length = _this.length + #"\"name\":";
    local value = value.name;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.origin ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"origin\":");
    _this.length = _this.length + #"\"origin\":";
    local value = value.origin;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.path ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"path\":");
    _this.length = _this.length + #"\"path\":";
    local value = value.path;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.presentationHint ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    local value = value.presentationHint;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sourceReference ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sourceReference\":");
    _this.length = _this.length + #"\"sourceReference\":";
    local value = value.sourceReference;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sources ~= nil) then 
    if (not __first) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sources\":");
    _this.length = _this.length + #"\"sources\":";
    local value = value.sources;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process5(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer46.prototype.write = function(self,value) 
  self:init();
  self:process0(value);
  do return _G.table.concat(self.buf.b) end
end

__tink_json_Writer46.prototype.__class__ =  __tink_json_Writer46
__tink_json_Writer46.__super__ = __tink_json_BasicWriter
setmetatable(__tink_json_Writer46.prototype,{__index=__tink_json_BasicWriter.prototype})

__tink_json_Writer47.new = function() 
  local self = _hx_new(__tink_json_Writer47.prototype)
  __tink_json_Writer47.super(self)
  return self
end
__tink_json_Writer47.super = function(self) 
  __tink_json_BasicWriter.super(self);
end
__tink_json_Writer47.__name__ = true
__tink_json_Writer47.prototype = _hx_e();
__tink_json_Writer47.prototype.process0 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.command;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"command\":");
  _this.length = _this.length + #"\"command\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.request_seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"request_seq\":");
  _this.length = _this.length + #"\"request_seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"seq\":");
  _this.length = _this.length + #"\"seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.success;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"success\":");
  _this.length = _this.length + #"\"success\":";
  local _this = self.buf;
  local str = (function() 
    local _hx_1
    if (value1) then 
    _hx_1 = "true"; else 
    _hx_1 = "false"; end
    return _hx_1
  end )();
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.type;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"type\":");
  _this.length = _this.length + #"\"type\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.body;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"body\":");
    _this.length = _this.length + #"\"body\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      self:process1(_g);
    end;
  end;
  local _g = value.message;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"message\":");
    _this.length = _this.length + #"\"message\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer47.prototype.process1 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value = value.variables;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"variables\":");
  _this.length = _this.length + #"\"variables\":";
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(91));
  _this.length = _this.length + 1;
  local first = true;
  local _g = 0;
  while (_g < value.length) do 
    local value = value[_g];
    _g = _g + 1;
    if (first) then 
      first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    self:process2(value);
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(93));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer47.prototype.process2 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.name;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"name\":");
  _this.length = _this.length + #"\"name\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.value;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"value\":");
  _this.length = _this.length + #"\"value\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.variablesReference;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"variablesReference\":");
  _this.length = _this.length + #"\"variablesReference\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.evaluateName;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"evaluateName\":");
    _this.length = _this.length + #"\"evaluateName\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.indexedVariables;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"indexedVariables\":");
    _this.length = _this.length + #"\"indexedVariables\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.memoryReference;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"memoryReference\":");
    _this.length = _this.length + #"\"memoryReference\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.namedVariables;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"namedVariables\":");
    _this.length = _this.length + #"\"namedVariables\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.presentationHint;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      self:process3(_g);
    end;
  end;
  local _g = value.type;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"type\":");
    _this.length = _this.length + #"\"type\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer47.prototype.process3 = function(self,value) 
  local __first = true;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  if (value.attributes ~= nil) then 
    __first = false;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"attributes\":");
    _this.length = _this.length + #"\"attributes\":";
    local value = value.attributes;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        local s = __haxe_format_JsonPrinter.print(value);
        local _this = self.buf;
        local str = Std.string(s);
        _G.table.insert(_this.b, str);
        _this.length = _this.length + #str;
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  if (value.kind ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"kind\":");
    _this.length = _this.length + #"\"kind\":";
    local value = value.kind;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.visibility ~= nil) then 
    if (not __first) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"visibility\":");
    _this.length = _this.length + #"\"visibility\":";
    local value = value.visibility;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer47.prototype.write = function(self,value) 
  self:init();
  self:process0(value);
  do return _G.table.concat(self.buf.b) end
end

__tink_json_Writer47.prototype.__class__ =  __tink_json_Writer47
__tink_json_Writer47.__super__ = __tink_json_BasicWriter
setmetatable(__tink_json_Writer47.prototype,{__index=__tink_json_BasicWriter.prototype})

__tink_json_Writer48.new = function() 
  local self = _hx_new(__tink_json_Writer48.prototype)
  __tink_json_Writer48.super(self)
  return self
end
__tink_json_Writer48.super = function(self) 
  __tink_json_BasicWriter.super(self);
end
__tink_json_Writer48.__name__ = true
__tink_json_Writer48.prototype = _hx_e();
__tink_json_Writer48.prototype.process0 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.command;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"command\":");
  _this.length = _this.length + #"\"command\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.request_seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"request_seq\":");
  _this.length = _this.length + #"\"request_seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.seq;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"seq\":");
  _this.length = _this.length + #"\"seq\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.success;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"success\":");
  _this.length = _this.length + #"\"success\":";
  local _this = self.buf;
  local str = (function() 
    local _hx_1
    if (value1) then 
    _hx_1 = "true"; else 
    _hx_1 = "false"; end
    return _hx_1
  end )();
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.type;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"type\":");
  _this.length = _this.length + #"\"type\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.body;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"body\":");
    _this.length = _this.length + #"\"body\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      self:process1(_g);
    end;
  end;
  local _g = value.message;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"message\":");
    _this.length = _this.length + #"\"message\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer48.prototype.process1 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.stackFrames;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"stackFrames\":");
  _this.length = _this.length + #"\"stackFrames\":";
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(91));
  _this.length = _this.length + 1;
  local first = true;
  local _g = 0;
  while (_g < value1.length) do 
    local value = value1[_g];
    _g = _g + 1;
    if (first) then 
      first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    self:process2(value);
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(93));
  _this.length = _this.length + 1;
  local _g = value.totalFrames;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"totalFrames\":");
    _this.length = _this.length + #"\"totalFrames\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer48.prototype.process2 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.column;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"column\":");
  _this.length = _this.length + #"\"column\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.id;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"id\":");
  _this.length = _this.length + #"\"id\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.line;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"line\":");
  _this.length = _this.length + #"\"line\":";
  local s = Std.string(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value1 = value.name;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"name\":");
  _this.length = _this.length + #"\"name\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _g = value.endColumn;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"endColumn\":");
    _this.length = _this.length + #"\"endColumn\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.endLine;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"endLine\":");
    _this.length = _this.length + #"\"endLine\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.moduleId;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"moduleId\":");
    _this.length = _this.length + #"\"moduleId\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      self:writeDynamic(_g);
    end;
  end;
  local _g = value.presentationHint;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    if (_g == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(_g);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  local _g = value.source;
  if (_g ~= nil) then 
    local _this = self.buf;
    _G.table.insert(_this.b, _G.string.char(44));
    _this.length = _this.length + 1;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"source\":");
    _this.length = _this.length + #"\"source\":";
    self:process3(_g);
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer48.prototype.process3 = function(self,value) 
  local __first = true;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  if (value.adapterData ~= nil) then 
    __first = false;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"adapterData\":");
    _this.length = _this.length + #"\"adapterData\":";
    self:writeDynamic(value.adapterData);
  end;
  if (value.checksums ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"checksums\":");
    _this.length = _this.length + #"\"checksums\":";
    local value = value.checksums;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process4(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  if (value.name ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"name\":");
    _this.length = _this.length + #"\"name\":";
    local value = value.name;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.origin ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"origin\":");
    _this.length = _this.length + #"\"origin\":";
    local value = value.origin;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.path ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"path\":");
    _this.length = _this.length + #"\"path\":";
    local value = value.path;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.presentationHint ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    local value = value.presentationHint;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sourceReference ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sourceReference\":");
    _this.length = _this.length + #"\"sourceReference\":";
    local value = value.sourceReference;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sources ~= nil) then 
    if (not __first) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sources\":");
    _this.length = _this.length + #"\"sources\":";
    local value = value.sources;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process5(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer48.prototype.process4 = function(self,value) 
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  local value1 = value.algorithm;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"algorithm\":");
  _this.length = _this.length + #"\"algorithm\":";
  local s = __haxe_format_JsonPrinter.print(value1);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local value = value.checksum;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(44));
  _this.length = _this.length + 1;
  local _this = self.buf;
  _G.table.insert(_this.b, "\"checksum\":");
  _this.length = _this.length + #"\"checksum\":";
  local s = __haxe_format_JsonPrinter.print(value);
  local _this = self.buf;
  local str = Std.string(s);
  _G.table.insert(_this.b, str);
  _this.length = _this.length + #str;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer48.prototype.process5 = function(self,value) 
  local __first = true;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(123));
  _this.length = _this.length + 1;
  if (value.adapterData ~= nil) then 
    __first = false;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"adapterData\":");
    _this.length = _this.length + #"\"adapterData\":";
    self:writeDynamic(value.adapterData);
  end;
  if (value.checksums ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"checksums\":");
    _this.length = _this.length + #"\"checksums\":";
    local value = value.checksums;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process4(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  if (value.name ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"name\":");
    _this.length = _this.length + #"\"name\":";
    local value = value.name;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.origin ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"origin\":");
    _this.length = _this.length + #"\"origin\":";
    local value = value.origin;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.path ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"path\":");
    _this.length = _this.length + #"\"path\":";
    local value = value.path;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.presentationHint ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"presentationHint\":");
    _this.length = _this.length + #"\"presentationHint\":";
    local value = value.presentationHint;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = __haxe_format_JsonPrinter.print(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sourceReference ~= nil) then 
    if (__first) then 
      __first = false;
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sourceReference\":");
    _this.length = _this.length + #"\"sourceReference\":";
    local value = value.sourceReference;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local s = Std.string(value);
      local _this = self.buf;
      local str = Std.string(s);
      _G.table.insert(_this.b, str);
      _this.length = _this.length + #str;
    end;
  end;
  if (value.sources ~= nil) then 
    if (not __first) then 
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(44));
      _this.length = _this.length + 1;
    end;
    local _this = self.buf;
    _G.table.insert(_this.b, "\"sources\":");
    _this.length = _this.length + #"\"sources\":";
    local value = value.sources;
    if (value == nil) then 
      local _this = self.buf;
      _G.table.insert(_this.b, "null");
      _this.length = _this.length + #"null";
    else
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(91));
      _this.length = _this.length + 1;
      local first = true;
      local _g = 0;
      while (_g < value.length) do 
        local value = value[_g];
        _g = _g + 1;
        if (first) then 
          first = false;
        else
          local _this = self.buf;
          _G.table.insert(_this.b, _G.string.char(44));
          _this.length = _this.length + 1;
        end;
        self:process5(value);
      end;
      local _this = self.buf;
      _G.table.insert(_this.b, _G.string.char(93));
      _this.length = _this.length + 1;
    end;
  end;
  local _this = self.buf;
  _G.table.insert(_this.b, _G.string.char(125));
  _this.length = _this.length + 1;
end
__tink_json_Writer48.prototype.write = function(self,value) 
  self:init();
  self:process0(value);
  do return _G.table.concat(self.buf.b) end
end

__tink_json_Writer48.prototype.__class__ =  __tink_json_Writer48
__tink_json_Writer48.__super__ = __tink_json_BasicWriter
setmetatable(__tink_json_Writer48.prototype,{__index=__tink_json_BasicWriter.prototype})
-- require this for lua 5.1
pcall(require, 'bit')
if bit then
  _hx_bit_raw = bit
  _hx_bit = setmetatable({}, { __index = _hx_bit_raw });
else
  _hx_bit_raw = _G.require('bit32')
  _hx_bit = setmetatable({}, { __index = _hx_bit_raw });
  -- lua 5.2 weirdness
  _hx_bit.bnot = function(...) return _hx_bit_clamp(_hx_bit_raw.bnot(...)) end;
  _hx_bit.bxor = function(...) return _hx_bit_clamp(_hx_bit_raw.bxor(...)) end;
end
-- see https://github.com/HaxeFoundation/haxe/issues/8849
_hx_bit.bor = function(...) return _hx_bit_clamp(_hx_bit_raw.bor(...)) end;
_hx_bit.band = function(...) return _hx_bit_clamp(_hx_bit_raw.band(...)) end;
_hx_bit.arshift = function(...) return _hx_bit_clamp(_hx_bit_raw.arshift(...)) end;

if _hx_bit_raw then
    _hx_bit_clamp = function(v)
    if v <= 2147483647 and v >= -2147483648 then
        if v > 0 then return _G.math.floor(v)
        else return _G.math.ceil(v)
        end
    end
    if v > 2251798999999999 then v = v*2 end;
    if (v ~= v or math.abs(v) == _G.math.huge) then return nil end
    return _hx_bit_raw.band(v, 2147483647 ) - math.abs(_hx_bit_raw.band(v, 2147483648))
    end
else
    _hx_bit_clamp = function(v)
        if v < -2147483648 then
            return -2147483648
        elseif v > 2147483647 then
            return 2147483647
        elseif v > 0 then
            return _G.math.floor(v)
        else
            return _G.math.ceil(v)
        end
    end
end;



_hx_array_mt.__index = Array.prototype

local _hx_static_init = function()
  
  String.__name__ = true;
  Array.__name__ = true;__gmdebug_Cross.FOLDER = "gmdebug";
  
  __gmdebug_Cross.CLIENT_READY = __haxe_io_Path.join(_hx_tab_array({[0]=__gmdebug_Cross.FOLDER, "clientready.dat"}, 2));
  
  __gmdebug_Cross.INPUT = __haxe_io_Path.join(_hx_tab_array({[0]=__gmdebug_Cross.FOLDER, "in.dat"}, 2));
  
  __gmdebug_Cross.OUTPUT = __haxe_io_Path.join(_hx_tab_array({[0]=__gmdebug_Cross.FOLDER, "out.dat"}, 2));
  
  __gmdebug_Cross.READY = __haxe_io_Path.join(_hx_tab_array({[0]=__gmdebug_Cross.FOLDER, "ready.dat"}, 2));
  
  __gmdebug_lua__DebugHook_DDebugHook.hooks = __gmdebug_lua__DebugHook_DDebugHook.getHooks();
  
  __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC = 200;
  
  __gmdebug_lua_DebugLoop.STACK_LIMIT = 65450;
  
  __gmdebug_lua_DebugLoop.STACK_DEBUG_TAIL = 500;
  
  __gmdebug_lua_DebugLoop.STACK_DEBUG_RELIEF_OURFUNCS = __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC * 2;
  
  __gmdebug_lua_DebugLoop.STACK_DEBUG_RELIEF_TOLERANCE = __gmdebug_lua_DebugLoop.STACK_LIMIT_PER_FUNC * 4;
  
  __gmdebug_lua_DebugLoop.STACK_DEBUG_LIMIT = (__gmdebug_lua_DebugLoop.STACK_LIMIT - __gmdebug_lua_DebugLoop.STACK_DEBUG_RELIEF_OURFUNCS) - __gmdebug_lua_DebugLoop.STACK_DEBUG_RELIEF_TOLERANCE;
  
  __gmdebug_lua_DebugLoop.highestStackHeight = _G.math.huge;
  
  __gmdebug_lua_DebugLoop.escapeHatch = __gmdebug_lua_CatchOut.NONE;
  
  __gmdebug_lua_DebugLoop.prevStackHeight = 0;
  
  __gmdebug_lua_DebugLoop.lineSteppin = false;
  
  __gmdebug_lua_DebugLoop.nextCheckStack = 1;
  
  __gmdebug_lua_DebugLoop.curCheckStack = 0;
  
  __gmdebug_lua_DebugLoop.tailLength = 0;
  
  __gmdebug_lua_DebugLoop.tailLocals = 0;
  
  __gmdebug_lua_DebugLoop.supressCheckStack = __haxe_ds_Option.None;
  
  __gmdebug_lua_DebugLoopProfile.finish = _hx_tab_array({}, 0);
  
  __gmdebug_lua_DebugLoopProfile.pass = 0;
  
  __gmdebug_lua_DebugLoopProfile.profileState = __gmdebug_lua_ProfilingState.NOT_PROFILING;
  
  __gmdebug_lua_DebugLoopProfile.cumulativeTime = 0.0;
  
  __gmdebug_lua_DebugLoopProfile.totalProfileTime = 0.0;
  
  __gmdebug_lua_Exceptions.exceptFuncs = __gmdebug_lua_Exceptions.getexceptFuncs();
  
  __gmdebug_lua_StackConst.MIN_HEIGHT = 3;
  
  __gmdebug_lua_StackConst.MIN_HEIGHT_OUT = 4;
  
  __gmdebug_lua_StackConst.STEP = 3;
  
  __gmdebug_lua_StackConst.STEP_DEBUG_LOOP = 5;
  
  __gmdebug_lua_StackConst.EXCEPT = 4;
  
  __gmdebug_lua_StackConst.PAUSE = 5;
  
  __gmod_helpers_macros_include_Build.buildIdent = "Foxtrot Juliett";
  _hx_exports["buildIdent"] = __gmod_helpers_macros_include_Build.buildIdent;
  __haxe_EntryPoint.pending = Array.new();
  
  __haxe_EntryPoint.threadCount = 0;
  
  __haxe_ds_IntMap.tnull = ({});
  
  __haxe_ds_StringMap.tnull = ({});
  
  __lua_Boot.MAXSTACKSIZE = 1000;
  
  
end

_hx_bind = function(o,m)
  if m == nil then return nil end;
  local f;
  if o._hx__closures == nil then
    _G.rawset(o, '_hx__closures', {});
  else
    f = o._hx__closures[m];
  end
  if (f == nil) then
    f = function(...) return m(o, ...) end;
    o._hx__closures[m] = f;
  end
  return f;
end

_hx_funcToField = function(f)
  if type(f) == 'function' then
    return function(self,...)
      return f(...)
    end
  else
    return f
  end
end

_hx_print = print or (function() end)

_hx_table = {}
_hx_table.pack = _G.table.pack or function(...)
    return {...}
end
_hx_table.unpack = _G.table.unpack or _G.unpack
_hx_table.maxn = _G.table.maxn or function(t)
  local maxn=0;
  for i in pairs(t) do
    maxn=type(i)=='number'and i>maxn and i or maxn
  end
  return maxn
end;

_hx_wrap_if_string_field = function(o, fld)
  if _G.type(o) == 'string' then
    if fld == 'length' then
      return _G.string.len(o)
    else
      return String.prototype[fld]
    end
  else
    return o[fld]
  end
end

_hx_static_init();
_G.xpcall(function() 
  __gmdebug_lua_Start.main();
  __haxe_EntryPoint.run();
end, _hx_error)
return _hx_exports
