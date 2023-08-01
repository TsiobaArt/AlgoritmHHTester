#ifndef DATABASE_H
#define DATABASE_H


#include <QObject>
#include <QFile>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlError>
#include "qcoreapplication.h"


class Database : public QObject
{
    Q_OBJECT

public:
    explicit Database(QObject *parent = nullptr);
    ~Database();

    void connnectToDB();

private:
    QSqlDatabase _db;
    const QString _nameDataBase {qApp->applicationDirPath() + "/headDBNew.db"};

    bool openDataBase();

};
#endif // DATABASE_H
