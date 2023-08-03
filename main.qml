import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
Window { // варіант де результат передається по завершенню роботи функцію за сигналом
    id: mainWindow
    visible: true
    width: 1280
    height: 720
    title: "Map Points Calculator"
    minimumHeight:  800
    minimumWidth:   1200
    property var referencePointsModel: pointMatcher.getReferencePoints()
    property var dataPointsModel: pointMatcher.getCandidatePoints()
    ListModel { id: bestMatchingPointsModel }
    ListModel {  id: previousPointsModel   }
    property real distance_threshold: 0.001
    property real angle_threshold: 5.0
    property int mapStyle1: 0
    property int mapStyle2: 0

    function setCenterReferenceMap(latitude, longitude) {
        console.log ("setCenterReferenceMap")
        console.log (latitude, longitude)
         referenceMap.center =  QtPositioning.coordinate(latitude, longitude)
     }
    function setCenterDataMap(latitude, longitude) {
         itemMap2.dataMap.center =  QtPositioning.coordinate(latitude, longitude)
     }
    Connections {
        target: pointMatcher
        function onMatchesFound(matches) {
            handleMatchesFound(matches);
            handleMatchesFound(matches); // додав щоб відразу малювало і стару модель і нову
        }
    }
    function handleMatchesFound(matches) {
        previousPointsModel.clear()
        // Збереження попередніх точок
        for (var i = 0; i < bestMatchingPointsModel.count; i++) {
            previousPointsModel.append({
                                           point: bestMatchingPointsModel.get(i).ref_point,
                                           role: "ref"
                                       });
            previousPointsModel.append({
                                           point: bestMatchingPointsModel.get(i).cand_point,
                                           role: "cand"
                                       });
        }
        // результати роботи алгоритму
        bestMatchingPointsModel.clear();
        for (var j = 0; j < matches.length; j++) {
            var match = matches[j];

            bestMatchingPointsModel.append({
                                               ref_point: {
                                                   lat: referencePointsModel[match.ref_idx1].lat,
                                                   lon: referencePointsModel[match.ref_idx1].lon,
                                                   idx: match.ref_idx1
                                               },
                                               cand_point: {
                                                   lat: dataPointsModel[match.cand_idx1].lat,
                                                   lon: dataPointsModel[match.cand_idx1].lon,
                                                   idx: match.cand_idx1
                                               },
                                               matched: true
                                           });

            bestMatchingPointsModel.append({
                                               ref_point: {
                                                   lat: referencePointsModel[match.ref_idx2].lat,
                                                   lon: referencePointsModel[match.ref_idx2].lon,
                                                   idx: match.ref_idx2

                                               },
                                               cand_point: {
                                                   lat: dataPointsModel[match.cand_idx2].lat,
                                                   lon: dataPointsModel[match.cand_idx2].lon,
                                                   idx: match.cand_idx2
                                               },
                                               matched: true
                                           });
        }
    }

    function pointToGeoCoordinate(point) {
        return QtPositioning.coordinate(point.lat, point.lon);
    }


    function clearMatching() {
        bestMatchingPointsModel.clear();
        previousPointsModel.clear();
    }

    function editReferencePointsModel (index, lat, lon) {
        // функція для зміни моделі  функції
        var point = referencePointsModel[index];
        point.lat = lat;
        point.lon = lon;
        referencePointsModel[index] = point;
    }
    function editCandidatePointsModel (index, lat, lon) {
        // функція для зміни моделі  функції
        var point = dataPointsModel[index];
        point.lat = lat;
        point.lon = lon;
        dataPointsModel[index] = point;
    }

    function addReferencePointModel(lat, lon) {
        // створюємо нову точку
        var newPoint = {"lat": lat, "lon": lon};

        // додаємо нову точку до моделі
        referencePointsModel.push(newPoint);
    }
    function addCandidatePointModel(lat, lon) {
        // створюємо нову точку
        var newPoint = {"lat": lat, "lon": lon};

        // додаємо нову точку до моделі
        dataPointsModel.push(newPoint);
    }
    function removeReferencePointModel(index) {
        if (index >= 0 && index < referencePointsModel.count) {
            referencePointsModel.remove(index);
        }
    }
    function removeCandidatePointModel(index) {
        if (index >= 0 && index < referencePointsModel.count) {
            dataPointsModel.remove(index);
        }
    }
    Row {
        anchors.fill: parent
        Item {
            width: parent.width / 2
            height: parent.height
            Map {
                id: referenceMap
                width: parent.width
                height: parent.height
                copyrightsVisible: false
                minimumZoomLevel: 1
                plugin: Plugin {
                    name: "mapboxgl"
                }
                center: QtPositioning.coordinate(50.4629, 30.4420)
                zoomLevel: 14
                activeMapType: referenceMap.supportedMapTypes[mapStyle1]

                MouseArea {
                    id:mapMouseArea
                    anchors.fill: parent
                    onDoubleClicked: {
                        var clickedCoordinaye = referenceMap.toCoordinate(Qt.point(mouse.x, mouse.y))
                        addReferencePointModel(clickedCoordinaye.latitude, clickedCoordinaye.longitude)
                        pointMatcher.addReferencePoint(clickedCoordinaye.latitude, clickedCoordinaye.longitude)
                        referencePointsModel = pointMatcher.getReferencePoints();
                    }
                }

                Rectangle {
                    color: "#646060"
                    width: 35
                    height: 35
                    radius: 5
                    anchors.verticalCenter: tittleRec.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    z:1
                    Item {
                        id: icon3
                        width: parent.width - 10
                        height: parent.height - 10
                        anchors.centerIn: parent
                        property string  source: "qrc:/icon/layers.svg"

                        Image {
                            id: imageMapButton3
                            source: icon3.source
                            sourceSize.width: parent.width
                            sourceSize.height: parent.height
                            anchors.centerIn: parent

                        }
                        ColorOverlay {
                            anchors.fill: imageMapButton3
                            source: imageMapButton3
                            color:   "lightblue"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onPressed: {
                            if (mouse.button === Qt.LeftButton) {
                                if (mapStyle1 === 0) mapStyle1 = 11
                                else mapStyle1 --
                            }
                            else if (mouse.button === Qt.RightButton) {
                                if (mapStyle1 === 11) mapStyle1 = 0
                                else mapStyle1 ++
                            }
                        }
                    }
                }
                Rectangle {
                    id: tittleRec
                    radius: 10
                    width: text.width + 20
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
                        id:text
                        text: "Еталонні точки (Польотне завдання)"
                        font.pixelSize: 16
                        color: "white"
                        anchors.top: parent.top
                        anchors.centerIn: parent
                        opacity: 0.8
                    }

                }

                ReferencePointsItemView {
                    id: referencePointsItemView
                }

                // -- filter Data
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
                                ctx.strokeStyle = Qt.rgba(1, 0, 0, 1);
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

                BestMatchingPoints {
                    id: bestMatchingPoints
                }

                PreviousPointsItemView {
                    id: previousPointsItemView
                }
                BestMatchingPointsItemView {
                    id: bestMatchingPointsItemViewLine
                }
                // -- CEntralPoint Real Data
                MapQuickItem {
                    id: centralPointReal
                    anchorPoint.x: imageCentralPoint.width / 2
                    anchorPoint.y: imageCentralPoint.height / 2
                    sourceItem: Image {
                        id: imageCentralPoint
                        source: "qrc:/icon/target.svg"
                        sourceSize.width: 40
                        sourceSize.height: 40
                        ColorOverlay {
                            id: colorImg
                            anchors.fill: imageCentralPoint
                            source: imageCentralPoint
                            color: "red"
                        }
                    }
                }
                // -- CEntralPoint Real Data
            }
            PanelIntrument {
                id: panelIntrument
            }

            InfoMenuCoordinateCentalPoint {
                id: infoMenuCoordinateCentalPoint
            }

        }

        Rectangle { // розділяємо карти ддля кращої візуалазації
            width: 3
            height: parent.height
            color: "#7D7A7A"
        }

        ItemMap2 {
            id: itemMap2
        }
    }


    SettingsDialogSession {
        id: settingsDialog
    }
    TicDialog {
        id: ticDialog
    }


}

