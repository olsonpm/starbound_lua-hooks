## Starbound - Lua Hooks

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
#### Table of Contents
- [What is it?](#what-is-it)
- [Why create it?](#why-create-it)
- [How to install it?](#how-to-install-it)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### What is it?
This mod enables dependent mods to run code inside vanilla starbound files
without modifying the file themselves.


### Why create it?
To have a reliable way for all mods to run code in the context of vanilla files
which can't be wrapped via json patches.

*Initially I created this to modify player_primary.lua - however bk3k pointed*
*out this method may break compatibility with existing mods which wrap vanilla*
*files via json patches.  Not all vanilla files can be wrapped via json*
*patches so this library is still relevant, however I don't currently have a*
*need to modify any vanilla behavior besides player_primary.lua so I removed*
*the vanilla hooks.  I also removed the examples previously listed in the*
*readme because they're not very useful without existing code to reference.*


### How to install it
[Like this](https://github.com/olsonpm/starbound_health-monitor/blob/master/docs/how-to-install.md)
