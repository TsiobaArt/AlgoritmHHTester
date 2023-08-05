#ifndef FINDLOCATION_H
#define FINDLOCATION_H

#include <QObject>
#include <QVector>
#include <QPair>
#include <QDebug>
#include "StructData.h"
#include <QJsonObject>
#include <QVector>
#include <iostream>
#include <QGeoCoordinate>

class FindLocation : public QObject
{
    Q_OBJECT
public:
    explicit FindLocation(QObject *parent = nullptr);

    std::pair<double, double> sortedDataMatches(const std::vector<Match>& qmlMatches); // Функція отримує список співпадінь як аргумент

    std::pair<double, double> solveSystem(double x1, double y1, double d1, double x2, double y2, double d2, double x3, double y3, double d3);

    std::pair<double, double> findMyLocation();



    // Приватні дані
private:
    std::vector<Match> _allMatches; // Всі співпадіння

signals:

};

#endif // FINDLOCATION_H
