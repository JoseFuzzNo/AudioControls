import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4

Item {
    id: root
    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property string text: "TextButton"
    signal pressed
    signal released

    Component.onCompleted: {
        width = btnText.width + 10
    }

    onPressed: {
        clickAnimation.stop( )
        clickAnimation.start( )
    }

    onReleased: {
    }


    ColorAnimation {
        id: clickAnimation
        from: color
        to: secondColor
        duration: 100
        target: background
        properties: "color"
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.secondColor
        //border.color: root.color
        radius: 1
    }

    Text {
        id: btnText
        text: root.text
        anchors.centerIn: parent
        anchors.horizontalCenter: Text.horizontalCenter
        color: root.color
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: {
            root.pressed( );
        }
        onReleased: {
            root.released( );
        }

    }

}
