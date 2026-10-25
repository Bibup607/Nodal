import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

import NodalDB
import "../../"
import "Tables"
import "Relations"
import "Colors"
import "CustomButtons"


Item {
    id: workspaceRoot
    anchors.fill: parent

    property string projectName: "untitled"
    property string dbEngine: "PostgreSQL"

    Rectangle {
        anchors.fill: parent
        color: "#0D1117"
    }

    Fonts {
        id: fonts
    }

    TableItemsView {
        id: globalTablesModel
        dbEngine: workspaceRoot.dbEngine
    }

    RelationsModel {
        id: globalRelationsModel
    }

    ProjectStorage {
        id: projectStorage
    }

    // пустой пока проект ни разу не сохраняли
    property url projectPath: ""

    // все данные проекта одним объектом
    function projectData() {
        return {
            version: 1,
            name: projectName,
            engine: dbEngine,
            tables: globalTablesModel.serialize(),
            relations: globalRelationsModel.serialize(),
            customColors: customColorStore.colors
        }
    }

    signal projectSaved(string fileName)
    signal backRequested()

    // снимок последнего сохранения сравниваем с текущим чтобы показать unsaved
    property string savedSnapshot: ""
    property bool hasUnsavedChanges: false

    function snapshot() {
        return JSON.stringify(projectData())
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: workspaceRoot.hasUnsavedChanges = workspaceRoot.snapshot() !== workspaceRoot.savedSnapshot
    }

    function setEngine(engine) {
        if (engine === dbEngine) return
        globalTablesModel.convertTypes(dbEngine, engine)
        dbEngine = engine
        hasUnsavedChanges = true
    }

    readonly property string fileName: projectPath.toString() !== ""
                                       ? decodeURIComponent(projectPath.toString().split("/").pop())
                                       : projectName + ".schema"

    function writeProject(path) {
        if (projectStorage.saveProject(path, projectData())) {
            savedSnapshot = snapshot()
            hasUnsavedChanges = false
            projectPath = path
            projectSaved(path.toString().split("/").pop())
            return true
        }
        console.warn("save failed:", projectStorage.lastError)
        return false
    }

    // сохраняем проект и возвращаемся в меню
    property bool leaveAfterSave: false

    function leaveProject() {
        if (projectPath.toString() === "") {
            leaveAfterSave = true
            saveDialog.open()
        } else if (writeProject(projectPath))
            backRequested()
    }

    // первый раз спрашиваем куда потом сохраняем молча
    function saveProject() {
        if (projectPath.toString() === "")
            saveDialog.open()
        else
            writeProject(projectPath)
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save project")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("NodalDB schema (*.schema)")]
        defaultSuffix: "schema"
        onAccepted: {
            if (workspaceRoot.writeProject(selectedFile) && workspaceRoot.leaveAfterSave)
                workspaceRoot.backRequested()
            workspaceRoot.leaveAfterSave = false
        }
        onRejected: workspaceRoot.leaveAfterSave = false
    }

    // общая палитра для таблиц и связей: базовые цвета и созданные пользователем
    QtObject {
        id: customColorStore

        readonly property var baseColors: [
            "#60a5fa", "#52d6a6", "#a78bfa", "#f472b6",
            "#f87171", "#fb923c", "#facc15", "#94a3b8"
        ]
        property var colors: []

        function add(c) {
            c = c.toLowerCase()
            if (baseColors.indexOf(c) !== -1 || colors.indexOf(c) !== -1) return
            colors = colors.concat([c]) // новый массив чтобы сработало изменение свойства
        }

        function remove(i) {
            let copy = colors.slice()
            copy.splice(i, 1)
            colors = copy
        }
    }

    Connections {
        target: globalTablesModel

        function onRowsRemoved(parent, first, last) {
            workspaceCanvas.cancelRelation()
            for (let t = last; t >= first; --t) {
                let freed = globalRelationsModel.removeTableRelations(t)
                for (let e of freed) {
                    if (!globalRelationsModel.isFkUsed(e.table, e.field))
                        globalTablesModel.setFieldFk(e.table, e.field, false)
                }
            }
        }
    }

    TablesFilterProxyModel {
        id: filteredTablesModel
        sourceModel: globalTablesModel      // говорим, откуда брать таблицы
        filterPattern: searchField.text     // привязываем к тексту из строки поиска
    }

    // данные открытого файла null значит новый проект
    property var initialData: null

    // сначала связи потом таблицы иначе удаление таблиц начнет чистить связи
    function loadProjectData(data) {
        globalRelationsModel.clear()
        globalTablesModel.load(data.tables)
        globalRelationsModel.load(data.relations || [])
        customColorStore.colors = data.customColors || []
    }

    Component.onCompleted: {
        if (initialData) {
            loadProjectData(initialData)
            savedSnapshot = snapshot()
        } else {
            globalTablesModel.convertTypes("PostgreSQL", dbEngine)
            globalTablesModel.addNewTable(150, 150)
        }
    }

    property var tableClipboard: null

    readonly property int targetTableIndex: workspaceCanvas.selectedTableIndex >= 0
                                            ? workspaceCanvas.selectedTableIndex
                                            : globalTablesModel.count - 1

    function addTableAtView() {
        let c = workspaceCanvas.viewCenter()
        globalTablesModel.addNewTable(c.x - 125, c.y - 40)
        workspaceCanvas.selectedTableIndex = globalTablesModel.count - 1
    }

    // удаление со сдвигом выделения потому что индексы после удаленной уменьшаются
    function deleteTable(tableIndex) {
        const sel = workspaceCanvas.selectedTableIndex
        if (tableIndex === sel)
            workspaceCanvas.selectedTableIndex = -1
        else if (sel > tableIndex)
            workspaceCanvas.selectedTableIndex = sel - 1
        globalTablesModel.removeTable(tableIndex)
    }

    function copySelected() {
        let data = globalTablesModel.tableData(workspaceCanvas.selectedTableIndex)
        if (data) tableClipboard = data
    }

    // строка в сайдбаре ловит эти сигналы по своему realIndex
    signal renameTableRequested(int tableIndex)
    signal commentTableRequested(int tableIndex)

    // показывает строку таблицы в сайдбаре чтобы было куда поставить курсор
    function revealInSidebar(tableIndex) {
        sidebarPanel.visible = true
        dbSection.isExpanded = true
        let shown = false
        for (let i = 0; i < filteredTablesModel.count; ++i) {
            if (filteredTablesModel.mapToSourceRow(i) === tableIndex) shown = true
        }
        // таблица скрыта фильтром сбрасываем поиск
        if (!shown) searchField.text = ""
    }


    function renameTable(tableIndex) {
        revealInSidebar(tableIndex)
        Qt.callLater(workspaceRoot.renameTableRequested, tableIndex)
    }

    function commentTable(tableIndex) {
        revealInSidebar(tableIndex)
        Qt.callLater(workspaceRoot.commentTableRequested, tableIndex)
    }

    function pasteTable() {
        if (!tableClipboard) return
        workspaceCanvas.selectedTableIndex = globalTablesModel.appendTable(tableClipboard, 40)
        // следующая вставка встанет еще ниже а не поверх
        tableClipboard.posX += 40
        tableClipboard.posY += 40
    }


    readonly property bool isTyping: Window.activeFocusItem !== null
                                     && Window.activeFocusItem.cursorPosition !== undefined
    readonly property bool hasSelection: workspaceCanvas.selectedTableIndex >= 0

    Shortcut {
        sequences: ["Ctrl+Shift+Return", "Ctrl+Shift+Enter"]
        onActivated: workspaceRoot.addTableAtView()
    }

    Shortcut {
        sequences: ["Ctrl+Return", "Ctrl+Enter"]
        enabled: workspaceRoot.targetTableIndex >= 0
        onActivated: globalTablesModel.addColumnToTable(workspaceRoot.targetTableIndex)
    }

    Shortcut {
        sequence: "Ctrl+D"
        enabled: workspaceRoot.hasSelection
        onActivated: workspaceCanvas.selectedTableIndex = globalTablesModel.duplicateTable(workspaceCanvas.selectedTableIndex)
    }

    Shortcut {
        sequence: StandardKey.Save
        onActivated: workspaceRoot.saveProject()
    }

    Shortcut {
        sequence: "F2"
        enabled: workspaceRoot.hasSelection && !workspaceRoot.isTyping
        onActivated: workspaceRoot.renameTable(workspaceCanvas.selectedTableIndex)
    }

    Shortcut {
        sequence: "Ctrl+Alt+M"
        enabled: workspaceRoot.hasSelection && !workspaceRoot.isTyping
        onActivated: workspaceRoot.commentTable(workspaceCanvas.selectedTableIndex)
    }

    Shortcut {
        sequences: [StandardKey.Delete, "Backspace"]
        enabled: workspaceRoot.hasSelection && !workspaceRoot.isTyping
        onActivated: workspaceRoot.deleteTable(workspaceCanvas.selectedTableIndex)
    }

    Shortcut {
        sequence: StandardKey.Copy
        enabled: workspaceRoot.hasSelection && !workspaceRoot.isTyping
        onActivated: workspaceRoot.copySelected()
    }

    Shortcut {
        sequence: StandardKey.Cut
        enabled: workspaceRoot.hasSelection && !workspaceRoot.isTyping
        onActivated: {
            workspaceRoot.copySelected()
            workspaceRoot.deleteTable(workspaceCanvas.selectedTableIndex)
        }
    }

    Shortcut {
        sequence: StandardKey.Paste
        enabled: workspaceRoot.tableClipboard !== null && !workspaceRoot.isTyping
        onActivated: workspaceRoot.pasteTable()
    }


    Shortcut {
        sequence: "Esc"
        enabled: workspaceRoot.hasSelection && !workspaceRoot.isTyping && !workspaceCanvas.isConnecting
        onActivated: workspaceCanvas.selectedTableIndex = -1
    }

    Shortcut {
        sequence: "Ctrl+B"
        onActivated: sidebarPanel.visible = !sidebarPanel.visible
    }


    Shortcut {
        sequences: ["Ctrl+/", StandardKey.Find]
        onActivated: {
            sidebarPanel.visible = true
            searchField.forceActiveFocus()
            searchField.selectAll()
        }
    }

    Shortcut {
        sequences: ["=", "+", StandardKey.ZoomIn]
        enabled: !workspaceRoot.isTyping
        onActivated: workspaceCanvas.zoomAt(1.2, workspaceCanvas.width / 2, workspaceCanvas.height / 2)
    }

    Shortcut {
        sequences: ["-", StandardKey.ZoomOut]
        enabled: !workspaceRoot.isTyping
        onActivated: workspaceCanvas.zoomAt(1 / 1.2, workspaceCanvas.width / 2, workspaceCanvas.height / 2)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Верхняя шапка (Тулбар)
        Rectangle {
            Layout.fillWidth: true
            height: 52
            border {
                color: "#252c37"
                width: 1
            }
            color: "#11151C"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                // Логотип
                Item {
                    implicitWidth: logoRow.implicitWidth
                    implicitHeight: logoRow.implicitHeight
                    opacity: logoMouse.containsMouse ? 0.75 : 1

                    RowLayout {
                        id: logoRow
                        anchors.fill: parent
                        spacing: 8

                        Image {
                            width: 28
                            height: 28
                            source: "qrc:/Images/logo.svg"
                        }

                        Text {
                            text: "Nodal"
                            font.family: fonts.interBold.family
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }
                    }

                    MouseArea {
                        id: logoMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: workspaceRoot.leaveProject()
                    }
                }

                Item { Layout.fillWidth: true }

                // Инструменты по центру
                RowLayout {
                    spacing: 4

                    ToolbarButton {
                        id: selectBtn
                        imageSource: "qrc:/Images/select.svg"
                        imageSourceActive: "qrc:/Images/select-icon-active.svg"
                        text: qsTr("Select")
                        // состояние берем из холста чтобы клик не сбивал привязку
                        checkable: false
                        checked: workspaceCanvas.tool === "select"
                        Layout.preferredHeight: 35

                        onClicked: workspaceCanvas.tool = "select"
                    }

                    ToolbarButton {
                        id: panBtn
                        imageSource: "qrc:/Images/pan.svg"
                        imageSourceActive: "qrc:/Images/pan-icon-active.svg"
                        text: qsTr("Pan")
                        checkable: false
                        checked: workspaceCanvas.tool === "pan"
                        Layout.preferredHeight: 35

                        onClicked: workspaceCanvas.tool = "pan"
                    }

                    Rectangle {
                        id: addTableBtn
                        // ширина по содержимому + отступы слева 10 и справа 8
                        Layout.preferredWidth: btnRow.implicitWidth + 18
                        Layout.preferredHeight: 35
                        radius: 6

                        readonly property color normalBg: "#11151c"
                        readonly property color activeBg: "#183c35"

                        readonly property color normalBorder: "#252c37"
                        readonly property color activeBorder: "#52d6a6"

                        readonly property color normalText: "#a1a9b7"
                        readonly property color activeText: "#52d6a6"

                        color: (mouseArea.pressed || mouseArea.containsMouse) ? activeBg : normalBg
                        border.width: 1
                        border.color: (mouseArea.pressed || mouseArea.containsMouse) ? activeBorder : normalBorder

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }

                        RowLayout {
                            id: btnRow
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 6

                            Image {
                                id: btnIcon
                                source: (mouseArea.pressed || mouseArea.containsMouse) ? "qrc:/Images/table-icon-active.svg" : "qrc:/Images/table.svg"
                                sourceSize.width: 13
                                sourceSize.height: 13
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                id: btnText
                                text: qsTr("Table")
                                color: (mouseArea.pressed || mouseArea.containsMouse) ? addTableBtn.activeText : addTableBtn.normalText
                                font.pixelSize: 12
                                font.family: "Monospace"
                                Layout.alignment: Qt.AlignVCenter

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: workspaceRoot.addTableAtView()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Правые кнопки экспорта
                RowLayout {
                    spacing: 8

                    ImportButton {
                        text: qsTr("Save")
                        font.bold: true
                        onClicked: workspaceRoot.saveProject()
                        // ширина по тексту но не уже прежней
                        Layout.minimumWidth: 60
                        Layout.preferredHeight: 30
                    }

                    ImportButton {
                        text: qsTr("Export SQL")
                        font.bold: true
                        Layout.minimumWidth: 90
                        Layout.preferredHeight: 30
                    }
                }

                Item { Layout.fillWidth: true }

                // Кнопки управления окном
                WindowControls {
                    onCloseRequested: {
                        if (Window.window) Window.window.close()
                    }
                    onMinimizeRequested: {
                        if (Window.window) Window.window.showMinimized()
                    }
                    onMaximizeRequested: {
                        if (!Window.window) return
                        if (Window.window.visibility === Window.Maximized) {
                            Window.window.showNormal()
                        } else {
                            Window.window.showMaximized()
                        }
                    }
                }
            }
        }

        // Рабочая зона: Сайдбар + Канвас
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Левый сайдбар (SCHEMA EXPLORER)
            Rectangle {
                id: sidebarPanel
                Layout.preferredWidth: 206
                Layout.fillHeight: true
                color: "#11151c"

                // Разделительная граница справа от сайдбара
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: "#252c37"
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    Text {
                        text: qsTr("SCHEMA EXPLORER")
                        color: "#a1a9b7"
                        font.bold: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 14
                        Layout.topMargin: 14
                    }

                    // Поле поиска
                    TextField {
                        id: searchField

                        Image {
                            source: "qrc:/Images/search.svg"
                            width: 13
                            height: 13
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Esc возвращает фокус холсту чтобы снова работали горячие клавиши
                        Keys.onEscapePressed: workspaceCanvas.forceActiveFocus()

                        placeholderText: qsTr("Filter tables...")
                        placeholderTextColor: "#a1a9b7"
                        color: "#a1a9b7"
                        font.pointSize: 10
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 14
                        Layout.preferredWidth: 178
                        leftPadding: 30

                        background: Rectangle {
                            color: "#0d1117"
                            border.color: "#252c37"
                            border.width: 1
                            radius: 6
                        }
                    }

                    // Область прокрутки списка
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        // Скроллбар
                        ScrollBar.vertical: ScrollBar {
                            parent: parent
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 1
                            width: 3
                            policy: ScrollBar.AsNeeded

                            contentItem: Rectangle {
                                implicitWidth: 3
                                radius: 1.5
                                color: parent.pressed ? "#52d6a6" : (parent.hovered ? "#475569" : "#262f3f")

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            background: Rectangle {
                                color: "transparent"
                            }
                        }

                        // База данных и список таблиц
                        Column {
                            id: dbSection
                            width: 206
                            height: implicitHeight
                            spacing: 8
                            topPadding: 10
                            bottomPadding: 16

                            // true = список таблиц развернут
                            property bool isExpanded: true

                            Item {
                                width: 178
                                height: 22
                                x: 14

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Image {
                                        id: chevronIcon
                                        rotation: dbSection.isExpanded ? 0 : 180
                                        width: 13
                                        height: 13
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: "qrc:/Images/chevron-down.svg"

                                        Behavior on rotation {
                                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: dbSection.isExpanded = !dbSection.isExpanded
                                        }
                                    }

                                    Image {
                                        source: "qrc:/Images/database.svg"
                                        width: 14
                                        height: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: workspaceRoot.projectName
                                        width: Math.min(implicitWidth, 178 - 43 - tablesCountText.width - 12 - 8)
                                        elide: Text.ElideRight
                                        color: "white"
                                        font.family: fonts.jetBrainsMB.family
                                        font.pointSize: 9
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    id: tablesCountText
                                    text: filteredTablesModel.count
                                    color: "#64748b"
                                    font.family: fonts.jetBrainsMB.family
                                    font.pointSize: 9
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Список карточек таблиц
                            Repeater {
                                model: filteredTablesModel

                                delegate: Item {
                                    id: rowDelegate
                                    visible: dbSection.isExpanded
                                    width: 178
                                    // строка растет вниз, когда открыт комментарий
                                    height: 30 + (commentField.visible ? commentField.height + 4 : 0)
                                    x: 14

                                    readonly property int realIndex: filteredTablesModel.mapToSourceRow(index)
                                    property bool isSelected: workspaceCanvas.selectedTableIndex === realIndex
                                    property bool isEditing: false

                                    // при входе в режим редактирования подставляем текущее имя и даем фокус полю
                                    onIsEditingChanged: {
                                        if (isEditing) {
                                            renameField.text = model.tableName
                                            Qt.callLater(function() {
                                                renameField.forceActiveFocus()
                                                renameField.selectAll()
                                            })
                                        }
                                    }

                                    // сохраняет новое имя пустое имя игнорируем
                                    function commitRename() {
                                        if (!isEditing) return
                                        const newName = renameField.text.trim()
                                        isEditing = false
                                        if (newName !== "" && newName !== model.tableName) {
                                            globalTablesModel.setTableName(realIndex, newName)
                                        }
                                    }

                                    // открывает область комментария и ставит в нее курсор
                                    function startComment() {
                                        workspaceCanvas.selectedTableIndex = realIndex
                                        globalTablesModel.addComment(realIndex)
                                        Qt.callLater(function() {
                                            commentField.forceActiveFocus()
                                            commentField.cursorPosition = commentField.length
                                        })
                                    }

                                    Connections {
                                        target: workspaceRoot
                                        function onRenameTableRequested(tableIndex) {
                                            if (tableIndex === rowDelegate.realIndex) rowDelegate.isEditing = true
                                        }
                                        function onCommentTableRequested(tableIndex) {
                                            if (tableIndex === rowDelegate.realIndex) rowDelegate.startComment()
                                        }
                                    }

                                    Rectangle {
                                        id: rowBg
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 30
                                        radius: 6

                                        property color normalColorbg: "transparent"
                                        property color activeColorbg: "#183c35"
                                        property color normalColort: "#a1a9b7"
                                        property color activeColort: "#52d6a6"

                                        color: (isSelected || rowMouse.containsMouse) ? activeColorbg : normalColorbg

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }

                                        MouseArea {
                                            id: rowMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                rowDelegate.forceActiveFocus()
                                                workspaceCanvas.selectedTableIndex = (workspaceCanvas.selectedTableIndex === realIndex ? -1 : realIndex)
                                            }
                                        }

                                        // кнопка цвета таблицы по клику открывает палитру
                                        Rectangle {
                                            id: colorBtn
                                            width: 10
                                            height: 10
                                            radius: 5
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: model.tableColor
                                            border.width: colorMouse.containsMouse || colorPopup.visible ? 2 : 0
                                            border.color: "#ffffff"
                                            scale: colorMouse.containsMouse ? 1.2 : 1

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }

                                            Behavior on scale {
                                                NumberAnimation { duration: 120 }
                                            }

                                            MouseArea {
                                                id: colorMouse
                                                anchors.fill: parent
                                                anchors.margins: -4 // увеличиваем зону клика чтобы попасть по маленькому кружку
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: colorPopup.open()
                                            }

                                            // палитра выбора цвета
                                            Popup {
                                                id: colorPopup
                                                y: colorBtn.height + 8
                                                x: -6
                                                padding: 8

                                                background: Rectangle {
                                                    color: "#11151c"
                                                    border.color: "#252c37"
                                                    border.width: 1
                                                    radius: 8
                                                }

                                                contentItem: ColorPalette {
                                                    colorStore: customColorStore
                                                    currentColor: model.tableColor

                                                    onColorSelected: (color) => {
                                                        globalTablesModel.setTableColor(rowDelegate.realIndex, color)
                                                        colorPopup.close()
                                                    }
                                                    onAddRequested: {
                                                        colorPopup.close()
                                                        colorPicker.openWith(model.tableColor)
                                                    }
                                                }
                                            }

                                            // создание своего цвета, после Add он попадает в палитру и сразу ставится таблице
                                            ColorPickerPopup {
                                                id: colorPicker
                                                y: colorBtn.height + 8
                                                x: -6

                                                onColorAccepted: (color) => {
                                                    customColorStore.add(color)
                                                    globalTablesModel.setTableColor(rowDelegate.realIndex, color)
                                                }
                                            }
                                        }

                                        Text {
                                            text: model.tableName
                                            visible: !rowDelegate.isEditing
                                            color: (isSelected || rowMouse.containsMouse) ? rowBg.activeColort : rowBg.normalColort
                                            font.family: fonts.jetBrainsMB.family
                                            font.pointSize: 8
                                            anchors.left: parent.left
                                            anchors.leftMargin: 28
                                            anchors.verticalCenter: parent.verticalCenter

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }

                                        // поле переименования, показывается вместо имени в режиме редактирования
                                        TextField {
                                            id: renameField
                                            visible: rowDelegate.isEditing
                                            anchors.left: parent.left
                                            anchors.leftMargin: 24
                                            anchors.right: parent.right
                                            anchors.rightMargin: 48
                                            anchors.verticalCenter: parent.verticalCenter
                                            height: 24
                                            leftPadding: 6
                                            rightPadding: 6
                                            topPadding: 0
                                            bottomPadding: 0
                                            verticalAlignment: TextInput.AlignVCenter
                                            maximumLength: 20
                                            selectByMouse: true
                                            color: "#ffffff"
                                            selectionColor: "#1f4e43"
                                            font.family: fonts.jetBrainsMB.family
                                            font.pointSize: 8

                                            background: Rectangle {
                                                radius: 4
                                                color: "#11151c"
                                                border.width: 1
                                                border.color: "#52d6a6"
                                            }

                                            onAccepted: rowDelegate.commitRename()
                                            onActiveFocusChanged: {
                                                if (!activeFocus) rowDelegate.commitRename()
                                            }
                                            Keys.onEscapePressed: rowDelegate.isEditing = false
                                        }

                                        Text {
                                            text: model.fields ? model.fields.count : 0
                                            font.family: fonts.jetBrainsMB.family
                                            color: (isSelected || rowMouse.containsMouse) ? rowBg.activeColort : rowBg.normalColort
                                            font.pointSize: 8
                                            anchors.right: parent.right
                                            anchors.rightMargin: 30
                                            anchors.verticalCenter: parent.verticalCenter

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }

                                        Text {
                                            id: dotsBtn
                                            text: "⋮"
                                            color: dotsMouse.containsMouse || tableAction.visible ? "#52d6a6" : "#a1a9b7"
                                            font.pointSize: 15
                                            anchors.right: parent.right
                                            anchors.rightMargin: 9
                                            anchors.verticalCenter: parent.verticalCenter

                                            MouseArea {
                                                id: dotsMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: tableAction.open()
                                            }

                                            // шрифт пунктов меню жирный потому что при наведении текст становится шире
                                            FontMetrics {
                                                id: tableActionFont
                                                font.family: "Monospace"
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            FontMetrics {
                                                id: tableHintFont
                                                font.family: "Monospace"
                                                font.pixelSize: 10
                                            }

                                            Menu {
                                                id: tableAction
                                                y: dotsBtn.height + 4
                                                padding: 4

                                                // ширина по самому длинному пункту вместе с подсказкой клавиш чтобы перевод не вылезал
                                                width: {
                                                    let rowWidth = 0
                                                    for (let i = 0; i < count; ++i) {
                                                        let item = itemAt(i)
                                                        let hint = item.action && item.action.hint ? item.action.hint : ""
                                                        let w = tableActionFont.advanceWidth(item.text)
                                                        if (hint !== "") w += 16 + tableHintFont.advanceWidth(hint)
                                                        rowWidth = Math.max(rowWidth, w)
                                                    }
                                                    return Math.max(140, Math.ceil(rowWidth) + 24 + leftPadding + rightPadding)
                                                }

                                                background: Rectangle {
                                                    color: "#11151c"
                                                    border.color: "#252c37"
                                                    border.width: 1
                                                    radius: 8
                                                }

                                                delegate: MenuItem {
                                                    id: menuItem
                                                    implicitHeight: 28

                                                    readonly property bool isDestructive: menuItem.action && menuItem.action.isDestructive === true
                                                    // подсказка клавиш справа берется из property hint у Action
                                                    readonly property string hint: menuItem.action && menuItem.action.hint ? menuItem.action.hint : ""

                                                    contentItem: Item {
                                                        Text {
                                                            anchors.left: parent.left
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: menuItem.text
                                                            font.family: "Monospace"
                                                            font.pixelSize: 11
                                                            font.bold: menuItem.highlighted

                                                            color: menuItem.highlighted
                                                                   ? (menuItem.isDestructive ? "#ef4444" : "#52d6a6")
                                                                   : "#cbd5e1"

                                                            leftPadding: 8

                                                            Behavior on color {
                                                                ColorAnimation { duration: 150 }
                                                            }
                                                        }

                                                        Text {
                                                            anchors.right: parent.right
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: menuItem.hint
                                                            font.family: "Monospace"
                                                            font.pixelSize: 10
                                                            color: "#64748b"
                                                            rightPadding: 4
                                                        }
                                                    }

                                                    background: Rectangle {
                                                        radius: 4

                                                        color: menuItem.highlighted
                                                               ? (menuItem.isDestructive ? "#2d1519" : "#1b222c")
                                                               : "transparent"

                                                        Behavior on color {
                                                            ColorAnimation { duration: 150 }
                                                        }
                                                    }
                                                }

                                                // включаем редактирование только после закрытия меню, иначе меню заберет фокус у поля
                                                property bool renameRequested: false
                                                property bool commentRequested: false
                                                onClosed: {
                                                    if (renameRequested) {
                                                        renameRequested = false
                                                        rowDelegate.isEditing = true
                                                    }
                                                    if (commentRequested) {
                                                        commentRequested = false
                                                        rowDelegate.startComment()
                                                    }
                                                }

                                                Action {
                                                    text: qsTr("Rename table")
                                                    property string hint: "F2"
                                                    onTriggered: tableAction.renameRequested = true
                                                }

                                                Action {
                                                    text: qsTr("Add column")
                                                    property string hint: "Ctrl+Enter"
                                                    onTriggered: globalTablesModel.addColumnToTable(realIndex)
                                                }

                                                Action {
                                                    text: qsTr("Add comment")
                                                    property string hint: "Ctrl+Alt+M"
                                                    onTriggered: tableAction.commentRequested = true
                                                }

                                                Action {
                                                    text: qsTr("Duplicate table")
                                                    property string hint: "Ctrl+D"
                                                    onTriggered: globalTablesModel.duplicateTable(realIndex)
                                                }

                                                Action {
                                                    text: qsTr("Delete table")
                                                    property string hint: "Del"
                                                    property bool isDestructive: true
                                                    onTriggered: workspaceRoot.deleteTable(realIndex)
                                                }
                                            }
                                        }
                                    }

                                    // область комментария под названием таблицы
                                    TextArea {
                                        id: commentField
                                        visible: model.hasComment && rowDelegate.isSelected
                                        anchors.top: rowBg.bottom
                                        anchors.topMargin: 4
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        text: model.comment
                                        placeholderText: qsTr("Comment...")
                                        placeholderTextColor: "#64748b"
                                        wrapMode: TextEdit.Wrap
                                        selectByMouse: true
                                        padding: 6
                                        leftPadding: 12
                                        color: "#cbd5e1"
                                        selectionColor: "#1f4e43"
                                        font.family: fonts.jetBrainsMB.family
                                        font.pointSize: 8

                                        background: Rectangle {
                                            radius: 4
                                            color: "#11151c"
                                            border.width: 1
                                            border.color: commentField.activeFocus ? "#52d6a6" : "#252c37"
                                        }

                                        // сохраняем при потере фокуса, пустой комментарий закроет область
                                        onEditingFinished: globalTablesModel.setTableComment(rowDelegate.realIndex, text)
                                        Keys.onEscapePressed: commentField.focus = false
                                        Keys.onReturnPressed: commentField.focus = false
                                        Keys.onEnterPressed: commentField.focus = false
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                InfiniteCanvas {
                    id: workspaceCanvas
                    anchors.fill: parent
                    tablesModel: globalTablesModel
                    relationsModel: globalRelationsModel
                    colorStore: customColorStore
                    dbEngine: workspaceRoot.dbEngine

                    Rectangle {
                        id: tableCard

                        DragHandler {
                            id: cardDragHandler
                            target: tableCard
                            acceptedButtons: Qt.LeftButton
                            grabPermissions: PointerHandler.TakeOverForbidden | PointerHandler.CanTakeOverFromItems

                            xAxis.onActiveValueChanged: (delta) => {
                                tableCard.x += delta / workspaceCanvas.zoom
                            }
                            yAxis.onActiveValueChanged: (delta) => {
                                tableCard.y += delta / workspaceCanvas.zoom
                            }
                        }
                    }
                }
            }
        }

        // строка состояния файл сводка и выбор базы данных
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            color: "#11151C"

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#252C37"
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Text {
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.alignment: Qt.AlignVCenter
                    text: workspaceRoot.fileName + (workspaceRoot.hasUnsavedChanges ? " · " + qsTr("unsaved") : "")
                    color: "#7D8796"
                    font.pixelSize: 11
                }

                Text {
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("%n table(s)", "", globalTablesModel.count) + " · "
                          + qsTr("%n relation(s)", "", globalRelationsModel.count)
                    color: "#7D8796"
                    font.pixelSize: 11
                }

                Item { Layout.fillWidth: true }

                Button {
                    id: engineBtn
                    Layout.fillHeight: true
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 0
                    bottomPadding: 0
                    hoverEnabled: true
                    text: workspaceRoot.dbEngine

                    ToolTip.visible: hovered && !engineMenu.visible
                    ToolTip.delay: 500
                    ToolTip.text: qsTr("Database: %1").arg(workspaceRoot.dbEngine)

                    contentItem: Text {
                        text: engineBtn.text
                        color: engineBtn.hovered ? "#E6EDF3" : "#A1A9B7"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: engineBtn.hovered ? "#1B222C" : "transparent"
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    onClicked: engineMenu.open()

                    Menu {
                        id: engineMenu
                        y: -height - 4
                        x: parent.width - width
                        width: 160
                        topPadding: 4
                        bottomPadding: 4
                        leftPadding: 0
                        rightPadding: 0

                        background: Rectangle {
                            color: "#161B22"
                            border.color: "#252C37"
                            border.width: 1
                            radius: 6
                        }

                        delegate: MenuItem {
                            id: engineItem
                            implicitHeight: 28
                            leftPadding: 12
                            indicator: null
                            arrow: null

                            contentItem: Text {
                                text: engineItem.text
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                color: engineItem.highlighted ? "#E6EDF3"
                                                              : (engineItem.text === workspaceRoot.dbEngine ? "#FFFFFF" : "#A1A9B7")
                            }

                            background: Rectangle {
                                color: engineItem.highlighted ? "#1B222C" : "transparent"
                            }
                        }

                        Action {
                            text: "PostgreSQL"
                            onTriggered: workspaceRoot.setEngine(text)
                        }

                        Action {
                            text: "MySQL"
                            onTriggered: workspaceRoot.setEngine(text)
                        }

                        Action {
                            text: "SQLite"
                            onTriggered: workspaceRoot.setEngine(text)
                        }
                    }
                }
            }
        }
    }
}