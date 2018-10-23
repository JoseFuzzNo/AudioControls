
import QtQuick 2.0

Item {
    id: root

    property int rows: 3
    property int columns: 3
    property string mode: "normal"
    property string buttonShape: "rectangle"
    property int size: 30

    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property color thirdColor: "yellow"
    property color backgroundColor: "transparent"

    property alias background: background

    property variant symbols: []

    width: size * columns
    height: size * rows

    signal statusChanged( var row, var column, int value )

    function updateGrid( index, value ) {
        var row, column;
        switch ( mode ) {
        case "normal":
            repeater.itemAt( index ).color = value ? color : secondColor
            row = parseInt( index / columns );
            column = index % columns;
            statusChanged( row, column, value )
            break;
        case "toggle":
            if ( value ) {
                row = parseInt( index / columns );
                column = index % columns;
                if (  repeater.itemAt( index ).color === color ) {
                    repeater.itemAt( index ).color = secondColor;
                    statusChanged( row, column, 0 )
                } else {
                    repeater.itemAt( index ).color = color
                    statusChanged( row, column, 1 )
                }
            }

            break;
        case "justOne":
            if ( value ) {
                for ( var i = 0; i < rows * columns; i++ ) {
                    if ( repeater.itemAt( i ).color === color ) {
                        repeater.itemAt( i ).color = secondColor;
                        statusChanged( parseInt( index / columns ), index % columns, 0 )
                    }
                }
                repeater.itemAt( index ).color = color;
                row = parseInt( index / columns );
                column = index % columns;
                statusChanged( row, column, 1 );
            }

            break;
        case "onePerColumn":
            function updateColumn( col ) {
                for ( var i = 0; i < rows; i++ ) {
                    repeater.itemAt( col + i * columns ).color = secondColor;
                }
                repeater.itemAt( index ).color = color;
            }
            if ( value ) {
                column = index % columns;
                updateColumn( column );
            }
            break;
        default:
            break;
        }

        // Se anima el plano del boton
        repeater.itemAt( index ).scale = value ? 1.1 : 1;
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.backgroundColor
        radius: 2
    }

    MouseArea {
        anchors.fill: parent
        property int lastIndex: 0

        onPressed: {
            var column = parseInt( mouseX / size );

            var row = parseInt( mouseY / size );
            var index = column + row * root.columns;
            updateGrid( index, 1 );
            lastIndex = index;
        }
        onPositionChanged: {
            var column = parseInt( mouseX / size );
            if ( column >= root.columns )
                column = root.columns - 1;
            else if ( column < 0 )
                column = 0;
            var row = parseInt( mouseY / size );
            if ( row >= root.rows )
                row = root.rows - 1;
            else if ( row < 0 )
                row = 0;
            var index = column + row * root.columns;

            if ( index != lastIndex ) {
                updateGrid( lastIndex, 0 );
                lastIndex = index;
                updateGrid( index, 1 );

            }
        }
        onReleased: {
            var column = parseInt( mouseX / size );
            if ( column >= root.columns )
                column = root.columns - 1;
            else if ( column < 0 )
                column = 0;
            var row = parseInt( mouseY / size );
            if ( row >= root.rows )
                row = root.rows - 1;
            else if ( row < 0 )
                row = 0;
            var index = column + row * root.columns;
            updateGrid( index, 0 );
        }

        Grid {
            id: grid
            rows: root.rows
            columns: root.columns
            Repeater {
                id: repeater
                model: rows * columns
                Item {
                    width: root.size
                    height: root.size
                    property color color: root.secondColor
                    property real scale: 1

                    Rectangle {
                        clip: true
                        color: parent.color
                        scale : parent.scale
                        Behavior on color {
                            ColorAnimation {
                                duration: 50
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                            }
                        }

                        anchors.rightMargin: root.size / 20
                        anchors.leftMargin: anchors.rightMargin
                        anchors.bottomMargin: root.size / 20
                        anchors.topMargin: anchors.bottomMargin
                        anchors.fill: parent
                        radius: {
                            switch ( root.buttonShape ) {
                            case "rectangle":
                                return root.size / 10
                            case "circle":
                                return root.size / 2
                            default: // square
                                return root.size / 10
                            }

                        }

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: symbols[index] !== undefined ? symbols[index] : ""
                            color: root.thirdColor
                        }
                    }
                }
            }
        }
    }

}
