import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: root
    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property int size: 30
    property string label: ""
    property bool checked: false

    Component.onCompleted: {
        state = checked ? "CHECKED" : "UNCHECKED";
    }

    width: size
    height: size


    states: [
        State {
            name: "CHECKED"
            PropertyChanges { target: rectangle; color: root.color }
            PropertyChanges { target: root; checked: true }
        },
        State {
            name: "unchecked"
            PropertyChanges { target: rectangle; color: root.secondColor }
            PropertyChanges { target: root; checked: false }
        }

    ]
    state: "unchecked"
    transitions: [
        Transition {
            from: "UNCHECKED"
            to: "CHECKED"
            SequentialAnimation {
                NumberAnimation {
                    target: rectangle
                    property: "scale"
                    to: 1.3
                    duration: 50
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: rectangle
                    property: "scale"
                    to: 1
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        },
        Transition {
            from: "CHECKED"
            to: "UNCHECKED"
            SequentialAnimation {
                NumberAnimation {
                    target: rectangle
                    property: "scale"
                    to: 0.7
                    duration: 50
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: rectangle
                    property: "scale"
                    to: 1
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }
    ]

    Rectangle {
        id: rectangle
        width: parent.width - 2
        height: parent.height - 2
        anchors.centerIn: parent
        radius: 0
        //border.width: 1
        border.color: hoverArea.hovered ? parent.color : color
        Behavior on border.color {
            ColorAnimation {
                duration: 50
            }
        }

        color: parent.secondColor

        Behavior on color {
            ColorAnimation {
                duration: 50
            }
        }



        MouseArea {
            id: hoverArea
            property bool hovered: false

            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                if ( root.state === "UNCHECKED" ) {
                    root.state = "CHECKED"
                } else {
                    root.state = "UNCHECKED"
                }
            }
            onEntered: {
                //cursorShape = Qt.PointingHandCursor
                hovered = true
            }
            onExited: {
                hovered = false
            }
        }

    }

    /*DropShadow {
        visible: hoverArea.hovered
        anchors.fill: rectangle
        radius: 6
        samples: 20
        color: root.color
        opacity: 0.3
        //color: horizontalSlider.color
        source: rectangle
    }*/

    Text {
        text: label
        color: parent.color
        font.pointSize: size / 5 < 6 ? 6 : size / 5
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -size / 2 - font.pointSize
    }
}
