#include "serialconfiguration.h"

#include <utils/outputformatter.h>

#include "constants.h"

namespace SerialTerminal {
namespace Internal {

SerialControl::SerialControl(Settings& settings, QObject* parent) :
    QObject(parent),
    m_serialPort(new QSerialPort(this))
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
            this, &SerialControl::handleReadyRead);

    connect(m_serialPort, static_cast<void (QSerialPort::*)(QSerialPort::SerialPortError)>(&QSerialPort::error),
            this, &SerialControl::handleError);

    connect(&m_reconnectTimer, &QTimer::timeout,
            this, &SerialControl::reconnectTimeout);
}

SerialControl::~SerialControl()
{
    //
}


bool SerialControl::start()
{
    stop();

    if (!m_serialPort->open(QIODevice::ReadWrite)) {
        //qWarning("Unable to open port %s", qPrintable(m_serialPort->portName()));
        return false;
    }

    m_serialPort->setDataTerminalReady(m_initialDTRState);
    m_serialPort->setRequestToSend(m_initialRTSState);

    appendMessage(QString(tr("Starting new session on %1...\n")).arg(portName()), Utils::NormalMessageFormat);

    emit started();
    emit runningChanged(true);
    return true;
}

void SerialControl::stop()
{
    if (m_serialPort->isOpen()) {
        m_serialPort->close();

        appendMessage(QString(tr("\nSession finished on %1\n\n")).arg(portName()), Utils::NormalMessageFormat);

        emit finished();
        emit runningChanged(false);
    }
}

bool SerialControl::isRunning() const
{
    return m_serialPort->isOpen();
}

QString SerialControl::displayName() const
{
    return portName().isEmpty() ? "<no port>" : portName();
}

bool SerialControl::canReUseOutputPane(const SerialControl* other) const
{
    if (other->portName() == portName())
        return true;

    return false;
}

Utils::OutputFormatter*SerialControl::outputFormatter()
{
    return new Utils::OutputFormatter();
}


void SerialControl::appendMessage(const QString &msg, Utils::OutputFormat format)
{
    emit appendMessageRequested(this, msg, format);
}

QString SerialControl::portName() const
{
    return m_serialPort->portName();
}

void SerialControl::setPortName(const QString& name)
{
    if (m_serialPort->portName() == name) return;
    m_serialPort->setPortName(name);
}

qint32 SerialControl::baudRate() const
{
    return m_serialPort->baudRate();
}

void SerialControl::setBaudRate(qint32 baudRate)
{
    m_serialPort->setBaudRate(baudRate);
}

QString SerialControl::baudRateText() const
{
    return QString::number(baudRate());
}

void SerialControl::pulseDTR()
{
    m_serialPort->setDataTerminalReady(!m_initialDTRState);
    QTimer::singleShot(Constants::RESET_DELAY, [&]() {
        m_serialPort->setDataTerminalReady(m_initialDTRState);
    });
}

void SerialControl::handleReadyRead()
{
    auto qb = m_serialPort->readAll();

    appendMessage(QString::fromLocal8Bit(qb), Utils::StdOutFormat);
}


void SerialControl::reconnectTimeout()
{
    // Try to reconnect, stop timer if successful
    if (start()) {
        m_reconnectTimer.stop();
    }
}

void SerialControl::handleError(QSerialPort::SerialPortError error)
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

void SerialControl::tryReconnect()
{
    if (m_reconnectTimer.isActive() || m_serialPort->portName().isEmpty()) return;

    m_reconnectTimer.start();
}


} // namespace Internal
} // namespace SerialTerminal
