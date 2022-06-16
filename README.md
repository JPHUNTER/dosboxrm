

# Overview

I started this fork of DOSBox in order to run ReelMagic games. It would appear
that no one else has done this, so I took this on as I really wanted to play the
ReelMagic version of Return to Zork.

## Contributors

The following people have made this project a reality:

* Jon Dennis <jrdennisoss_at_gmail.com>
* Chris Guthrie <csguthrieoss_at_gmail.com>
* Joseph Whittaker <j.whittaker.us_at_ieee.org>

It is also worth mentioning Dominic Szablewski's (https://phoboslab.org) awesome
MPEG decoder library `PL_MPEG` was used for this, and of course this project is
built on top of work the DOSBox Team created.

## Game Compatibility

The following ReelMagic games are known to work on this emulator with minimal issues:

* Return to Zork
* Lord of the Rings
* The Horde
* Entity
* Man Enough
* Dragon's Lair
* Flash Traffic
* Crime Patrol
* Crime Patrol 2 - Drug Wars

Note: Entity crashes when viewing a video message. This happens on both the
      emulator and on the real setup.

## Current Known Issues and Limitations

* The emulator does not correctly implement MPEG DMA streaming.
* MPEG video decode is only about 98% complete. There are a few glitches.
* Need to revisit architecture and approach for mixing VGA and MPEG.
* Need to re-base on to DOSBox SVN trunk.


## Running ReelMagic DOSBox

Runs just like normal DOSBox except that it supports ReelMagic MPEG games.
There are some optional configuration parameters. See `Configuration` section
under the `Changes to DOSBox` section below for more information on this.


## ReelMagic Driver API

All that has been discovered about how the ReelMagic driver works and interacts
with things is currently documented in the `RMDOS_API.md` file.

## ReelMagic Proprietary MPEG Format

Most ReelMagic MPEG file assets have been encoded in a non-standard way which
prevents them from playing in a standard MPEG media player such as VLC. In
order to get things properly working in DOSBox, I had to make a few changes
to the MPEG decoder. More information on this can be found in the
`NOTES_MPEG.md` file.

## Known Game Bugs

Game bugs that are known to exist in both this emulator AND that also happen
wich a real hardware setup are documented in the `KNOWN_GAME_BUGS.md` file.
This helps with not spending too much time chasing phantom issues.


# Changes to DOSBox

Several modifications to DOSBox have been made to make this work.

## Configuration

A `[reelmagic]` configuration section has been added. It is not mandatory to
configure anything to have a working ReelMagic setup as the defaults will
enable ReelMagic emulation.
The parameters are:

* `enabled`         -- Enables/disables the ReelMagic emulator. By default this is `true`
* `alwaysresident`  -- This forces `FMPDRV.EXE` to always be loaded.  By default this is `false`
* `vgadup5hack`     -- Duplicate every 5th VGA line to help give output a 4:3 ratio. By default this is `false`
* `initialmagickey` -- Provides and alternate value for the initial global "magic key" value in hex. Defaults to 40044041.
* `magicfhack`      -- Use for MPEG video debugging purposes only. See `reelmagic_player.cpp` for what exactly this does to the MPEG decoder.
* `a204debug`       -- Controls FMPDRV.EXE function Ah subfunction 204h debug logging. Only applicable in "heavy debugging" build.
* `a206debug`       -- Controls FMPDRV.EXE function Ah subfunction 206h debug logging. Only applicable in "heavy debugging" build.


For example:
```
[reelmagic]
enabled=true
alwaysresident=true
vgadup5hack=false
```

## Modified Files

The following existing DOSBox source code files have been modified for ReelMagic emulation functionality:

* `include/logging.h`                     -- Added `REELMAGIC` logging type + quick fix for variable length logging args
* `src/debug/debug_gui.cpp`               -- Added `REELMAGIC` logging type.
* `src/dosbox.cpp`                        -- ReelMagic init hook-in and config section.
* `src/hardware/Makefile.am`              -- Declared new ReelMagic *.cpp source code files

The following files have been modified to include the ReelMagic override header to redirect all VGA output from DOSBox RENDER to ReelMagic:

* `src/hardware/vga_dac.cpp`              
* `src/hardware/vga_draw.cpp`             
* `src/hardware/vga_other.cpp`            


## New Files

The following new DOSBox source code files have been added for ReelMagic emulation functionality:

* `include/reelmagic.h`                   -- Header file for all ReelMagic stuff
* `include/vga_reelmagic_override.h`      -- Header file used to redirect all VGA output from DOSBox RENDER to ReelMagic
* `src/hardware/reelmagic_driver.cpp`     -- Implements the Driver + Hardware Emulation
* `src/hardware/reelmagic_pl_mpeg.cpp`    -- Modified version of PHOBOSLAB's `PL_MPEG` library found here: `https://github.com/phoboslab/pl_mpeg`
* `src/hardware/reelmagic_player.cpp`     -- Implements MPEG Media Decoder/Player Functionality
* `src/hardware/reelmagic_videomixer.cpp` -- Intercepts the VGA output and mixes in the decoded MPEG video.


# ReelMagic Emulator Architecture

ReelMagic emulation software components are wired up as such:
```
                             |-----------------|                                    |---------------|
                             |     PL_MPEG     |                                    |   Existing    |
                             | Decoder Library |                                    |    DOSBox     |
                             |-----------------|                                    |   "Render"    |
                                      ^                                             |---------------|
                                      |                        |-------------|              ^
                                      | Uses                   |             |              | Mixed VGA + MPEG
                                      |           Outputs      |   DOSBox    |              | Output Goes Here
|---------------|              |-------------|    Audio to     |    Mixer    |      |---------------|
|               |              |             | --------------->|             |      |               |
|   Driver +    |              |    MPEG     |                 |-------------|      |     Video     |
|   Hardware    | <----------> |  Player(s)  |                                      |    Underlay   |
|   Emulation   |   Controls   |             | -----------------------------------> |     Mixer     |
|               |              |-------------|               Outputs                |               |
|---------------|                                            Video to               |---------------|
        ^                                                                                   ^
        | Can                                                                               | Video Output
        | Use                                                                               | Intercepted By
|----------------|                                                                  |---------------|
|    Emulated    |                                                                  |   Existing    |
|  DOS Programs  |                                                                  |    DOSBox     |
|----------------|                                                                  |     VGA       |
                                                                                    |   Emulation   |
                                                                                    |---------------|
```





# Building DOSBox

## On Windows 10

See this guide: https://www.dosbox.com/wiki/Building_DOSBox_with_MinGW


## On Ubuntu 20.04
```
sudo apt install build-essential autoconf automake-1.15 autotools-dev m4
./autogen.sh
./configure
make
```

## On macOS Monterey 12.4
*Prerequisite - Install homebrew (GOOGLE IT)
```
brew install autoconf automake libtool sdl
cd dosbox-0.74-3
bash autogen.sh
bash configure
make
```

## Enabling DOSBox Debugger
```
./configure --enable-debug
-- OR --
./configure --enable-debug=heavy
```


# Online Resources

Here are some useful online resources:

## Information about ReelMagic

Here is a handful of links that helped me get started on the ReelMagic side of things:

* https://www.vogons.org/viewtopic.php?t=7364
* https://www.vogons.org/viewtopic.php?t=37363
* http://bitsavers.informatik.uni-stuttgart.de/pdf/c-cube/90-1450-101_CL450_MPEG_Video_Decoder_Users_Manual_1994.pdf
* http://www.oldlinux.org/Linux.old/docs/interrupts/int-html/rb-5094.htm
* http://www.oldlinux.org/Linux.old/docs/interrupts/int-html/rb-4251.htm


## PL ("Phobos Lab") MPEG Library

This is the awesome MPEG decoder library used for this project. This guy gets it.

* https://phoboslab.org/log/2019/06/pl-mpeg-single-file-library
* https://github.com/phoboslab/pl_mpeg

# DOSBox - Pixel-perfect mod + vsync + savestates

<p align="center"><img src="https://cloud.githubusercontent.com/assets/4263742/23454383/521f32ae-fe6c-11e6-8be2-8f6471b24ed3.png" alt="DOSBox original vs pixel-perfect mod"/></p>

This is a modified version of DOSBox with focus on **super crisp visual output**. It uses integer scaling to produce homogenous pixels, supports VSYNC, plays nice with high-DPI displays and adds other enhancements like **savestates**.

## 💾 [Download](https://github.com/bladeSk/DOSBox-pixel-perfect/releases/download/r4019.3/dosbox-pixel-perfect-SVNr4019.3-win.zip)

Get the [latest Windows version](https://github.com/bladeSk/DOSBox-pixel-perfect/releases/download/r4019.3/dosbox-pixel-perfect-SVNr4019.3-win.zip) or check the _releases_ tab.

In case DOSBox doesn't run (`VCRUNTUME140.dll missing` error), you need to install the [Microsoft Visual C++ 2017 Runtime Library](https://go.microsoft.com/fwlink/?LinkId=746571).

## Features

### Pixel perfect mode (aka. integer scaling)

This mode makes the rendered image fill as much of your screen as possible while keeping it scaled to the nearest integer. GPU scaling is used instead of relying on software scalers.

The original DOSBox also renders a stretched image to a power-of-two texture, which is then stretched to the screen. This mod creates a texture with exact dimensions. This improves the image quality at the cost of breaking compatibility with very old video cards.

When `aspect=false`, square pixels are produced (1x1, 2x2, 3x3, etc.), which is what works best for most (but not all) games.

When `aspect=true`, the aspect ratio is approximated using rectangular pixels. For instance 320x200 on a 1920x1080 resolution will use 4x5 pixels. This yields a 4:3.125 aspect ratio instead of the intended 4:3, but the difference is only 4%.

### Borderless fullscreen window / VSYNC

A feature used by modern games that relies on the OS to provide VSYNC. This eliminates screen tearing.

### High-DPI support

This DOSBox fork is DPI-aware. When using 150% scaling, the image is no longer blurred.

### Savestates

Savestates allow you to save (`Alt+F5`) and load (`Alt+F9`) any game whenever you like. Note that this is an experimental feature and some games may crash. The credit for implementing this feature goes to ZenJu, tikalat, ykhwong, gandhig and bruenor41. I used the code found [here](https://www.vogons.org/viewtopic.php?f=32&t=53116) and tweaked it to compile with Visual Studio.

### Ready to use

A configuration file with sane defaults is provided. No need to fiddle around with settings, just run it and have fun. The folder `games` is automatically mounted.

The only thing you may want to adjust per-game is the speed of the emulator (`Ctrl+F11`/`Ctrl+F12`). Some games require very low speed (ie. Lemmings needs \~6000 cycles), some may require more speed.

## DOSBox config

You can just use the provided config, but if you have your own special `dosbox.conf`, make sure your values match the ones below to use the new features. Savestates work automatically, but you need to rebuild your mapper file, if you use one.

	[sdl]
	fullscreen=true
	fulldouble=true
	fullresolution=desktop
	output=openglnb # ⚠ important: pixel-perfect scaling only works with OpenGL!
	pixelperfect=true # set to false to make the image fill as much of the screen as possible
	borderless=true # prevents screen tearing; set to false to disable borderless fullscreen

	[render]
	aspect=false # change to true if circles in your game look like ellipses
	scaler=none


## Building

All the dependencies are included in the source code (under `lib`). You need to build them before you can build DOSBox. I used Visual Studio 2017, but older versions should be fine also. Build the projects in the following order:

* `lib\libpng-1.6.29\projects\vstudio\vstudio.sln` - use the "Release Library" configuration
* `lib\SDL-1.2.15\VisualC\SDL.sln`
* `lib\SDL_net-1.2.7\VisualC\SDL_net.sln` - requires MFC to be installed
* `visualc_net\dosbox.sln` - requires SDL.dll built in the previous step to be copied next to the .exe file
