# Git commands integration

> Runs pre defined git commands on current file

Commands are only available if git is present, is in PATH and can be run by the user.

Prerequisites:
    apt install git

## On save
On save plugin checks for change against the repository's last commited state
and provides a git commit prompt for instant commiting. If left empty, no commit takes place.

## Commands
> gitcommit "commit message"
Will run "git commit -m" compile the parameters into a single message
Runs git commit -m "compiled message" ] [filename]

> gitcommitall "commit message"
Will run "git commit -a -m" compile the parameters into a single message

> gitpush
Runs "git push"

> gitcheckout args[]
Runs "git checkout args[1]"

> gitdiff
Runs "git diff" with current filename.
Does NOT save buffer.

> git args
Runs a "git" command and passes all args as is.
