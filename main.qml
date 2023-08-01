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

                MapItemView {
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

                PreviousPointsItemView {
                    id: previousPointsItemView
                }
                BestMatchingPointsItemView {
                    id: bestMatchingPointsItemView
                }
            }
            PanelIntrument {
                id: panelIntrument
            }
        }

        Rectangle {
            width: 3
            height: parent.height
            color: "#7D7A7A"

        }

        ItemMap2 {
            id: itemMap2
        }
    }
    //        Window {
    //            id: resultsWindow
    //            title: "Результати"
    //            visible: true
    //            width: 400
    //            height: 500

    //            ListView {
    //                anchors.fill: parent
    //                model: bestMatchingPointsModel
    //                delegate: Text {
    //                    text: "Index: " + index +
    //                       "\nReference Point index: " + model.ref_point.idx +   " Reference Point: " + model.ref_point.lat + ", " + model.ref_point.lon +
    //                       "\nCandidate Point index: " + model.cand_point.idx +  " Candidate Point: " + model.cand_point.lat + ", " + model.cand_point.lon +
    //                       "\nMatched: " + (model.matched ? "Yes" : "No")
    //                    font.pixelSize: 16
    //                }
    //            }
    //        }

    Window {
        id:test
        title: "Test"
        visible: true
        width: 500
        height: mainWindow.height
        x: mainWindow.x + mainWindow.width  // Зміщуємо вікно справа від основного вікна
        y: mainWindow.y  // Встановлюємо вікно на ту ж саму горизонтальну лінію, що і основне вікно
        ListView {
            id: listView
            anchors.fill: parent
            model: sessionModel
            header: Item {
                width: listView.width
                height: 50
                Column {
                    spacing: 5
                    Row {
                        spacing: 10
                        Text { text: "ID" ;    width: 50 }
                        Rectangle {height: 40; width: 2; color: "black"}

                        Text { text:  "Data";width: 100 }
                        Rectangle {height: parent.height; width: 2; color: "black"}

                        Text { text: "Назва таблиці"  ; width: 200}
                        Rectangle {height: parent.height; width: 2; color: "black"}

                        Text { text:   "Назва сесії" ; width: 200 }
                        Rectangle {height: parent.height; width: 2; color: "black"}

                        Text { text:  "Нотатки"; width: 500 }
                        Rectangle {height: parent.height; width: 2; color: "black"}

                    }
                    Rectangle {width: parent.width; height: 2; color: "black"}

                }
            }
            delegate: Item {
                width: listView.width
                height: 50
                Column {
                    spacing: 5
                    Row {
                        spacing: 10

                        Text { text: model.id  ;  width: 50 }
                        Rectangle {height: 40; width: 2; color: "black"}
                        Text { text:  model.date; width: 100}
                        Rectangle {height: parent.height; width: 2; color: "black"}
                        Text { text: model.tableName  ; width: 200}
                        Rectangle {height: parent.height; width: 2; color: "black"}
                        Text { text:   model.sessionName ; width: 200 }
                        Rectangle {height: parent.height; width: 2; color: "black"}
                        Text { text:  model.notes; width: 500 }
                        Rectangle {height: parent.height; width: 2; color: "black"}

                    }

                    Rectangle {width: parent.width; height: 2; color: "black"}
                }
            }
        }
    }
}

