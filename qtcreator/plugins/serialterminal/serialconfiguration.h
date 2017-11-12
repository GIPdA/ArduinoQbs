#ifndef SERIALCONFIGURATION_H
#define SERIALCONFIGURATION_H

#include "serialterminal_global.h"

#include <utils/outputformat.h>

#include <QObject>

#include <QSerialPort>
#include <QTimer>

#include "settings.h"

namespace Utils { class OutputFormatter; }

namespace SerialTerminal {
namespace Internal {

class SerialControl : public QObject
{
    Q_OBJECT

public:
    enum StopResult {
        StoppedSynchronously, // Stopped.
        AsynchronousStop     // Stop sequence has been started
    };

    SerialControl(Settings &settings, QObject* parent = nullptr);
    ~SerialControl();

    bool start();

    void stop();
    bool isRunning() const;

    QString displayName() const;

    bool canReUseOutputPane(const SerialControl *other) const;

    Utils::OutputFormatter* outputFormatter();

    void appendMessage(const QString &msg, Utils::OutputFormat format);

    QString portName() const;
    void setPortName(const QString &name);

    qint32 baudRate() const;
    void setBaudRate(qint32 baudRate);

    void pulseDTR();

signals:
    void appendMessageRequested(SerialControl *serialControl,
                                const QString &msg, Utils::OutputFormat format);
    void started();
    void finished();
    void runningChanged(bool running);


private slots:
    void handleReadyRead();
    void reconnectTimeout();
    void handleError(QSerialPort::SerialPortError error);

protected:
    void tryReconnect();

private:
    QString m_portName;
    QSerialPort *m_serialPort {nullptr};
    QTimer m_reconnectTimer;

    QString m_lineEnd;

    bool m_initialDTRState {false};
    bool m_initialRTSState {false};
    bool m_clearInputOnSend {false};
};

} // namespace Internal
} // namespace SerialTerminal

#endif // SERIALCONFIGURATION_H
