#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>
#include "pointmatcher.h"
#include <QElapsedTimer>
#include <QMetaType>
#include "dataVec.h"
#include "datafromdb.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    PointMatcher point_matcher;
//    const int random_point_count = 500;
//          double min_lat = 50.30, max_lat = 50.60;
//          double min_lon = 30.20, max_lon = 30.70;

//        std::vector<Point> random_points = point_matcher.generateRandomPoints(random_point_count, min_lat, max_lat, min_lon, max_lon);
//        std::vector<Point> shifted_points_set1 = point_matcher.createShiftedPoints(reference_pointsTest, 0.01, 0.01);
//        std::vector<Point> shifted_points_set2 = point_matcher.createShiftedPoints(reference_pointsTest, 0.02, 0.02);
//        std::vector<Point> shifted_points_set3 = point_matcher.createShiftedPoints(reference_pointsTest, 0.03, 0.03);

//        std::vector<Point> all_candidate_points = random_points;
//        all_candidate_points.insert(all_candidate_points.end(), shifted_points_set1.begin(), shifted_points_set1.end());
//        all_candidate_points.insert(all_candidate_points.end(), shifted_points_set2.begin(), shifted_points_set2.end());
//        all_candidate_points.insert(all_candidate_points.end(), shifted_points_set3.begin(), shifted_points_set3.end());


//    DataFromDB dataFromDb;
//    dataFromDb.loadData("session_14_06_07_33");

    QQmlApplicationEngine engine;

    QElapsedTimer timer;
    timer.start();

//// залежність роботи алгоритму у випадку якщо об'єкти ідуть не по порядку
//    sortPoints(reference_points);
//    sortPoints(candidate_points);
//    std::vector<Point> sorted_reference_points = reference_points;
//    std::vector<Point> sorted_candidate_points = candidate_points;

//    point_matcher.setReferencePoints(sorted_reference_points);
//    point_matcher.setCandidatePoints(sorted_candidate_points); // перевірка на залежність порядку точок
//// залежність роботи алгоритму у випадку якщо об'єкти ідуть не по порядку

    engine.rootContext()->setContextProperty("pointMatcher", &point_matcher);


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
