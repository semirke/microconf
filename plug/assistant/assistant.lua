local config = import("micro/config")
local util = import("micro/util")
local shell = import("micro/shell")
local micro = import("micro")
local buffer = import("micro/buffer")
local filepath = import("path/filepath")

function askreview(bp)
	local cmd = "python3"

	local pwd = config.ConfigDir .. "/plug/assistant/"

	local fname = bp.buf.AbsPath
	local ext = fname:match("\.([^\.]+)$")
	local newFname = fname:match("(.*)\.[^\.]*")

	newFname = fname.sub(fname, 1, -1 * (string.len(ext) +1 )) .. "diff." .. ext
	micro.InfoBar():Message(string.format("Your assistant is thinking, please wait. (Might take up to 1-2 minutes.)" ))

	shell.JobSpawn(cmd, {pwd .. "assistant.py", fname}, nil, nil, onExit, bp, newFname)

end

function onExit(output, args)
	local pb, fname = args[1], args[2]

	if output == nil then
		micro.InfoBar():Message(string.format("Running assistant failed (nil) %s ", output ))
		return
	end

	local buf = buffer.NewBuffer(output, fname)

    diffBase = pb.buf:Bytes()
    pb.buf:SetDiffBase(diffBase)

	local newPb = buffer.NewVSplitFromBuffer(buf, pb)

	--local buf2 = buffer.NewBuffer(output, fname)
	--buffer.OpenBufferFromString(output, fname, pb)
	--pb:OpenBuffer(buf2)


	micro.InfoBar():Message(string.format("Done " ))

	return
end


function init()

	config.MakeCommand("askreview", askreview, config.NoComplete)
	--config.TryBindKey("F4", "command:jumptag", true)

	-- add our help topic
    config.AddRuntimeFile("askreview", config.RTHelp, "help/assistant.md")

end

