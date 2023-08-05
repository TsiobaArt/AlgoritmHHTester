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

    void sortedDataMathes(const std::vector<Match>& qmlMathes);

    std::pair<double, double> solveSystem(double x1, double y1, double d1, double x2, double y2, double d2, double x3, double y3, double d3) ;// розвязування системи рівнять за допомогою методу Крамера (для знаходження своиїх коорлинат ).


    std::pair<double, double> findMyLocation();

    std::vector<StructData> allDataDb;


signals:

};

#endif // FINDLOCATION_H
