import QtQuick
import "Tables"

Item {
    id: canvasRoot

    clip: true // обрезка того что выходит за рамку

    property var tablesModel: null
    property int selectedTableIndex: -1

    property real panX: 0
    property real panY: 0

    property real zoom: 1.0

    readonly property real minZoom: 0.15
    readonly property real maxZoom: 3.0

    default property alias content: worldContainer.data

    Canvas {
        id: canvasGrid
        anchors.fill: parent

        readonly property real baseStep: 40

        // Запуск первой отрисовки при старте приложения
        Component.onCompleted: requestPaint()

        // создаем линии канваса
        onPaint: {
            let ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            // размер клетки пропорционально зуму
            let step = baseStep * canvasRoot.zoom

            while (step < 20) step *= 2

            let startX = canvasRoot.panX % step
            let startY = canvasRoot.panY % step

            ctx.strokeStyle = "#252f3f"
            ctx.lineWidth = 1
            ctx.beginPath()

            for (let x = startX; x < width; x += step) {
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
            }

            for (let y = startY; y < height; y += step) {
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
            }

            ctx.stroke() // фактическое нанесение краски на холст
        }
    }

    // Реакция на сдвиг, зум и изменение размеров окна
    onPanXChanged: canvasGrid.requestPaint()
    onPanYChanged: canvasGrid.requestPaint()
    onZoomChanged: canvasGrid.requestPaint()
    onWidthChanged: canvasGrid.requestPaint()
    onHeightChanged: canvasGrid.requestPaint()

    Item {
        id: worldContainer

        x: canvasRoot.panX
        y: canvasRoot.panY
        scale: canvasRoot.zoom

        transformOrigin: Item.TopLeft

        Repeater {
            model: canvasRoot.tablesModel
            delegate: TableCard {
                id: cardItem

                // сохраняем индекс таблицы для замыканий
                readonly property int currentTableIndex: index

                // исправлена опечатка (было seletedTableIndex)
                isSelected: canvasRoot.selectedTableIndex === index

                onSelected: {
                    canvasRoot.selectedTableIndex = index
                }

                onRemoveTable: {
                    if (canvasRoot.tablesModel) {
                        if (canvasRoot.selectedTableIndex === cardItem.currentTableIndex) {
                            canvasRoot.selectedTableIndex = -1
                        }
                        if (canvasRoot.tablesModel.removeTable) {
                            canvasRoot.tablesModel.removeTable(cardItem.currentTableIndex)
                        } else if (canvasRoot.tablesModel.removeRow) {
                            canvasRoot.tablesModel.removeRow(cardItem.currentTableIndex)
                        }
                    }
                }

                onRequestAddColumn: {
                    if (canvasRoot.tablesModel) {
                        canvasRoot.tablesModel.addColumnToTable(cardItem.currentTableIndex)
                    }
                }

                // переименование таблицы
                onNameChanged: (newName) => {
                    if (canvasRoot.tablesModel && canvasRoot.tablesModel.setTableName) {
                        canvasRoot.tablesModel.setTableName(cardItem.currentTableIndex, newName)
                    }
                }

                // переключение ключей PK / FK / NONE
                onFieldKeyChanged: (fieldIndex, keyType) => {
                    if (canvasRoot.tablesModel) {
                        canvasRoot.tablesModel.setFieldKey(cardItem.currentTableIndex, fieldIndex, keyType)
                    }
                }

                onFieldTypeChanged: (fieldIndex, newType) => {
                    if (canvasRoot.tablesModel) {
                        canvasRoot.tablesModel.setFieldType(cardItem.currentTableIndex, fieldIndex, newType)
                    }
                }
            }
        }
    }

    // перемещение камеры
    DragHandler {
        id: panDragHandler

        target: null

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onTranslationChanged: (delta) => {
            canvasRoot.panX += delta.x
            canvasRoot.panY += delta.y
        }
    }


    // зум к точке под курсором
    WheelHandler {
        id: zoomWheelHandler
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: (event) => {

            let factor = event.angleDelta.y > 0 ? 1.1 : 0.9

            let nextZoom = Math.min(Math.max(canvasRoot.zoom * factor, canvasRoot.minZoom), canvasRoot.maxZoom)

            if (nextZoom !== canvasRoot.zoom) {

                let mouseX = event.x
                let mouseY = event.y

                canvasRoot.panX = mouseX - (mouseX - canvasRoot.panX) * (nextZoom / canvasRoot.zoom)
                canvasRoot.panY = mouseY - (mouseY - canvasRoot.panY) * (nextZoom / canvasRoot.zoom)

                canvasRoot.zoom = nextZoom
            }
        }
    }
}