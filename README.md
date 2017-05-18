# Arduino Qbs

Base QBS project to program Arduino with Qt Creator.

**Still in beta!**


## Introduction

The code editor of the Arduino IDE is very basic and lacks a lot of features, which is annoying for advanced developers.

Qt Creator is a very good C++ IDE, targeted for Qt obviously but it can handle any other toolchain very easily, and using QBS we can have a nicely integrated Arduino solution (not perfect but functional).

Things you loose at the moment are the easy board selector, the integrated library manager and the integrated serial console. Theses could be solved using plugins, which are on the todo list.


#### Working yet:
- Teensy compilation and uploading using genuine Teensy Loader (all Teensy 3.x boards)
- AVR compilation **but not uploading** (not yet implemented)


### Multiplatform

As of now, paths are hard-coded for macOS, it is on the todo list to support Windows and Linux.


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

>C: < Path to Arduino App >/Java/hardware/tools/arm/bin/arm-none-eabi-gcc

>C++: < Path to Arduino App >/Java/hardware/tools/arm/bin/arm-none-eabi-g++
	
- For AVR:

>C: < Path to Arduino App >/Java/hardware/tools/avr/bin/avr-gcc

>C++: < Path to Arduino App >/Java/hardware/tools/avr/bin/avr-g++

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
- the architecture used (```arduinoArch```): ```teensy3``` or ```avr```
- the frequency used: ```frequency```


#### 3. Select the appropriate Kit

In the Projects Tab (on the left), Build & Run, add the toolchain for your project (Teensy or AVR) and remove the Qt Kit if needed (it's usually the default kit).


#### 4. Edit Run configuration

##### For Teensy:
As specified in the QBS project file:
> Executable:              %{CurrentProject:Path}/qbs/tools/teensy_load

> Command line arguments:  %{CurrentProject:FileBaseName} %{CurrentProject:Path}

> Working directory:       %{CurrentProject:Path}/build

With that you will be able to hit "Run" to upload your code to your Teensy.

##### For AVR:
> TODO


#### 5. Build and upload!
Happy coding :)



-
##### TODO list:
- Add support for Windows and Linux,
- Add the option to set the serial port for programming,
- Add all AVR boards,
- Qt Creator plugin for project wizard,
- Qt Creator plugin for missing features (board selector, serial console)

