#include "findlocation.h"
#include <math.h>

FindLocation::FindLocation(QObject *parent)
    : QObject{parent}
{

}

void FindLocation::sortedDataMathes(const std::vector<Match> &qmlMathes)
{
//    allDataDb = dataFromDB->getAllData();
//    std::vector<Point> candidate;
//    std::set<int> uniqueIndexCandidate;

//    candidate.clear();
//    for (const Match& match : qmlMathes) {
//        uniqueIndexCandidate.insert(match.ref_idx1);
//        uniqueIndexCandidate.insert(match.ref_idx2);
//    }

//    for (const auto &value :uniqueIndexCandidate ) {
//        candidate.push_back(_candidate_points[value]);
//    }

//    std::vector<StructData> filteredDataDb;

//    for (const StructData& dataPoint : allDataDb) {
//        bool found = false;
//        for (const Point& candidatePoint : candidate) {
//            if (candidatePoint.lat == dataPoint.latitude && candidatePoint.lon == dataPoint.longitude) {
//                found = true;
//                break;
//            }
//        }
//        if (found) {
//            filteredDataDb.push_back(dataPoint);
//        }
//    }


//    //      for (const StructData& data : _allDataDb) {
//    //          qDebug() << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ start "  << data.latitude;
//    //          qDebug() <<"data.AzimuthBearing " << data.AzimuthBearing;
//    //          qDebug() <<"data.Distance " << data.Distance;
//    //          qDebug() <<"data.Rcs " << data.Rcs;
//    //          qDebug() <<"data.latitude " << data.latitude;
//    //          qDebug() <<"data.longitude " << data.longitude;
//    //          qDebug() << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ end "  ;

//    //      }

//    allDataDb = filteredDataDb;
//    findMyLocation();
}

std::pair<double, double> FindLocation::solveSystem(double x1, double y1, double d1, double x2,
                                                    double y2, double d2, double x3, double y3, double d3)
{
    double a1 = 2*(x2 - x1);
    double b1 = 2*(y2 - y1);
    double c1 = pow(d1, 2) - pow(d2, 2) - pow(x1, 2) + pow(x2, 2) - pow(y1, 2) + pow(y2, 2);

    double a2 = 2*(x3 - x1);
    double b2 = 2*(y3 - y1);
    double c2 = pow(d1, 2) - pow(d3, 2) - pow(x1, 2) + pow(x3, 2) - pow(y1, 2) + pow(y3, 2);

    double det = a1*b2 - a2*b1;
    double x = (b2*c1 - b1*c2) / det;
    double y = (a1*c2 - a2*c1) / det;

    qDebug () <<   "x longtitue:  " << x; // довгота
    qDebug () <<   "y latitude:  " << y; // широта

    return {x, y};
}

std::pair<double, double> FindLocation::findMyLocation()
{
    std::pair<double, double> coordinate;
    qDebug() << allDataDb.size();
    qDebug () << "allDataDb.size() " << allDataDb.size();
    if (allDataDb.size() > 2) {
        // Нам потрібно принаймні три точки для трілатерації
        qDebug () <<  " _allDataDb.size() < 2 ";

        // Використовуємо перші три точки в _allDataDb
        // Ви можете використовувати інші точки або всі комбінації трьох точок для більш точного результату
        auto point1 = allDataDb[0];
        auto point2 = allDataDb[1];
        auto point3 = allDataDb[2];

        qDebug () <<  " point1.Distance " <<  point1.Distance;
        qDebug () <<  " point2.Distance " <<  point2.Distance;
        qDebug () <<  " point3.Distance " <<  point3.Distance;


        // Обчислюємо наші координати
        auto coordinates = solveSystem(point1.latitude, point1.longitude, point1.Distance, point2.latitude, point2.longitude, point2.Distance, point3.latitude, point3.longitude, point3.Distance);

        // Повертаємо наше місцезнаходження
        double _latitudeCentalPoint = coordinates.first;
        double _longitudeCentalPoint = coordinates.second;
        qDebug() << "findMyLocation latitude " << _latitudeCentalPoint;
        qDebug() << "findMyLocation latitude " << _longitudeCentalPoint;
        coordinate.first = _latitudeCentalPoint;
        coordinate.second = _longitudeCentalPoint;
    }
    return coordinate;

}
