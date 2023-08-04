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


signals:

};

#endif // FINDLOCATION_H
