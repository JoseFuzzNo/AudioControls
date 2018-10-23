/*!
    \qmltype Knob
    \brief Dial control similar to Ableton's Live knobs.

    It has different tapers for different applications and
    it can be used as a standard knob or as a centered or
    inverted knob.

    \qmlproperty int Knob::curve

    Curva aplicada al control, siendo el valor introducido
    la base del logarítmo que genera la curva.

    \qmlmethod void Knob::applyCurve( int value )

    Se aplica la curva a un valor introducido. La curva
    estará definida por el valor de la propiedad "curve".

    \qmlmethod void Knob::removeCurve( int value )

    Paso inverso para eliminar la curva del valor del knob.
    La curva estará definida por el valor de la propiedad
    "curve".
*/



import QtQuick 2.0



Item {
    id: root

    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property color thirdColor: "yellow"
    property double from: 0
    property double to: 1
    property double value: 0
    property double showedValue: value
    property double steps: 100
    property int size: 35
    property string label: ""
    property bool showValue: true
    property string units: ""
    property int decimals: 0
    property int decimalsOnKiloUnit: decimals
    property int decimalsOnMegaUnit: decimals
    property int curve: 0
    property string mode: "normal"
    width: size + 10
    height: label === "" ? size + 15 : size + 30

    function applyCurve( value ) {
        switch ( curve ) {
        case 0:
            return value;
        default:
            var exp = Math.pow( 2, curve * 2 );
            var zeroToOne = ( value - from ) / ( to - from );
            var expValue = Math.pow( exp, zeroToOne );
            expValue = ( expValue - 1 /* exp min */ ) /
                    ( exp - 1 /* exp max - exp min */ );
            return expValue * ( to - from ) + from;

        }
    }
    function removeCurve( value ) {
        switch ( curve ) {
        case 0:
            return value;
        default:
            var exp = Math.pow( 2, curve * 2 );
            var oneToExp = ( value - from ) / ( to - from ) * ( exp - 1 ) + 1;
            var normalValue = Math.log( oneToExp ) / Math.log( exp );
            normalValue = normalValue * ( to - from ) + from;
            return normalValue;
        }
    }

    Component.onCompleted: {
        if ( value < from )
            value = from
        else if ( value > to )
            value = to
    }

    onValueChanged: {
        showedValue = value;
    }
    onShowedValueChanged: {
        canvas.requestPaint( );
    }

    onColorChanged: {
        canvas.requestPaint( );
        back.requestPaint( );
    }

    onSecondColorChanged: {
        canvas.requestPaint( );
        back.requestPaint( );
    }

    Behavior on showedValue {
        PropertyAnimation {
            duration: 50
        }
    }

    Item {
        width: size
        height: size
        anchors.centerIn: parent
        Canvas {
            id: canvas
            antialiasing: true
            anchors.fill: parent
            onPaint: {
                var ctx = getContext( "2d" )
                ctx.reset( )
                ctx.lineWidth = 2
                ctx.lineCap = "round"

                var startAngle;
                switch ( root.mode ) {
                case "normal":
                    startAngle = 0.7 * Math.PI;
                    break;
                case "centered":
                    startAngle = 1.5 * Math.PI;
                    break;
                case "inverted":
                    startAngle = 2.3 * Math.PI;
                    break;
                default:
                    startAngle = 0.7 * Math.PI;
                    break;
                }

                var finalAngle = ( ( 2.3 - 0.7 ) * ( removeCurve( showedValue ) - from ) / ( to - from ) + 0.7 ) * Math.PI

                var direction = startAngle > finalAngle;

                ctx.beginPath( );
                ctx.strokeStyle = secondColor
                ctx.moveTo( size/2, size/2 )
                ctx.lineTo( size/2 + ( size/2 - ctx.lineWidth ) * Math.cos( finalAngle ) , size/2 + ( size/2 - ctx.lineWidth ) * Math.sin( finalAngle ) )
                ctx.stroke( )



                ctx.beginPath( );
                ctx.fillStyle = "transparent"
                ctx.strokeStyle = direction ? root.thirdColor : root.color
                if ( hoverArea.hovered ) {
                    ctx.shadowBlur = 1
                    ctx.shadowColor = Qt.rgba( color.r, color.g, color.b, color.a / 3 )
                }

                ctx.arc(size/2, size/2, size/2 - ctx.lineWidth, startAngle, finalAngle, direction)
                ctx.fill();
                ctx.stroke();



            }
        }

        Canvas {
            id: back
            anchors.fill: parent
            //opacity: 0.5
            z: -1
            onPaint: {
                var ctx = getContext( "2d" )
                ctx.reset( )
                ctx.beginPath( );
                ctx.fillStyle = "transparent"
                ctx.strokeStyle = secondColor
                ctx.lineWidth = 2
                ctx.lineCap = "round"
                var startAngle = 0.7 * Math.PI
                var finalAngle = (2.3)*Math.PI
                ctx.arc(size/2, size/2, size/2 - ctx.lineWidth, startAngle, finalAngle, false)
                ctx.fill();
                ctx.stroke();
            }
        }

        MouseArea {
            id: mouseArea
            property variant mouseInit: Qt.point( 0, 0 )
            property double valueInit: 0
            property bool shift: false

            anchors.fill: parent
            onPressed: {
                mouseInit = Qt.point( mouseX, mouseY )
                valueInit = removeCurve( value )
                if ( ( mouse.button === Qt.LeftButton ) && ( mouse.modifiers & Qt.ShiftModifier ) ) {
                    shift = true;
                    console.log( "Left")
                } else {
                    shift = false;
                }
            }

            onPositionChanged: {
                var dy = ( mouseInit.y - mouseY ) / steps * ( to - from );
                if ( shift ) {
                    dy /= 10;
                }
                var adjustedValue = applyCurve( valueInit + dy );
                if ( adjustedValue > to )
                    adjustedValue = to;
                else if ( adjustedValue < from )
                    adjustedValue = from;

                value = adjustedValue;
            }

            onWheel: {
                var delta = wheel.angleDelta.y / 24 / steps * ( to - from );
                if (  wheel.modifiers & Qt.ShiftModifier ) {
                    delta /= 10;
                }

                var adjustedValue = applyCurve( removeCurve( value ) + delta );
                if ( adjustedValue > to )
                    adjustedValue = to
                else if ( adjustedValue < from )
                    adjustedValue = from
                value = adjustedValue
            }
        }
        MouseArea {
            z: -1
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true

            property bool hovered: false
            onHoveredChanged: {
                canvas.requestPaint( )
            }

            onEntered: {
                hovered = true
            }
            onExited: {
                hovered = false
            }
        }

    }

    Text {
        text: label
        color: parent.color
        font.pointSize: size / 5
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -size / 2 - font.pointSize
    }

    Text {
        visible: showValue
        text: {
            if ( units === "" )
                return value.toFixed( decimals );
            if ( units === "%" )
                return ( value * 100 ).toFixed( decimals ) + " %";
            if ( units === "dB" ) {
                //text.replace( "Infinity", "" );
                // TODO reemplazar el texto de /Infinity por el simbolo

                var text;
                if ( value === 0 ) {
                    //text = "-∞"
                    text = "-\u221e"
                } else {
                    var dBs = 20 * Math.log( value ) / Math.LN10;
                    text = dBs >= 0 ? "+" : "";
                    text += dBs.toFixed( decimals );
                }

                text += " dB";
                return text;
            }
            else {
                var adjustedValue = value
                var adjustedUnit = units
                var adjustedDecimals = decimals
                if ( value > 1000000 ) {
                    adjustedValue = units == "ms" ? value / 1000 : value / 1000000
                    adjustedUnit = units == "ms" ? "s" : "M" + units
                    adjustedDecimals = decimalsOnMegaUnit
                } else if ( value > 1000 ) {
                    adjustedValue = value / 1000
                    adjustedUnit = units == "ms" ? "s" : "K" + units
                    adjustedDecimals = decimalsOnKiloUnit
                }

                return adjustedValue.toFixed( adjustedDecimals ) + " " + adjustedUnit
            }
        }
        color: parent.color
        font.pointSize: size / 5
        anchors.centerIn: parent
        anchors.verticalCenterOffset: size / 2 + font.pointSize
    }
}
