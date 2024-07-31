-- Include libraries

local LFS = require("lfs")

-- LuaDOS code

local plugins = {}
local cmdCtl
local del
local os_type, username, hostname, cwd

if package.config:sub(1,1) == "\\" then

    os_type = "Windows"
    username = os.getenv("USERNAME")
    hostname = os.getenv("COMPUTERNAME")
else
 
    os_type = "Unix-like"
    local handle

    handle = io.popen("whoami")
    if handle then
        username = handle:read("*l")
        handle:close()
    else
        username = "unknown"
    end

    handle = io.popen("hostname")
    if handle then
        hostname = handle:read("*l")
        handle:close()
    end

    if not hostname or hostname == "" then
        handle = io.open("/etc/hostname", "r")
        if handle then
            hostname = handle:read("*l")
            handle:close()
        end
    end

    if not hostname or hostname == "" then
        handle = io.popen("uname -n")
        if handle then
            hostname = handle:read("*l")
            handle:close()
        end
    end

    if not hostname or hostname == "" then
        hostname = "unknown"
    end
end


local getCWD = function()
    local dir = LFS.currentdir()
    if os_type == "Windows" then
        return dir:gsub("/", "\\")
    else
        return dir:gsub("^/home/"..username, "~")
    end
end

local function displayPrompt()
    cwd = getCWD()
    if os_type == "Windows" then
        io.write(string.format("[LuaDOS %s]> ", cwd))
    else
        io.write(string.format("[LuaDOS %s@%s %s]$ ", username, hostname, cwd))
    end
end

local NewLine = function()
    print("\n")
end

local ls = function()
    for file in LFS.dir(".") do
        if file ~= "." and file ~= ".." then
            local attr, err = LFS.attributes(file)
            if attr then
                if attr.mode == "directory" then
                    print(file .. "/")
                else
                    print(file)
                end
            else
                print("There was an error accessing the file '" .. file .. "'. LFS said this: " .. err)
            end
        end
    end
end

local mkdir = function(dirname)
    if dirname and dirname ~= "" then
        local success, err = LFS.mkdir(dirname)
        if success then
            print("A directory with the name " ..dirname.. " was created.")
        else
            print("Error creating directory " ..dirname.. ". (Do you have sudo/run as administrator permissions?)")
        end
    else
        print("Usage: mkdir <directory>")
    end
end

local cd = function(dirname)
    if dirname and dirname ~= "" then
        local success, err = LFS.chdir(dirname)
        if success then
            print("Navigated to "..dirname)
        else
            print("Error navigating to directory: " .. err)
        end
    else
        print("Usage: cd <directory>")
    end
end

del = function(path)
    if not path or path == "" then
        print("Usage: del <file/directory>")
        return
    end

    local attr, err = LFS.attributes(path)
    if not attr then
        print("Error accessing '" .. path .. "'. LFS said this: " .. err)
        return
    end

    if attr.mode == "directory" then
        for file in LFS.dir(path) do
            if file ~= "." and file ~= ".." then
                local sub_path = path .. "/" .. file
                del(sub_path)
            end
        end
        local success, err = LFS.rmdir(path)
        if success then
            print("Directory '" .. path .. "' was successfully deleted.")
        else
            print("Error deleting directory '" .. path .. "': " .. err .. " (do you have sudo/run as administrator permissions?)")
        end
    else
        local success, err = os.remove(path)
        if success then
            print("File '" .. path .. "' deleted.")
        else
            print("Error deleting file '" .. path .. "': " .. err .. " (do you have sudo/run as administrator permissions?)")
        end
    end
end

local ReadLine = function()
    return io.read("*l")
end

local exec = function(command)
    if command and command ~= "" then
        local success, _, exitCode = os.execute(command)

        if (success == true or success == 0) and (exitCode == nil or exitCode == 0) then
            -- Command executed successfully
        else
            print("\27[31mCommand did not complete successfully. (do you have sudo/run as administrator permissions?)\27[0m")
        end
    else
        print("Usage: exec <command>")
    end
end

local about = function()
    print("LuaDOS is a DOS-like environment made with Lua.\nMade by alexthefemboy.")
end

local runc = function(cfile)
    if not cfile:match("%.c$") then
        print("Please provide a valid C file ending in .c")
        return
    end

    local gccCheck = io.popen("gcc --version")
    local output = gccCheck:read("*a")
    gccCheck:close()

    if not output or output == "" then
        print("\27[31mThe GNU C Compiler (gcc) is either not installed on your system or not in your environment PATH variable.\27[0m")
        return
    end

    local outputBinary = cfile:gsub("%.c$", "")
    local binaryExtension = (package.config:sub(1,1) == "\\") and ".exe" or ""
    outputBinary = outputBinary .. binaryExtension

    local compileCmd = string.format("gcc \"%s\" -o \"%s\" 2>&1", cfile, outputBinary)

    local compiler = io.popen(compileCmd)
    local compilerOutput = compiler:read("*a")
    local compileSuccess, compileStatus, compileExitCode = compiler:close()

    if not compileSuccess then
        print("\27[31mYour C file failed to compile to a binary (is there an error in your code?)\27[0m")
        return
    end

    local runCmd
    if package.config:sub(1, 1) == "\\" then
        runCmd = outputBinary
    else
        runCmd = "./" .. outputBinary
    end

    local runBin = os.execute(runCmd)

    local deleteCmd
    if package.config:sub(1,1) == "\\" then
        deleteCmd = string.format("del /Q \"%s\"", outputBinary)
    else
        deleteCmd = string.format("rm \"%s\"", outputBinary)
    end

    os.execute(deleteCmd)
end

local runlua = function(command)
    local func, error = load(command)
    if not func then
        print("\27[31mFailed to execute: " .. error .."\27[0m")
    else
        local success, result = pcall(func)
        if not success then
            print("\27[31mFailed to execute: " .. result .."\27[0m")
        elseif result then
            print(result)
        end
    end
end

local execCommandCtl = function(cmdInput)
    local cmd, arg = cmdInput:match("^(%S+)%s*(.*)$")
    if cmd == "help" then
        print("Current commands:")
        print("help -- Gives all current commands.")
        print('echo "<message>" -- Prints a message to the screen.')
        print("exit -- Exits LuaDOS back to your terminal.")
        print("dir -- Lists all the files in the current directory.")
        print("mkdir <directory> -- Makes a directory in the current directory.")
        print("cd <directory> -- Navigates to a directory.")
        print("cls -- Clears the screen.")
        print("del <file/directory> -- deletes a file/directory.")
        print("exec <command> -- Executes a terminal command from LuaDOS.")
        print("about -- Gives information about LuaDOS.")
        print("runc <C file> -- Directly runs a C file from LuaDOS.")
        print("runlua -- Runs a Lua command.")
        print("reloadplugins -- Reloads all plugins.")
        -- Display plugins as well
        for name, plugin in pairs(plugins) do
            print(name .. " -- " .. (plugin.Description or "No description provided."))
        end
    elseif cmd == "echo" then
        local message = arg:match('^"(.-)"$')
        if message then
            print(message)
        else
            print('Usage: print "message"')
        end
    elseif cmd == "exit" then
        print("Exiting LuaDOS...")
        Core.Exit();
    elseif cmd == "dir" then
        ls()
    elseif cmd == "mkdir" then
        mkdir(arg)
    elseif cmd == "cd" then
        cd(arg)
    elseif cmd == "del" then
        del(arg)
    elseif cmd == "cls" then
        io.write("\27[2J\27[H")
    elseif cmd == "exec" then
        exec(arg)
    elseif cmd == "about" then
        about()
    elseif cmd == "runc" then
        runc(arg)
    elseif cmd == "runlua" then
        runlua(arg)
    elseif cmd == "reloadplugins" then
        Core.LoadPlugins()
    else
        local plugin = plugins[cmd]
        if plugin and plugin.Function then
            plugin.Function()
        else
            print("\27[31mUnknown command. Type 'help' for commands.\27[0m")
        end
    end
    NewLine()
    cmdCtl()
end

cmdCtl = function()
    displayPrompt()
    local cmdInput = ReadLine()
    execCommandCtl(cmdInput)
end

Core = {
    Execute = function()
        print("Welcome to LuaDOS.")
        print("Version 1.7")
        print("By alexthefemboy\n")
        Core.LoadPlugins()
        cmdCtl()
    end,
    Exit = function()
        os.exit(0)
    end,
    LoadPlugins = function()
        local pluginPath = "Plugins/"

        if package.config:sub(1, 1) == "\\" then
            pluginPath = pluginPath:gsub("/", "\\")
        end

        if LFS.attributes(pluginPath, "mode") ~= "directory" then
            print("\x1b[33mWarning: Could not find plugins directory. No plugins will be loaded.\x1b[0m")
            return
        end

        for file in LFS.dir(pluginPath) do
            if file:match("%.lua$") then
                local pluginName = file:match("(.+)%.lua$")
                local plugin = require(pluginPath .. pluginName)

                if plugin and plugin.Name and plugin.Function then
                    plugins[plugin.Name] = plugin
                else
                    print("\x1b[33mWarning: Plugin ".. file .. " is missing required fields and was not loaded.\x1b[0m")
                end
            end
        end
    end,
}

Core.Execute()

return Core