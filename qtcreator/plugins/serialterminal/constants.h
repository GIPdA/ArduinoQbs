#pragma once

namespace SerialTerminal {
namespace Constants {

const char OUTPUT_PANE_TITLE[] = QT_TRANSLATE_NOOP("SerialTerminal::Internal::SerialTerminalOutputPane", "Serial Terminal");

// Settings entries
const char SETTINGS_GROUP[] = "SerialTerminalPlugin";
const char SETTINGS_BAUDRATE[] = "BaudRate";
const char SETTINGS_DATABITS[] = "DataBits";
const char SETTINGS_PARITY[] = "Parity";
const char SETTINGS_STOPBITS[] = "StopBits";
const char SETTINGS_FLOWCONTROL[] = "FlowControl";
const char SETTINGS_PORTNAME[] = "PortName";
const char SETTINGS_INITIAL_DTR_STATE[] = "DTR";
const char SETTINGS_INITIAL_RTS_STATE[] = "RTS";
const char SETTINGS_ENTER_KEY_EMULATION[] = "EnterKeyEmulation";
const char SETTINGS_CLEAR_INPUT_ON_SEND[] = "ClearInputOnSend";


const char ACTION_ID[] = "SerialTerminal.Action";
const char MENU_ID[] = "SerialTerminal.Menu";

const int RECONNECT_DELAY = 1500; // milliseconds
const int RESET_DELAY = 100; // milliseconds

// Context
const char C_SERIAL_OUTPUT[]         = "SerialTerminal.SerialOutput";

} // namespace SerialTerminal
} // namespace Constants
