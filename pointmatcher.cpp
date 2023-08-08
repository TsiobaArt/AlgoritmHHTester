#include "pointmatcher.h"


bool operator<(const Match &m1, const Match &m2) {
    return m1.distance_diff + m1.angle_diff < m2.distance_diff + m2.angle_diff;
}


PointMatcher::PointMatcher(QObject *parent) : QObject(parent)
{
    dataFromDB  =   new DataFromDB(this);
//    dataFromDB->loadData("session_14_06_07_33",10,10);
//    for (const Point& point : dataFromDB->getCoordinates()) {
//          qDebug() << "Latitude:" << point.lat << "Longitude:" << point.lon;
//      }//    _candidate_points = dataFromDB->getCoordinates();
//    setCandidatePoints( dataFromDB->getCoordinates());

    QObject::connect(dataFromDB, &DataFromDB::sendCoordinateScan, this, &PointMatcher::getCentalPointCoordinate);

}

void PointMatcher::setReferencePoints(const std::vector<Point>& points) {
    _reference_points = points;
}

void PointMatcher::setCandidatePoints(const std::vector<Point>& points) {
    _candidate_points = points;
}


QVariantList PointMatcher::getReferencePoints() const {
    return _convertPointsToQVariantList(_reference_points);
}

QVariantList PointMatcher::getCandidatePoints() const {
    return _convertPointsToQVariantList(_candidate_points);
}



QVariantList PointMatcher::findMatches(double distance_threshold, double angle_threshold, double grad_threshold) {
    std::vector<Match> matches;
    QElapsedTimer timer ;
    timer.start();

    QList<QFuture<void>> futures;
    for (size_t i = 0; i < _reference_points.size(); ++i) {
        for (size_t j = i + 1; j < _reference_points.size(); ++j) {
            futures.append(QtConcurrent::run([this, i, j, distance_threshold, angle_threshold, &matches]() {
                _comparePoints(i, j, distance_threshold, angle_threshold, matches);
            }));
        }
    }

    // очікуємо завершення
    for (auto &future : futures) {
        future.waitForFinished();
    }

    std::vector<Match> best_matches = _selectBestMatches(matches, grad_threshold);
    std::map<size_t, std::vector<std::pair<size_t, Point>>> grouped_matches = _groupMatches(best_matches);

    QVariantList qmlMatches;

    // -------------- Тестую знаходження позиції
    FindLocation locationFinder;
    std::pair<double, double> locationPair;
    locationPair = locationFinder.sortedDataMatches(best_matches);
    qDebug () << "LOCATION  latitude  :" << locationPair.first;
    qDebug () << "LOCATION  longitude :" << locationPair.second;

     _latitudeCentalPoint = locationPair.first;
     _longitudeCentalPoint = locationPair.second;

    // -------------- Тестую знаходження позиції

    for (const Match &match : best_matches  /*matches*/) {
        QVariantMap qmlMatch;

        qmlMatch.insert("ref_idx1", QVariant(static_cast<qint64>(match.ref_idx1))); // варінат для лінкуса це більше для qml
        qmlMatch.insert("ref_idx2", QVariant(static_cast<qint64>(match.ref_idx2)));
        qmlMatch.insert("cand_idx1", QVariant(static_cast<qint64>(match.cand_idx1)));
        qmlMatch.insert("cand_idx2", QVariant(static_cast<qint64>(match.cand_idx2)));



        qmlMatch.insert("distance_diff", match.distance_diff);
        qmlMatch.insert("angle_diff", match.angle_diff);
        qmlMatches.push_back(qmlMatch);

    }
    return qmlMatches;
}

QVariantList PointMatcher::findMatchesAllMode(double distance_threshold, double angle_threshold)
{
    std::vector<Match> matches;
    QElapsedTimer timer ;
    timer.start();

    QList<QFuture<void>> futures;
    for (size_t i = 0; i < _reference_points.size(); ++i) {
        for (size_t j = i + 1; j < _reference_points.size(); ++j) {
            futures.append(QtConcurrent::run([this, i, j, distance_threshold, angle_threshold, &matches]() {
                _comparePoints(i, j, distance_threshold, angle_threshold, matches);
            }));
        }
    }

    for (auto &future : futures) {
        future.waitForFinished();
    }


    std::map<size_t, std::vector<std::pair<size_t, Point>>> grouped_matches = _groupMatches(matches);
    QVariantList qmlMatches;
    for (const Match &match : /*best_matches*/  matches) {
        QVariantMap qmlMatch;

        qmlMatch.insert("ref_idx1", QVariant(static_cast<qint64>(match.ref_idx1))); // варінат для лінкуса це більше для qml
        qmlMatch.insert("ref_idx2", QVariant(static_cast<qint64>(match.ref_idx2)));
        qmlMatch.insert("cand_idx1", QVariant(static_cast<qint64>(match.cand_idx1)));
        qmlMatch.insert("cand_idx2", QVariant(static_cast<qint64>(match.cand_idx2)));

        qmlMatch.insert("distance_diff", match.distance_diff);
        qmlMatch.insert("angle_diff", match.angle_diff);
        qmlMatches.push_back(qmlMatch);

    }

    return qmlMatches;
}


void PointMatcher::downloadCompletedTest()
{
    setReferencePoints(reference_pointsTest);
    setCandidatePoints(candidate_pointsTest);
}

void PointMatcher::downloadRandomTest(const int countShiftedPoint, const int countReferencePoint, const int countCandidatePoint,
                                      const double minLat, const double maxLat, const double minLon, const double maxLon, const double rangeShift)
{

//    const double minLatRef = 50.2623;
//    const double maxLatRef = 50.2629;
//    const double minLonRef = 30.2560;
//    const double maxLonRef = 30.2571;
    const double minLatRef = 50.2623;
    const double maxLatRef = 50.2624;
    const double minLonRef = 30.2561;
    const double maxLonRef = 30.2562;


    std::vector<Point> reference_points = generateRandomPoints(countReferencePoint, minLatRef, maxLatRef, minLonRef, maxLonRef);

        std::vector<Point> all_candidate_points;

//        // Зміщення точок по нарастаючій
//        for (int i = 0; i < countShiftedPoint; i++) {
//            double lat_shift = rangeShift * (i + rangeShift*50); // Змінюємо значення зміщення для кожного набору
//            double lon_shift = rangeShift * (i + rangeShift*50);

//            std::vector<Point> shifted_points = createShiftedPoints(reference_points, lat_shift, lon_shift);
//            all_candidate_points.insert(all_candidate_points.end(), shifted_points.begin(), shifted_points.end());
//        }

        // довільне зміщення а не по прямій лінії
        std::random_device rd; //
          std::mt19937 gen(rd());
          std::uniform_real_distribution<> dis(-rangeShift, rangeShift); // генерує випадкові числа в діапазоні

          for (int i = 0; i < countShiftedPoint; i++) {
              double lat_shift = dis(gen); // Випадкове зміщення в діапазоні [-rangeShift, rangeShift]
              double lon_shift = dis(gen); // Випадкове зміщення в діапазоні [-rangeShift, rangeShift]

              std::vector<Point> shifted_points = createShiftedPoints(reference_points, lat_shift, lon_shift);
              all_candidate_points.insert(all_candidate_points.end(), shifted_points.begin(), shifted_points.end());
          }
        // Генерація випадкових точок
        std::vector<Point> random_points = generateRandomPoints(countCandidatePoint, minLat, maxLat, minLon, maxLon);
        all_candidate_points.insert(all_candidate_points.end(), random_points.begin(), random_points.end());

        _reference_points = reference_points;
        _candidate_points = all_candidate_points;

}

void PointMatcher:: convertQVariantListToPoints(const QVariantList &qmlPoints)
{
    std::vector<Point> points;
    for (const QVariant &variant : qmlPoints) {
        QVariantMap qmlPoint = variant.toMap();
        Point point;
        point.lat = qmlPoint["lat"].toDouble();
        point.lon = qmlPoint["lon"].toDouble();
        points.push_back(point);
    }

     std::vector<Point> point2;
    _reference_points = points;

}

void PointMatcher::addReferencePoint(double lat, double lon)
{
    Point newPoint;
    newPoint.lat = lat;
    newPoint.lon = lon;

    _reference_points.push_back(newPoint);
}

void PointMatcher::addCandidatePoint(double lat, double lon)
{
    Point newPoint;
    newPoint.lat = lat;
    newPoint.lon = lon;

    _candidate_points.push_back(newPoint);
}

void PointMatcher::removeReferencePoint(int index)
{
    if (index >= 0 && index < _reference_points.size()) {
         _reference_points.erase(_reference_points.begin() + index);
     }
}

void PointMatcher::removeCandidatePoint(int index)
{
    if (index >= 0 && index < _candidate_points.size()) {
        _candidate_points.erase(_candidate_points.begin() + index);
    }
}

void PointMatcher::updateReferencePoint(int index, double lat, double lon)
{
    if (index >= 0 && index < _reference_points.size()) {
        _reference_points[index].lat = lat;
        _reference_points[index].lon = lon;
    }
}

void PointMatcher::updateCandidatePoint(int index, double lat, double lon)
{
    if (index >= 0 && index < _candidate_points.size()) {
        _candidate_points[index].lat = lat;
        _candidate_points[index].lon = lon;
    }
}

void PointMatcher::setRcsAndSignalStrength(const double signalStrength, const double rcs)
{
    _rcs = rcs;
    _signalStrength = signalStrength;
}

void PointMatcher::downloadDataBaseTest(const double signalStrength, const double rcs, const QString nameTable, const int tickNumber )
{

//    _reference_points.clear();
//    QString nameTable2 = "session_26_07_15_48_45"; //
//    dataFromDB->loadData(nameTable2,rcs,signalStrength, tickNumber); // для швидкого тесту

    dataFromDB->loadData(nameTable,rcs,signalStrength, tickNumber);
    _candidate_points = dataFromDB->getCoordinates();
    mapTicAndId = dataFromDB->dataTicAndId;


//    // ------- первірка даних  про тіки та id
//        QVariantMap::const_iterator i;
//        for (i = mapTicAndId.constBegin(); i != mapTicAndId.constEnd(); ++i) {
//            qDebug() << "Key: " << i.key() << ", Value: " << i.value();
//        }
//   // ------- первірка даних  про тіки та id

    // перевірка даних по приходу з бази дани
//    for (auto &value : _candidate_points ) {
//        qDebug() << "start";
//            qDebug() <<  " перевірка db dist"  <<value.dist;
//            qDebug() <<  " перевірка db Rcs"  <<value.Rcs;
//            qDebug() <<  " перевірка db lat"  <<value.lat;
//        qDebug() << "end";



//    }
//    // перевірка даних по приходу з бази дани

}

void PointMatcher::downloadDBTecAndId(const QString nameTable)
{
//    QString nameTable2 = "session_26_07_15_48_45"; // для швидкого тесту
//    mapTicAndId = dataFromDB->readTicCountAndId(nameTable2);

    mapTicAndId = dataFromDB->readTicCountAndId(nameTable);

}


void PointMatcher::processingDataDB(const double rcs, const double distance, const double azimuthBearning)
{

    dataFromDB->processingData(rcs, distance, azimuthBearning);
    _candidate_points = dataFromDB->getCoordinates();

}
double PointMatcher::longitudeCentalPoint() const
{
    return _longitudeCentalPoint;
}

QGeoCoordinate PointMatcher::getCoordinateScan()
{
    return coordinateScan;
}

QVariantMap PointMatcher::getMapTicAndId()
{
    return mapTicAndId;
}


double PointMatcher::latitudeCentalPoint() const
{
    return _latitudeCentalPoint;
}

std::vector<Point> PointMatcher::generateRandomPoints(int count, double min_lat, double max_lat, double min_lon, double max_lon)
{
    std::vector<Point> random_points;
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> lat_dis(min_lat, max_lat); // генерує випадкові числа в діапазоні (в документації сказано щ розподіл по функції щільності(густині) імовірності )
    std::uniform_real_distribution<> lon_dis(min_lon, max_lon);

    for (int i = 0; i < count; i++) {
        random_points.push_back({lat_dis(gen), lon_dis(gen)});
    }

    return random_points;
}

std::vector<Point> PointMatcher::createShiftedPoints(const std::vector<Point> &reference_points, double lat_shift, double lon_shift)
{
    std::vector<Point> shifted_points;
    for (const Point& point : reference_points) {
        shifted_points.push_back({point.lat + lat_shift, point.lon + lon_shift});
    }
    return shifted_points;
}


//void PointMatcher::_comparePoints(size_t i, size_t j, double distance_threshold, double angle_threshold, std::vector<Match>& matches) { // тепер приймає в градусах але в декартовій системі координат

//    double ref_dist = _haversineDistance(_reference_points[i], _reference_points[j]);
//    double ref_angle = _angle(_reference_points[i], _reference_points[j]);

//    for (auto &value : _candidate_points) {
//        qDebug() << " Перевірка даних value.Rcs" <<  value.Rcs;
//        qDebug() << " Перевірка даних value.dist" <<  value.dist;
//        qDebug() << " Перевірка даних value.lat" <<  value.lat;


//    }

//    for (size_t k = 0; k < _candidate_points.size(); ++k) {
//        for (size_t l = 0; l < _candidate_points.size(); ++l) {
//            if (k == l) continue; // Пропускаємо однакові точки

//            double cand_dist = _haversineDistance(_candidate_points[k], _candidate_points[l]);
//            double cand_angle = _angle(_candidate_points[k], _candidate_points[l]);


//            if (std::abs(ref_dist - cand_dist) <= distance_threshold &&
//                    std::abs(ref_angle - cand_angle) <= angle_threshold) {


//                Match match = {i, j, k, l, std::abs(ref_dist - cand_dist), std::abs(ref_angle - cand_angle)};
//                {
//                    QMutexLocker locker(&_matches_mutex);
//                    matches.push_back(match);
//                }
//            }
//        }
//    }
//}

void PointMatcher::_comparePoints(size_t i, size_t j, double distance_threshold, double angle_threshold, std::vector<Match>& matches) { // заповнюю зразу всі поля

    double ref_dist = _haversineDistance(_reference_points[i], _reference_points[j]);
    double ref_angle = _angle(_reference_points[i], _reference_points[j]);

//    for (auto &value : _candidate_points) {
//        qDebug() << " Перевірка даних value.Rcs" <<  value.Rcs;
//                qDebug() << " Перевірка даних value.dist" <<  value.dist;
//            qDebug() << " Перевірка даних value.lat" <<  value.lat;
//    }

    for (size_t k = 0; k < _candidate_points.size(); ++k) {
        for (size_t l = 0; l < _candidate_points.size(); ++l) {
              if (k == l) continue; // Пропускаємо однакові точки

              double cand_dist = _haversineDistance(_candidate_points[k], _candidate_points[l]);
              double cand_angle = _angle(_candidate_points[k], _candidate_points[l]);


              if (std::abs(ref_dist - cand_dist) <= distance_threshold &&
                  std::abs(ref_angle - cand_angle) <= angle_threshold) {

                  Match match;
                  match.ref_idx1 = i;
                  match.ref_idx2 = j;
                  match.cand_idx1 = k;
                  match.cand_idx2 = l;
                  match.distance_diff = std::abs(ref_dist - cand_dist);
                  match.angle_diff = std::abs(ref_angle - cand_angle);


                  match.cand_idx1_lat = _candidate_points[k].lat;
                  match.cand_idx1_lon = _candidate_points[k].lon;
                  match.cand_idx1_Dist = _candidate_points[k].dist;
                  match.cand_idx1_AzimuthBearing = _candidate_points[k].AzimuthBearing;
                  match.cand_idx1_Rcs = _candidate_points[k].Rcs;
                  match.cand_idx1_bearing = _candidate_points[k].bearing;



                  match.cand_idx2_lat = _candidate_points[l].lat;
                  match.cand_idx2_lon = _candidate_points[l].lon;
                  match.cand_idx2_Dist = _candidate_points[l].dist;
                  match.cand_idx2_AzimuthBearing = _candidate_points[l].AzimuthBearing;
                  match.cand_idx2_Rcs = _candidate_points[l].Rcs;
                  match.cand_idx2_bearing = _candidate_points[l].bearing;

                  match.ref_idx1_lat = _reference_points[i].lat;
                  match.ref_idx1_lot = _reference_points[i].lon;

                  match.ref_idx2_lat = _reference_points[j].lat;
                  match.ref_idx2_lot = _reference_points[j].lon;

                  {
                      QMutexLocker locker(&_matches_mutex);
                      matches.push_back(match);
                  }
              }

        }
    }
}

double PointMatcher::_haversineDistance(const Point &p1, const Point &p2) const {
    const double R = 6371.0;
    double dLat = (p2.lat - p1.lat) * M_PI / 180.0;
    double dLon = (p2.lon - p1.lon) * M_PI / 180.0;

    double a = std::sin(dLat / 2) * std::sin(dLat / 2) +
               std::cos(p1.lat * M_PI / 180.0) * std::cos(p2.lat * M_PI / 180.0) *
               std::sin(dLon / 2) * std::sin(dLon / 2);

    double c = 2 * std::atan2(std::sqrt(a), std::sqrt(1 - a));
    return R * c;
}

std::vector<double> PointMatcher::_normalizeDistances(const std::vector<double> &distances) const
{
    double min_distance = *std::min_element(distances.begin(), distances.end());
     double max_distance = *std::max_element(distances.begin(), distances.end());

     std::vector<double> normalized_distances(distances.size());

     for (size_t i = 0; i < distances.size(); ++i) {
         normalized_distances[i] = (distances[i] - min_distance) / (max_distance - min_distance);
     }

     return normalized_distances;
}

double PointMatcher::_angle(const Point &p1, const Point &p2) const { //  значення в радіанах повертається
//    return std::atan2(p2.lat - p1.lat, p2.lon - p1.lon); //  радіани
    double rad = std::atan2(p2.lat - p1.lat, p2.lon - p1.lon); // градуси
    return _radiansToDegrees(rad); //  градуси
}

double PointMatcher::_azimuth(const Point& p1, const Point& p2) const { //  значення в градусах повертається
    double dLon = (p2.lon - p1.lon) * M_PI / 180.0;
    double lat1_rad = p1.lat * M_PI / 180.0;
    double lat2_rad = p2.lat * M_PI / 180.0;

    double y = std::sin(dLon) * std::cos(lat2_rad);
    double x = std::cos(lat1_rad) * std::sin(lat2_rad) - std::sin(lat1_rad) * std::cos(lat2_rad) * std::cos(dLon);
    double azi_rad = std::atan2(y, x);

    double azi_deg = azi_rad * 180.0 / M_PI;
    if (azi_deg < 0.0) {
        azi_deg += 360.0;
    }
    return azi_deg;
}


double PointMatcher::_azimuthDifference(double az1, double az2) const { //  значення в градусах повертається
    double diff = std::abs(az1 - az2);
    if (diff > 180.0) {
        diff = 360.0 - diff;
    }
    return diff;
}

QVariantList PointMatcher::_convertPointsToQVariantList(const std::vector<Point>& points) const {
    QVariantList qmlPoints;
    for (const Point &point : points) {
        QVariantMap qmlPoint;
        qmlPoint.insert("lat", point.lat);
        qmlPoint.insert("lon", point.lon);
        qmlPoints.push_back(qmlPoint);
    }
    return qmlPoints;
}

//std::vector<Match> PointMatcher::_selectBestMatches(const std::vector<Match>& matches, const double grad_threshold) { // групувань та фільрацій кандидатів з якимось параметрами

//    std::map<std::pair<size_t, size_t>, Match> best_matches_map;

//    for (const Match& match : matches) {
//        std::pair<size_t, size_t> ref_pair(match.ref_idx1, match.ref_idx2);
//        auto it = best_matches_map.find(ref_pair);

//        if (it == best_matches_map.end() || match.distance_diff + match.angle_diff < it->second.distance_diff + it->second.angle_diff) {
//            best_matches_map[ref_pair] = match;
//        }
//    }

//    std::vector<Match> best_matches;
//    for (const auto& [_, match] : best_matches_map) { // [_, match] ++17 довзволяє пропускати ключ і ідти тільки по значенням
//        best_matches.push_back(match);
//    }

//    double radius_multiplier = 1.9; // збільшення радіуса на 90%
//    std::vector<Match> filtered_matches = _filterCandidatesByRadius(best_matches, _reference_points, radius_multiplier);

//    std::vector<Match> filtered_matchedDegree = _filterCandidatesByDegree(filtered_matches, grad_threshold); // додав фільтрацію по градусній мірі
////    std::vector<Match> filtered_matchedDegree = _filterCandidatesByDegree(best_matches, grad_threshold); // додав фільтрацію по градусній мірі



//    // - - - - - - - - - - - - - - - - - - - - - - - - - -

//    for(const Match& match : filtered_matchedDegree) {
//        qDebug() << "ref_idx1: " << match.ref_idx1 ;
//        qDebug() << "ref_idx2: " << match.ref_idx2 ;
//        qDebug() << "cand_idx1: " << match.cand_idx1;
//        qDebug() << "cand_idx2: " << match.cand_idx2 ;
//        qDebug() << "distance_diff: " << match.distance_diff ;
//        qDebug() << "angle_diff: " << match.angle_diff;
//    }


//    std::map<size_t, int> ref_idx1_counts;
//    for(const Match& match : filtered_matchedDegree) {
//        ref_idx1_counts[match.ref_idx1]++;
//    }

//    for(const auto& pair : ref_idx1_counts) {
//        if(pair.second > 1) {
//            qDebug() << "ref_idx1: " << pair.first << " repeats " << pair.second << " times.";
//        }
//    }

//    // - - - - - - - - - - - - - - - - - - - - - - - - - -


////    return filtered_matches;
//    return filtered_matchedDegree;

//}

std::vector<Match> PointMatcher::_selectBestMatches(const std::vector<Match>& matches, const double grad_threshold) {

    std::map<size_t, Match> best_matches_map;

    for (const Match& match : matches) {
        auto it = best_matches_map.find(match.ref_idx1);

        if (it == best_matches_map.end() || match.distance_diff + match.angle_diff < it->second.distance_diff + it->second.angle_diff) { // філтрація по різниці сум дистанці та кута
            best_matches_map[match.ref_idx1] = match;
        }
//        if (it == best_matches_map.end() || match.distance_diff < it->second.distance_diff) { // тільки по дистанції
//            best_matches_map[match.ref_idx1] = match;
//        }
    }

    std::vector<Match> best_matches;
    for (const auto& [_, match] : best_matches_map) {
        best_matches.push_back(match);
    }

    double radius_multiplier = 1.9;


    std::vector<Match> filtered_matches = _filterCandidatesByRadius(best_matches, _reference_points, radius_multiplier);

    std::vector<Match> filtered_matchedDegree = _filterCandidatesByDegree(filtered_matches, grad_threshold);

    std::map<size_t, int> ref_idx1_counts;
    for(const Match& match : filtered_matchedDegree) {
        ref_idx1_counts[match.ref_idx1]++;
    }

    for(const auto& pair : ref_idx1_counts) {
        if(pair.second > 1) {
            qDebug() << "ref_idx1: " << pair.first << " repeats " << pair.second << " times.";
        }
    }
    // ------  фільтрація даних  щоб знайти найкращі спавпадіння якщо до однієї  точки привзяані декілтка

    return filtered_matchedDegree;


}
Point PointMatcher::_computeCentroid(const std::vector<Point>& points) const {
    double sum_lat = 0;
    double sum_lon = 0;
    size_t count = points.size();

    for (const Point& p : points) {
        sum_lat += p.lat;
        sum_lon += p.lon;
    }

    return {sum_lat / count, sum_lon / count};
}

std::vector<Match> PointMatcher::_filterCandidatesByRadius(const std::vector<Match>& matches, const std::vector<Point>& ref_points, double radius_multiplier) {
    Point centroid = _computeCentroid(ref_points);
    double ref_radius = _calculateRadius(ref_points);

    // Знаходимо найближчого кандидата до центроїда
    double min_distance = std::numeric_limits<double>::max();
    Point closest_candidate;
    for (const Match& match : matches) {
        Point candidate = _candidate_points[match.cand_idx1];
        double distance = _haversineDistance(centroid, candidate);
        if (distance < min_distance) {
            min_distance = distance;
            closest_candidate = candidate;
        }
    }
    // Збільшуємо радіус, множачи його на множник
    double enlarged_radius = ref_radius * radius_multiplier;

    // Відсіюємо точки, які знаходяться поза збільшеним радіусом
    std::vector<Match> filtered_matches;
    for (const Match& match : matches) {
        Point candidate = _candidate_points[match.cand_idx1];
        double distance = _haversineDistance(closest_candidate, candidate);
        if (distance <= enlarged_radius) {
            filtered_matches.push_back(match);
        }
    }

    return filtered_matches;
}

std::vector<Match> PointMatcher::_filterCandidatesByDegree(const std::vector<Match> &matches, double degree_threshold)
{

    std::vector<Match> filtered_matchesDegree;
    for(const Match& match : matches) {
        Point reference = _reference_points[match.ref_idx1];
        Point candidate = _candidate_points[match.cand_idx1];
         if ( abs(reference.lat - candidate.lat) <= degree_threshold
                && abs(reference.lon - candidate.lon) <= degree_threshold){
             filtered_matchesDegree.push_back(match);
         }
    }
    return filtered_matchesDegree;
}

double PointMatcher::_calculateRadius(const std::vector<Point> &ref_points)
{
    if (ref_points.empty()) {
        return 0.0;
    }

    Point centroid = _computeCentroid(ref_points);
    double max_distance = 0.0;

    for (const Point& point : ref_points) {
        double distance = _haversineDistance(centroid, point);
        if (distance > max_distance) {
            max_distance = distance;
        }
    }

    return max_distance;
}

double PointMatcher::_degreesToRadians(double degrees)const {
    return degrees * (M_PI / 180.0);
}

double PointMatcher::_radiansToDegrees(double radians) const {
    return radians * (180.0 / M_PI);
}

void PointMatcher::startFindMatches(double distance_threshold, double angle_threshold, double allMode, double grad_threshold) {
    qDebug() <<  "distance_threshold - " << distance_threshold;
    qDebug() <<  "angle_threshold - " << angle_threshold;
    qDebug() <<  "grad_threshold - " << grad_threshold;

    if (allMode) {
        QtConcurrent::run([this, distance_threshold, angle_threshold]() {
            QVariantList qmlMatches = findMatchesAllMode(distance_threshold, angle_threshold);

            emit matchesFound(qmlMatches);
        });
    } else {
    QtConcurrent::run([this, distance_threshold, angle_threshold, grad_threshold]() {
        QVariantList qmlMatches = findMatches(distance_threshold, angle_threshold, grad_threshold);

        emit matchesFound(qmlMatches);
        }); }
}

void PointMatcher::getCentalPointCoordinate(double latitude, double longitude)
{
    coordinateScan.setLongitude(longitude);
    coordinateScan.setLatitude(latitude);
}

double PointMatcher::getSignalStrength() const
{
    return _signalStrength;
}

double PointMatcher::getRcs() const
{
    return _rcs;
}

void PointMatcher::updateCandidatePoints(const std::vector<Point> &points)
{

     std::cout << "start";

}

std::map<size_t, std::vector<std::pair<size_t, Point>>> PointMatcher::_groupMatches(const std::vector<Match>& matches) { // функція щоб спростити видачу результатів  для кращої обробки повинна бути видача [індекс точки координати співпадіння в такому ж форматі\]

    std::map<size_t, std::set<std::pair<size_t, Point>>> temp_grouped_matches; // спробувати писати тільки унікальні співпадіння але для цього потрібно добавити оператори порівнянн в структуру Point бо std::set використвує оператори порівняння
    std::map<size_t, std::vector<std::pair<size_t, Point>>> grouped_matches;

    for (const Match& match : matches) {
        Point ref_point1 = _reference_points[match.ref_idx1];
        Point ref_point2 = _reference_points[match.ref_idx2];
        Point cand_point1 = _candidate_points[match.cand_idx1];
        Point cand_point2 = _candidate_points[match.cand_idx2];



        grouped_matches[match.ref_idx1].push_back({match.cand_idx1, cand_point1});
        grouped_matches[match.ref_idx2].push_back({match.cand_idx2, cand_point2});
    }

    for (const auto& [ref_idx, candidates] : grouped_matches) {
        Point ref_point = _reference_points[ref_idx];
        qDebug() << "Reference point " << ref_idx << " (" << ref_point.lat << ", " << ref_point.lon << ") matches:";

        for (const auto& [cand_idx, cand_point] : candidates) {
            qDebug() << "  Candidate point " << cand_idx << " (" << cand_point.lat << ", " << cand_point.lon << ")";
        }
    }
    return grouped_matches;
}
