#ifndef REFERENCEMODEL_H
#define REFERENCEMODEL_H

#include <QSqlTableModel>
#include <QObject>
#include <QObject>
#include <names.h>
#include <QAbstractTableModel>
#include <QSqlTableModel>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

class ReferenceModel : public QSqlTableModel
{
    Q_OBJECT
public:
    enum Roles {
        Latitude = Qt::UserRole + 1,
        Longitude,
        ReaLatitude,
        ReaLongitude,
        Zoom,
        Name
    };
    explicit ReferenceModel(QObject *parent = nullptr);
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
    Q_INVOKABLE void updateModel();


};

#endif // REFERENCEMODEL_H
