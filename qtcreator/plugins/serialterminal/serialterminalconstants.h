#pragma once

namespace SerialTerminal {
namespace Constants {

const char OUTPUT_PANE_TITLE[] = QT_TRANSLATE_NOOP("SerialTerminal::Internal::SerialTerminalOutputPane", "Serial Terminal");

const char ACTION_ID[] = "SerialTerminal.Action";
const char MENU_ID[] = "SerialTerminal.Menu";

const int RECONNECT_DELAY = 1500; // milliseconds
const int RESET_DELAY = 100; // milliseconds

} // namespace SerialTerminal
} // namespace Constants
