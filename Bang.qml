import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: bang
    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property int size: 35
    property string label: ""

    signal triggered( )

    width: size
    height: size

    Timer {
        id: timer
        interval: 100
        onTriggered: {
            circle.color = bang.secondColor
        }
    }

    Rectangle {
        id: circle
        width: parent.width
        height: parent.height
        radius: parent.width / 2
        border.width: 1
        border.color: parent.color
        color: parent.secondColor

        MouseArea {
            id: hoverArea
            property bool hovered: false

            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                triggered( )
                parent.color = bang.color
                timer.start( )
            }
            onEntered: {
                hovered = true
            }
            onExited: {
                hovered = false
            }
        }

    }

    DropShadow {
        visible: hoverArea.hovered
        anchors.fill: circle
        radius: 6
        samples: 20
        color: Qt.rgba( bang.color.r, bang.color.g, bang.color.b, bang.color.a * 0.3  )
        //color: horizontalSlider.color
        source: circle
    }

    Text {
        text: label
        color: parent.color
        font.pointSize: size / 5 < 6 ? 6 : size / 5
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -size / 2 - font.pointSize
    }
}
