import QtQuick
import "Tables"
import "Relations"

Item {
    id: canvasRoot

    clip: true // обрезка того что выходит за рамку

    property var tablesModel: null
    property var relationsModel: null
    property int selectedTableIndex: -1

    property bool isConnecting: false
    property int pendingTable: -1
    property int pendingField: -1
    property string pendingType: ""

    readonly property real mouseWorldX: (canvasHover.point.position.x - panX) / zoom
    readonly property real mouseWorldY: (canvasHover.point.position.y - panY) / zoom

    function startRelation(tableIndex, fieldIndex, relType) {
        pendingTable = tableIndex
        pendingField = fieldIndex
        pendingType = relType
        isConnecting = true
    }

    function finishRelation(tableIndex, fieldIndex) {
        if (relationsModel && relationsModel.addRelation(pendingTable, pendingField, tableIndex, fieldIndex, pendingType)) {
            let fk = relationsModel.fkEnd(relationsModel.count - 1)
            tablesModel.setFieldFk(fk.table, fk.field, true)
        }
        cancelRelation()
    }

    function cancelRelation() {
        isConnecting = false
        pendingTable = -1
        pendingField = -1
        pendingType = ""
    }

    function removeRelation(relationIndex) {
        let fk = relationsModel.fkEnd(relationIndex)
        relationsModel.remove(relationIndex)
        if (!relationsModel.isFkUsed(fk.table, fk.field))
            tablesModel.setFieldFk(fk.table, fk.field, false)
    }

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
            model: canvasRoot.relationsModel
            delegate: RelationLine {
                fromCard: tablesRepeater.count > fromTable ? tablesRepeater.itemAt(fromTable) : null
                toCard: tablesRepeater.count > toTable ? tablesRepeater.itemAt(toTable) : null
                fromField: model.fromField
                toField: model.toField
                relType: model.relType

                onRemoveRequested: canvasRoot.removeRelation(index)
            }
        }

        Repeater {
            id: tablesRepeater
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
                    const sel = canvasRoot.selectedTableIndex
                    if (cardItem.currentTableIndex === sel) {
                        canvasRoot.selectedTableIndex = -1
                    }
                    else if (sel > cardItem.currentTableIndex) {
                        canvasRoot.selectedTableIndex = sel -1
                    }
                    globalTablesModel.removeTable(cardItem.currentTableIndex)
                }

                onRelationStarted: (fieldIndex, relType) => {
                    canvasRoot.startRelation(cardItem.currentTableIndex, fieldIndex, relType)
                }

                onPortClicked: (fieldIndex) => {
                    canvasRoot.finishRelation(cardItem.currentTableIndex, fieldIndex)
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

        RelationLine {
            isPreview: true
            visible: canvasRoot.isConnecting && fromCard !== null
            fromCard: canvasRoot.isConnecting && tablesRepeater.count > canvasRoot.pendingTable
                      ? tablesRepeater.itemAt(canvasRoot.pendingTable) : null
            fromField: canvasRoot.pendingField
            relType: canvasRoot.pendingType
            previewEnd: Qt.point(canvasRoot.mouseWorldX, canvasRoot.mouseWorldY)
        }
    }

    HoverHandler {
        id: canvasHover
    }

    TapHandler {
        enabled: canvasRoot.isConnecting
        onTapped: canvasRoot.cancelRelation()
    }

    Shortcut {
        sequence: "Esc"
        enabled: canvasRoot.isConnecting
        onActivated: canvasRoot.cancelRelation()
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