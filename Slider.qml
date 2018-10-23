import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

Item {
    id: root

    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property color thirdColor: "#aaaaaa"
    property double from: 0
    property double to: 1
    property double value: 0
    property double showedValue: value
    property double stepSize: 1
    property string label: ""
    property bool showValue: true
    property string units: ""
    property int decimals: 0
    property bool mouseEnabled: true

    readonly property int orientation: root.width > root.height ? Qt.Horizontal : Qt.Vertical

    width: 150
    height: 20

    Component.onCompleted: {
        if ( value < from )
            value = from
        else if ( value > to )
            value = from
    }

    Behavior on showedValue {
        PropertyAnimation {
            duration: 50
        }
    }

    Item {
        id: slider
        anchors.fill: parent

        Rectangle {
            id: background
            anchors.fill: parent
            color: secondColor
            radius: 1
        }

        Rectangle {
            id: contentItem
            width: root.width * ( root.showedValue  - from ) / ( to - from )
            height: root.height * ( root.showedValue  - from ) / ( to - from )
            anchors.top: orientation === Qt.Horizontal ? parent.top : undefined
            //anchors.top: parent.top
            anchors.right: orientation === Qt.Vertical ? parent.right : undefined
            anchors.bottom: parent.bottom
            anchors.left: parent.left


            color: root.color
            radius: 1
        }

        DropShadow {
            visible: hoverArea.hovered && mouseEnabled
            anchors.fill: contentItem
            radius: 5
            samples: 20
            color: Qt.rgba( root.color.r, root.color.g, root.color.b, root.color.a * 0.9  )
            //color: horizontalSlider.color
            source: contentItem
        }

        MouseArea {
            anchors.fill: parent
            onWheel: {
                if ( mouseEnabled ) {
                    var auxValue = value += ( wheel.angleDelta.y / 120 ) * stepSize
                    if ( auxValue > to )
                        value = to
                    else if ( auxValue < from )
                        value = from
                    else
                        value = auxValue
                }

            }
            onPressed: {
                if ( mouseEnabled )
                    if ( orientation == Qt.Horizontal )
                        value = mouse.x / width * ( to - from ) + from
                    else if ( orientation == Qt.Vertical )
                        value = ( height - mouse.y ) / height * ( to - from ) + from
            }
            onPositionChanged: {
                if ( mouseEnabled ) {
                    var auxValue
                    if ( orientation == Qt.Horizontal )
                        auxValue = mouse.x / width * ( to - from ) + from
                    else if ( orientation == Qt.Vertical )
                        auxValue = ( height - mouse.y ) / height * ( to - from ) + from
                    if ( auxValue > to )
                        value = to
                    else if ( auxValue < from )
                        value = from
                    else
                        value = auxValue
                }
            }
        }

        MouseArea {
            z: -1
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true

            property bool hovered: false
            onEntered: {
                hovered = true
            }
            onExited: {
                hovered = false
            }
        }
    }

    Text {
        id: valueText

        visible: showValue
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        z:102
        color: thirdColor
        font.pointSize: 8

        text: {
            if ( units === "" )
                return value.toFixed( decimals )
            if ( units === "%" )
                return ( value * 100 ).toFixed( decimals ) + " %"
            else {
                var adjustedValue = value
                var adjustedUnit = units
                if ( value > 1000000 ) {
                    adjustedValue = value / 1000000
                    adjustedUnit = "M" + units
                } else if ( value > 1000 ) {
                    adjustedValue = value / 1000
                    adjustedUnit = "K" + units
                }

                return adjustedValue.toFixed( decimals ) + " " + adjustedUnit
            }
        }


    }

    Text {
        text: label
        color: root.color
        font.pointSize: 8
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height / 2 - font.pointSize
    }


}
