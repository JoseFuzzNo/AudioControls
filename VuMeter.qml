import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: root
    width: size + 30
    height: size / 2 + 30

    property int size: 100
    property double value: 0
    property color color: "#aabbdd"
    property color secondColor: "#444444"
    property color thirdColor: "yellow"

    property string label: "VU"

    Item {
        width: size
        height: size
        anchors.verticalCenterOffset: -10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.bottom


        CircularGauge {
            width: root.size
            height: root.size
            //anchors.fill: root
            minimumValue: -20
            maximumValue: 3
            value: root.value

            style: CircularGaugeStyle {
                property real xCenter: outerRadius
                property real yCenter: outerRadius
                readonly property real maxWarningStartAngle: maximumValueAngle - 45

                function toPixels(percentage) {
                    return percentage * outerRadius;
                }

                function degToRad(degrees) {
                    return degrees * (Math.PI / 180);
                }

                function radToDeg(radians) {
                    return radians * (180 / Math.PI);
                }

                minimumValueAngle: -60
                maximumValueAngle: 60
                tickmarkStepSize: 5
                labelStepSize: tickmarkStepSize
                labelInset: toPixels(-0.25)
                minorTickmarkCount: 1
                tickmark: Rectangle {
                    implicitWidth: 1.5
                    antialiasing: true
                    implicitHeight: toPixels(0.15)
                    color: root.secondColor
                }
                tickmarkLabel: Text {
                    color: root.color
                    //visible: styleData.value === 0 || styleData.value === 1
                    font.pixelSize: {
                        var pixelSize = toPixels(0.15)
                        if ( pixelSize < 7 )
                            return 7
                        return pixelSize

                    }
                    text: styleData.value
                }
                minorTickmark: null
                needle: Rectangle {
                    id: needle
                    y: outerRadius * 0.15
                    implicitWidth: 2
                    implicitHeight: outerRadius * 0.92
                    antialiasing: true
                    color: root.color
                }
                foreground: Item {
                    Rectangle {
                        width: outerRadius * 0.2
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: root.color
                    }
                }
                background: Item {
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();

                            //if (halfGauge) {
                                ctx.beginPath();
                                ctx.rect(0, 0, ctx.canvas.width, ctx.canvas.height / 2);
                                ctx.clip();
                            //}
                            /*ctx.beginPath();
                            ctx.strokeStyle = gauge.secondColor;
                            ctx.lineWidth = 2
                            ctx.arc(xCenter, yCenter, outerRadius - ctx.lineWidth / 2, outerRadius - ctx.lineWidth / 2, 0, Math.PI * 2);
                            ctx.stroke();*/

                            ctx.beginPath( );
                            ctx.fillStyle = "transparent"
                            ctx.strokeStyle = root.secondColor
                            ctx.lineWidth = 2
                            ctx.lineCap = "round"
                            var startAngle = 1.1 * Math.PI
                            var finalAngle = (-0.1)*Math.PI
                            ctx.arc(xCenter, yCenter, outerRadius - ctx.lineWidth / 2, startAngle, finalAngle, false)
                            ctx.fill();
                            ctx.stroke();

                            ctx.beginPath();
                            ctx.lineWidth = toPixels(0.15);
                            ctx.lineCap = "butt"
                            ctx.strokeStyle = root.color;
                            ctx.arc(outerRadius, outerRadius,
                                // Start the line in from the decorations, and account for the width of the line itself.
                                outerRadius - tickmarkInset - ctx.lineWidth / 2,
                                degToRad(maxWarningStartAngle - angleRange / (minorTickmarkCount + 1)),
                                finalAngle, false);
                            ctx.stroke();
                        }
                    }

                    Text {
                        //anchors.bottom: parent.verticalCenter
                        //anchors.bottomMargin: toPixels(0.3)
                        //anchors.horizontalCenter: parent.horizontalCenter
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: - root.height / 4
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 8
                        width: toPixels(0.3)
                        height: width
                        text: root.label
                        color: root.thirdColor
                    }
                }

            }


        }
    }
}
