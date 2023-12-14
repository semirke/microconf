-- https://github.com/terokarvinen/micro-jump
-- MIT license

local config = import("micro/config")
local shell = import("micro/shell")
local micro = import("micro")
local buffer = import("micro/buffer")
local util = import("micro/util")

-- default to pass insentitive to find
local insensitive = "i"
-- default to only crawl files with the same extension
local noext = false

function grepfindCommandCs(bp, args)
	insensitive = ""
	return grepfindCommand(bp, args)
end

function grepfindCommandAll(bp, args)
	noext = true
	return grepfindCommand(bp, args)
end

function grepfindCommand(bp, args) -- bp BufPane
	local filename = bp.Buf.Path
	local ext = filename:match(".([^.]+)$")
	local toSearch = ""

	if ext ~= "" and ext ~= nil then
		ext = "." ..ext
	else
		ext = ""
	end

	if noext==true then
		ext = ""
	end

	if true then
		micro.InfoBar():Message("filename: |" .. filename .. "|" .. ext .."|")
	end

   	if args ~= nil and #args > 0 then
       	toSearch = args[1]
       else
       	local c = bp.Buf:GetActiveCursor()
       	toSearch = bp.Buf:WordAt(-c.Loc)
       	toSearch = util.String(toSearch)
   	end

   	if toSearch == "" or toSearch == nil then
		micro.InfoBar():Message("No search string provided nor is a word at the cursor")
		return
   	end

	local cmd = string.format("bash -c \"find . -type f -name \\\"*%s\\\" -not -path \"*\.git/*\" -print0| xargs -0 grep -%sl \\\"%s\\\" 2>/dev/null | fzf --layout=reverse  --preview='grep --color=always  -%sn2 \\\"%s\\\" {} ' | cut -d':' -f1\"", ext, insensitive, toSearch, insensitive, toSearch)
	local fname = shell.RunInteractiveShell(cmd, false, true)

	if fname == nil or fname=="" then
		micro.InfoBar():Message("Selection was aborted")
		return
	end
	local exists = false
	local f=io.popen(fname,"r")
  		if f ~= nil then
  			exists = true
  		else
  			exists = false
  		end

	if exists == false then
		micro.InfoBar():Message(string.format("File couldn't be opened (%s)", fname))
		return
	end
	micro.InfoBar():Message(string.format("Opening file (%s)", fname))
	io.close(f)

	if fname.find(fname, "./") ~= nil then
		fname = fname.sub(fname, 3, -2)
	end

	local b = buffer.OpenFileToNewTab(fname)
	b.LastSearch = toSearch
	b.HighlightSearch = true

	insensitive = "i"
	noext=false

end


function init()
	config.MakeCommand("grepfind",    grepfindCommand,    config.NoComplete)
	config.MakeCommand("grepfindcs",  grepfindCommandCs,  config.NoComplete)
	config.MakeCommand("grepfindall", grepfindCommandAll, config.NoComplete)
	--config.TryBindKey("F4", "command:jumptag", true)
end

