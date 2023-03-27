# gmdebug
Gmod debugger using the debug adapter protocol in haxe (javascript + lua)

Can be run as a vscode extension or as a standalone server.

Aims to make debugging your gmod addon easier

## Features

- Windows and linux support
- Conditional breakpoints targeting functions and lines
- Stepping
- Evaluation
- Support for debugging gmod clients and servers simultaneously as seperate threads (must be on same computer)
- Catches most exceptions
- Runs as 100% lua on your server
- Copies your addon files on run, no need to be developing in your addons folder all the time

## Future plans

If I can get this project in a stable state, here are the current features that are being considered for future updates 

- Gma support (currently untested)
- Auto download of specified addons
- Data breakpoints (need to investigate further)
- Autocompletion in debug console
- TCP Socket support (again)
- Stepping granuility
- Goto support (?)
- Releasing on the vscode extension marketplace

## Known issues

- Your game/server may freeze when the debugger does not shutdown cleanly, or in other scenarios (due to blocking named pipes)
- Breakpoints in top level init files will not fire
- Currently, catching gui exceptions is extremely performance taxing

## Usage

Do not run this on a public facing server, or with addons and lua code you do not trust. This debugger is intended for use to inspect your own code, and protecting against malicous actors is not a high priority for this project

### Install from vsix

Check releases, download and add to your vscode installation. From there, open any folder and goto the debug tab. From there, add a gmdebug launch sample configuration, and ensure you fill in the following properties

`serverFolder`

The path to your gmod dedicated server `garrysmod` folder. This folder should contain an `addons` folder for the debugger to add it's addon

`programPath`

If set to auto, will use the server path of `../srcds_linux` relative to `serverFolder`. If this is not how you launch your server, please set this manually.

`programArgs`

An array of arguments to added to your launch command. Each element is seperated with a space

`clientFolders`

An array of client gmod installation paths (pointing to the `garrysmod` folder). If you wish to debug clientside lua, this should contain one path pointing to your steam gmod installation.

### Building for vscode

Run the following commands in the root folder

`npm install`

`haxe buildall.hxml`

You may have to install some haxe libraries to complete the build. Check the output for information about missing haxe libraries. 
