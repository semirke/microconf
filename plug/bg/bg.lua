VERSION = "1.0.0"

local config = import("micro/config")
local shell = import("micro/shell")
local micro = import("micro")

function init()
    config.MakeCommand("bg", bg, config.NoComplete)
    config.AddRuntimeFile("bg", config.RTHelp, "help/bg.md")
end


function bg(bp)
    micro.TermMessage("Press CTRL+D to return to Micro")
    shell.RunInteractiveShell("bash", true, false)
end
