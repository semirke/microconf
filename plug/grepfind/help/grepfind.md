# grepfind - Finds files and Greps them for string

## Install

Plugin needs fzf available. On systems supporting apt:
	$ apt install fzf

The plugin. If you have never ran micro before, start 'micro' and quit it with Ctrl-Q to create configuration files.

	$ mkdir $HOME/.config/micro/plug/
	$ cd $HOME/.config/micro/plug/
	$ git clone https://github.com/semirke/micro-grepfind
	$ cd

## Usage

By default grepfind only searches in files with the same extension.
On the micro command prompt enter grepfind and add a value to search for.

### Case sensitive search

Done by calling grepfindcs.

### Search in all files

Done by calling grepfindall.
