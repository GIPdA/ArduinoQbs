#ifndef COMBOBOX_H
#define COMBOBOX_H

#include <QComboBox>

namespace SerialTerminal {
namespace Internal {

class ComboBox : public QComboBox
{
    Q_OBJECT
public:
    ComboBox();
    ~ComboBox();

    virtual void showPopup();

signals:
    void opened();
};

} // namespace Internal
} // namespace SerialTerminal

#endif // COMBOBOX_H
