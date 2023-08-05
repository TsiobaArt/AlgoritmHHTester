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
    double dist; //  критерій для пошуку співпадінь
    int Rcs;
    double AzimuthBearing;



};

Q_DECLARE_METATYPE(Point)

struct Match {
    size_t ref_idx1;
    size_t ref_idx2;
    size_t cand_idx1;
    size_t cand_idx2;
    double distance_diff;
    double angle_diff;


    // ---------------------------- додаю нові поля для пошуку співпадінь

    double ref_idx1_lat;
    double ref_idx1_lot;
    double ref_idx1_Dist;
    double ref_idx1_AzimuthBearing;
    double ref_idx1_Rcs;
    double ref_idx1_SignalStrength;


    double ref_idx2_lat;
    double ref_idx2_lot;
    double ref_idx2_Dist;
    double ref_idx2_AzimuthBearing;
    double ref_idx2_Rcs;
    double ref_idx2_SignalStrength;


    double cand_idx1_lat;
    double cand_idx1_lon;
    double cand_idx1_Dist;
    double cand_idx1_AzimuthBearing;
    double cand_idx1_Rcs;
    double cand_idx1_SignalStrength;



    double cand_idx2_lat;
    double cand_idx2_lon;
    double cand_idx2_Dist;
    double cand_idx2_AzimuthBearing;
    double cand_idx2_Rcs;
    double cand_idx2_SignalStrength;


    // ---------------------------- додав нові поля для пошуку співпадінь


};

bool operator<(const Match &m1, const Match &m2); // потрібно було перегрузити для для того щоб порівнювати

#endif // STRUCTDATA_H
