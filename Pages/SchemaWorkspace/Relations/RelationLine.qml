import QtQuick
import QtQuick.Shapes
import QtQuick.Controls

Item {
    id: root

    property Item fromCard: null
    property Item toCard: null
    property int fromField: -1
    property int toField: -1
    property string relType: "1:M"

    property bool isPreview: false
    property point previewEnd: Qt.point(0, 0)

    signal removeRequested()

    visible: fromCard !== null && (isPreview || toCard !== null)

    // линия берет цвет таблицы откуда начата связь при наведении на бейдж красная
    readonly property color fromColor: badgeMouseArea.containsMouse ? "#ef4444" : (fromCard ? fromCard.tableColor : "#52d6a6")
    readonly property color toColor: badgeMouseArea.containsMouse ? "#ef4444" : (toCard ? toCard.tableColor : fromColor)
    readonly property color lineColor: fromColor

    readonly property real gap: 40
    readonly property bool toIsRight: toCard !== null && fromCard !== null
                                      && toCard.x > fromCard.x + fromCard.width + gap
    readonly property bool toIsLeft: toCard !== null && fromCard !== null
                                     && toCard.x + toCard.width + gap < fromCard.x

    readonly property bool fromRight: isPreview
                                      ? (fromCard !== null && previewEnd.x >= fromCard.x + fromCard.width / 2)
                                      : !toIsLeft
    readonly property bool toRight: isPreview ? !fromRight : !toIsRight

    readonly property point p1: fromCard ? fromCard.portPoint(fromField, fromRight) : Qt.point(0, 0)
    readonly property point p2: isPreview ? previewEnd
                                          : (toCard ? toCard.portPoint(toField, toRight) : Qt.point(0, 0))

    readonly property int dir1: fromRight ? 1 : -1
    readonly property int dir2: toRight ? 1 : -1
    readonly property real bend: Math.max(50, Math.abs(p2.x - p1.x) / 2)

    readonly property string fromLabel: relType === "M:1" ? "M" : "1"
    readonly property string toLabel: relType === "1:M" ? "M" : "1"

    Shape {
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.lineColor
            strokeWidth: 2
            strokeStyle: root.isPreview ? ShapePath.DashLine : ShapePath.SolidLine
            dashPattern: [4, 3]
            fillColor: "transparent"

            startX: root.p1.x
            startY: root.p1.y

            PathCubic {
                x: root.p2.x
                y: root.p2.y
                control1X: root.p1.x + root.dir1 * root.bend
                control1Y: root.p1.y
                control2X: root.p2.x + root.dir2 * root.bend
                control2Y: root.p2.y
            }
        }
    }

    Text {
        visible: !root.isPreview
        text: root.fromLabel
        color: root.fromColor
        font.family: "Monospace"
        font.pixelSize: 11
        font.bold: true
        x: root.fromRight ? root.p1.x + 6 : root.p1.x - 6 - width
        y: root.p1.y - height - 1
    }

    Text {
        visible: !root.isPreview
        text: root.toLabel
        color: root.toColor
        font.family: "Monospace"
        font.pixelSize: 11
        font.bold: true
        x: root.toRight ? root.p2.x + 6 : root.p2.x - 6 - width
        y: root.p2.y - height - 1
    }

    Rectangle {
        id: badge
        visible: !root.isPreview

        readonly property real midX: (root.p1.x + root.p2.x) / 2 + 0.375 * root.bend * (root.dir1 + root.dir2)
        readonly property real midY: (root.p1.y + root.p2.y) / 2

        x: midX - width / 2
        y: midY - height / 2
        width: badgeText.implicitWidth + 10
        height: 16
        radius: 4
        color: "#121721"
        border.width: 1
        border.color: root.lineColor

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: root.relType
            color: root.lineColor
            font.family: "Monospace"
            font.pixelSize: 9
            font.bold: true
        }

        MouseArea {
            id: badgeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: badgeMenu.open()
        }

        Menu {
            id: badgeMenu
            y: badge.height + 4
            width: 110
            padding: 4

            background: Rectangle {
                color: "#11151c"
                border.color: "#252c37"
                border.width: 1
                radius: 8
            }

            MenuItem {
                id: delRelation
                text: "Del Relation"
                implicitHeight: 28
                onTriggered: root.removeRequested()

                contentItem: Text {
                    text: delRelation.text
                    color: delRelation.highlighted ? "#ef4444" : "#a1a9b7"
                    font.family: "Monospace"
                    font.pixelSize: 10
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 6
                }

                background: Rectangle {
                    radius: 4
                    color: delRelation.highlighted ? "#3d141b" : "transparent"
                }
            }
        }
    }
}
