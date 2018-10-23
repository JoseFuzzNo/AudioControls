import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    id: root

    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property double from: 0
    property double to: 0
    property double value: 0
    property double stepSize: 1
    property int decimals: 0
    property int digits: 3
    property string cornerShape: "truncated"

    width: valueText.font.pointSize * ( digits + 1 )
    height: 20

    Component.onCompleted: {
        if ( value < from )
            value = from
        else if ( value > to )
            value = to
    }

    Canvas {
        antialiasing: true
        anchors.fill: parent
        onPaint: {
            var ctx = getContext( "2d" );
            var cornerRadius = height / 4;

            ctx.reset( );
            ctx.moveTo( 0, 0 );
            ctx.lineTo( width - cornerRadius, 0 );
            switch ( root.cornerShape ) {
            case "rounded":
                //ctx.arcTo( width - cornerRadius, 0, width, cornerRadius, cornerRadius );
                ctx.arc(width - cornerRadius, cornerRadius, cornerRadius, Math.PI / 2, 0, false );
                //ctx.moveTo( width, cornerRadius );
                break;
            case "square":
                ctx.lineTo( width, 0 );
                ctx.lineTo( width, cornerRadius );
                break;
            case "truncated":
            default:
                ctx.lineTo( width, cornerRadius );
                break;
            }
            ctx.lineTo( width, height );
            ctx.lineTo( 0, height );



            ctx.closePath( );
            ctx.fillStyle = root.secondColor
            ctx.fill( );

        }
    }

    Text {
        id: valueText
        text: root.value.toFixed( decimals )
        font.pointSize: parent.height / 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: ( parent.height - font.pixelSize ) / 2
        //anchors.horizontalCenter: Text.horizontalCenter
        color: root.color
    }

    MouseArea {
        id: mouseArea
        property variant mouseInit: Qt.point( 0, 0 )
        property double valueInit: 0
        property bool shift: false

        anchors.fill: parent
        onPressed: {
            mouseInit = Qt.point( mouseX, mouseY )
            valueInit = value
            if ( ( mouse.button === Qt.LeftButton ) && ( mouse.modifiers & Qt.ShiftModifier ) ) {
                shift = true;
            } else {
                shift = false;
            }
        }

        onPositionChanged: {
            var dy = ( mouseInit.y - mouseY ) * stepSize;
            if ( shift )
                dy /= 10;
            var adjustedValue = valueInit + dy;
            if ( to !== from ) {    // If 'to' equals 'from' the limits are ignored
                if ( adjustedValue > to )
                    adjustedValue = to;
                else if ( adjustedValue < from )
                    adjustedValue = from;
            }

            root.value = adjustedValue.toFixed( decimals );
        }

        onWheel: {
            var delta = wheel.angleDelta.y / 120 * Math.max( stepSize, 1 / Math.pow( 10, decimals ) );
            var adjustedValue = root.value + delta;
            if ( to !== from ) {
                if ( adjustedValue > root.to )
                    adjustedValue = root.to
                else if ( adjustedValue < root.from )
                    adjustedValue = root.from
            }
            root.value = adjustedValue.toFixed( decimals );
        }
    }

}
