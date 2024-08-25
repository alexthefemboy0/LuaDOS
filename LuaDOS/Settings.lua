local Settings = {
    ExecPermissionLevel = 2,
    --[[
    Exec Permission Levels:
    2: unrestricted access to exec
    1: only certain commands are allowed to run (see ExecAllowedCommands)
    0: exec is disabled
    ]]--
    ExecAllowedCommands = {
        "ls",
        "echo",
    }, -- Commands exec is allowed to use if permission level is 1.
    systemInfoCommand = "fastfetch", -- Command that 'systeminfo' will use. (e.g. neofetch, fastfetch, hyfetch, etc.)
}

return Settings
