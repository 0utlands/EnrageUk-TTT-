@echo off
cls
echo Protecting srcds from crashes...
echo If you want to close srcds and this script, close the srcds window and type Y depending on your language followed by Enter.
title srcds.com Watchdog
:srcds
echo (%time%) srcds started.
start /wait srcds.exe -console -game garrysmod +map gm_construct +maxplayers 16 +gamemode terrortown -host_workshop_collection 266060348 -authkey 9CD6F22E51079D5B0686B717B518CA2E +sv_loadingurl "http://r3achrp.webfrag.net/Crystal/Crystal%20Load/?steamid=%s"
