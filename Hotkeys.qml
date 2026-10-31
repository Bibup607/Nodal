
pragma Singleton
import QtQuick
import QtCore

QtObject {
    readonly property var defaults: ({
        addTable: "Ctrl+Shift+Return",
        addColumn: "Ctrl+Return",
        rename: "F2",
        comment: "Ctrl+Alt+M",
        duplicate: "Ctrl+D",
        deleteTable: "Del",
        search: "Ctrl+/",
        togglePanel: "Ctrl+B",
        selectTool: "V",
        panTool: "H",
        save: "Ctrl+S"
    })

    property var keys: defaults

    property Settings store: Settings {
        category: "hotkeys"
        property string saved: ""
    }

    Component.onCompleted: {
        if (store.saved !== "")
            keys = Object.assign({}, defaults, JSON.parse(store.saved))
    }

    function set(id, sequence) {
        let copy = Object.assign({}, keys)
        for (let k in copy)
            if (copy[k] === sequence) copy[k] = ""
        copy[id] = sequence
        keys = copy
        store.saved = JSON.stringify(copy)
    }

    function reset() {
        keys = defaults
        store.saved = ""
    }
}
