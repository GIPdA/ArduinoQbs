# Arduino Qbs

Base QBS project to program Arduino with Qt Creator.

**Still in beta!**


## Introduction

The code editor of the Arduino IDE is very basic and lacks a lot of features, which is annoying for advanced developers.

Qt Creator is a very good C++ IDE, targeted for Qt obviously but it can handle any other toolchain very easily, and using QBS we can have a nicely integrated Arduino solution (not perfect but functional).

Things you loose at the moment are the easy board selector, the integrated library manager and the integrated serial console. Theses could be solved using plugins, which are on the todo list.


#### Working:
- Teensy compilation and uploading using genuine Teensy Loader (all Teensy 3.x boards)
- AVR compilation and uploading (only pro mini supported yet, other boards will come)


### Multiplatform

Compilation and upload should work on all Arduino-supported platforms, but only macOS has been tested yet (defaults paths to Arduino resources on other platforms than macOS are still to be validated).

**Upload may not work under Windows due to the current use of scripts, this is on the todo list.**


## Requirements

Qt Creator Bare Metal Device plugin (activate it with the plugins manager)


## Usage

Some steps are required in order to compile and upload successfully.

### Qt Creator Setup
To do only once:

#### 1. Add compilers
Got to Qt Creator Preferences > Compile & Execute > Compilers tab.

Then add custom GCC compilers (C then C++) from the Arduino package/install folder:

- For the Teensy 3:

```
C: <Path to Arduino App>/Java/hardware/tools/arm/bin/arm-none-eabi-gcc
C++: <Path to Arduino App>/Java/hardware/tools/arm/bin/arm-none-eabi-g++
```

- For AVR:

```
C: <Path to Arduino App>/Java/hardware/tools/avr/bin/avr-gcc
C++: <Path to Arduino App>/Java/hardware/tools/avr/bin/avr-g++
```

#### 2. Add new Kits:
- Name: AVR or Teensy,
- Peripheral: Bare Metal Device,
- Compiler: AVR or Teensy you set before,
- Debugger: None
- Qt Version: None



### Project Setup
For each project you add:

#### 1. Copy repo content

Download the repo, it is the base project. Rename the folder to your convenience, as well as the ```ArduinoQbs.qbs``` and ```Arduino.cpp``` files.

#### 2. Open in Qt Creator

Open what was ```ArduinoQbs.qbs``` in Qt Creator to add the project to your current session. In that file you need to change :

- the list of source files: ```files```
- the board name: ```board```
- the frequency used (if needed, mainly for Teensy): ```frequency```


#### 3. Select the appropriate Kit

In the Projects Tab (on the left), Build & Run, add the toolchain for your project (Teensy or AVR) and remove the Qt Kit if needed (it's usually the default kit).


#### 4. Edit Build & Run configurations

Edit the install directory as specified in ```ArduinoQbs.qbs``` file under the "Build Configuration Guide" comment.

Add a custom executable configuration and set the fields as specified in ```ArduinoQbs.qbs``` file under the "Run Configuration" comment.

With that you will be able to hit "Run" to upload your code, using avrdude for AVR boards and Teensy Loader for Teensy boards.


#### 5. Build and upload!
Happy coding :)



--
##### TODO list:
- Test under Windows and Linux,
- Add all AVR boards,
- Qt Creator plugin for project wizard,
- Qt Creator plugin for missing features (board selector, serial console)

