import QtQuick 2.0

Item {
    id: root

    width: 40
    height: 20

    // Properties
    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property color thirdColor: "yellow"

    property string label: ""

    property alias value: number.value
    property alias from: number.from
    property alias to: number.to
    property alias stepSize: number.stepSize
    property alias digits: number.digits
    property alias cornerShape: number.cornerShape


    // Elements
    Row {
        Rectangle {
            width: labelText.width + 10
            height: root.height

            color: "transparent"
            border.color: root.secondColor

            Text {
                id: labelText
                anchors.centerIn: parent
                text: root.label
                font.pointSize: 7
                color: root.secondColor
            }
        }
        Number {
            id: number
            color: root.color
            secondColor: root.secondColor
            height: root.height
        }
    }
}
