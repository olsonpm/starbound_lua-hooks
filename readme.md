## Starbound - Lua Hooks

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
#### Table of Contents
- [What is it?](#what-is-it)
- [Why create it?](#why-create-it)
- [How to install it?](#how-to-install-it)
- [How it works](#how-it-works)
- [Limitations](#limitations)
- [Todo ideas](#todo-ideas)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### What is it?
This mod enables dependent mods to run code inside vanilla starbound files
without modifying the file themselves.  See [how it works](#how-it-works) for
further info.


### Why create it?
Given there's no way for a mod to patch lua files, vanilla starbound files are
best left untouched.  However in order for me to create my [health monitor](https://github.com/olsonpm/starbound_health-monitor)
I needed to modify `player_primary.lua`.  Instead of modifying the file outright
I wanted to create a reusable pattern that allowed all mods to safely run code
in the context of vanilla files.  This mod both accomplished that goal and
allowed mods to expose hooks into their own files.  You can see an example of
that in my [quest scope hook mod](https://github.com/olsonpm/starbound_health-monitor)
whose soul purpose is to allow other mods to run code inside the context of an
ever-lasting invisible quest.


### How to install it
[Like this](https://github.com/olsonpm/starbound_health-monitor/blob/master/docs/how-to-install.md)


### How it works
Considering the goal of this mod is to allow dependent mods to all run code
inside vanilla contexts, we need:

1. The ability to run other mods' code.
2. Allow the mods to configure where its code is run.


##### Run other mods' code
Lua hooks exposes a json file `initscripts.json` which currently only has a
single empty array named `initscripts`.  This file is meant to be patched by
mods who add their own scripts to this array.  When the object is initialized it
`require`s all files in this array.

To show how this works, let's take a mod called `invincible` which has a magic
function `makePlayerInvincible()` that must be run inside
`player_primary.lua -> init()`.  First it needs to patch `initscripts.json` and
add its own initscript to the array.

```
-- /mods/invincible/my-initscripts.lua

--
-- Just to make sure our file is run like we expect
--
sb.logInfo("invincible: hey this ran!")
```

```hson
// /mods/invincible/luahooks/initscripts.json.patch
[
  {
    "op": "add",
    "path": "/initscripts/-",
    "value": "/my-initscripts.lua"
  }
]
```

With this code alone, you should see `invincible: hey this ran!` in
`starbound.log` when your character first loads.

Now that step 1 is finished, we need to run `makePlayerInvincible()` upon
`player_primary.lua -> init()`


##### Allow the mods to configure where its code is run

Lua Hooks enables this by exposing a global object `luaHooks`.  This object
holds two things:

1. Tables representing our 'hooks' which holds lists of functions to be ran.

For example the property

`luaHooks.vanilla["/stats/player_primary.lua"].onInit`

holds a table (list) of functions which will all be called when
`player_primary.lua -> init()` is ran.

2. An initialization function which you only have to worry about if you want to
   expose hooks in your own mod (I do that for example in my
   [quest-scope-hook mod](https://github.com/olsonpm/starbound_quest-scope-hook)).
   Documentation for the init function [is below](#the-initialization-function).

So to run `makePlayerInvincible()` upon `player_primary.lua -> init()`, we would
modify our `/mods/invincible/my-initscripts.lua` file like so:

```lua
-- /mods/invincible/my-initscripts.lua

local functionsToRunOnInit = luaHooks.vanilla["/stats/player_primary.lua"].onInit

local makePlayerInvincible = function()
  -- some magic which makes the current player invincible
  -- ...
  -- and then a message saying it's done :)
  sb.logInfo("my character is now invincible!")
end

local willRunOnInit = function()
  makePlayerInvincible()
end

table.insert(functionsToRunOnInit, willRunOnInit)
```

Voila, your character is now invincible :)

If any of the above doesn't make sense then please file an issue so I can help
make the documentation more clear.  Hopefully you understand how this mod
enables any number of mods to run code in vanilla contexts without modifying the
vanilla files.


##### The initialization function
*Bare with me because this isn't easy to explain.  Also if you can think of a
better way to explain it please let me know.  Good documentation is very
important to me.*

This function is a little goofy due to us not having the global `root` table
available to us when the file first loads.  It's also goofy because there will
be multiple scripting contexts (not sure if that's the right term) running
simultaneously, and each one will need to have its own copy of `luaHooks`.  As
far as I can tell, there's no way for me to load `luaHooks` once and have all
scripting contexts use it, thus we need to run the initialization function
before any hooks are actually run.

**So what is the initialization function anyway?**
It's [`initIfNotAlready`](https://github.com/olsonpm/starbound_lua-hooks/blob/master/src/luahooks/hooks.lua#L40-L48)
and for example is called in the [`init()` of `player_primary.lua`](https://github.com/olsonpm/starbound_lua-hooks/blob/master/src/stats/player_primary.lua#L7)

We can run it there because `root` is available at that time.  Note how it's run
before the player_primary [init hooks are run](https://github.com/olsonpm/starbound_lua-hooks/blob/master/src/stats/player_primary.lua#L28).
Because [we ensure the object won't initialize more than once](https://github.com/olsonpm/starbound_lua-hooks/blob/master/src/luahooks/hooks.lua#L41-L42),
we can follow this pattern safely throughout the codebase.


### Limitations

- As with all mods, this is not compatible with any other mods which directly
modify the same vanilla files.  This is only woth noting because this mod may
grow by adding hooks into many vanilla files making it more likely to conflict.
The solution is for conflicting mods to require this mod instead and write hooks
to achieve the same results.

- Although hooks allow for additional code to be ran, it doesn't allow you to
alter the existing code within the vanilla files.  There are solutions to this
but I prefer to tackle that problem when and if it comes.


### Todo ideas

If people find this mod useful then adding to it will be very easy.  The only
real *todo* I can think of is to add more hooks.
