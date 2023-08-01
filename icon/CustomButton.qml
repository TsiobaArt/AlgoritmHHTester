import QtQuick 2.15
import QtQuick.Window 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

Rectangle {
    id: custombutton
    width: 100
    height: 35
    radius: 5
    color: "transparent"
    border.width: 2
    border.color: "black"

    property alias textColor: textBut.color
    property string  textButton: ""
    property int fontSize: 16

    signal pressCustomButton()

    Text {
        id : textBut
        text : textButton
        anchors.centerIn: parent
        font.family: "Roboto"
        color: "black"

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered:  {   }
        onPressed:  { parent.scale = 0.9 }
        onReleased: {
            parent.scale = 1
        }
        onClicked: {
            pressCustomButton();
        }
        onExited: { parent.scale = 1}

    }
}
