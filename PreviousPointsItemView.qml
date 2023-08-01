import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
MapItemView {
    id: previousPointsItemView
    model: previousPointsModel
    delegate: MapQuickItem {
        anchorPoint.x: image.width * 0.5
        anchorPoint.y: image.height * 0.5

        sourceItem: Image {
            id: image
            source: model.role === "ref" ? "qrc:/icon/cross.svg" : "qrc:/icon/circle.svg"
            width: 22
            height: 22
        }

        coordinate: pointToGeoCoordinate(model.point)
    }
}
