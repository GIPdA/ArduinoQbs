#include "serialdevicemodel.h"

#include <QDebug>

namespace SerialTerminal {
namespace Internal {


SerialDeviceModel::SerialDeviceModel(QObject *parent) :
    QAbstractListModel(parent),
    m_headerText("None"),
    m_baudRates(QSerialPortInfo::standardBaudRates())
{
}

QString SerialDeviceModel::portName(int index) const
{
    if (index < 0 || index >= m_ports.size()) return QString();
    return m_ports.at(index).portName();
}

QStringList SerialDeviceModel::baudRates() const
{
    QStringList l;
    for (auto b : m_baudRates) {
        l << QString::number(b);
    }
    return l;
}

qint32 SerialDeviceModel::baudRate(int index) const
{
    if (index < 0 || index >= m_baudRates.size()) return 0;
    return m_baudRates.at(index);
}

int SerialDeviceModel::indexForBaudRate(qint32 baudRate) const
{
    return m_baudRates.indexOf(baudRate);
}

void SerialDeviceModel::disablePort(const QString& portName)
{
    m_disabledPorts.insert(portName);

    int i {0};
    for (const auto& p : m_ports) {
        if (p.portName() == portName) {
            emit dataChanged(index(i), index(i), {Qt::DisplayRole});
            break;
        }
        ++i;
    }
}

void SerialDeviceModel::enablePort(const QString& portName)
{
    m_disabledPorts.remove(portName);
}


void SerialDeviceModel::update()
{
    const auto serialPortInfos = QSerialPortInfo::availablePorts();

    if (serialPortInfos.isEmpty()) {
        // Nothing found, clear
        if (!m_ports.isEmpty()) {
            beginRemoveRows(QModelIndex(), 1, m_ports.size());
            m_ports.clear();
            endRemoveRows();
        }
        return;
    }

    //qDebug() << QObject::tr("Total number of ports available: ") << serialPortInfos.count();


    // Filter the list
    decltype(m_ports) newPorts;
    newPorts.reserve(serialPortInfos.size());
    for (const auto& serialPortInfo : serialPortInfos) {
        //auto description = serialPortInfo.description();
        //auto manufacturer = serialPortInfo.manufacturer();
        //auto serialNumber = serialPortInfo.serialNumber();

        auto portName = serialPortInfo.portName();

        // TODO: test in Windows
        if (!portName.isEmpty() && !portName.startsWith("tty") /*&& serialPortInfo.hasVendorIdentifier()*/) {
            newPorts << serialPortInfo;
        }
    }

    // Update model
    if (m_ports.size() > newPorts.size()) {
        // Remove extra
        beginRemoveRows(QModelIndex(), m_ports.size()-1, newPorts.size()-1);
        m_ports = newPorts;
        endRemoveRows();
    } else if (m_ports.size() < newPorts.size()) {
        // Add new
        beginInsertRows(QModelIndex(), newPorts.size()-1, m_ports.size()-1);
        m_ports = newPorts;
        endInsertRows();
    } else {
        m_ports = newPorts;
    }

    emit dataChanged(index(0), index(m_ports.size()-1));
}

Qt::ItemFlags SerialDeviceModel::flags(const QModelIndex& index) const
{
    auto f = QAbstractListModel::flags(index);
    if (!index.isValid() || index.row() < 0 || index.row() >= m_ports.size())
        return f;

    if (m_disabledPorts.contains(m_ports.at(index.row()).portName())) {
        f &= ~Qt::ItemIsEnabled;
    }
    return f;
}

int SerialDeviceModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
    return m_ports.size();
}

QVariant SerialDeviceModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) return QVariant();
    if (role != Qt::DisplayRole) return QVariant();

    return m_ports.at(index.row()).portName();
}



} // namespace Internal
} // namespace SerialTerminal
