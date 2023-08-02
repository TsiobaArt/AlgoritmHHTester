#ifndef REFERENCEMODEL_H
#define REFERENCEMODEL_H

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
    Q_INVOKABLE QJsonObject get(const int index);


};

#endif // REFERENCEMODEL_H
