#include "serialterminalplugin.h"
#include "constants.h"

#include <coreplugin/icore.h>
#include <coreplugin/icontext.h>
#include <coreplugin/actionmanager/actionmanager.h>
#include <coreplugin/actionmanager/command.h>
#include <coreplugin/actionmanager/actioncontainer.h>
#include <coreplugin/coreconstants.h>

#include <QAction>
#include <QMessageBox>
#include <QMainWindow>
#include <QMenu>

#include "serialconfiguration.h"

namespace SerialTerminal {
namespace Internal {

SerialTerminalPlugin::SerialTerminalPlugin()
{
}

SerialTerminalPlugin::~SerialTerminalPlugin()
{
    // Unregister objects from the plugin manager's object pool
    // Delete members
}

bool SerialTerminalPlugin::initialize(const QStringList &arguments, QString *errorString)
{
    // Register objects in the plugin manager's object pool
    // Load settings
    // Add actions to menus
    // Connect to other plugins' signals
    // In the initialize function, a plugin can be sure that the plugins it
    // depends on have initialized their members.

    Q_UNUSED(arguments)
    Q_UNUSED(errorString)

    m_settings.load(Core::ICore::settings());

    /*QAction *action = new QAction(tr("SerialTerminal Action"), this);
    Core::Command *cmd = Core::ActionManager::registerAction(action, Constants::ACTION_ID,
                                                             Core::Context(Core::Constants::C_GLOBAL));
    cmd->setDefaultKeySequence(QKeySequence(tr("Ctrl+Alt+Meta+A")));
    connect(action, &QAction::triggered, this, &SerialTerminalPlugin::triggerAction);

    Core::ActionContainer *menu = Core::ActionManager::createMenu(Constants::MENU_ID);
    menu->menu()->setTitle(tr("SerialTerminal"));
    menu->addAction(cmd);
    Core::ActionManager::actionContainer(Core::Constants::M_TOOLS)->addMenu(menu);//*/


    // Create serial output pane
    m_serialOutputPane = new SerialOutputPane(m_settings);
    addAutoReleasedObject(m_serialOutputPane);

//    auto rc = new SerialControl(m_settings);
//    rc->setPortName("tty.usbmodem-2736");
//    m_serialOutputPane->createNewOutputWindow(rc);

    return true;
}

void SerialTerminalPlugin::extensionsInitialized()
{
    // Retrieve objects from the plugin manager's object pool
    // In the extensionsInitialized function, a plugin can be sure that all
    // plugins that depend on it are completely initialized.
}

ExtensionSystem::IPlugin::ShutdownFlag SerialTerminalPlugin::aboutToShutdown()
{
    m_serialOutputPane->close();

    // Disconnect from signals that are not needed during shutdown
    // Hide UI (if you add UI that is not in the main window directly)
    return SynchronousShutdown;
}


void SerialTerminalPlugin::settingsChanged(const Settings &settings)
{
    settings.save(Core::ICore::settings());
    m_settings = settings;

    //m_serialOutputPane->setSettings(m_settings);
}


void SerialTerminalPlugin::triggerAction()
{
    QMessageBox::information(Core::ICore::mainWindow(),
                             tr("Action Triggered"),
                             tr("This is an action from SerialTerminal."));
}

} // namespace Internal
} // namespace SerialTerminal
