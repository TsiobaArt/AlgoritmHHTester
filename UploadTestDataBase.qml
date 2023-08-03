import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
//import QtQuick.Controls 1.4

import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Material 2.15
import QtQuick.Controls.Styles 1.4

//import Qt.labs.platform 1.1
///////////////////////////////////////////////////////////////////////////////////
Rectangle {
    id: uploadTestDataBase
    width: parent.width - 20
    anchors.horizontalCenter: parent.horizontalCenter
    height: 40
    color: parent.parent.color
    radius: 10
    border.width: 2
    border.color:  "white"
    property alias customComboBox: customComboBox
    property alias dataBaseDialog: dataBaseDialog
    property alias tickModel:tickModel

    property int selectIdTick: -1
    function convertModelToPoints(model) {
        var points = [];
        for (var i = 0; i < model.rowCount(); i++) {
            var obj = model.get(i);
            var lat = obj["latitude"];
            var lon = obj["longitude"];
            if (lat === undefined || lon === undefined) {
                console.log("Error: invalid data in row " + i);
            } else {
                points.push({"lat": lat, "lon": lon});
            }
        }
        return points;
    }

    ListModel {
        id: tickModel
    }

    Text {
        id: textTestDataBase
        text: qsTr("Дані з  DB")
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
                //                            ComboBox {
                //                                       id: myComboBox
                //                                       width: 200
                ////                                       model: ["session_14_06_07_33", "session_14_06_07_36"]
                //                                       model:sessionModel

                ////                                        model: sessionModel
                ////                                        displayText:  model.tableName

                //                                       currentIndex: 0 // No selection by default
                //                                   }
                //                            ComboBox {
                //                                id: myComboBox
                //                                width: 200
                //                                model: sessionModel
                //                                textRole: "tableName" // ви можете замінити "tableName" на ім'я поля, яке ви хочете відображати
                //                                currentIndex: 0

                //                            }
                Item {
                    id: customComboBox
                    width: 200
                    height: 30
                    property int currentIndex: -1
                    property string currentText: "Вікрити сессію"
                    property var model: sessionModel
                    signal activated(int index)
                    readonly property real itemHeight: 30  // Add this line

                    Rectangle {
                        id: comboBox
                        width: parent.width
                        height: parent.height
                        color: "lightgrey"
                        border.width: 1
                        border.color: "black"
                        Text {
                            anchors.centerIn: parent
                            text: customComboBox.currentText
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: settingsDialog.open()
                    }
                }


                Item {
                    id: ticItem
                    width: 200
                    height: 30
                    property int currentIndex: -1
                    property string currentText: "Обрати тік"
                    property var model: sessionModel
                    signal activated(int index)
                    readonly property real itemHeight: 30  // Add this line

                    Rectangle {
                        id: ticItemRec
                        width: parent.width
                        height: parent.height
                        color: "lightgrey"
                        opacity: tickModel.count > 0 ? 1 : 0.5
                        border.width: 1
                        border.color: "black"
                        Text {
                            anchors.centerIn: parent
                            text: ticItem.currentText
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: ticDialog.open()
                        enabled: tickModel.count > 0 ? true : false
                    }
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
                        width: 110

                    }

                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                Button {
                    text: "Підтвердити"
                    enabled: tickModel.count && selectIdTick > 0 ? true : false
                    onClicked: {
                        // Дії при натисканні кнопки Підтвердити

                        referencePointsModel = []
                        dataPointsModel = []
                        bestMatchingPointsModel.clear()
                        previousPointsModel.clear()

                        convertModelToPoints(referenceModel)
                        pointMatcher.convertQVariantListToPoints (convertModelToPoints(referenceModel));
                        pointMatcher.downloadDataBaseTest(poinSignalStrength.text, pointRcs.text,customComboBox.currentText,panelIntrument.uploadTestDataBase.selectIdTick)
                        referencePointsModel = pointMatcher.getReferencePoints()
                        dataPointsModel      = pointMatcher.getCandidatePoints()



                        // ----  фокус на нові точки
                        setCenterReferenceMap(referencePointsModel[0].lat,referencePointsModel[0].lon )
                        setCenterDataMap(dataPointsModel[0].lat,dataPointsModel[0].lon )
                        // ----  фокус на нові точки


                        dataBaseDialog.accept()
                        tickModel.clear()
                        panelIntrument.uploadTestDataBase.selectIdTick = -1
                    }
                }

                Button {
                    text: "Відмінити"
                    onClicked: {
                        dataBaseDialog.reject()
                        tickModel.clear()
                        panelIntrument.uploadTestDataBase.selectIdTick = -1
                    }
                }
            }

        }

    }
}
