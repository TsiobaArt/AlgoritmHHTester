#include "database.h"
#include "qdebug.h"


Database::Database(QObject *parent)
    : QObject{parent} {}

Database::~Database()
{
    if (_db.isOpen()) _db.close();
}

void Database::connnectToDB()
{
    if (QFile(_nameDataBase).exists()) this->openDataBase();
    else qWarning() << "Database does not exist!";
}

bool Database::openDataBase()
{
    _db = QSqlDatabase::addDatabase("QSQLITE");
    _db.setDatabaseName(_nameDataBase);

    if (!_db.open()) {
        qWarning() << "Cannot open database, error: " << _db.lastError();
        return false;
    }
    return true;
}
