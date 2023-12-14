VERSION = "1.0.0"

local config = import("micro/config")
local shell = import("micro/shell")
local buffer = import("micro/buffer")
local micro = import("micro")

function init()
    local fp = io.popen("git")

    if (fp ~= nil) then
        io.close(fp)
        config.MakeCommand("git",          git,          config.FileComplete)
        config.MakeCommand("gitcommit",    gitcommit,    config.NoComplete)
        config.MakeCommand("gitcommitall", gitcommitall, config.NoComplete)
        config.MakeCommand("gitpush",      gitpush,      config.NoComplete)
        config.MakeCommand("gitdiff",      gitdiff,      config.NoComplete)
        config.MakeCommand("gitadd",       gitadd,       config.NoComplete)
        config.MakeCommand("gitstatus",    gitstatus,    config.NoComplete)
    end
    config.AddRuntimeFile("git", config.RTHelp, "help/git.md")
end

function onPromptDone(resp, cancelled)
    if cancelled == false then
        gitcommit(nil, {resp})
    else
        micro.InfoBar():Message("git: not commiting")
    end

end

function onSave(bp)
    local fp = io.popen("git diff --exit-code " .. bp.Buf.Path)
    if fp ~= nil then
        fp:read("*all")
        local rc, s = io.close(fp)
        if rc == 1 then
            micro.InfoBar():Prompt("> gitcommit ", "", "Command", nil,
                function (resp, cancelled)
                    if cancelled == false then
                        gitcommit(bp, {resp})
                    else
                        micro.InfoBar():Message("git: not commiting")
                    end
                end
            )
        end
    end
end

function git(bp, args)
    local a = {"git"}
    for i=1, #args do
        table.insert(a, args[i])
    end

    local out, error = shell.RunInteractiveShell(table.concat(a, " "), false, false)
    if error == nil then
        micro.InfoBar():Message("success: " .. table.concat(a, " "))
    else
        micro.InfoBar():Message("git failed: " .. tostring(error))
    end
end

function gitcommit(bp, args)
    local a = {""}
    for i=1, #args do
        table.insert(a, args[i])
    end

    local msg = table.concat(a, " ")
    if #args == 0 or msg == "" or msg == " " then
        micro.InfoBar():Message("not commiting empty message")
        return
    end

    local out, error = shell.ExecCommand("git", "commit", "-m", msg, bp.Buf.Path)
    if error == nil then
        micro.InfoBar():Message(string.format("success: Git commit done."))
    else
        micro.InfoBar():Message("git failed: " .. tostring(error) .. " " .. tostring(string.len(msg)).. " |".. msg .."|")
    end
end


function gitcommitall(bp, args)
    local a = {""}
    for i=1, #args do
        table.insert(a, args[i])
    end

    local msg = table.concat(a, " ")
    if #args == 0 or msg == "" then
        micro.InfoBar():Message("not commiting empty message")
    end

    local out, error = shell.ExecCommand("git", "commit", "-a", "-m", msg, bp.Buf.Path)
    if error == nil then
        micro.InfoBar():Message(string.format("success: Git commit done."))
    else
        micro.InfoBar():Message("git failed: " .. tostring(error))
    end
end

function gitpush(bp)
    local out, error = shell.ExecCommand("git", "push")
    if error == nil then
        micro.InfoBar():Message(string.format("success: git push successful"))
    else
        micro.InfoBar():Message("git failed: " .. tostring(error))
    end
end

function gitadd(bp)
    local out, error = shell.ExecCommand("git", "add", bp.Buf.Path)
    if error == nil then
        micro.InfoBar():Message(string.format("success: git add successful"))
    else
        micro.InfoBar():Message("git failed: " .. tostring(error))
    end
end

function gitdiff(bp)
    local out, error = shell.RunCommand("bash -c \"git diff " .. bp.Buf.Path .. "\"") -- .. " | cat -A \"")
    if error ~= nil then
        micro.TermMessage(error)
    else
        if out ~= "" then
            local buf = buffer.NewBufferWithType(out, bp.Buf.Path .. ".diff", buffer.BTDiff)
            buffer.NewVSplitFromBuffer(buf, bp)
        else
            micro.InfoBar():Message(string.format("success: git diff found no difference"))
        end
    end
end

function gitstatus(bp)
    local out, error = shell.ExecCommand("git", "status")
    if error ~= nil then
        micro.TermMessage(error)
    else
        local buf = buffer.NewBuffer(out, "git.status.out")
        local newPb = buffer.NewVSplitFromBuffer(buf, bp)
    end
end

