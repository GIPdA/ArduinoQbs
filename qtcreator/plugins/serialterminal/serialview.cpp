#include "serialview.h"

#include <QDebug>
#include <QString>
#include <QVBoxLayout>
#include <QScrollBar>

#include "serialterminalconstants.h"

namespace SerialTerminal {
namespace Internal {


SerialView::SerialView(Settings &settings, QWidget *parent) :
    QWidget(parent),
    m_serialPort(new QSerialPort(this)),
    m_textEdit(new QTextEdit(this)),
    m_inputLine(new QLineEdit(this))
{
    m_serialPort->setBaudRate(settings.baudRate);
    m_serialPort->setDataBits(settings.dataBits);
    m_serialPort->setParity(settings.parity);
    m_serialPort->setStopBits(settings.stopBits);
    m_serialPort->setFlowControl(settings.flowControl);

    if (!settings.portName.isEmpty())
        m_serialPort->setPortName(settings.portName);

    m_lineEnd = settings.enterKeyEmulation;

    m_initialDTRState = settings.initialDTRState;
    m_initialRTSState = settings.initialRTSState;
    m_clearInputOnSend = settings.clearInputOnSend;


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

    m_serialPort->setDataTerminalReady(m_initialDTRState);
    m_serialPort->setRequestToSend(m_initialRTSState);

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

    QTextCursor prev_cursor { m_textEdit->textCursor() };
    auto scollbar = m_textEdit->verticalScrollBar();

    int const sliderPosition = scollbar->sliderPosition();
    bool const sliderAtMax = sliderPosition == scollbar->maximum();

    m_textEdit->moveCursor(QTextCursor::End);
    m_textEdit->insertPlainText(QString::fromLocal8Bit(qb));
    m_textEdit->setTextCursor(prev_cursor);

    // If the scroll was at the bottom, scroll to bottom,
    //  otherwise stay at the position set by the user
    scollbar->setSliderPosition(sliderAtMax ? scollbar->maximum() : sliderPosition);
}


void SerialView::clearContent()
{
    m_textEdit->clear();
}

void SerialView::pulseDTR()
{
    m_serialPort->setDataTerminalReady(!m_initialDTRState);
    QTimer::singleShot(Constants::RESET_DELAY, [&]() {
        m_serialPort->setDataTerminalReady(m_initialDTRState);
    });
}

void SerialView::sendInput()
{
    if (connected()) {
        m_serialPort->write(m_inputLine->text().toLocal8Bit());
        m_serialPort->write(m_lineEnd.toLocal8Bit());
        // TODO: add history

        if (m_clearInputOnSend)
            m_inputLine->clear();
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
