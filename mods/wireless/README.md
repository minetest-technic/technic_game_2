minetest-wireless
=================

wireless digilines mod. 
No compilation needed.
Drop this folder into games/minetest_game/mods/ and rename it to just "wireless" .
Depends upon whole mesecons, digilines modpacks.  
Crafting recipes can be found at the end of init.lua, but they require digilines,
which are not craftable in Jeija's version.
so in order to craft wireless you need to replace digilines with my fork:
in minetest/games/minetest_game/mods :
git clone git://github.com/lordcirth/minetest-mod-digilines.git
Or be using technic_game, which adds digiline recipes.

If you want to contribute, please make better textures and nodeboxes - the current ones are just placeholders.
Submit a pull request to https://github.com/lordcirth/minetest-wireless

See also https://github.com/lordcirth/minetest-digipad - great for entering passcodes / messages to a transmitter.
