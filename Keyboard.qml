import QtQuick 2.0

Item {
    id: root

    property int octaves: 1
    readonly property int keys: octaves * 12 + 1
    property int startNote: 48
    property string mode: "normal"

    property int keySize: 30
    height: 100
    width: keySize * ( 6 * octaves + 1 )

    property color mainColor: "orange"
    property color secondColor: "#444444"
    property color thirdColor: "yellow"
    property color fourthColor: "#393939"
    property color backgroundColor: "#333333"

    property alias background: background

    property variant symbols: []

    signal statusChanged( var key, int value )

    function noteType( note ) {
        var octNote = ( note % 12 );
        var blacks = [1, 3, 6, 8, 10];
        for ( var i in blacks ) {
           if ( octNote === blacks[i] )
               return 1;   // BLACK
        }
        return 0;       // WHITE
    }

    function calculateIndex( x, y ) {
        var index = parseInt( x / keySize );
        if ( index >= root.keys )
            index = root.keys - 1;
        else if ( index < 0 )
            index = 0;
        return index;
    }

    function locateIndex( index ) {
        return {
            x: index * keySize,
            y: 0,
            height: noteType( index ) ? root.height / 2 : root.height
        }
    }

    function updateKeyboard( index, value ) {
        switch ( mode ) {
        case "normal":
            repeater.itemAt( index ).color = value ? mainColor : noteType( index ) ? root.fourthColor : root.secondColor
            statusChanged( index + startNote, value )
            break;
        case "toggle":
            if ( value ) {
                if (  repeater.itemAt( index ).color === mainColor ) {
                    repeater.itemAt( index ).color = noteType( index ) ? root.fourthColor : root.secondColor;
                    statusChanged( index + startNote, 0 )
                } else {
                    repeater.itemAt( index ).color = mainColor
                    statusChanged( index, 1 )
                }
            }

            break;
        case "justOne":
            if ( value ) {
                for ( var i = 0; i < keys; i++ ) {
                    if ( repeater.itemAt( i ).color === mainColor ) {
                        repeater.itemAt( i ).color = noteType( index ) ? root.fourthColor : root.secondColor;
                        statusChanged( index, 0 )
                    }
                }
                repeater.itemAt( index ).color = mainColor;
                statusChanged( index, 1 );
            }

            break;
        default:
            break;
        }
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
            var index = calculateIndex( mouseX, mouseY );
            updateKeyboard( index, 1 );
            lastIndex = index;
        }
        onPositionChanged: {
            var index = calculateIndex( mouseX, mouseY );

            if ( index !== lastIndex ) {
                updateKeyboard( lastIndex, 0 );
                lastIndex = index;
                updateKeyboard( index, 1 );

            }
        }
        onReleased: {
            var index = calculateIndex( mouseX, mouseY );

            updateKeyboard( index, 0 );
        }
    }

    Repeater {
        id: repeater
        model: keys
        Item {
            width: root.keySize
            //height: root.height
            property color color: noteType( index ) ? root.fourthColor : root.secondColor
            property real scale: 1

            x: locateIndex( index ).x
            height: locateIndex( index ).height

            Rectangle {
                clip: true
                color: parent.color
                scale : parent.scale
                Behavior on color {
                    ColorAnimation {
                        duration: 50
                    }
                }
                anchors.rightMargin: root.keySize / 20
                anchors.leftMargin: anchors.rightMargin
                anchors.bottomMargin: root.keySize / 20
                anchors.topMargin: anchors.bottomMargin
                anchors.fill: parent
                radius: root.keySize / 10

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
