#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQml>
#include "pointmatcher.h"
#include <QElapsedTimer>
#include <QMetaType>
#include "dataVec.h"
#include "datafromdb.h"
#include "database.h"
#include "sessionmodel.h"
#include "referencemodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    Database db;
    db.connnectToDB();

    PointMatcher point_matcher;
    SessionModel *sessionModel = new SessionModel(&app);
    ReferenceModel *referenceModel   = new ReferenceModel(&app);
    QQmlApplicationEngine engine;

    QElapsedTimer timer;
    timer.start();


    engine.rootContext()->setContextProperty("pointMatcher", &point_matcher);
    engine.rootContext()->setContextProperty("sessionModel", sessionModel);
    engine.rootContext()->setContextProperty("referenceModel", referenceModel);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
