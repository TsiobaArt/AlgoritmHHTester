#include "findlocation.h"
#include <cmath>
#include <set>

FindLocation::FindLocation(QObject *parent) : QObject(parent)
{
}

std::pair<double, double> FindLocation::sortedDataMatches(const std::vector<Match>& qmlMatches)
{
//    std::set<size_t> uniqueIndexCandidate;
//    std::vector<Match> uniqueMatches;

//    for (const Match& match : qmlMatches) {
//        // Перевіряємо, чи є обидва індекси новими
//        if (uniqueIndexCandidate.count(match.ref_idx1) == 0 && uniqueIndexCandidate.count(match.ref_idx2) == 0) {
//            uniqueIndexCandidate.insert(match.ref_idx1);
//            uniqueIndexCandidate.insert(match.ref_idx2);
//            uniqueMatches.push_back(match);
//        }
//    }

//    _allMatches = uniqueMatches;

  _allMatches = qmlMatches;
    for (const Match& match : _allMatches) {
      qDebug() <<      "match cand_idx1_lat" << match.cand_idx1_lat;
      qDebug() <<      "match cand_idx1_lon" << match.cand_idx1_lon;
      qDebug() <<      "match cand_idx1_Dist" << match.cand_idx1_Dist;
      qDebug() <<      "match cand_idx1_bearing" << match.cand_idx1_bearing;
      qDebug() <<      "match cand_idx1_AzimuthBearing" << match.cand_idx1_AzimuthBearing;
}



    return findMyLocation();
}

std::pair<double, double> FindLocation::solveSystem(double x1, double y1, double d1, double x2, double y2, double d2, double x3, double y3, double d3)
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

    return {x, y};
}


//std::pair<double, double> FindLocation::findMyLocation()
//{
//    qDebug () <<  "FindLocation_ allMatches.size(); "  << _allMatches.size();
////    if (_allMatches.size() >= 2) {
//        auto point1 = _allMatches[0];
//        auto point2 = _allMatches[1];
//        auto point3 = _allMatches[2];

////        //   ----  тест вручну
////        QGeoCoordinate coordCentr;
////        coordCentr.setLatitude(48.484095);
////        coordCentr.setLongitude(24.466879);

////        QGeoCoordinate coord1;
////        coord1.setLatitude(48.52014269118956);
////        coord1.setLongitude(24.4611438434119);

////        QGeoCoordinate coord2;
////        coord2.setLatitude(48.50626180537989);
////        coord2.setLongitude(24.4771927081015);

////        QGeoCoordinate coord3;
////        coord3.setLatitude(48.502215407637294);
////        coord3.setLongitude(24.4723471243014);


////        double dist1 = coordCentr.distanceTo(coord1);
////        double dist2 = coordCentr.distanceTo(coord2);
////        double dist3 = coordCentr.distanceTo(coord3);


////        qDebug ()  << "FindLocation::findMyLocation() dist1 " << dist1;
////        qDebug ()  << "FindLocation::findMyLocation() dist2 " << dist2;
////        qDebug ()  << "FindLocation::findMyLocation() dist3 " << dist3;


////        qDebug ()  << "FindLocation::findMyLocation() coordCentr lat " << coordCentr.latitude() << " lon " << coordCentr.longitude();
////        qDebug ()  << "FindLocation::findMyLocation() coord1 lat " << coord1.latitude() << " lon " << coord1.longitude();
////        qDebug ()  << "FindLocation::findMyLocation() coord2 lat " << coord2.latitude() << " lon " << coord2.longitude();
////        qDebug ()  << "FindLocation::findMyLocation() coord2 lat " << coord3.latitude() << " lon " << coord3.longitude();




////        auto coordinates = solveSystem(coord1.latitude(), coord1.longitude(), dist1,
////                                       coord2.latitude(), coord2.longitude(), dist2,
////                                       coord3.latitude(), coord3.longitude(), dist3);

////        //   ----  тест вручну



//        qDebug () << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ " << point1.cand_idx1_AzimuthBearing;
//        auto coordinates = solveSystem(point1.cand_idx1_lat, point1.cand_idx1_lon, point1.cand_idx1_Dist,
//                                       point2.cand_idx1_lat, point2.cand_idx1_lon, point2.cand_idx1_Dist,
//                                       point3.cand_idx1_lat, point3.cand_idx1_lon, point3.cand_idx1_Dist);


//        return coordinates;
////    } else {
////        return {0, 0}; // Return default coordinates if there aren't enough matches
//        //    }
//}
std::pair<double, double> FindLocation::findMyLocation() {
    qDebug () <<  "FindLocation_ allMatches.size(); "  << _allMatches.size();
    if (_allMatches.size() >= 2) {
      double totalLat = 0.0;
      double totalLon = 0.0;

      for (auto& point : _allMatches) {
          QGeoCoordinate coord(point.cand_idx1_lat, point.cand_idx1_lon);
          double dist = point.cand_idx1_Dist;
          double azimuthAzimuthBearing = point.cand_idx1_AzimuthBearing;
          double bearing = point.cand_idx1_bearing;


          double sumAzimuth = azimuthAzimuthBearing + bearing;
          double reverseAzimuth = sumAzimuth + 180.0;
          if (reverseAzimuth >= 360.0) {
              reverseAzimuth -= 360.0;
          }

          // Get the new coordinates at the specified distance and azimuth
          QGeoCoordinate newCoord = coord.atDistanceAndAzimuth(dist, reverseAzimuth);

          // Accumulate latitudes and longitudes
          totalLat += newCoord.latitude();
          totalLon += newCoord.longitude();

      }



      // Calculate the average latitude and longitude
      double avgLat = totalLat / _allMatches.size();
      double avgLon = totalLon / _allMatches.size();

      qDebug() <<  "avgLat " << avgLat;
      qDebug() <<  "avgLon " << avgLon;

      QGeoCoordinate geoTrilateration ;

      geoTrilateration = trilateration(_allMatches);

      qDebug() <<  "avgLat geoTrilateration latitude" << geoTrilateration.latitude();
      qDebug() <<  "avgLon geoTrilateration longitude " << geoTrilateration.longitude();


      return {avgLat, avgLon};
    } else {
      return {0, 0}; // Return default coordinates if there aren't enough matches
    }
}

//QGeoCoordinate FindLocation::trilateration(const std::vector<Match>& allMatches)
//{
//    int n = allMatches.size();

//    if (n < 3) {
//      std::cerr << "Need at least 3 matches." << std::endl;
//      return QGeoCoordinate();
//    }

//    Eigen::MatrixXd A(n, 2);
//    Eigen::VectorXd b(n);

//    for (int i = 0; i < n; i++) {
//      double lat = allMatches[i].cand_idx1_lat - allMatches[0].cand_idx1_lat;
//      double lon = allMatches[i].cand_idx1_lon - allMatches[0].cand_idx1_lon;

//      qDebug() <<  "trilateriation lat " << allMatches[i].cand_idx1_lat ;
//      qDebug() <<  "trilateriation lon " << lon;
//      qDebug()<<  "dist " << allMatches[i].cand_idx1_Dist;

//      A(i, 0) = 2 * lat;
//      A(i, 1) = 2 * lon;
//      b(i) = std::pow(allMatches[0].cand_idx1_Dist, 2) - std::pow(allMatches[i].cand_idx1_Dist, 2) - lat * lat - lon * lon;
//    }

//    Eigen::Vector2d solution = A.colPivHouseholderQr().solve(b);

//    double latitude = solution(0) + allMatches[0].cand_idx1_lat;
//    double longitude = solution(1) + allMatches[0].cand_idx1_lon;

//    return QGeoCoordinate(latitude, longitude);
//}
//QGeoCoordinate FindLocation::trilateration(const std::vector<Match>& allMatches)
//{
//    int n = allMatches.size();

//    if (n < 3) {
//      std::cerr << "Need at least 3 matches." << std::endl;
//      return QGeoCoordinate();
//    }

//    Eigen::MatrixXd A(n, 2);
//    Eigen::VectorXd b(n);

//    double lat0 = allMatches[0].cand_idx1_lat * M_PI / 180.0;
//    double lon0 = allMatches[0].cand_idx1_lon * M_PI / 180.0;
//    double R = 6371000; // Радіус Землі в метрах

//    for (int i = 0; i < n; i++) {
//      double lat = (allMatches[i].cand_idx1_lat - allMatches[0].cand_idx1_lat) * M_PI / 180.0;
//      double lon = (allMatches[i].cand_idx1_lon - allMatches[0].cand_idx1_lon) * M_PI / 180.0;

//      double x = R * cos(lat) * cos(lon) - R * cos(lat0) * cos(lon0);
//      double y = R * cos(lat) * sin(lon) - R * cos(lat0) * sin(lon0);

//      A(i, 0) = 2 * x;
//      A(i, 1) = 2 * y;
//      b(i) = std::pow(allMatches[0].cand_idx1_Dist, 2) - std::pow(allMatches[i].cand_idx1_Dist, 2) - x * x - y * y;
//    }

//    Eigen::Vector2d solution = A.colPivHouseholderQr().solve(b);

//    // Перетворюємо рішення назад у географічні координати
//    double x = solution(0);
//    double y = solution(1);

//    double latRad = asin(y / sqrt(x * x + y * y + R * R));
//    double lonRad = atan2(y, x);

//    double latitude = latRad * 180.0 / M_PI + allMatches[0].cand_idx1_lat;
//    double longitude = lonRad * 180.0 / M_PI + allMatches[0].cand_idx1_lon;

//    return QGeoCoordinate(latitude, longitude);
//}
QGeoCoordinate FindLocation::trilateration(const std::vector<Match>& allMatches) {
    int n = allMatches.size();

    if (n < 3) {
      std::cerr << "Need at least 3 matches." << std::endl;
      return QGeoCoordinate();
    }

    double lat0 = allMatches[0].cand_idx1_lat;
    double lon0 = allMatches[0].cand_idx1_lon;

    Eigen::MatrixXd A(n, 2);
    Eigen::VectorXd b(n);

    qDebug() << "Initial latitude: " << lat0;
    qDebug() << "Initial longitude: " << lon0;

    for (int i = 0; i < n; i++) {
      double lati = allMatches[i].cand_idx1_lat;
      double loni = allMatches[i].cand_idx1_lon;

      // Перетворюємо географічні координати у плоскі
      auto [xi, yi] = latLonToXY(lati, loni, lat0, lon0);
      auto [x0, y0] = latLonToXY(lat0, lon0, lat0, lon0);

      qDebug() << "Converted coordinates " << i << ": x=" << xi << " y=" << yi;

      double di = std::sqrt(std::pow(xi - x0, 2) + std::pow(yi - y0, 2));

      A(i, 0) = 2 * (xi - x0);
      A(i, 1) = 2 * (yi - y0);
      b(i) = std::pow(allMatches[0].cand_idx1_Dist, 2) - std::pow(allMatches[i].cand_idx1_Dist, 2) + std::pow(di, 2);
    }

    std::cout << "Matrix A:\n" << A << std::endl;
    std::cout << "Vector b:\n" << b << std::endl;


    Eigen::Vector2d solution = A.colPivHouseholderQr().solve(b);

    double x = solution(0);
    double y = solution(1);

    qDebug() << "Solution x: " << x;
    qDebug() << "Solution y: " << y;

    // Перетворюємо плоскі координати назад у географічні
    auto [latitude, longitude] = xyToLatLon(x, y, lat0, lon0);

    qDebug() << "Final latitude: " << latitude;
    qDebug() << "Final longitude: " << longitude;

    return QGeoCoordinate(latitude, longitude);
}

//std::pair<double, double> FindLocation::findMyLocation()
//{
//    // Set coordinates manually
//    QGeoCoordinate coord1(48.52014269118956, 24.4611438434119);
//    QGeoCoordinate coord2(48.50626180537989, 24.4771927081015);
//    QGeoCoordinate coord3(48.502215407637294, 24.4723471243014);

//    // Set center coordinate manually
//    QGeoCoordinate coordCentr(48.4841690063477, 24.4669399261475);

//    // Compute distances from the center to each point (in meters)
//    double dist1 = coord1.distanceTo(coordCentr);
//    double dist2 = coord2.distanceTo(coordCentr);
//    double dist3 = coord3.distanceTo(coordCentr);

//    // Calculate the azimuth to each point
//    double azimuth1 = coord1.azimuthTo(coordCentr);
//    double azimuth2 = coord2.azimuthTo(coordCentr);
//    double azimuth3 = coord3.azimuthTo(coordCentr);

//    double azimuth11 = coordCentr.azimuthTo(coord1);
//    double azimuth22 = coordCentr.azimuthTo(coord2);
//    double azimuth33 = coordCentr.azimuthTo(coord3);

//    qDebug () << "azimuth1 " << azimuth1;
//    qDebug () << "azimuth2 " << azimuth2;
//    qDebug () << "azimuth3 " << azimuth3;


//    qDebug () << "azimuth11 " << azimuth11;
//    qDebug () << "azimuth22 " << azimuth22;
//    qDebug () << "azimuth33 " << azimuth33;

//    // Get the new coordinates at the specified distance and azimuth
//    QGeoCoordinate newCoord1 = coord1.atDistanceAndAzimuth(dist1, azimuth1);
//    QGeoCoordinate newCoord2 = coord2.atDistanceAndAzimuth(dist2, azimuth2);
//    QGeoCoordinate newCoord3 = coord3.atDistanceAndAzimuth(dist3, azimuth3);

//    // Calculate the average latitude and longitude
//    double avgLat = (newCoord1.latitude() + newCoord2.latitude() + newCoord3.latitude()) / 3.0;
//    double avgLon = (newCoord1.longitude() + newCoord2.longitude() + newCoord3.longitude()) / 3.0;

////    double avgLat = newCoord1.latitude() ;
////    double avgLon = newCoord1.longitude() ;
//    qDebug() <<  "avgLat " << avgLat;
//    qDebug() <<  "avgLon " << avgLon;

//    return {avgLat, avgLon};
//}

