VERSION = "1.0.0"

--  Basically the linter can be copied fully...

local config = import("micro/config")
local shell = import("micro/shell")
local micro = import("micro")
function init()
    config.MakeCommand("formatter", formatter, config.NoComplete)
    config.AddRuntimeFile("formatter", config.RTHelp, "help/formatter.md")
end


function formatter(bp)
    bp:Save()
    out, err = shell.ExecCommand("black",  bp.Buf.Path)
    bp.Buf:ReOpen()
    micro.InfoBar():Message(string.format("Formatting done %s", out))
end
