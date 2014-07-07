Readme for version 1.2.6
#Team - EasyCodez

-Description
This grenade will freeze all players in a (default 300) radius.

-Installation
1. Just move "entities" folder to main ttt-gamemode-folder. Nothing will be override.

2. Goto gamemode/lang/english.lua
Go just down to latest line and insert the below code to then end.!!!JUST BETWEEN!!! [CODE] [/CODE]-- .
[CODE]
-- Custom Item Description
-- Freeze Grenade
L.freezegrenade_name   = "Freeze Grenade"

L.freezegrenade_desc   = [[
A grenade, which freezes all for 5 seconds, 
if it explodes. Evil :)

]]
[/CODE]

BTW: If you have more languagefiles you should add to other language files too :).

-INFORMATION
If you want to change important things see below.

FILES: 
weapons\weapon_ttt_freegrenade\shared.sh
entities\ttt_freezegrenade_proj\shared.sh

Check please there. In the file are short description which is changeable.