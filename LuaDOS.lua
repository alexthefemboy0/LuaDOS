-- Include libraries

local LFS = require("lfs")

-- LuaDOS code 

local cmdCtl
local del

local NewLine = function()
    print("\n")
end

local Terminate = function()
    os.exit(0)
end

local function ls()
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
    elseif cmd == "echo" then
        local message = arg:match('^"(.-)"$')
        if message then
            print(message)
        else
            print('Usage: print "message"')
        end
    elseif cmd == "exit" then
        print("Exiting LuaDOS...")
        Terminate()
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
    else
        print("\27[31mUnknown command. Type 'help' for commands.\27[0m")
    end
    NewLine()
    cmdCtl()
end

cmdCtl = function()
    local cmdInput = ReadLine()
    execCommandCtl(cmdInput)
end

function Execute()
    print("Welcome to LuaDOS.")
    print("Version 1.2")
    print("By alexthefemboy\n")
    cmdCtl()
end

Execute() -- Run LuaDOS