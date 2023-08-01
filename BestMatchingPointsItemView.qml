import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
MapItemView {
    id:  bestMatchingPointsItemView
    model: bestMatchingPointsModel
    delegate: MapPolyline {
        line.width: 1
        line.color: "red"
        smooth: true

        path: [
            pointToGeoCoordinate(model.ref_point),
            pointToGeoCoordinate(model.cand_point)
        ]
    }
}
