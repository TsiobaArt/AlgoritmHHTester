import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
MapItemView {
    id: referencePointsItemView
    model: referencePointsModel
    delegate: MapQuickItem {
        coordinate: pointToGeoCoordinate(modelData)
        anchorPoint.x: recImg.width * 0.5
        anchorPoint.y: recImg.height * 0.5
        sourceItem: Item {
            width: 22
            height: 22
            Rectangle {
                id: recImg
                width: parent.width
                height: parent.height
                color: "lightblue"
                border.width: 2
                border.color: "black"
                radius: parent.width
                Rectangle {
                    id: recImg2
                    width: 12
                    height: 12
                    radius: 12
                    color: "white"
                    anchors.centerIn: parent
                    border.width: 2
                    border.color: "black"
                }
            }
            Text {
                text:index
                font.pixelSize: 12
                anchors.top: recImg.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            drag.target: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            Menu {
                id: contextMenu
                Action {
                    text: "Видалити точку"
                    onTriggered: {
                        bestMatchingPointsModel.clear();
                        previousPointsModel.clear();
                        removeReferencePointModel(model.index);
                        pointMatcher.removeReferencePoint(model.index);
                        referencePointsModel = pointMatcher.getReferencePoints();
                    }
                }
            }
            onPressed: {
                if (mouse.button == Qt.RightButton) {
                    contextMenu.popup()
                }
            }
            onReleased:  {
                if (mouse.button == Qt.LeftButton) {
                    var newCordinate = parent.coordinate
                    editReferencePointsModel (model.index, newCordinate.latitude, newCordinate.longitude );
                    pointMatcher.updateReferencePoint(model.index, newCordinate.latitude, newCordinate.longitude);
                    bestMatchingPointsModel.clear();
                    previousPointsModel.clear();
                    referencePointsModel = pointMatcher.getReferencePoints();
                }
            }
        }
    }
}
