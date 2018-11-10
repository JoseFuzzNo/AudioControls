import QtQuick 2.0

Item {
    id: root

    property int octaves: 1
    readonly property int keys: octaves * 12
    property int startOctave: 4
    readonly property int startNote: startOctave * 12
    property int velocity: 127
    property string mode: "normal"

    property int keySize: 30
    readonly property int blackKeyHeight:  root.height / 1.5
    height: 100
    width: keySize * ( 7 * octaves)

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
        var whiteKeysCount = parseInt( x / keySize );
        var octavesCount = parseInt( whiteKeysCount / 7 ); // 7 White keys in an octave
        var index = octavesCount * 12;
        if ( y < blackKeyHeight ) { // Maybe black key
            var indexLengths = [0.6, 0.8, 0.2, 0.8, 0.6, 0.6, 0.8, 0.2, 0.8, 0.2, 0.8, 0.6];
            var lengthCounter = 0;
            for ( var i in indexLengths ) {
                lengthCounter += indexLengths[i] * keySize;
                if ( x < lengthCounter + octavesCount * keySize * 7 ) {
                    index += parseInt( i );
                    break;
                }
            }
        } else {    // White key
            index += ( whiteKeysCount % 7 ) * 2;
            if ( whiteKeysCount % 7 > 2 )
                index--;
        }

        if ( index >= root.keys )
            index = root.keys - 1;
        else if ( index < 0 )
            index = 0;
        return index;
    }

    function locateIndex( index ) {
        var octavesSinceStart = Math.floor( index / 12 );
        var nt = noteType( index + startNote );
        var xPosition = octavesSinceStart * 7 * keySize;
        if ( nt ) { // Si la nota es negra
            xPosition += keySize / 2;
            index--;
        }
        var indexInOctave = Math.ceil( ( ( index + startNote ) % 12 ) / 2 )
        xPosition += keySize * indexInOctave;
        return {
            //x: index * keySize,
            x: nt ? xPosition + root.keySize * 0.1 : xPosition,
            y: 0,
            z: nt ? 0 : -1,
            height: nt ? blackKeyHeight : root.height,
            width: nt ? root.keySize * 0.8 : root.keySize
        }
    }

    function updateKeyboard( index, value ) {
        switch ( mode ) {
        case "normal":
            repeater.itemAt( index ).color = value ? mainColor : noteType( index + startNote ) ? root.fourthColor : root.secondColor
            statusChanged( index + startNote, value * velocity )
            break;
        case "toggle":
            if ( value ) {
                if (  repeater.itemAt( index ).color === mainColor ) {
                    repeater.itemAt( index ).color = noteType( index + startNote ) ? root.fourthColor : root.secondColor;
                    statusChanged( index + startNote, 0 )
                } else {
                    repeater.itemAt( index ).color = mainColor
                    statusChanged( index + startNote , velocity )
                }
            }

            break;
        case "justOne":
            if ( value ) {
                for ( var i = 0; i < keys; i++ ) {
                    if ( repeater.itemAt( i ).color === mainColor ) {
                        repeater.itemAt( i ).color = noteType( i + startNote ) ? root.fourthColor : root.secondColor;
                        statusChanged( i + startNote, 0 )
                        break;
                    }
                }
                repeater.itemAt( index ).color = mainColor;
                statusChanged( index + startNote, velocity );
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
        //color: "red"
        radius: 2
        z: -10
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

            property color color: noteType( index + startNote ) ? root.fourthColor : root.secondColor
            property real scale: 1
            property var location: locateIndex( index )

            height: location.height
            width: location.width
            x: location.x
            z: location.z


            Rectangle {
                clip: true
                color: parent.color
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
