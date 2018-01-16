----------
-- Init --
----------

luaHooks = luaHooks or {}
luaHooks.utils = {}
local lhu = luaHooks.utils


----------
-- Main --
----------

function lhu.callHooksWithArgs(theHooks, ...)
  for _, aHook in ipairs(theHooks) do
    aHook(table.unpack({...}))
  end
end
