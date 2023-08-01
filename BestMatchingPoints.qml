import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
MapItemView {
    id: bestMatchingPoints
    model: bestMatchingPointsModel
    delegate: MapQuickItem {
        coordinate: pointToGeoCoordinate(model.ref_point)
        anchorPoint.x: matchedMarkerImage.width * 0.5
        anchorPoint.y: matchedMarkerImage.height * 0.5

        sourceItem: Image {
            id: matchedMarkerImage
            source: "qrc:/icon/cross.svg"
            width: 10
            height: 10
        }
    }
}
