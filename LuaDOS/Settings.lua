local Settings = {
    ExecPermissionLevel = 2,
    --[[
    Exec Permission Levels:
    2: unrestricted access to exec
    1: only certain commands are allowed to run
    0: exec is disabled
    ]]--
    ExecAllowedCommands = {
        "ls",
        "echo",
    },
}

return Settings
