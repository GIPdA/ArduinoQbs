#pragma once

#include "serialterminal_global.h"

#include <coreplugin/ioutputpane.h>

#include "serialview.h"
#include "serialdevicemodel.h"
#include "combobox.h"
#include "settings.h"

QT_BEGIN_NAMESPACE
class QToolButton;
class QButtonGroup;
class QAbstractButton;
class QComboBox;
QT_END_NAMESPACE

namespace SerialTerminal {
namespace Internal {

class SerialOutputPane : public Core::IOutputPane
{
    Q_OBJECT

public:
    SerialOutputPane(Settings& settings);
    ~SerialOutputPane();


    // IOutputPane
    QWidget *outputWidget(QWidget* parent) override;
    QList<QWidget *> toolBarWidgets() const override;
    QString displayName() const override;

    int priorityInStatusBar() const override;
    void clearContents() override;
    void visibilityChanged(bool) override;
    bool canFocus() const override;
    bool hasFocus() const override;
    void setFocus() override;

    bool canNext() const override;
    bool canPrevious() const override;
    void goToNext() override;
    void goToPrev() override;
    bool canNavigate() const override;

    void close();

private:
    void createToolButtons();

    void setCurrentDevice(int index);

    void connectControl();
    void disconnectControl();
    void resetControl();
    void connectedChanged(bool connected);

    SerialView* m_terminalView {nullptr};
    SerialDeviceModel* m_devicesModel {nullptr};

    QAction* m_disconnectAction {nullptr};
    QToolButton* m_connectButton {nullptr};
    QToolButton* m_disconnectButton {nullptr};
    QToolButton* m_resetButton {nullptr};
    ComboBox* m_portsSelection {nullptr};
    ComboBox* m_baudRateSelection {nullptr};
};

} // namespace Internal
} // namespace SerialTerminal
