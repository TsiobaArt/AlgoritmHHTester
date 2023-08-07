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
//#include <eigen3/Eigen/Dense>
class FindLocation : public QObject
{
    Q_OBJECT
public:
    explicit FindLocation(QObject *parent = nullptr);

    std::pair<double, double> sortedDataMatches(const std::vector<Match>& qmlMatches); // Функція отримує список співпадінь як аргумент

    std::pair<double, double> solveSystem(double x1, double y1, double d1, double x2, double y2, double d2, double x3, double y3, double d3);

    std::pair<double, double> findMyLocation();

//    QGeoCoordinate trilateration(const std::vector<Match>& allMatches) ;

//    // Функція для перетворення географічних координат в плоскі
//    std::pair<double, double> latLonToXY(double lat, double lon, double lat0, double lon0) {
//        double x = (lon - lon0) * cos(lat0) * 111.32;
//        double y = (lat - lat0) * 110.574;
//        return {x, y};
//    }

//    // Функція для перетворення плоских координат назад в географічні
//    std::pair<double, double> xyToLatLon(double x, double y, double lat0, double lon0) {
//        double lat = y / 110.574 + lat0;
//        double lon = x / (cos(lat0) * 111.32) + lon0;
//        return {lat, lon};
//    }
    // Приватні дані
private:
    std::vector<Match> _allMatches; // Всі співпадіння

signals:

};

#endif // FINDLOCATION_H
