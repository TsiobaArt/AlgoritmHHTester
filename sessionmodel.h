#ifndef SESSIONMODEL_H
#define SESSIONMODEL_H

#include <QSqlTableModel>
#include <QObject>
#include <QtCore>
#include <QObject>
#include <names.h>
#include <QAbstractTableModel>
#include <QSqlTableModel>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

class SessionModel : public QSqlTableModel
{
    Q_OBJECT
public:
    explicit SessionModel(QObject *parent = nullptr);
    enum Parametrs{
        IdRole = Qt::UserRole +1,
        DateRole,
        TableNameRole,
        SessionNameRole,
        NotesRole
    };
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
    Q_INVOKABLE void updateModel();
    Q_INVOKABLE QJsonObject get(const int index);

private:

};

#endif // SESSIONMODEL_H
