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
//                    coordinate {
//                        latitude: pointMatcher.latitudeCentalPoint();
//                        longitude: pointMatcher.longitudeCentalPoint();
//                    }
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

                MapItemView {
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
                MapItemView {
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

        Item {
            width: parent.width / 2
            height: parent.height


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
                MapItemView {
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

                MapItemView {
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
                MapItemView {
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
            }
        }
    }
    //    Window {
    //        id: resultsWindow
    //        title: "Результати"
    //        visible: true
    //        width: 400
    //        height: 500

    //        ListView {
    //            anchors.fill: parent
    //            model: bestMatchingPointsModel
    //            delegate: Text {
    //                text: "Index: " + index +
    //                   "\nReference Point index: " + model.ref_point.idx +   " Reference Point: " + model.ref_point.lat + ", " + model.ref_point.lon +
    //                   "\nCandidate Point index: " + model.cand_point.idx +  " Candidate Point: " + model.cand_point.lat + ", " + model.cand_point.lon +
    //                   "\nMatched: " + (model.matched ? "Yes" : "No")
    //                font.pixelSize: 16
    //            }
    //        }
    //    }
}

