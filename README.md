# LuaDOS<br><br>

Thank you for using LuaDOS!<br>
LuaDOS is a DOS-like shell written in Lua for versatile OS management.<br><br>

# How to get started<br><br>
First, install Lua.<br><br>

On Arch-based Linux systems:<br>
`sudo pacman -S lua`<br><br>

On Debian-based Linux systems:<br>
`sudo apt install lua<version>`<br>
For example, `sudo apt install lua5.4`<br><br>

On other Linux systems:<br>
Please find your package manager's equivalent and download Lua from there.<br>
Alternatively, you may download and build Lua from source.<br><br>

On Windows systems:<br>
Use LuaBinaries and LuaDist to install Lua.<br><br>

Once Lua is installed, please install LuaRocks.<br>
To install LuaRocks:<br><br>

On Arch-based Linux systems:<br>
`sudo pacman -S luarocks`<br><br>

On Debian-based Linux systems:<br>
`sudo apt install luarocks`<br><br>

On Windows systems:<br>
Download the LuaRocks executable from GitHub.<br>
Note: if you want LuaRocks to be accessible from everywhere, you'll want to put it in your environment PATH variable.<br><br>

Once you have LuaRocks installed, please run this command:<br><br>

Linux systems:<br>
`sudo luarocks install luafilesystem`<br><br>

Windows systems:<br>
Open a new command prompt session as administrator, navigate to where the luarocks.exe file is located using cd and then run:<br>
`luarocks.exe install luafilesystem`<br><br>


# Running LuaDOS<br><br>
To run LuaDOS:<br><br>

On Linux systems:<br>
`sudo (if you want to have elevated priveleges) lua LuaDOS.lua`<br><br>

On Windows systems:<br>
Open a new command prompt session as administrator (if you want to have elevated privileges)<br>
Navigate to where LuaDOS.lua is located<br>
`lua LuaDOS.lua`<br><br>

# Commands<br><br>
To find all available commands, please run LuaDOS and then type 'help'.