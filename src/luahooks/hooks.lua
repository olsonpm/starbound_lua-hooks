----------
-- Init --
----------

local initHasRun = false


----------
-- Main --
----------

luaHooks = {
  --
  -- only call this if you're exposing a hook within your own mod.  See
  --   https://github.com/olsonpm/starbound_quest-scope-hook for an example
  --
  --
  -- ## why expose this as a property and not just initialize luaHooks inside
  --    this file?
  --
  -- I'm a new modder so there may be a cleaner way to accomplish this, but the
  --   global `root` object isn't available right away.  Manually calling
  --   `initIfNotAlready` before calling hooks was the cleanest solution I
  --   could muster.
  --
  initIfNotAlready = function()
    if not initHasRun then
      initHasRun = true
      local config = root.assetJson("/luahooks/initscripts.json")
      for _, aScript in ipairs(config.initscripts) do
        require(aScript)
      end
    end
  end
}
