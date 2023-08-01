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
Rectangle {
    id: genereTest
    width: parent.width - 20
    anchors.horizontalCenter: parent.horizontalCenter
    height: 40
    radius: 10
    color: parent.parent.color
    border.width: 2
    border.color:  "white"
    property alias settingsDialog: settingsDialog
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
                        settingsDialog.accept()
                    }
                }

                Button {
                    text: "Відмінити"
                    onClicked: {
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
        }
    }
}
