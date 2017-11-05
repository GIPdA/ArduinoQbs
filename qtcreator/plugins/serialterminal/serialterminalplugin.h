#pragma once

#include "serialterminal_global.h"
#include "serialoutputpane.h"

#include <extensionsystem/iplugin.h>

namespace SerialTerminal {
namespace Internal {

class SerialTerminalPlugin : public ExtensionSystem::IPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QtCreatorPlugin" FILE "SerialTerminal.json")

public:
    SerialTerminalPlugin();
    ~SerialTerminalPlugin();

    bool initialize(const QStringList &arguments, QString *errorString);
    void extensionsInitialized();
    ShutdownFlag aboutToShutdown();

private:
    void triggerAction();
};

} // namespace Internal
} // namespace SerialTerminal
