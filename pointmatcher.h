#ifndef POINTMATCHER_H
#define POINTMATCHER_H

#include <vector>
#include <iostream>
#include <QDebug>
#include <QElapsedTimer>
#include <QtConcurrent/QtConcurrent>
#include <QObject>
#include <QVariantList>
#include <QVariant>
#include <QMutex>
#include <set>
#include "StructData.h"
#include "datafromdb.h"
#include <QGeoCoordinate>

class PointMatcher : public QObject {

    Q_OBJECT

public:
    explicit PointMatcher(QObject *parent = nullptr);

    Q_INVOKABLE void setReferencePoints(const std::vector<Point>& points);
    Q_INVOKABLE void setCandidatePoints(const std::vector<Point>& points);

    Q_INVOKABLE QVariantList getReferencePoints() const;
    Q_INVOKABLE QVariantList getCandidatePoints() const;

    Q_INVOKABLE QVariantList findMatches(double distance_threshold, double angle_threshold, double grad_threshold);
    Q_INVOKABLE QVariantList findMatchesAllMode(double distance_threshold, double angle_threshold);


    Q_INVOKABLE void downloadCompletedTest ();
    Q_INVOKABLE void downloadRandomTest (const int countShiftedPoint, const int countReferencePoint,const int countCandidatePoint,
                                         const double minLat, const double maxLat, const double minLon, const double maxLon,const double rangeShift);

    Q_INVOKABLE void convertQVariantListToPoints(const QVariantList& qmlPoints);

    Q_INVOKABLE void addReferencePoint(double lat, double lon);
    Q_INVOKABLE void addCandidatePoint(double lat, double lon);
    Q_INVOKABLE void removeReferencePoint(int index);
    Q_INVOKABLE void removeCandidatePoint(int index);
    Q_INVOKABLE void updateReferencePoint(int index, double lat, double lon);
    Q_INVOKABLE void updateCandidatePoint(int index, double lat, double lon);

    // ---- Дані з Бази даних
    Q_INVOKABLE void setRcsAndSignalStrength(const double signalStrength, const double rcs);
    Q_INVOKABLE void downloadDataBaseTest (const double signalStrength, const double rcs, const QString nameTable,const int tickNumber);
    // ---- Дані з Бази даних

    // ---- фільтрація даних з бази даних
    Q_INVOKABLE void processingDataDB(const double rcs, const double distance, const double azimuthBearning);
    Q_INVOKABLE double latitudeCentalPoint() const;
    Q_INVOKABLE double longitudeCentalPoint() const;
    // ---- фільтрація даних з бази даних


    Q_INVOKABLE QGeoCoordinate getCoordinateScan();
    QGeoCoordinate                  coordinateScan;
    // -------- tickAndId
     QVariantMap mapTicAndId;
     Q_INVOKABLE  QVariantMap getMapTicAndId();
     Q_INVOKABLE  void downloadDBTecAndId (const QString nameTable);

    // -------- tickAndId


    std::vector<Point> generateRandomPoints(int count, double min_lat, double max_lat, double min_lon, double max_lon); // функція для генерації випадкових значень з зазначеним діапазоном
    std::vector<Point> createShiftedPoints(const std::vector<Point>& reference_points, double lat_shift, double lon_shift); // функція для генерації випадкових значень з зазначеним діапазоном

    std::vector<Point> reference_pointsTest = { // вектор еталонних значень для тесту
        {50.4599, 30.4441},//3
        {50.4584, 30.4402},// 4
        {50.4624, 30.4374}, // 2
        {50.4629, 30.4420}, // 1
        {50.4607, 30.4360}//5
    };

    std::vector<Point> candidate_pointsTest = { //  вектор точок кандидатів для тесту
        {50.5129, 30.4920},//*1
        {50.5099, 30.4941},//*3
        {50.5129, 30.4948},//*1test


        {50.4086, 30.6245}, // Теремки
        {50.5223, 30.4981}, // Троещина
        {50.4607, 30.4323},//
        {50.5124, 30.4874},//*2
        {50.4131, 30.6767}, // Бортничи
        {50.5084, 30.4902},//*4
        {50.5084, 30.4920},//*4test
        {50.5124, 30.4854},//*2 test

        {50.5084, 30.4925},//*4test
        {50.5087, 30.4924},//*4test

        {50.5034,30.4383},//
        {50.4625,30.4417}, // new
        {50.4549,30.3968}, // new
        {50.4625,30.4272}, // new
        {50.5034,30.4233},//
        {50.4625,30.44123}, // new
        {50.4549,30.3458}, // new
        {50.4583, 30.432447}, // new
        {50.5034,30.454383},//
        {50.4625,30.423417}, // new
        {50.5098, 30.43441},//*3 testt
        {50.4583,30.478447},  // new
        {50.4549,30.324968}, // new
        {50.4625,30.4643272}, // new
        {50.5034,30.64383},//
        {50.4625,30.74417}, // new

        {50.4597, 30.4444},//3
        {50.4582, 30.4405},// 4
        {50.4622, 30.4377}, // 2
        {50.4627, 30.4423}, // 1
        {50.4605, 30.4363},//5

        {50.4549,30.32348}, // new
        {50.4583, 30.41232447}, // new
        {50.5034,30.443454383},//
        {50.4625,30.12323417}, // new
        {50.4583,30.21378447},  // new
        {50.4549,30.23424968}, // new
        {50.4625,30.456643272}, // new
        {50.5034,30.6574383},//
        {50.4625,30.124417}, // new
        {50.4549,30.3458}, // new
        {50.5034,30.23454383},//
        {50.4625,30.423417}, // new
        {50.5109, 30.4967},//3*test
        {50.5109, 30.4867},//3*test
        {50.5179, 30.4966},//3*test
        {50.5119, 30.4957},//3*test

        {50.4583,30.23478447},  // new
        {50.4549,30.324968}, // new
        {50.4625,30.432443272}, // new
        {50.5034,30.234383},//
        {50.4625,30.74417}, // new
        {50.4549,30.234458}, // new
        {50.4583, 30.23432447}, // new
        {50.5034,30.454383},//
        {50.4625,30.56723417}, // new
        {50.4583,30.65778447},  // new
        {50.4549,30.34524968}, // new
        {50.4625,30.4567643272}, // new
        {50.5034,30.3454383},//
        {50.4625,30.3454417}, // new

        {50.4549,30.43968}, // new
        {50.4625,30.24272}, // new
        {50.4583, 30.14747}, // new
        {50.4269, 30.309},//
        {50.5107, 30.4860},//*5
        {50.4131, 30.6767} // Бортничи
                                              };
    double getRcs() const;

    double getSignalStrength() const;


public slots:
    void updateCandidatePoints(const std::vector<Point>& points);
    void startFindMatches(double distance_threshold, double angle_threshold, double allMode, double grad_threshold); // зробив слот на мйбутне який буде запускати алгоритм в іншому потоці
    void getCentalPointCoordinate(double latitude, double longitude);
private:
    std::vector<Point> _reference_points;
    std::vector<Point> _candidate_points;

    // ---- Дані з Бази даних
    double _rcs {4};
    double _signalStrength{0};
    // ---- Дані з Бази даних

    // ---- Фільтрація даних з бази данних
    std::vector<StructData> _allDataDb;
    void _findLocation(const std::vector<Match>& qmlMatches);
    std::pair<double, double> solveSystem(double x1, double y1, double d1, double x2,
                                          double y2, double d2, double x3, double y3, double d3);
    double _latitudeCentalPoint{0};
    double _longitudeCentalPoint{0};

    void findMyLocation();
    // ---- Фільтрація даних з бази данних

    void   _comparePoints(size_t i, size_t j, double distance_threshold, double angle_threshold, std::vector<Match>& matches);
    double _haversineDistance(const Point &p1, const Point &p2) const;
    std::vector<double> _normalizeDistances(const std::vector<double> &distances) const;

    double _angle(const Point &p1, const Point &p2) const;
    double _azimuth(const Point& p1, const Point& p2) const;
    double _azimuthDifference(double az1, double az2) const;

    double _degreesToRadians(double degrees)const;
    double _radiansToDegrees(double radians)const;

    std::vector<Match>_selectBestMatches(const std::vector<Match>& matches,const double grad_threshold);

    double _calculateRadius(const std::vector<Point>& ref_points);
    Point _computeCentroid(const std::vector<Point>& points) const;
    std::vector<Match>_filterCandidatesByRadius(const std::vector<Match>& matches, const std::vector<Point>& ref_points, double radius_multiplier);
    std::vector<Match>_filterCandidatesByDegree(const std::vector<Match>& matches, double degree_threshold);

    QVariantList _convertPointsToQVariantList(const std::vector<Point>& points) const;
    std::map<size_t, std::vector<std::pair<size_t, Point>>> _groupMatches(const std::vector<Match>& matches); // контейнера можна зберігати групи співпадінь, де ключ - це індекс групи, а значення - це вектор пар,
    // де перший елемент пари - індекс кандидата, а другий елемент - точка кандидата, що співпадає з точкою відповідної групи.

    QMutex _matches_mutex; // блокування одночасного доступа до файлу

    DataFromDB *dataFromDB {nullptr};


signals:
    void matchesFound(const QVariantList& qmlMatches);

};

#endif // POINTMATCHER_H
