#include "consolelineedit.h"
#include <QKeyEvent>
#include <QDebug>

ConsoleLineEdit::ConsoleLineEdit(QWidget* parent) :
    QLineEdit(parent)
{
    connect(this, &QLineEdit::returnPressed, this, &ConsoleLineEdit::addHistoryEntry);
}

// Add current text to history entries, if not empty and different from last entry.
// Called when return key is pressed.
void ConsoleLineEdit::addHistoryEntry()
{
    m_currentEntry = 0;
    if (text().isEmpty()) return;
    if (!m_history.isEmpty() && m_history.first() == text()) return;

    m_history.prepend(text());
    if (m_history.size() > m_maxEntries) {
        m_history.removeLast();
    }
    //qDebug() << "Entries:" << m_history;
}

// Load a specific history entry: 0 = current, n = n-most last entry
void ConsoleLineEdit::loadHistoryEntry(int index)
{
    if (index < 0 || index > m_history.size()) return;

    //qDebug("Load entry: %d", index);

    if (m_currentEntry == 0) {
        m_editingEntry = text();
    }
    if (index <= 0 && m_currentEntry > 0) {
        m_currentEntry = 0;
        setText(m_editingEntry);
    } else if (index > 0) {
        m_currentEntry = index;
        setText(m_history.at(index-1));
    }
}

void ConsoleLineEdit::keyPressEvent(QKeyEvent* event)
{
    // Navigate history with up/down keys
    if (event->key() == Qt::Key_Up) {
        loadHistoryEntry(m_currentEntry+1);
        event->accept();
    } else if (event->key() == Qt::Key_Down) {
        loadHistoryEntry(m_currentEntry-1);
        event->accept();
    } else {
        QLineEdit::keyPressEvent(event);
    }
}
