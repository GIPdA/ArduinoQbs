#ifndef SERIALVIEW_H
#define SERIALVIEW_H

#include <QWidget>
#include <QSerialPort>
#include <QTimer>
#include <QTextEdit>
#include <QLineEdit>


namespace SerialTerminal {
namespace Internal {

class SerialView : public QWidget
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)

public:
    explicit SerialView(QWidget *parent = 0);

    bool connected() const;

    QString portName() const;

    Q_INVOKABLE QString errorString() const;

signals:
    void connectedChanged(bool connected);

public slots:
    void setPortName(const QString &name);
    void setBaudRate(qint32 baudRate);
    bool open(const QString &portName = QString());
    void close();
    void clearContent();

    void doReset();

private slots:
    void handleReadyRead();
    void reconnectTimeout();
    void handleError(QSerialPort::SerialPortError error);

    void sendInput();

protected:
    void tryReconnect();

private:
    QString m_portName;
    QSerialPort *m_serialPort {nullptr};
    QString m_readData;
    QTimer m_reconnectTimer;

    QTextEdit* m_textEdit {nullptr};
    QLineEdit* m_inputLine {nullptr};
    QString m_lineEnd;
};

} // namespace Internal
} // namespace SerialTerminal

#endif // SERIALVIEW_H
