#include "serialview.h"

#include <QDebug>
#include <QString>
#include <QVBoxLayout>

#include "serialterminalconstants.h"

namespace SerialTerminal {
namespace Internal {


SerialView::SerialView(QWidget *parent) :
    QWidget(parent),
    m_serialPort(new QSerialPort(this)),
    m_textEdit(new QTextEdit(this)),
    m_inputLine(new QLineEdit(this)),
    m_lineEnd("\n")
{
    m_serialPort->setBaudRate(QSerialPort::Baud115200);

    m_reconnectTimer.setInterval(Constants::RECONNECT_DELAY);
    m_reconnectTimer.setSingleShot(false);

    connect(m_serialPort, &QSerialPort::readyRead,
            this, &SerialView::handleReadyRead);

    connect(m_serialPort, static_cast<void (QSerialPort::*)(QSerialPort::SerialPortError)>(&QSerialPort::error),
            this, &SerialView::handleError);

    connect(&m_reconnectTimer, &QTimer::timeout,
            this, &SerialView::reconnectTimeout);


    m_inputLine->setPlaceholderText("Enter text and hit Enter to send");

    connect(m_inputLine, &QLineEdit::returnPressed, this, &SerialView::sendInput);


    QVBoxLayout *layout = new QVBoxLayout;
    layout->setMargin(0);
    layout->setSpacing(1);
    layout->addWidget(m_textEdit);
    layout->addWidget(m_inputLine);
    setLayout(layout);
}


QString SerialView::errorString() const
{
    return m_serialPort->errorString();
}

void SerialView::setPortName(const QString& name)
{
    m_serialPort->setPortName(name);
}

void SerialView::setBaudRate(qint32 baudRate)
{
    m_serialPort->setBaudRate(baudRate);
}

bool SerialView::connected() const
{
    return m_serialPort->isOpen();
}

QString SerialView::portName() const
{
    return m_serialPort->portName();
}


bool SerialView::open(const QString& portName)
{
    close();

    if (!portName.isEmpty())
        m_serialPort->setPortName(portName);

    if (!m_serialPort->open(QIODevice::ReadWrite)) {
        //qWarning("Unable to open port %s", qPrintable(m_serialPort->portName()));
        return false;
    }

    m_serialPort->setDataTerminalReady(false);
    m_serialPort->setRequestToSend(false);

    emit connectedChanged(true);
    return true;
}

void SerialView::close()
{
    if (m_serialPort->isOpen()) {
        m_serialPort->close();
        emit connectedChanged(false);
    }
}

void SerialView::handleReadyRead()
{
    auto qb = m_serialPort->readAll();
    m_textEdit->append(QString::fromLocal8Bit(qb));
}


void SerialView::clearContent()
{
    m_textEdit->clear();
}

void SerialView::doReset()
{
    m_serialPort->setDataTerminalReady(true);
    QTimer::singleShot(Constants::RESET_DELAY, [&]() {
        m_serialPort->setDataTerminalReady(false);
    });
}

void SerialView::sendInput()
{
    if (connected()) {
        m_serialPort->write(m_inputLine->text().toLocal8Bit());
        m_serialPort->write(m_lineEnd.toLocal8Bit());
        // TODO: add history
        //m_inputLine->clear();
    } else {
        // TODO: show error
        qDebug("Not connected, cannot send!");
    }
}



void SerialView::reconnectTimeout()
{
    // Try to reconnect, stop timer if successful
    if (open()) {
        m_reconnectTimer.stop();
    }
}

void SerialView::handleError(QSerialPort::SerialPortError error)
{
    if (error != QSerialPort::NoError)
        qWarning("Serial port error: %s (%d)", qPrintable(m_serialPort->errorString()), error);

    switch (error) {
    case QSerialPort::NoError: break;

    case QSerialPort::OpenError:
    case QSerialPort::DeviceNotFoundError:
    case QSerialPort::WriteError:
    case QSerialPort::ReadError:
    case QSerialPort::ResourceError:
    case QSerialPort::UnsupportedOperationError:
    case QSerialPort::UnknownError:
    case QSerialPort::TimeoutError:
    case QSerialPort::NotOpenError:
        tryReconnect();
        break;

    case QSerialPort::PermissionError: break;
    case QSerialPort::ParityError: break;
    case QSerialPort::FramingError: break;
    case QSerialPort::BreakConditionError: break;

    default: break;
    }
}

void SerialView::tryReconnect()
{
    if (m_reconnectTimer.isActive() || m_serialPort->portName().isEmpty()) return;

    m_reconnectTimer.start();
}



} // namespace Internal
} // namespace SerialTerminal
