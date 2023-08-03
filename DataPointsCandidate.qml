import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
MapItemView {
    id: dataPointsCandidate
    model: dataPointsModel
    delegate: MapQuickItem {
        coordinate: pointToGeoCoordinate(modelData)
        anchorPoint.x: recImgD.width * 0.5
        anchorPoint.y: recImgD.height * 0.5

        sourceItem: Item {
            width: 22
            height: 22
            Rectangle {
                id: recImgD
                width: parent.width
                height: parent.height
                color: "lightblue"
                border.width: 2
                border.color: "black"
                radius: parent.width
                Rectangle {
                    id: recImg2D
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
                anchors.top: recImgD.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            drag.target: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            Menu {
                id: contextMenu2
                Action {
                    text: "Видалити точку"
                    onTriggered: {
                        bestMatchingPointsModel.clear();
                        previousPointsModel.clear();
                        removeCandidatePointModel(model.index);
                        pointMatcher.removeCandidatePoint(model.index);
                        dataPointsModel = pointMatcher.getCandidatePoints();
                    }
                }
            }

            onPressed: {
                if (mouse.button == Qt.RightButton) {
                    contextMenu2.popup()
                }
                console.log ( "Candidate model.lat : ",  modelData.lat)
                console.log ( "Candidate model.lon : ",  modelData.lon)
            }

            onReleased:  {
                if (mouse.button == Qt.LeftButton) {
                    var newCordinate = parent.coordinate
                    editCandidatePointsModel (model.index, newCordinate.latitude, newCordinate.longitude );
                    pointMatcher.updateCandidatePoint(model.index, newCordinate.latitude, newCordinate.longitude);
                    bestMatchingPointsModel.clear();
                    previousPointsModel.clear();
                    dataPointsModel = pointMatcher.getCandidatePoints();
                }
            }
        }
    }
}
