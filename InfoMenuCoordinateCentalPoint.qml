import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

///////////////////////////////////////////////////////////////////////////////////
Item {
    id: infoMenuCoordinateCentalPoint
    width: 180
    height:160
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: panelIntrument.horizontalCenter
    anchors.bottomMargin: 5

    property string latitudeR:"00.00000"
    property string longitudeR:"00.00000"

    property string latitudeС:"00.00000"
    property string longitudeС:"00.00000"


    property string diference: "000000"


    Rectangle {
        anchors.fill: parent
        color: "#646060"
        opacity: 0.7
        radius: 10
        Column {
            spacing: 10
            anchors.fill: parent
            anchors.topMargin: 10
            Text {id: textTittle; color: "white"; text: "Координати Головки";  horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; font.pointSize: 9;font.bold: true}
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {id: textLatitideReal; color: "white"; text: "Широта Реальна   -";  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
                Text {id: dataLatitideReal; color: "white"; text: latitudeR;  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
            }
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {id: textLongitudeReal; color: "white"; text: "Довгота Реальна   -";  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
                Text {id: dataLongitudeReal; color: "white"; text: longitudeR;  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
            }
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {id: textLatitideCalc; color: "white"; text: "Широта Розр.   -";  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
                Text {id: dataLatitideCalc; color: "white"; text: latitudeС;  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
            }
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {id: textLongitudeCalc; color: "white"; text: "Довгота Розр.   -";  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
                Text {id: dataLongitudeCalc; color: "white"; text: longitudeС;  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
            }
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {id: diferenceTittle; color: "white"; text: "Різниця -";  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
                Text {id: diferenceValue; color: "white"; text: longitudeС + " м.";  horizontalAlignment: Text.AlignHCenter; font.pointSize: 9; }
            }

        }
    }
}
