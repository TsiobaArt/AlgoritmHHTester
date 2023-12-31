#ifndef DATAFROMDB_H
#define DATAFROMDB_H

#include <QObject>
#include <QVector>
#include <QPair>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QDebug>
#include "StructData.h"
#include "qcoreapplication.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QSqlError>
#include <QVector>
#include <iostream>

class DataFromDB : public QObject
{

    Q_OBJECT

public:
    explicit DataFromDB(QObject *parent = nullptr);
    void loadData(const QString &table, const double rcsRange, const double signalStrengthRange);
    std::vector<Point> getCoordinates() const;
    std::vector<StructData> getAllData() const;
    void processingData (const double rcs, const double distance, const double azimuthBearning);
signals:
    void candidatePointsUpdated(const std::vector<Point>& points);
private:
    QSqlDatabase m_db;
    std::vector<Point> m_coordinates;
    std::vector <StructData> _allDataDb; // Добавлю структру повних даних з DB
    QString _dbName {qApp->applicationDirPath() + "/headDB.db"};
    QString tableName;
};

#endif // DATAFROMDB_H
