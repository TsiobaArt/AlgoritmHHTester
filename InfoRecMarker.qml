import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4


Rectangle {
    id: infoRecMarker
    width: 240
    height: 170
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 5
    anchors.rightMargin: 5
    color: "#7D7A7A"
    radius: 10
    opacity: 0.9
    border.width: 2
    border.color:  "lightblue"
    z: 1
    MouseArea {anchors.fill: parent}
    Column {
        spacing: 10
        anchors.fill: parent
        topPadding: 10
        Text {
            text: "Умовні позначення:"
            color: "white"
            font.pixelSize: 14
            opacity: 0.8
            anchors.horizontalCenter: parent.horizontalCenter

        }
        Row {
            spacing: 5
            anchors.left: parent.left
            anchors.leftMargin: 10
            Item {
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
                    anchors.verticalCenter: parent.verticalCenter

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

            }

            Text {
                text: " - Маркер з координатами."
                color: "white"
                opacity: 0.8
            }

        }

        Row {
            spacing: 5
            anchors.left: parent.left
            anchors.leftMargin: 10
            Image {
                id: image2
                width: 22
                height: 22
                source: "qrc:/icon/circle.svg"
                anchors.verticalCenter: parent.verticalCenter

            }

            Text {
                text: " - Проекція співпадінь."
                color: "white"
                opacity: 0.8
            }

        }

        Row {
            spacing: 5
            anchors.left: parent.left
            anchors.leftMargin: 10
            Image {
                id: image3
                width: 25
                height: 25
                source: "qrc:/icon/cross.svg"
                anchors.verticalCenter: parent.verticalCenter

            }

            Text {
                text: "- Співпадіння знайдено."
                color: "white"
                opacity: 0.8
            }

        }
        Row {
            spacing: 5
            anchors.left: parent.left
            anchors.leftMargin: 12
            Rectangle {
                id: recImgLine
                width: 18
                height: 2
                color: "red"
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 5
            }

            Text {
                text: " - Співставлення співпадінь."
                color: "white"
                opacity: 0.8
            }

        }
    }
}
