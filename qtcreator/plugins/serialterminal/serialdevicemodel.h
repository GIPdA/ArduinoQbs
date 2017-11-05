#ifndef SERIALDEVICEMODEL_H
#define SERIALDEVICEMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSerialPortInfo>

namespace SerialTerminal {
namespace Internal {

class SerialDeviceModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit SerialDeviceModel(QObject *parent = 0);

    QString portName(int index) const;

    QStringList baudRates() const;
    qint32 baudRate(int index) const;
    int indexForBaudRate(qint32 baudRate) const;

signals:

public slots:
    void update();

    // QAbstractItemModel interface
public:
    int rowCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;

private:
    QList<QSerialPortInfo> m_ports;
    QString m_headerText;
    QList<qint32> m_baudRates;
};

} // namespace Internal
} // namespace SerialTerminal

#endif // SERIALDEVICEMODEL_H
