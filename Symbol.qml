import QtQuick 2.5

Item {
    id: itemSymbol

    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property string label: ""
    property string symbol: ""

    onSymbolChanged: {
        textInput.text = symbol
    }

    width: 150
    height: 20

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            border.width: 1
            border.color: secondColor
            radius: 2
            color: "transparent"
        }
        TextInput {
            id: textInput
            text: qsTr("Path to audio file...")
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 8
            color: itemSymbol.color
            selectByMouse: true
            selectionColor: secondColor
            clip: true
            onEditingFinished: {
                symbol = text
            }

        }
    }

    Text {
        text: label
        color: itemSymbol.color
        font.pointSize: 8
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height / 2 - font.pointSize

    }


}
