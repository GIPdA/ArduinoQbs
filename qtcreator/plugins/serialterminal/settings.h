
#pragma once

#include <QtGlobal>
#include <QString>
#include <QSerialPort>

class QSettings;

namespace SerialTerminal {
namespace Internal {

class Settings {
public:
    bool edited {false};
    qint32 baudRate {9600};
    QSerialPort::DataBits dataBits {QSerialPort::Data8};
    QSerialPort::Parity parity {QSerialPort::NoParity};
    QSerialPort::StopBits stopBits {QSerialPort::OneStop};
    QSerialPort::FlowControl flowControl {QSerialPort::NoFlowControl};

    QString portName;

    bool initialDTRState {false};
    bool initialRTSState {false};
    QString enterKeyEmulation;

    bool clearInputOnSend {false};


    void save(QSettings *settings) const;
    void load(QSettings *settings);
    void setDefault();
    bool equals(const Settings &other) const;
};

bool operator ==(Settings &s1, Settings &s2);
bool operator !=(Settings &s1, Settings &s2);

} // namespace Internal
} // namespace SerialTerminal
