#include "serialoutputpane.h"
#include "constants.h"
#include "serialconfiguration.h"

#include <coreplugin/icore.h>
#include <coreplugin/icontext.h>
#include <coreplugin/actionmanager/actionmanager.h>
#include <coreplugin/actionmanager/command.h>
#include <coreplugin/actionmanager/actioncontainer.h>
#include <coreplugin/coreconstants.h>
#include <coreplugin/outputwindow.h>

#include <utils/icon.h>
#include <utils/theme/theme.h>
#include <utils/utilsicons.h>
#include <utils/qtcassert.h>
#include <utils/algorithm.h>
#include <utils/outputformatter.h>

#include <QtGlobal>
#include <QDebug>
#include <QAction>
#include <QMenu>
#include <QToolButton>
#include <QComboBox>
#include <QTabBar>
#include <QVBoxLayout>

enum { debug = 1 };

namespace SerialTerminal {
namespace Internal {

class TabWidget : public QTabWidget
{
    Q_OBJECT
public:
    TabWidget(QWidget *parent = nullptr);
signals:
    void contextMenuRequested(const QPoint &pos, int index);
protected:
    bool eventFilter(QObject *object, QEvent *event) override;
private:
    void slotContextMenuRequested(const QPoint &pos);
    int m_tabIndexForMiddleClick {-1};
};


TabWidget::TabWidget(QWidget *parent) :
    QTabWidget(parent)
{
    tabBar()->installEventFilter(this);
    setContextMenuPolicy(Qt::CustomContextMenu);
    connect(this, &QWidget::customContextMenuRequested,
            this, &TabWidget::slotContextMenuRequested);
}

bool TabWidget::eventFilter(QObject *object, QEvent *event)
{
    if (object == tabBar()) {
        if (event->type() == QEvent::MouseButtonPress) {
            QMouseEvent *me = static_cast<QMouseEvent *>(event);
            if (me->button() == Qt::MiddleButton) {
                m_tabIndexForMiddleClick = tabBar()->tabAt(me->pos());
                event->accept();
                return true;
            }
        } else if (event->type() == QEvent::MouseButtonRelease) {
            QMouseEvent *me = static_cast<QMouseEvent *>(event);
            if (me->button() == Qt::MiddleButton) {
                int tab = tabBar()->tabAt(me->pos());
                if (tab != -1 && tab == m_tabIndexForMiddleClick)
                    emit tabCloseRequested(tab);
                m_tabIndexForMiddleClick = -1;
                event->accept();
                return true;
            }
        }
    }
    return QTabWidget::eventFilter(object, event);
}

void TabWidget::slotContextMenuRequested(const QPoint &pos)
{
    emit contextMenuRequested(pos, tabBar()->tabAt(pos));
}



SerialOutputPane::SerialControlTab::SerialControlTab(SerialControl* serialControl, Core::OutputWindow* w) :
    serialControl(serialControl), window(w)
{}


SerialOutputPane::SerialOutputPane(Settings &settings) :
    m_mainWidget(new QWidget),
    m_tabWidget(new TabWidget),
    m_settings(settings),
    m_devicesModel(new SerialDeviceModel),
    m_closeCurrentTabAction(new QAction(tr("Close Tab"), this)),
    m_closeAllTabsAction(new QAction(tr("Close All Tabs"), this)),
    m_closeOtherTabsAction(new QAction(tr("Close Other Tabs"), this))
{
    createToolButtons();

    QVBoxLayout *layout = new QVBoxLayout;
    layout->setMargin(0);
    m_tabWidget->setDocumentMode(true);
    m_tabWidget->setTabsClosable(true);
    m_tabWidget->setMovable(true);
    connect(m_tabWidget, &QTabWidget::tabCloseRequested,
            this, [this](int index) { closeTab(index); });
    layout->addWidget(m_tabWidget);

    connect(m_tabWidget, &QTabWidget::currentChanged, this, &SerialOutputPane::tabChanged);
    connect(m_tabWidget, &TabWidget::contextMenuRequested,
            this, &SerialOutputPane::contextMenuRequested);

    m_mainWidget->setLayout(layout);

//    connect(TextEditor::TextEditorSettings::instance(), &TextEditor::TextEditorSettings::fontSettingsChanged,
//            this, &SerialOutputPane::updateFontSettings);

//    connect(TextEditor::TextEditorSettings::instance(), &TextEditor::TextEditorSettings::behaviorSettingsChanged,
//            this, &SerialOutputPane::updateBehaviorSettings);

//    connect(ProjectExplorer::SessionManager::instance(), &SessionManager::aboutToUnloadSession,
//            this, &SerialOutputPane::aboutToUnloadSession);
//    connect(ProjectExplorerPlugin::instance(), &ProjectExplorerPlugin::settingsChanged,
//            this, &SerialOutputPane::updateFromSettings);

#ifdef Q_OS_WIN
//    connect(this, &SerialOutputPane::allRunControlsFinished,
//            WinDebugInterface::instance(), &WinDebugInterface::stop);
#endif

//    QSettings *settings = Core::ICore::settings();
//    m_zoom = settings->value(QLatin1String(SETTINGS_KEY), 0).toFloat();

//    connect(Core::ICore::instance(), &Core::ICore::saveSettingsRequested,
//            this, &SerialOutputPane::saveSettings);

    enableDefaultButtons();
}

SerialOutputPane::~SerialOutputPane()
{
    // Unregister objects from the plugin manager's object pool
    // Delete members
    delete m_mainWidget;
}

QWidget* SerialOutputPane::outputWidget(QWidget* parent)
{
    Q_UNUSED(parent)
    return m_mainWidget;
}

QList<QWidget*> SerialOutputPane::toolBarWidgets() const
{
    return { m_connectButton, m_disconnectButton, m_resetButton, m_portsSelection, m_baudRateSelection, m_newButton };
}


QString SerialOutputPane::displayName() const
{
    return tr(Constants::OUTPUT_PANE_TITLE);
}

int SerialOutputPane::priorityInStatusBar() const
{
    return 30;
}

void SerialOutputPane::clearContents()
{
    Core::OutputWindow *currentWindow = qobject_cast<Core::OutputWindow *>(m_tabWidget->currentWidget());
    if (currentWindow)
        currentWindow->clear();
}

void SerialOutputPane::visibilityChanged(bool)
{
}

bool SerialOutputPane::canFocus() const
{
    return m_tabWidget->currentWidget();
}

bool SerialOutputPane::hasFocus() const
{
    QWidget *widget = m_tabWidget->currentWidget();
    if (!widget)
        return false;
    return widget->window()->focusWidget() == widget;
}

void SerialOutputPane::setFocus()
{
    if (m_tabWidget->currentWidget())
        m_tabWidget->currentWidget()->setFocus();
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


void SerialOutputPane::appendMessage(SerialControl *rc, const QString &out, Utils::OutputFormat format)
{
    const int index = indexOf(rc);
    if (index != -1) {
        Core::OutputWindow *window = m_serialControlTabs.at(index).window;
        window->appendMessage(out, format);
        if (format != Utils::NormalMessageFormat) {
            if (m_serialControlTabs.at(index).behaviorOnOutput == Flash)
                flash();
            else
                popup(NoModeSwitch);
        }
    }
}


void SerialOutputPane::createNewOutputWindow(SerialControl *rc)
{
    connect(rc, &SerialControl::started,
            this, &SerialOutputPane::slotSerialControlStarted);
    connect(rc, &SerialControl::finished,
            this, &SerialOutputPane::slotSerialControlFinished);

//    connect(rc, &SerialControl::applicationProcessHandleChanged,
//            this, &SerialOutputPane::enableDefaultButtons);

    connect(rc, &SerialControl::appendMessageRequested,
            this, &SerialOutputPane::appendMessage);

    Utils::OutputFormatter *formatter = rc->outputFormatter();

    // First look if we can reuse a tab
    /*const int tabIndex = Utils::indexOf(m_serialControlTabs, [rc](const SerialControlTab &tab) {
        return rc->canReUseOutputPane(tab.serialControl);
    });

    if (tabIndex != -1) {
        SerialControlTab &tab = m_serialControlTabs[tabIndex];
        // Reuse this tab
        delete tab.serialControl;
        tab.serialControl = rc;
        handleOldOutput(tab.window);
        tab.window->scrollToBottom();
        tab.window->setFormatter(formatter);
        if (debug)
            qDebug() << "OutputPane::createNewOutputWindow: Reusing tab" << tabIndex << " for " << rc;
        return;
    }//*/

    // Create new
    static uint counter = 0;
    Core::Id contextId = Core::Id(Constants::C_SERIAL_OUTPUT).withSuffix(counter++);
    Core::Context context(contextId);
    Core::OutputWindow *ow = new Core::OutputWindow(context, m_tabWidget);
    ow->setWindowTitle(tr("Application Output Window"));
//    ow->setWindowIcon(Icons::WINDOW.icon());
    ow->setFormatter(formatter);
//    ow->setWordWrapEnabled(ProjectExplorerPlugin::projectExplorerSettings().wrapAppOutput);
//    ow->setMaxLineCount(ProjectExplorerPlugin::projectExplorerSettings().maxAppOutputLines);
//    ow->setWheelZoomEnabled(TextEditor::TextEditorSettings::behaviorSettings().m_scrollWheelZooming);
//    ow->setBaseFont(TextEditor::TextEditorSettings::fontSettings().font());
//    ow->setFontZoom(m_zoom);

    /*connect(ow, &Core::OutputWindow::wheelZoom, this, [this, ow]() {
        m_zoom = ow->fontZoom();
        foreach (const RunControlTab &tab, m_runControlTabs)
            tab.window->setFontZoom(m_zoom);
    });//*/

//    Aggregation::Aggregate *agg = new Aggregation::Aggregate;
//    agg->add(ow);
//    agg->add(new Core::BaseTextFind(ow));

    m_serialControlTabs.push_back(SerialControlTab(rc, ow));
    m_tabWidget->addTab(ow, rc->displayName());

    if (debug)
        qDebug() << "OutputPane::createNewOutputWindow: Adding tab for " << rc;

    updateCloseActions();
}


bool SerialOutputPane::closeTabs(CloseTabMode mode)
{
    bool allClosed = true;
    for (int t = m_tabWidget->count() - 1; t >= 0; t--)
        if (!closeTab(t, mode))
            allClosed = false;

    if (debug)
        qDebug() << "OutputPane::closeTabs() returns " << allClosed;

    return allClosed;
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

    // New terminal button
    m_newButton = new QToolButton;
    m_newButton->setIcon(Utils::Icons::PLUS_TOOLBAR.icon());
    m_newButton->setToolTip(tr("Add new terminal"));
    m_newButton->setAutoRaise(true);
    m_newButton->setEnabled(true);

    connect(m_newButton, &QToolButton::clicked,
            this, &SerialOutputPane::openNewTerminalControl);


    // Available devices box
    m_portsSelection = new ComboBox();
    m_portsSelection->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    m_portsSelection->setModel(m_devicesModel);
    connect(m_portsSelection, &ComboBox::opened, m_devicesModel, &SerialDeviceModel::update);
    connect(m_portsSelection, QOverload<int>::of(&ComboBox::currentIndexChanged), this, &SerialOutputPane::activePortNameChanged);

    // Baud rates box
    m_baudRateSelection = new ComboBox();
    m_baudRateSelection->setSizeAdjustPolicy(QComboBox::AdjustToContents);
    m_baudRateSelection->addItems(m_devicesModel->baudRates());
    connect(m_baudRateSelection, QOverload<int>::of(&ComboBox::currentIndexChanged), this, &SerialOutputPane::activeBaudRateChanged);

    m_baudRateSelection->setCurrentIndex(m_devicesModel->indexForBaudRate(115200)); // TODO: add to settings, add fallback to 9600
}

int SerialOutputPane::indexOf(const SerialControl *rc) const
{
    for (int i = m_serialControlTabs.size() - 1; i >= 0; i--)
        if (m_serialControlTabs.at(i).serialControl == rc)
            return i;
    return -1;
}

int SerialOutputPane::indexOf(const QWidget *outputWindow) const
{
    for (int i = m_serialControlTabs.size() - 1; i >= 0; i--)
        if (m_serialControlTabs.at(i).window == outputWindow)
            return i;
    return -1;
}

int SerialOutputPane::currentIndex() const
{
    if (const QWidget *w = m_tabWidget->currentWidget())
        return indexOf(w);
    return -1;
}

SerialControl* SerialOutputPane::currentSerialControl() const
{
    const int index = currentIndex();
    if (index != -1)
        return m_serialControlTabs.at(index).serialControl;
    return 0;
}

int SerialOutputPane::findTabWithPort(const QString& portName) const
{
    for (int i {0}; i < m_serialControlTabs.size(); ++i) {
        if (m_serialControlTabs.at(i).serialControl->portName() == portName) {
            return i;
        }
    }
    return -1;
}

int SerialOutputPane::findRunningTabWithPort(const QString& portName) const
{
    for (int i {0}; i < m_serialControlTabs.size(); ++i) {
        if (m_serialControlTabs.at(i).serialControl->isRunning()
                && m_serialControlTabs.at(i).serialControl->portName() == portName) {
            return i;
        }
    }
    return -1;
}

void SerialOutputPane::handleOldOutput(Core::OutputWindow *window) const
{
    // TODO: add to settings
//    if (ProjectExplorerPlugin::projectExplorerSettings().cleanOldAppOutput)
//        window->clear();
//    else
        window->grayOutOldContent();
}

void SerialOutputPane::updateCloseActions()
{
    const int tabCount = m_tabWidget->count();
    m_closeCurrentTabAction->setEnabled(tabCount > 0);
    m_closeAllTabsAction->setEnabled(tabCount > 0);
    m_closeOtherTabsAction->setEnabled(tabCount > 1);
}

bool SerialOutputPane::closeTab(int tabIndex, CloseTabMode closeTabMode)
{
    int index = indexOf(m_tabWidget->widget(tabIndex));
    QTC_ASSERT(index != -1, return true);
    // TODO

    if (debug)
        qDebug() << "OutputPane::closeTab tab " << tabIndex << m_serialControlTabs[index].serialControl
                        << m_serialControlTabs[index].window << m_serialControlTabs[index].asyncClosing;

    // Prompt user to stop
    if (m_serialControlTabs[index].serialControl->isRunning()) {
        switch (closeTabMode) {
        case CloseTabNoPrompt:
            break;
        case CloseTabWithPrompt:
            // TODO: prompt to stop?
            /*QWidget *tabWidget = m_tabWidget->widget(tabIndex);
            if (!m_serialControlTabs[index].serialControl->promptToStop())
                return false;
            // The event loop has run, thus the ordering might have changed, a tab might
            // have been closed, so do some strange things...
            tabIndex = m_tabWidget->indexOf(tabWidget);
            index = indexOf(tabWidget);
            if (tabIndex == -1 || index == -1)
                return false;//*/
            break;
        }

        if (m_serialControlTabs[index].serialControl->isRunning()) { // yes it might have stopped already, then just close
            QWidget *tabWidget = m_tabWidget->widget(tabIndex);
            m_serialControlTabs[index].serialControl->stop();

            tabIndex = m_tabWidget->indexOf(tabWidget);
            index = indexOf(tabWidget);
            if (tabIndex == -1 || index == -1)
                return false;
        }
    }

    m_tabWidget->removeTab(tabIndex);
    delete m_serialControlTabs[index].serialControl;
    delete m_serialControlTabs[index].window;
    m_serialControlTabs.removeAt(index);
    updateCloseActions();

    if (m_serialControlTabs.isEmpty())
        hide();

    return true;
}


void SerialOutputPane::contextMenuRequested(const QPoint &pos, int index)
{
    QList<QAction *> actions { m_closeCurrentTabAction, m_closeAllTabsAction, m_closeOtherTabsAction };

    QAction *action = QMenu::exec(actions, m_tabWidget->mapToGlobal(pos), 0, m_tabWidget);
    const int currentIdx = index != -1 ? index : currentIndex();

    if (action == m_closeCurrentTabAction) {
        if (currentIdx >= 0)
            closeTab(currentIdx);
    } else if (action == m_closeAllTabsAction) {
        closeTabs(SerialOutputPane::CloseTabWithPrompt);
    } else if (action == m_closeOtherTabsAction) {
        for (int t = m_tabWidget->count() - 1; t >= 0; t--)
            if (t != currentIdx)
                closeTab(t);
    }
}


void SerialOutputPane::enableDefaultButtons()
{
    const auto* rc = currentSerialControl();
    const bool isRunning = rc && rc->isRunning();
    enableButtons(rc, isRunning);
}

void SerialOutputPane::enableButtons(const SerialControl *rc, bool isRunning)
{
    if (rc) {
        m_connectButton->setEnabled(!isRunning);
        m_disconnectButton->setEnabled(isRunning);
        m_resetButton->setEnabled(isRunning);

        m_portsSelection->setEnabled(!isRunning);
        m_baudRateSelection->setEnabled(!isRunning);

//        m_zoomInButton->setEnabled(true);
//        m_zoomOutButton->setEnabled(true);
    } else {
        m_connectButton->setEnabled(true);
        m_disconnectButton->setEnabled(false);

        m_portsSelection->setEnabled(true);
        m_baudRateSelection->setEnabled(true);

//        m_zoomInButton->setEnabled(false);
//        m_zoomOutButton->setEnabled(false);
    }
}

void SerialOutputPane::tabChanged(int i)
{
    const int index = indexOf(m_tabWidget->widget(i));
    if (i != -1 && index != -1) {
        const auto* rc = m_serialControlTabs.at(index).serialControl;

        // Update combobox index
        m_portsSelection->blockSignals(true);
        m_baudRateSelection->blockSignals(true);

        m_portsSelection->setCurrentText(rc->portName());
        m_baudRateSelection->setCurrentText(rc->baudRateText());

        m_portsSelection->blockSignals(false);
        m_baudRateSelection->blockSignals(false);

        // Update buttons
        enableButtons(rc, rc->isRunning());
    } else {
        enableDefaultButtons();
    }
}


void SerialOutputPane::slotSerialControlStarted()
{
    SerialControl *current = currentSerialControl();
    if (current && current == sender())
        enableButtons(current, true); // RunControl::isRunning() cannot be trusted in signal handler.
    //emit runControlStarted(current);
}

void SerialOutputPane::slotSerialControlFinished()
{
    SerialControl *rc = qobject_cast<SerialControl*>(sender());
    QTimer::singleShot(0, this, [this, rc]() { slotSerialControlFinished2(rc); });
    rc->outputFormatter()->flush();
}

void SerialOutputPane::slotSerialControlFinished2(SerialControl* sender)
{
    const int senderIndex = indexOf(sender);

    // This slot is queued, so the stop() call in closeTab might lead to this slot, after closeTab already cleaned up
    if (senderIndex == -1)
        return;

    // Enable buttons for current
    SerialControl *current = currentSerialControl();

    if (debug)
        qDebug() << "OutputPane::runControlFinished"  << sender << senderIndex
                    << " current " << current << m_serialControlTabs.size();

    if (current && current == sender)
        enableButtons(current, false); // RunControl::isRunning() cannot be trusted in signal handler.

    //emit runControlFinished(sender);

//    if (!isRunning())
//        emit allRunControlsFinished();
}

bool SerialOutputPane::isRunning() const
{
    return Utils::anyOf(m_serialControlTabs, [](const SerialControlTab &rt) {
        return rt.serialControl->isRunning();
    });
}

void SerialOutputPane::activePortNameChanged(int index)
{
    SerialControl *current = currentSerialControl();
    if (current) {
        auto pn = m_devicesModel->portName(index);
        if (debug) qDebug() << "Set port to" << index << pn;
        current->setPortName(pn);

        // Update tab text
        int tabIndex {indexOf(current)};
        if (tabIndex >= 0)
            m_tabWidget->setTabText(tabIndex, pn);
    }
}

void SerialOutputPane::activeBaudRateChanged(int index)
{
    SerialControl *current = currentSerialControl();
    if (current) {
        auto br = m_devicesModel->baudRate(index);
        if (debug) qDebug() << "Set baudrate to" << index << br;
        current->setBaudRate(br);
    }
}


void SerialOutputPane::connectControl()
{
    auto currentPortName = m_devicesModel->portName(m_portsSelection->currentIndex());
    if (currentPortName.isEmpty()) return;

    SerialControl *current = currentSerialControl();
    const int index = currentIndex();
    // MAYBE: use current->canReUseOutputPane(...)?

    // Show tab if already opened and running
    int i = findRunningTabWithPort(currentPortName);
    if (i >= 0) {
        m_tabWidget->setCurrentIndex(i);
        if (debug)
            qDebug() << "Port running in tab #" << i;
        return;
    }

    if (current) {
        current->setPortName(currentPortName);
        // Gray out old and connect
        if (index != -1) {
            auto& tab = m_serialControlTabs[index];
            handleOldOutput(tab.window);
            tab.window->scrollToBottom();
        }
        if (debug)
            qDebug() << "Connect to" << current->portName();
    } else {
        // Create a new window
        auto rc = new SerialControl(m_settings);
        rc->setPortName(currentPortName);
        createNewOutputWindow(rc);

        if (debug)
            qDebug() << "Create and connect to" << rc->portName();

        current = rc;
    }

    // Update tab text
    if (index != -1) {
        m_tabWidget->setTabText(index, current->portName());
    }

    current->start();
}

void SerialOutputPane::disconnectControl()
{
    SerialControl *current = currentSerialControl();
    if (current) {
        current->stop();
        if (debug)
            qDebug("Disconnected.");
    }
}

void SerialOutputPane::resetControl()
{
    SerialControl *current = currentSerialControl();
    if (current) {
        current->pulseDTR();
    }
}

void SerialOutputPane::openNewTerminalControl()
{
    auto currentPortName = m_devicesModel->portName(m_portsSelection->currentIndex());
    if (currentPortName.isEmpty()) return;

    auto rc = new SerialControl(m_settings);
    rc->setPortName(currentPortName);
    createNewOutputWindow(rc);

    if (debug)
        qDebug() << "Created new terminal on" << rc->portName();
}


} // namespace Internal
} // namespace SerialTerminal

#include "serialoutputpane.moc"
