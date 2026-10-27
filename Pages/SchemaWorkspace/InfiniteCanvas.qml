import QtQuick
import "Tables"
import "Relations"

Item {
    id: canvasRoot

    clip: true // обрезка того что выходит за рамку

    property var tablesModel: null
    property var relationsModel: null
    property var colorStore: null
    property string dbEngine: "PostgreSQL"   // нужна карточкам для меню типов
    property int selectedTableIndex: -1

    property bool isConnecting: false
    property int pendingTable: -1
    property int pendingField: -1
    property string pendingType: ""

    // текущий инструмент select или pan
    property string tool: "select"

    onToolChanged: if (tool === "pan") cancelRelation()

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

    // зум к точке px py на экране точка под ней остается на месте
    function zoomAt(factor, px, py) {
        let nextZoom = Math.min(Math.max(zoom * factor, minZoom), maxZoom)
        if (nextZoom === zoom) return

        panX = px - (px - panX) * (nextZoom / zoom)
        panY = py - (py - panY) * (nextZoom / zoom)
        zoom = nextZoom
    }

    // точка мира в центре видимой области
    function viewCenter() {
        return Qt.point((width / 2 - panX) / zoom, (height / 2 - panY) / zoom)
    }

    // ---------- экспорт всей схемы в PNG ----------

    // прямоугольник, в который помещаются все таблицы (в координатах мира), null если таблиц нет
    function contentBounds() {
        if (tablesRepeater.count === 0) return null
        let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity
        for (let i = 0; i < tablesRepeater.count; ++i) {
            let card = tablesRepeater.itemAt(i)
            if (!card) continue
            minX = Math.min(minX, card.x)
            minY = Math.min(minY, card.y)
            maxX = Math.max(maxX, card.x + card.width)
            maxY = Math.max(maxY, card.y + card.height)
        }
        return Qt.rect(minX, minY, maxX - minX, maxY - minY)
    }

    // снимок ВСЕЙ схемы (а не только того, что видно на экране) в файл path
    // done(ok) вызывается, когда файл записан
    function exportImage(path, done) {
        let b = contentBounds()
        if (!b) {
            done(false)
            return
        }

        const margin = 40
        let w = Math.ceil(b.width + margin * 2)
        let h = Math.ceil(b.height + margin * 2)
        // в 2 раза чётче, чем на экране при 100%, но не больше 8192 пикселей по стороне
        // (больше видеокарта может не потянуть)
        let k = Math.min(2, 8192 / Math.max(w, h))
        let pixelSize = Qt.size(Math.round(w * k), Math.round(h * k))

        cancelRelation()
        selectedTableIndex = -1   // без зелёной рамки выделения на картинке

        exportSource.sourceRect = Qt.rect(b.x - margin, b.y - margin, w, h)
        exportSource.textureSize = pixelSize
        exportFrame.width = w
        exportFrame.height = h
        exportFrame.visible = true

        // grabToImage асинхронный: картинка придёт в функцию, когда кадр отрисуется
        exportFrame.grabToImage(function(result) {
            let ok = result.saveToFile(path)
            exportFrame.visible = false
            done(ok)
        }, pixelSize)
    }

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
                fromSlot: canvasRoot.relationsModel.endpointSlot(index, model.fromTable, model.fromField)
                toSlot: canvasRoot.relationsModel.endpointSlot(index, model.toTable, model.toField)
                customColor: model.relColor
                colorStore: canvasRoot.colorStore

                onRemoveRequested: canvasRoot.removeRelation(index)
                onColorChangeRequested: (color) => canvasRoot.relationsModel.setRelationColor(index, color)
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
                dbEngine: canvasRoot.dbEngine

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

                onFieldRenamed: (fieldIndex, newName) => {
                    if (canvasRoot.tablesModel) {
                        canvasRoot.tablesModel.setFieldName(cardItem.currentTableIndex, fieldIndex, newName)
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

    // «камера» для экспорта в PNG. ShaderEffectSource рисует worldContainer в его собственных
    // координатах — без сдвига и зума экрана, — а sourceRect вырезает из него нужный кусок.
    // Видима только на время снимка и стоит за левым краем холста (clip: true), так что её не видно
    Item {
        id: exportFrame
        visible: false
        x: -width - 100

        Rectangle {
            anchors.fill: parent
            color: "#0D1117"   // фон как у холста, иначе картинка будет прозрачной
        }

        ShaderEffectSource {
            id: exportSource
            anchors.fill: parent
            sourceItem: worldContainer
        }
    }

    HoverHandler {
        id: canvasHover
    }

    TapHandler {
        enabled: canvasRoot.isConnecting
        onTapped: canvasRoot.cancelRelation()
    }

    // клик по пустому холсту забирает фокус у полей ввода чтобы снова работали горячие клавиши
    TapHandler {
        onTapped: canvasRoot.forceActiveFocus()
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

        // в select левой кнопкой пустой холст не двигается только средней
        acceptedButtons: Qt.MiddleButton

        onTranslationChanged: (delta) => {
            canvasRoot.panX += delta.x
            canvasRoot.panY += delta.y
        }
    }

    // в режиме pan перекрываем таблицы и тащим холст за любую точку
    MouseArea {
        id: panOverlay
        anchors.fill: parent
        visible: canvasRoot.tool === "pan"
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        property point lastPos

        onPressed: (mouse) => lastPos = Qt.point(mouse.x, mouse.y)
        onPositionChanged: (mouse) => {
            canvasRoot.panX += mouse.x - lastPos.x
            canvasRoot.panY += mouse.y - lastPos.y
            lastPos = Qt.point(mouse.x, mouse.y)
        }
    }


    // зум к точке под курсором
    WheelHandler {
        id: zoomWheelHandler
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        onWheel: (event) => canvasRoot.zoomAt(event.angleDelta.y > 0 ? 1.1 : 0.9, event.x, event.y)
    }
}