#ifndef STRUCTDATA_H
#define STRUCTDATA_H
#include <set>
#include <QObject>
#include <QObject>
#include <QVariantList>
#include <QVariant>
#include <vector>


struct StructData {
    double AzimuthBearing;
    int Distance;
//    int PlaceBearing;
    int Rcs;
//    int SignalStrength;
//        int Speed;
    double latitude;
    double longitude;
};

struct Point {
    double lat;
    double lon;
};

Q_DECLARE_METATYPE(Point)

struct Match {
    size_t ref_idx1;
    size_t ref_idx2;
    size_t cand_idx1;
    size_t cand_idx2;
    double distance_diff;
    double angle_diff;

};

bool operator<(const Match &m1, const Match &m2); // потрібно було перегрузити для для того щоб порівнювати

#endif // STRUCTDATA_H
