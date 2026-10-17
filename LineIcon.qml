import QtQuick
import QtQuick.Shapes

// линейная иконка из svg пути прямо в коде без файлов картинок
// путь пишется в квадрате viewBox x viewBox и масштабируется под размер элемента
Item {
    id: root

    // команды svg пути например "M6 3.5L10.5 8L6 12.5"
    property string pathData
    property color color: "#7d8796"
    // толщина линии в единицах viewBox
    property real lineWidth: 1.5
    // размер квадрата в котором написан путь
    property real viewBox: 16

    implicitWidth: 14
    implicitHeight: 14

    Shape {
        width: root.viewBox
        height: root.viewBox
        // растягиваем рисунок viewBox под размер элемента
        scale: root.width / root.viewBox
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.pathData }
        }
    }

    Behavior on color { ColorAnimation { duration: 150 } }
}
