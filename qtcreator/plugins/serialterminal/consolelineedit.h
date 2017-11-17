#ifndef CONSOLELINEEDIT_H
#define CONSOLELINEEDIT_H

#include <QLineEdit>

class ConsoleLineEdit : public QLineEdit
{
public:
    ConsoleLineEdit(QWidget* parent = nullptr);

    void addHistoryEntry();
    void loadHistoryEntry(int index);

protected:
    void keyPressEvent(QKeyEvent *event) override;

private:
    QStringList m_history;
    int m_maxEntries {10};
    int m_currentEntry {0};
    QString m_editingEntry;
};

#endif // CONSOLELINEEDIT_H
