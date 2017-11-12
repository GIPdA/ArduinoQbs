
#include "settings.h"
#include "constants.h"

//#include <coreplugin/coreconstants.h>
//#include <utils/theme/theme.h>

#include <QSettings>

namespace SerialTerminal {
namespace Internal {

void Settings::save(QSettings *settings) const
{
    if (!edited)
        return;

    settings->beginGroup(Constants::SETTINGS_GROUP);

    settings->setValue(Constants::SETTINGS_BAUDRATE, baudRate);
    settings->setValue(Constants::SETTINGS_DATABITS, dataBits);
    settings->setValue(Constants::SETTINGS_PARITY, parity);
    settings->setValue(Constants::SETTINGS_STOPBITS, stopBits);
    settings->setValue(Constants::SETTINGS_FLOWCONTROL, flowControl);
    settings->setValue(Constants::SETTINGS_PORTNAME, portName);
    settings->setValue(Constants::SETTINGS_INITIAL_DTR_STATE, initialDTRState);
    settings->setValue(Constants::SETTINGS_INITIAL_RTS_STATE, initialRTSState);
    settings->setValue(Constants::SETTINGS_ENTER_KEY_EMULATION, enterKeyEmulation);
    settings->setValue(Constants::SETTINGS_CLEAR_INPUT_ON_SEND, clearInputOnSend);

    settings->endGroup();
    settings->sync();
}

void Settings::load(QSettings *settings)
{
    setDefault();

    settings->beginGroup(Constants::SETTINGS_GROUP);

    baudRate = static_cast<qint32>(settings->value(Constants::SETTINGS_BAUDRATE, 9600).toInt());
    dataBits = static_cast<QSerialPort::DataBits>(settings->value(Constants::SETTINGS_DATABITS, QSerialPort::Data8).toInt());
    parity = static_cast<QSerialPort::Parity>(settings->value(Constants::SETTINGS_PARITY, QSerialPort::NoParity).toInt());
    stopBits = static_cast<QSerialPort::StopBits>(settings->value(Constants::SETTINGS_STOPBITS, QSerialPort::OneStop).toInt());
    flowControl = static_cast<QSerialPort::FlowControl>(settings->value(Constants::SETTINGS_FLOWCONTROL, QSerialPort::NoFlowControl).toInt());

    portName = settings->value(Constants::SETTINGS_PORTNAME, "").toString();
    initialDTRState = settings->value(Constants::SETTINGS_INITIAL_DTR_STATE, false).toBool();
    initialRTSState = settings->value(Constants::SETTINGS_INITIAL_RTS_STATE, false).toBool();
    enterKeyEmulation = settings->value(Constants::SETTINGS_ENTER_KEY_EMULATION, "\n").toString();

    clearInputOnSend = settings->value(Constants::SETTINGS_CLEAR_INPUT_ON_SEND, false).toBool();

    settings->endGroup();
}

void Settings::setDefault()
{
    baudRate = 9600;
    dataBits = QSerialPort::Data8;
    parity = QSerialPort::NoParity;
    stopBits = QSerialPort::OneStop;
    flowControl = QSerialPort::NoFlowControl;

    portName = QString();

    initialDTRState = false;
    initialRTSState = false;

    enterKeyEmulation = "\n";

    /*scanningScope = ScanningScopeCurrentFile;
    Utils::Theme *theme = Utils::creatorTheme();

    keyword.iconType = IconType::Todo;
    keyword.color = theme->color(Utils::Theme::OutputPanes_NormalMessageTextColor);

    keyword.iconType = IconType::Bug;
    keyword.color = theme->color(Utils::Theme::OutputPanes_ErrorMessageTextColor);

    keyword.iconType = IconType::Warning;
    keyword.color = theme->color(Utils::Theme::OutputPanes_WarningMessageTextColor);//*/

    edited = false;
}

bool Settings::equals(const Settings &other) const
{
    return (edited == other.edited)
            && (baudRate == other.baudRate)
            && (dataBits == other.dataBits)
            && (parity == other.parity)
            && (stopBits == other.stopBits)
            && (flowControl == other.flowControl)
            && (portName == other.portName)
            && (initialDTRState == other.initialDTRState)
            && (initialRTSState == other.initialRTSState)
            && (enterKeyEmulation == other.enterKeyEmulation);
}

bool operator ==(Settings &s1, Settings &s2)
{
    return s1.equals(s2);
}

bool operator !=(Settings &s1, Settings &s2)
{
    return !s1.equals(s2);
}

} // namespace Internal
} // namespace SerialTerminal

