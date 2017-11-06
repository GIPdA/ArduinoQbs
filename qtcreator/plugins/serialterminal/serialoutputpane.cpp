#include "serialoutputpane.h"
#include "serialterminalconstants.h"

#include <coreplugin/icore.h>
#include <coreplugin/icontext.h>
#include <coreplugin/actionmanager/actionmanager.h>
#include <coreplugin/actionmanager/command.h>
#include <coreplugin/actionmanager/actioncontainer.h>
#include <coreplugin/coreconstants.h>

#include <utils/icon.h>
#include <utils/theme/theme.h>
#include <utils/utilsicons.h>

#include <QtGlobal>
#include <QDebug>
#include <QAction>
#include <QMenu>
#include <QToolButton>
#include <QComboBox>

namespace SerialTerminal {
namespace Internal {

SerialOutputPane::SerialOutputPane(Settings &settings) :
    m_terminalView(new SerialView(settings))
{
    createToolButtons();

    connect(m_terminalView, &SerialView::connectedChanged, this, &SerialOutputPane::connectedChanged);
}

SerialOutputPane::~SerialOutputPane()
{
    // Unregister objects from the plugin manager's object pool
    // Delete members
}

QWidget* SerialOutputPane::outputWidget(QWidget* parent)
{
    m_terminalView->setParent(parent);
    return m_terminalView;
}

QList<QWidget*> SerialOutputPane::toolBarWidgets() const
{
    QWidgetList widgets;

    widgets << m_connectButton << m_disconnectButton << m_resetButton
            << m_portsSelection << m_baudRateSelection;

    return widgets;
}


QString SerialOutputPane::displayName() const
{
    return tr(Constants::OUTPUT_PANE_TITLE);
}

int SerialOutputPane::priorityInStatusBar() const
{
    return 10;
}

void SerialOutputPane::clearContents()
{
    m_terminalView->clearContent();
}

void SerialOutputPane::visibilityChanged(bool)
{
    //
}

bool SerialOutputPane::canFocus() const
{
    return true;
}

bool SerialOutputPane::hasFocus() const
{
    return false;// TODO
}

void SerialOutputPane::setFocus()
{
    //
}

bool SerialOutputPane::canNext() const
{
    return false;
}

bool SerialOutputPane::canPrevious() const
{
    return false;
}

void SerialOutputPane::goToNext()
{
    //
}

void SerialOutputPane::goToPrev()
{
    //
}

bool SerialOutputPane::canNavigate() const
{
    return false;
}

void SerialOutputPane::close()
{
    m_terminalView->close();
}



void SerialOutputPane::createToolButtons()
{
    // Connect button
    m_connectButton = new QToolButton;
    m_connectButton->setIcon(Utils::Icons::RUN_SMALL_TOOLBAR.icon());
    m_connectButton->setToolTip(tr("Connect"));
    m_connectButton->setAutoRaise(true);
    m_connectButton->setEnabled(false);
    connect(m_connectButton, &QToolButton::clicked,
            this, &SerialOutputPane::connectControl);

    // Disconnect
    /*m_disconnectAction = new QAction(tr("Disconnect"), this);
    m_disconnectAction->setIcon(Utils::Icons::STOP_SMALL_TOOLBAR.icon());
    m_disconnectAction->setToolTip(tr("Stop"));
    m_disconnectAction->setEnabled(false);

    Core::Command *cmd = Core::ActionManager::registerAction(m_disconnectAction, Constants::STOP);//*/

    // Disconnect button
    m_disconnectButton = new QToolButton;
    m_disconnectButton->setIcon(Utils::Icons::STOP_SMALL_TOOLBAR.icon());
    m_disconnectButton->setToolTip(tr("Disconnect"));
    m_disconnectButton->setAutoRaise(true);
    m_disconnectButton->setEnabled(false);
    //m_disconnectButton->setDefaultAction(cmd->action());

    /*connect(m_disconnectAction, &QAction::triggered,
            this, &SerialOutputPane::disconnectControl);//*/
    connect(m_disconnectButton, &QToolButton::clicked,
            this, &SerialOutputPane::disconnectControl);


    // Reset button
    m_resetButton = new QToolButton;
    m_resetButton->setIcon(Utils::Icons::RELOAD.icon());
    m_resetButton->setToolTip(tr("Reset the board"));
    m_resetButton->setAutoRaise(true);
    m_resetButton->setEnabled(false);
    //m_disconnectButton->setDefaultAction(cmd->action());

    connect(m_resetButton, &QToolButton::clicked,
            this, &SerialOutputPane::resetControl);



    m_devicesModel = new SerialDeviceModel;

    // Availbale devices box
    m_portsSelection = new ComboBox();
    m_portsSelection->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    m_portsSelection->setModel(m_devicesModel);
    connect(m_portsSelection, &ComboBox::opened, m_devicesModel, &SerialDeviceModel::update);
    connect(m_portsSelection, QOverload<int>::of(&ComboBox::currentIndexChanged), this, &SerialOutputPane::setCurrentDevice);

    // Baud rates box
    m_baudRateSelection = new ComboBox();
    m_baudRateSelection->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    m_baudRateSelection->addItems(m_devicesModel->baudRates());

    connect(m_baudRateSelection, QOverload<int>::of(&ComboBox::currentIndexChanged),
            [=](int index) {
        m_terminalView->setBaudRate(m_devicesModel->baudRate(index));
    }
    );

    m_baudRateSelection->setCurrentIndex(m_devicesModel->indexForBaudRate(115200)); // TODO: add to settings, add fallback to 9600
}

void SerialOutputPane::setCurrentDevice(int index)
{
    if (index == 0) {
        m_terminalView->setPortName("");
        return;
    }
    qDebug() << "Set port to" << index << m_devicesModel->portName(index);

    m_terminalView->setPortName(m_devicesModel->portName(index));
    m_connectButton->setEnabled(true);
}


void SerialOutputPane::connectControl()
{
    qDebug() << "Connect to" << m_terminalView->portName();

    if (m_terminalView->open()) {
        qDebug("Connected.");
        // TODO: reset on connect (setting)
    } else {
        qDebug("Connection failed.");
    }
}

void SerialOutputPane::disconnectControl()
{
    m_terminalView->close();
    qDebug("Disconnected.");
}

void SerialOutputPane::resetControl()
{
    m_terminalView->pulseDTR();
}

void SerialOutputPane::connectedChanged(bool connected)
{
    m_disconnectButton->setEnabled(connected);
    m_connectButton->setEnabled(!connected);
    m_resetButton->setEnabled(connected);

    m_portsSelection->setEnabled(!connected);
    m_baudRateSelection->setEnabled(!connected);
}

} // namespace Internal
} // namespace SerialTerminal
