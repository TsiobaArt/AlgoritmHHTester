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

      return {avgLat, avgLon};
    } else {
      return {0, 0}; // Return default coordinates if there aren't enough matches
    }
}


//std::pair<double, double> FindLocation::findMyLocation() {
//        qDebug () <<  "FindLocation_ allMatches.size(); "  << _allMatches.size();
//        if (_allMatches.size() >= 2) {
//            auto point1 = _allMatches[0];
//            auto point2 = _allMatches[1];
//            auto point3 = _allMatches[2];

//            QGeoCoordinate coord1(point1.cand_idx1_lat, point1.cand_idx1_lon);
//            QGeoCoordinate coord2(point2.cand_idx1_lat, point2.cand_idx1_lon);
//            QGeoCoordinate coord3(point3.cand_idx1_lat, point3.cand_idx1_lon);

//            double dist1 = point1.cand_idx1_Dist;
//            double dist2 = point2.cand_idx1_Dist;
//            double dist3 = point3.cand_idx1_Dist;

//            double azimuth1AzimuthBearing = point1.cand_idx1_AzimuthBearing;
//            double azimuth2AzimuthBearing = point2.cand_idx1_AzimuthBearing;
//            double azimuth3AzimuthBearing = point3.cand_idx1_AzimuthBearing;


//            double bearing1 = point1.cand_idx1_bearing;
//            double bearing2 = point2.cand_idx1_bearing;
//            double bearing3 = point3.cand_idx1_bearing;

//                // Get the new coordinates at the specified distance and azimuth
//                QGeoCoordinate newCoord1 = coord1.atDistanceAndAzimuth(dist1, azimuth1AzimuthBearing + bearing1);
//                QGeoCoordinate newCoord2 = coord2.atDistanceAndAzimuth(dist2, azimuth2AzimuthBearing + bearing2);
//                QGeoCoordinate newCoord3 = coord3.atDistanceAndAzimuth(dist3, azimuth3AzimuthBearing + bearing3);


//                    // Calculate the average latitude and longitude
//                    double avgLat = (newCoord1.latitude() + newCoord2.latitude() + newCoord3.latitude()) / 3.0;
//                    double avgLon = (newCoord1.longitude() + newCoord2.longitude() + newCoord3.longitude()) / 3.0;

////                    double avgLat = newCoord1.latitude() ;
////                    double avgLon = newCoord1.longitude() ;
//                    qDebug() <<  "avgLat " << avgLat;
//                    qDebug() <<  "avgLon " << avgLon;

//                    return {avgLat, avgLon};
//        } else {
//            return {0, 0}; // Return default coordinates if there aren't enough matches
//                }
//}


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


