#pragma once

#include "serialterminal_global.h"
#include "serialoutputpane.h"
#include "settings.h"

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
    void settingsChanged(const Settings &settings);

    void triggerAction();

    Settings m_settings;
    SerialOutputPane* m_serialOutputPane;
};

} // namespace Internal
} // namespace SerialTerminal
