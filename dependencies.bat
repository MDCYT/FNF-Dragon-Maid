@echo off
haxelib remove flixel
haxelib remove flixel-addons
haxelib remove flixel-ui
haxelib remove hscript
haxelib remove newgrounds
haxelib remove polymod
haxelib remove discord_rpc
haxelib remove hxvm-luajit
haxelib remove linc_luajit

haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib install newgrounds
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit
