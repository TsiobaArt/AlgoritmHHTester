import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
Popup {
    id: settingsDialog
    modal: true
    width: 450
    height: 500
    closePolicy: Popup.NoAutoClose
    anchors.centerIn: parent
    background: Rectangle {
        color: "#5E5E5E"
    }

    Rectangle {
        id: rectBackground
        anchors.fill: parent
        radius: 10
        color: "#A6A1A1"
        opacity: 0.7
        border.width: 2
        border.color:"gray"
    }
    Rectangle {
        id: recDialog
        anchors.fill: parent
        radius: 10
        color: "#5E5E5E"
        border.width: 2
        border.color: "gray"
        ScrollView {
            id: scrollView
            width: parent.width - 20
            height: parent.height - rowButt.height - rowButt.anchors.bottomMargin - 20
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            ListView {
                id: listView
                width: parent.width
                //                height: parent.height - rowButt.height - rowButt.anchors.bottomMargin - 10
                height: parent.height
                model: sessionModel
                clip: true
                spacing: 10

                property int selectedIndex: -1  // Властивість для зберігання індексу виділеного елемента
                property var tableName: model.tableName
                property var notes: model.notes
                property var sessionName: model.sessionName

                delegate: Item {
                    id: itemDelegate
                    width: recDialog.width - 20
                    height: 73

                    Component.onCompleted: {
                        if (listView.model.count > 0) {
                            itemDelegate.anchors.horizontalCenter = parent.horizontalCenter
                        } else {
                            itemDelegate.anchors.horizontalCenter = undefined
                        }
                    }
                    Rectangle {
                        id: recBorder
                        width: parent.width - 30
                        height: parent.height
                        color:  "transparent" // Змінюємо колір в залежності від того, чи обрано цей елемент
                        radius: 5
                        border.width: 2
                        anchors.horizontalCenter: parent.horizontalCenter

                        border.color:listView.selectedIndex === index  ? "white" :  "grey"
                        Text {

                            id: textArea
                            width: parent.width - 20 // Віднімаємо 10px з кожного боку для створення відступу
                            height: parent.height - 10 // Віднімаємо 10px з кожного боку для створення відступу
                            anchors.centerIn: parent
                            color: "white"
                            wrapMode: Text.Wrap
                            text: "Назва сесії: " +  tableName + "\n" +
                                  "Короткий опис: " +  sessionName + "\n" +
                                  "Нотатка: " + notes
                            font.pointSize: 9
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            listView.selectedIndex = index; // Встановлюємо індекс обраного елемента
                            panelIntrument.uploadTestDataBase.customComboBox.currentText = tableName
                            pointMatcher.downloadDBTecAndId(tableName)
                            panelIntrument.uploadTestDataBase.tickModel.clear()
                            var dataTic = pointMatcher.getMapTicAndId()

                            var keys = Object.keys(dataTic)
                            for (var key in dataTic) {
                                panelIntrument.uploadTestDataBase.tickModel.append({"id": dataTic[key].id, "ticCount": dataTic[key].ticCount})

                            }

                        }
                    }
                }
            }
        }



        Row {
            id: rowButt
            anchors.bottomMargin:   10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            anchors.bottom: parent.bottom

            CustomButton {
                id: buttonSave
                textButton: "Відкрити"
                onPressCustomButton: {
                    settingsDialog.close()
                    listView.selectedIndex = -1

                }
            }

            CustomButton {
                id: buttonCancel
                textButton: "Відмінити"
                onPressCustomButton: {
                    settingsDialog.close()
                    panelIntrument.uploadTestDataBase.customComboBox.currentText = "Відкрити сессію"
                    listView.selectedIndex = -1

                }
            }
        }
    }
}
