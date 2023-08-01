import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
MapItemView {
    id : bestMatchingPointsMapView
    model: bestMatchingPointsModel
    delegate: MapQuickItem {
        coordinate: pointToGeoCoordinate(model.cand_point)
        anchorPoint.x: matchedMarkerImage2.width * 0.5
        anchorPoint.y: matchedMarkerImage2.height * 0.5

        sourceItem: Image {
            id: matchedMarkerImage2
            source: "qrc:/icon/cross.svg"
            width: 12
            height: 12
        }
    }
}
