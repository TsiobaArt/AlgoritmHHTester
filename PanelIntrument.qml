import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
//import QtQuick.Controls 1.4

import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.15
//import Qt.labs.platform 1.1
///////////////////////////////////////////////////////////////////////////////////
Item {
    id: panelIntrument
    width: 180
    height: 420
    anchors.left: parent.left
    anchors.leftMargin: 5
    anchors.verticalCenter: parent.verticalCenter
    property real minLatFilteCandidate: 50.10
    property real maxLatFilteCandidate: 50.50
    property real minLonFilteCandidate: 30.10
    property real maxLonFilteCandidate: 30.50

    property real minLatFilteReference: 50.1594
    property real maxLatFilteReference: 50.1639
    property real minLonFilteReference: 30.1370
    property real maxLonFilteReference: 30.1451

    property int countReferencePoint: 5
    property int countCandidatePoint: 500

    property int countShiftedPoint: 4

    property real distanceThreshold: 0.001
    property string angleThreshold: "5.0"


    MouseArea {
        anchors.fill: parent

    }

    Rectangle {
        color: "#646060"
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height
        opacity: 0.7
        radius: 10
        Column {
            id: mainColumn
            anchors.fill: parent
            topPadding: 10
            spacing: 20
            Rectangle {
                id: uploadTest
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                color: parent.parent.color
                radius: 10
                border.width: 2
                border.color:  "white"

                Text {
                    id: text
                    text: qsTr("Готовий тест ")
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        uploadTest.border.color = "lightblue" // Зміна кольору обводки при наведенні
                    }

                    onExited: {
                        uploadTest.border.color = "white" // Повернення початкового кольору обводки
                    }

                    onPressed: {
                        uploadTest.scale = 0.9 // Зменшення масштабу при натисканні
                        referencePointsModel = []
                        dataPointsModel = []
                        bestMatchingPointsModel.clear()
                        previousPointsModel.clear()

                    }

                    onReleased: {
                        uploadTest.scale = 1 // Повернення початкового масштабу при відпусканні
                        pointMatcher.downloadCompletedTest()
                        referencePointsModel = pointMatcher.getReferencePoints()
                        dataPointsModel      = pointMatcher.getCandidatePoints()
                    }
                }
            }
            Rectangle {
                id: uploadTestDataBase
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                color: parent.parent.color
                radius: 10
                border.width: 2
                border.color:  "white"

                Text {
                    id: textTestDataBase
                    text: qsTr("Дані Сан-Франциско")
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16

                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        uploadTestDataBase.border.color = "lightblue"
                    }
                    onExited: {
                        uploadTestDataBase.border.color = "white" // Повернення початкового кольору обводки
                    }
                    onPressed: {
                        uploadTestDataBase.scale = 0.9 // Зменшення масштабу при натисканні
                    }
                    onReleased: {
                        uploadTestDataBase.scale = 1 // Повернення початкового масштабу при відпусканні
                        dataBaseDialog.open()
                    }
                }
                Dialog {
                    id: dataBaseDialog
                    title: "Завантажити дані з DB"
                    modal : Qt.WindowModal
                    leftMargin:  mainWindow.width/2 - dataBaseDialog.width/2
                    bottomMargin:   mainWindow.height/2 - dataBaseDialog.height/2

                    Column {
                        spacing: 10
                        Column {
                            spacing: 10
                            anchors.horizontalCenter:   parent.horizontalCenter

                            Text {
                                id: textSession
                                text: "Сессія"
                                font.bold: true
                                font.pixelSize: 12
                                color:"grey"
                                anchors.horizontalCenter:   parent.horizontalCenter
                                opacity: 1
                            }
                            ComboBox {
                                       id: myComboBox
                                       width: 200
                                       model: ["session_14_06_07_33", "session_14_06_07_36"]
//                                       model: ["session_25_07_10_23_41", "session_26_07_13_23_36", "session_26_07_13_49_24"]

                                       currentIndex: 0 // No selection by default
                                   }
                            Row {
                                spacing: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                Text {
                                    id: pointRcsText
                                    text: "Значення RCS"
                                    font.bold: true
                                    font.pixelSize: 12
                                    color:"grey"
                                    opacity: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                }
                                TextField {
                                    id: pointRcs
                                    placeholderText: "Rcs"
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
//                                    validator: RegExpValidator { regExp: /^(0?[1-9]|1[0-9]|20)$/ }
                                    width: 110

                                }

                            }
                            Row {
                                spacing: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                Text {
                                    id: poinSignalStrengthText
                                    text: "SignalStrength"
                                    font.bold: true
                                    font.pixelSize: 12
                                    color:"grey"
                                    opacity: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                }
                                TextField {
                                    id: poinSignalStrength
                                    placeholderText: "SignalStrength"
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
//                                    validator: RegExpValidator { regExp: /^(0?[1-9]|1[0-9]|20)$/ }
                                    width: 110

                                }

                            }
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 5

                            Button {
                                text: "Підтвердити"
                                onClicked: {
                                    // Дії при натисканні кнопки Підтвердити
                                    console.log(myComboBox.currentText)

                                    referencePointsModel = []
                                    dataPointsModel = []
                                    bestMatchingPointsModel.clear()
                                    previousPointsModel.clear()

                                    pointMatcher.downloadDataBaseTest(poinSignalStrength.text, pointRcs.text,myComboBox.currentText )
                                    referencePointsModel = pointMatcher.getReferencePoints()
                                    dataPointsModel      = pointMatcher.getCandidatePoints()


                                    dataBaseDialog.accept()
                                }
                            }

                            Button {
                                text: "Відмінити"
                                onClicked: {
                                    // Дії при натисканні кнопки Відмінити
                                    dataBaseDialog.reject()
                                }
                            }
                        }

                    }

                }
            }
                        Rectangle {
                            id: postProcessingData
                            width: parent.width - 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 40
                            radius: 10
                            color: parent.parent.color
                            border.width: 2
                            border.color:  "white"
                            Text {
                                id: textPostProcessingData
                                text: qsTr("Обробити дані")
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: 16

                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered: {
                                    postProcessingData.border.color = "lightblue" // Зміна кольору обводки при наведенні
                                }

                                onExited: {
                                    postProcessingData.border.color = "white" // Повернення початкового кольору обводки
                                }

                                onPressed: {
                                    postProcessingData.scale = 0.9 // Зменшення масштабу при натисканні

                                }

                                onReleased: {
                                    postProcessingData.scale = 1 // Повернення початкового масштабу при відпусканні
                                    dialogPostProcessingData.open()
                                }
                            }
                            Dialog {
                                id: dialogPostProcessingData
                                title: "Пост-Обробка Даних РГСН"
                                modal : Qt.WindowModal
                                leftMargin:  mainWindow.width/2 - dataBaseDialog.width/2
                                bottomMargin:   mainWindow.height/2 - dataBaseDialog.height/2
                                Column {
                                    spacing: 10
                                    Row {
                                        spacing: 5
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Text {
                                            id: postProcessingRcsText
                                            text: "Значення RCS  "
                                            font.bold: true
                                            font.pixelSize: 12
                                            color:"grey"
                                            opacity: 1
                                            anchors.verticalCenter: parent.verticalCenter

                                        }
                                        TextField {
                                            id: postProcessingRcs
                                            placeholderText: "Rcs"
                                            inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
        //                                    validator: RegExpValidator { regExp: /^(0?[1-9]|1[0-9]|20)$/ }
                                            width: 110

                                        }
                                    }
                                    Row {
                                        spacing: 5
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Text {
                                            id: postProcessingDistanceText
                                            text: "Distance           "
                                            font.bold: true
                                            font.pixelSize: 12
                                            color:"grey"
                                            opacity: 1
                                            anchors.verticalCenter: parent.verticalCenter

                                        }
                                        TextField {
                                            id: postProcessingDistance
                                            placeholderText: "Distance"
                                            inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри

        //                                    validator: RegExpValidator { regExp: /^(0?[1-9]|1[0-9]|20)$/ }
                                            width: 110

                                        }

                                    }
                                    Row {
                                        spacing: 5
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Text {
                                            id: postProcessingAzimuthBearingText
                                            text: "AzimuthBearing"
                                            font.bold: true
                                            font.pixelSize: 12
                                            color:"grey"
                                            opacity: 1
                                            anchors.verticalCenter: parent.verticalCenter

                                        }
                                        TextField {
                                            id: postProcessingAzimuthBearing
                                            placeholderText: "AzimuthBearing"
                                            inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри

        //                                    validator: RegExpValidator { regExp: /^(0?[1-9]|1[0-9]|20)$/ }
                                            width: 110

                                        }

                                    }
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 5

                                        Button {
                                            text: "Підтвердити"
                                            onClicked: {
                                                // Дії при натисканні кнопки Підтвердити

                                                referencePointsModel = []
                                                dataPointsModel = []
                                                bestMatchingPointsModel.clear()
                                                previousPointsModel.clear()

//                                                void PointMatcher::processingDataDB(const double rcs, const double distance, const double azimuthBearning)

                                                pointMatcher.processingDataDB(postProcessingRcs.text, postProcessingDistance.text, postProcessingAzimuthBearing.text)
                                                referencePointsModel = pointMatcher.getReferencePoints()
                                                dataPointsModel      = pointMatcher.getCandidatePoints()

                                                dialogPostProcessingData.accept()
                                            }
                                        }

                                        Button {
                                            text: "Відмінити"
                                            onClicked: {
                                                // Дії при натисканні кнопки Відмінити
                                                dialogPostProcessingData.reject()
                                            }
                                        }
                                    }
                                }
                            }
                        }
            Rectangle {
                id: genereTest
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                radius: 10
                color: parent.parent.color
                border.width: 2
                border.color:  "white"
                Text {
                    id: text1
                    text: qsTr("Випаковий тест")
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16

                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        genereTest.border.color = "lightblue" // Зміна кольору обводки при наведенні
                    }

                    onExited: {
                        genereTest.border.color = "white" // Повернення початкового кольору обводки
                    }

                    onPressed: {
                        genereTest.scale = 0.9 // Зменшення масштабу при натисканні

                    }

                    onReleased: {
                        genereTest.scale = 1 // Повернення початкового масштабу при відпусканні
                        settingsDialog.open()
                    }
                }

                Dialog {
                    id: settingsDialog
                    title: "Налаштування тесту"
                    modal: Qt.WindowModal
                    leftMargin: mainWindow.width/2 - settingsDialog.width/2
                    bottomMargin: mainWindow.height/2 - settingsDialog.height/2
                    Column {
                        spacing: 10

                        Column {
                            spacing: 10
                            Text {
                                id: countText
                                text: "Кількість наборів точок"
                                font.bold: true
                                font.pixelSize: 12
                                color:"grey"
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 1
                            }

                            Row {
                                spacing: 5
                                anchors.horizontalCenter: parent.horizontalCenter

                                TextField {
                                    id: pointsReference
                                    placeholderText: "Еталони"
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                    validator: RegExpValidator { regExp: /^(0?[1-9]|1[0-9]|20)$/ }
                                    width: 110

                                }
                                TextField {
                                    id: pointsCandidate
                                    placeholderText: "Кандидати"
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                    //                                    validator: RegExpValidator { regExp: /^([1-9][0-9]{0,2}|1000)$/ }
                                    width: 110
                                }
                            }
                        }
                        Column {
                            spacing: 10
                            Text {
                                id: countShifttext
                                text: "Кількість схожих сузір'їв"
                                font.bold: true
                                font.pixelSize: 12
                                color:"grey"
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 1
                            }
                            TextField {
                                anchors.horizontalCenter: parent.horizontalCenter
                                id: shiftedPoints
                                width: 225
                                placeholderText: "Кількість"
                                inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                validator: RegExpValidator { regExp: /^([1-9]|1[0-5])$/ }
                            }
                        }
                        Column {
                            spacing: 10
                            Text {
                                id: countShiftRange
                                text: "Розсіювання схожих сузір'їв"
                                font.bold: true
                                font.pixelSize: 12
                                color:"grey"
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 1
                            }
                            TextField {
                                anchors.horizontalCenter: parent.horizontalCenter
                                id: shiftedPointsRange
                                width: 225
                                placeholderText: "Градуси"
                                inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                validator: RegExpValidator { regExp: /^[0-0]\.\d{1,4}$/ }
                            }
                        }
                        Column {
                            spacing: 10
                            Text {
                                id: deltalat
                                text: "Діапазон широти"
                                font.bold: true
                                font.pixelSize: 12
                                color:"grey"
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 1
                            }
                            Row {
                                spacing: 5
                                anchors.horizontalCenter: parent.horizontalCenter

                                TextField {
                                    id: minLat
                                    placeholderText: "Мін широта "
                                    validator:  RegExpValidator { regExp: /^-?([0-8][0-9]?|90?)\.[0-9]{0,7}/ }
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                    width: 110
                                }
                                TextField {
                                    id: maxLat
                                    placeholderText: "Макс широта "
                                    validator:  RegExpValidator { regExp: /^-?([0-8][0-9]?|90?)\.[0-9]{0,7}/ }
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                    width: 110
                                }
                            }
                            Text {
                                id: deltaLon
                                text: "Діапазон Довготи"
                                font.bold: true
                                font.pixelSize: 12
                                color:"grey"
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 1
                            }
                            Row {
                                spacing: 5
                                anchors.horizontalCenter: parent.horizontalCenter

                                TextField {
                                    id: minLon
                                    placeholderText: "Мін довгота "
                                    validator:  RegExpValidator { regExp: /^-?([0-8][0-9]?|90?)\.[0-9]{0,7}/ }
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                    width: 110
                                }
                                TextField {
                                    id: maxLon
                                    placeholderText: "Макс довгота "
                                    validator:  RegExpValidator { regExp: /^-?([0-8][0-9]?|90?)\.[0-9]{0,7}/ }
                                    inputMethodHints: Qt.ImhDigitsOnly // Дозволяє вводити тільки цифри
                                    width: 110
                                }

                            }
                        }
                        Button {
                            text: "Cтандартні налаштування"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 180
                            onClicked: {
                                pointsReference.text = panelIntrument.countReferencePoint.toString()
                                pointsCandidate.text = panelIntrument.countCandidatePoint.toString()
                                shiftedPoints.text   = panelIntrument.countShiftedPoint.toString()
                                minLat.text          = panelIntrument.minLatFilteCandidate.toString()
                                maxLat.text          = panelIntrument.maxLatFilteCandidate.toString()
                                minLon.text          = panelIntrument.minLonFilteCandidate.toString()
                                maxLon.text          = panelIntrument.maxLonFilteCandidate.toString()
                                shiftedPointsRange.text = 0.001
                            }
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 5

                            Button {
                                text: "Підтвердити"
                                onClicked: {
                                    // Дії при натисканні кнопки Підтвердити
                                    settingsDialog.accept()
                                }
                            }

                            Button {
                                text: "Відмінити"
                                onClicked: {
                                    // Дії при натисканні кнопки Відмінити
                                    settingsDialog.reject()
                                }
                            }
                        }
                    }

                    onAccepted: {
                        referencePointsModel = []
                        dataPointsModel = []
                        bestMatchingPointsModel.clear()
                        previousPointsModel.clear()

                        pointMatcher.downloadRandomTest(parseInt(shiftedPoints.text), parseInt(pointsReference.text), parseInt(pointsCandidate.text), parseFloat(minLat.text), parseFloat(maxLat.text), parseFloat(minLon.text), parseFloat(maxLon.text), parseFloat(shiftedPointsRange.text))
                        console.log("Кількість точок: " + pointsCandidate.text)
                        referencePointsModel = pointMatcher.getReferencePoints()
                        dataPointsModel      = pointMatcher.getCandidatePoints()
                    }
                    onRejected: {
                        // Тут ви можете виконати дії при відхиленні діалогу (наприклад, очистити поля вводу)
                    }
                }
            }


            Rectangle {
                id: allDelete
                radius: 10
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                color: parent.parent.color
                border.width: 2
                border.color:  "white"
                Text {
                    id: text3
                    text: qsTr("Видалити все")
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16

                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        allDelete.border.color = "lightblue" // Зміна кольору обводки при наведенні
                    }

                    onExited: {
                        allDelete.border.color = "white" // Повернення початкового кольору обводки
                    }

                    onPressed: {
                        allDelete.scale = 0.9 // Зменшення масштабу при натисканні
                    }

                    onReleased: {
                        allDelete.scale = 1 // Повернення початкового масштабу при відпусканні
                        referencePointsModel = []
                        dataPointsModel = []
                        bestMatchingPointsModel.clear()
                        previousPointsModel.clear()
                    }
                }
            }

            Rectangle {
                id: clearCalculate
                radius: 10
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                color: parent.parent.color
                border.width: 2
                border.color:  "white"
                Text {
                    id: textcalculateClear
                    text: qsTr("Очистити результат")
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16

                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        clearCalculate.border.color = "lightblue" // Зміна кольору обводки при наведенні
                    }

                    onExited: {
                        clearCalculate.border.color = "white" // Повернення початкового кольору обводки
                    }

                    onPressed: {
                        clearCalculate.scale = 0.9 // Зменшення масштабу при натисканні
                    }

                    onReleased: {
                        clearCalculate.scale = 1 // Повернення початкового масштабу при відпусканні
                        clearMatching()

                    }
                }
            }
            Rectangle {
                id: calculate
                radius: 10
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                height: 40
                color: parent.parent.color
                border.width: 2
                border.color:  "white"
                Text {
                    id: textcalculate
                    text: qsTr("Розрахувати")
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16

                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        calculate.border.color = "lightblue" // Зміна кольору обводки при наведенні
                    }

                    onExited: {
                        calculate.border.color = "white" // Повернення початкового кольору обводки
                    }

                    onPressed: {
                        calculate.scale = 0.9 // Зменшення масштабу при натисканні
                    }

                    onReleased: {
                        calculate.scale = 1 // Повернення початкового масштабу при відпусканні
                        calculateDialog.open()

                    }
                }
                Dialog {
                    id: calculateDialog
                    title: "Налаштування обчислення"
                    modal: Qt.WindowModal
                    topPadding: 0
                    leftMargin:  mainWindow.width/2 - settingsDialog.width/2
                    bottomMargin:   mainWindow.height/2 - settingsDialog.height/2

                    Column {
                        spacing: 10

                        Row {
                            spacing: 5
                            anchors.horizontalCenter: parent.horizontalPadding
                            Column {
                                spacing: 10
                                Text {
                                    id: textDist
                                    text: "Діпазон дист"
                                    font.bold: true
                                    font.pixelSize: 12
                                    color:"grey"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    opacity: 1
                                }
                                TextField {
                                    id: calcDist
                                    placeholderText:  "км"
                                    validator: RegExpValidator { regExp: /^[0-9]\.\d{1,4}$/ }
                                    width: 100
                                }
                            }
                            Column {
                                spacing: 10
                                Text {
                                    id: textAngle
                                    text: "Діпазон кута"
                                    font.bold: true
                                    font.pixelSize: 12
                                    color:"grey"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    opacity: 1
                                }
                                TextField {
                                    id: calcAngle
                                    placeholderText:  "Градусів"
                                    validator: RegExpValidator { regExp: /^(0|[1-9]\d?|[12]\d{2}|3[0-5]\d)\.\d{2}$/ }
                                    width: 100

                                }
                            }
                        }
                        Column {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text {
                                id: textRangeCoord
                                text: "Діпазон координат"
                                font.bold: true
                                font.pixelSize: 12
                                color:"grey"
                                anchors.horizontalCenter: parent.horizontalCenter
                                opacity: 1
                            }
                            TextField {
                                id: calcRangeCoord
                                placeholderText:  "Градусів"
                                validator: RegExpValidator { regExp: /^[0-1]\.\d{1,4}$/ }
                                width: 205
                            }
                        }
                        Column {
                            spacing: 5
                            //                                anchors.verticalCenter:  parent.verticalCenter

                            RadioButton {
                                id: bestMatches
                                text: "Найкращі співпадіння"
                                checked: true
                            }

                            RadioButton {
                                id: allMatches
                                text: "Всі співпадіння"
                            }
                        }
                        CheckBox  {
                            id: myPossition
                            text: "Свое місцезнаходження"
                        }
                        Button {
                            text: "Cтандартні налаштування"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 180
                            onClicked: {
                                calcDist.text = panelIntrument.distanceThreshold.toString()
                                calcAngle.text = panelIntrument.angleThreshold
                                bestMatches.checked  = true
                                calcRangeCoord.text  = 0.001

                            }
                        }
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 5

                            Button {
                                text: "Підтвердити"
                                onClicked: {
                                    // Дії при натисканні кнопки Підтвердити
                                    pointMatcher.startFindMatches(parseFloat(calcDist.text), parseFloat(calcAngle.text), allMatches.checked, parseFloat(calcRangeCoord.text));
                                    console.log(" Шукати найкращі співпадіння: " + bestMatches.checked )
                                    console.log(" Шукати всі співпадіння: "  + allMatches.checked )
                                    calculateDialog.accept()
                                    centralPoint.coordinate.latitude = pointMatcher.latitudeCentalPoint();
                                    centralPoint.coordinate.longitude = pointMatcher.longitudeCentalPoint();
                                    console.log ( "centralPoint.coordinate.latitude " + centralPoint.coordinate.latitude)

                                }
                            }

                            Button {
                                text: "Відмінити"
                                onClicked: {
                                    // Дії при натисканні кнопки Відмінити
                                    calculateDialog.reject()
                                }
                            }
                        }
                    }
                }
            }
//            Rectangle {
//                id: calculatePosition
//                width: parent.width - 20
//                anchors.horizontalCenter: parent.horizontalCenter
//                height: 40
//                radius: 10
//                color: parent.parent.color
//                border.width: 2
//                border.color:  "white"
//            }
        }
    }
}
