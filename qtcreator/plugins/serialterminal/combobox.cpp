#include "combobox.h"

namespace SerialTerminal {
namespace Internal {

ComboBox::ComboBox()
{
}

ComboBox::~ComboBox()
{
}

void ComboBox::showPopup()
{
    emit opened();
    QComboBox::showPopup();
}


} // namespace Internal
} // namespace SerialTerminal
