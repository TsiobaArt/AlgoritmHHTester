import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
Item {
    id: itemMap2
    width: parent.width / 2
    height: parent.height
    property alias dataMap: dataMap
    property alias referencePointFromDb: referencePointFromDb
    property alias  centralPoint: centralPoint

    Map {
        id: dataMap
        width: parent.width
        height: parent.height
        copyrightsVisible: false
        plugin: Plugin {
            name: "mapboxgl"
        }
        center: QtPositioning.coordinate(50.5129, 30.4920)
        zoomLevel: 14
        minimumZoomLevel: 1
        activeMapType: dataMap.supportedMapTypes[mapStyle2]

        InfoRecMarker {
            id: infoRecMarker
        }
        // -- filter Data
        MapItemView {
            id: referencePointFromDb
            model: referenceModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                anchorPoint.x: matchedMarkerImage.width * 0.5
                anchorPoint.y: matchedMarkerImage.height * 0.5

                sourceItem: Image {
                    id: matchedMarkerImage
                    source: "qrc:/icon/cross.svg"
                    width: 35
                    height: 35

                }
                ColorOverlay {
                anchors.fill: parent
                source: matchedMarkerImage
                smooth: true
                color:"green"
                }

            }
        }
        Rectangle {
            color: "#646060"
            width: 35
            height: 35
            radius: 5
            anchors.verticalCenter: tittleRecCand.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            z:1
            Item {
                id: icon
                width: parent.width - 10
                height: parent.height - 10
                anchors.centerIn: parent
                property string  source: "qrc:/icon/layers.svg"

                Image {
                    id: imageMapButton
                    source: icon.source
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                    anchors.centerIn: parent

                }
                ColorOverlay {
                    anchors.fill: imageMapButton
                    source: imageMapButton
                    color:   "lightblue"
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: {
                    if (mouse.button === Qt.LeftButton) {
                        if (mapStyle2 === 0) mapStyle2 = 11
                        else mapStyle2 --
                    }
                    else if (mouse.button === Qt.RightButton) {
                        if (mapStyle2 === 11) mapStyle2 = 0
                        else mapStyle2 ++
                    }
                }
            }
        }

        MouseArea {
            id:mapMouseCandidate
            anchors.fill: parent
            onDoubleClicked: {
                var clickedCoordinaye = dataMap.toCoordinate(Qt.point(mouse.x, mouse.y))
                addCandidatePointModel(clickedCoordinaye.latitude, clickedCoordinaye.longitude)
                pointMatcher.addCandidatePoint(clickedCoordinaye.latitude, clickedCoordinaye.longitude)
                dataPointsModel = pointMatcher.getCandidatePoints();
            }
        }

        Rectangle {
            id: tittleRecCand
            radius: 10
            width: text1.width + 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            height: 40
            color: "#7D7A7A"
            border.width: 2
            border.color:  "lightblue"
            opacity: 1
            z:1

            Text {
                id:text1
                text: "Точки кандидати ( РГСН )"
                font.pixelSize: 16
                anchors.top: parent.top
                anchors.centerIn: parent
                color: "white"
                opacity: 0.8
            }

        }

        DataPointsCandidate {
            id: dataPointsCandidate
        }

        BestMatchingPointsMapView {
            id: bestMatchingPointsMapView
        }
        MapQuickItem {
            id: centralPointReal2
            anchorPoint.x: imageCentralPoint2.width / 2
            anchorPoint.y: imageCentralPoint2.height / 2
            coordinate : centralPointReal.coordinate
            sourceItem: Image {
                id: imageCentralPoint2
                source: "qrc:/icon/target.svg"
                sourceSize.width: 40
                sourceSize.height: 40
                ColorOverlay {
                    id: colorImg2
                    anchors.fill: imageCentralPoint2
                    source: imageCentralPoint2
                    color: "red"
                }
            }
        }
        MapQuickItem {
            id: centralPoint
            anchorPoint.x: cross.width / 2
            anchorPoint.y: cross.height / 2
            sourceItem: Item {
                id: cross
                width: 36
                height: 36
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext('2d');
                        ctx.strokeStyle = "blue";
                        ctx.lineWidth = 2;
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(parent.width, parent.height);
                        ctx.moveTo(parent.width, 0);
                        ctx.lineTo(0, parent.height);
                        ctx.stroke();
                    }
                }
            }
        }
        MapItemView {
            model: previousPointsModel
            delegate: MapQuickItem {
                anchorPoint.x: image2.width * 0.5
                anchorPoint.y: image2.height * 0.5

                sourceItem: Image {
                    id: image2
                    source: model.role === "ref" ?  "qrc:/icon/circle.svg" : "qrc:/icon/cross.svg"
                    width: 22
                    height: 22
                }

                coordinate: pointToGeoCoordinate(model.point)
            }
        }
        BestMatchingPointsViewMap {
            id: bestMatchingPointsViewMap
        }

    }
}
