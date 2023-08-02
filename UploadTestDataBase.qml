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

//                    Popup {
//                        id: popup
//                        width: mainWindow.width / 2
//                        height:  mainWindow.height / 2
//                        anchors.centerIn: parent
//                        closePolicy: Popup.NoAutoClose

//                        ListView {
//                            id: listView
//                            width: parent.width
//                            height: parent.height
//                            model: sessionModel
//                            delegate: ItemDelegate {
//                                width: listView.width
//                                height: customComboBox.itemHeight
//                                text: model.tableName
//                                highlighted: ListView.isCurrentItem
//                                onClicked: {
//                                    customComboBox.currentIndex = index
//                                    customComboBox.currentText = text
//                                    customComboBox.activated(index)
//                                    popup.close()
//                                }
//                            }
//                        }
//                    }
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
                    onClicked: {
                        // Дії при натисканні кнопки Підтвердити
                        console.log(customComboBox.currentText)

                        referencePointsModel = []
                        dataPointsModel = []
                        bestMatchingPointsModel.clear()
                        previousPointsModel.clear()

                        pointMatcher.downloadDataBaseTest(poinSignalStrength.text, pointRcs.text,customComboBox.currentText )
                        referencePointsModel = pointMatcher.getReferencePoints()
                        dataPointsModel      = pointMatcher.getCandidatePoints()


                        dataBaseDialog.accept()
                    }
                }

                Button {
                    text: "Відмінити"
                    onClicked: {
                        dataBaseDialog.reject()
                    }
                }
            }

        }

    }
}
