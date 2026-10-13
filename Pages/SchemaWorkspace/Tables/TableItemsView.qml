import QtQuick

ListModel {
    id: tablesModelRoot

    // дефолтная тестовая таблица для старта
    ListElement {
        tableName: "users"
        posX: 100
        posY: 100
        comment: ""
        hasComment: false
        fields: [
            ListElement { name: "id"; type: "uuid"; isPk: true; isFk: false },
            ListElement { name: "username"; type: "varchar"; isPk: false; isFk: false }
        ]
    }

    function addNewTable() {
            append({
                tableName: "table_" + (count + 1),
                posX: 120 + (count * 40),
                posY: 120 + (count * 40),
                comment: "",
                hasComment: false,
                fields: [
                    {
                        name: "id",
                        type: "uuid",
                        isPk: true,
                        isFk: false
                    }
                ]
            })
        }

    // переключение статуса ключа поля PK FK или обычное
    function setFieldKey(tableIndex, fieldIndex, keyType) {
        if (tableIndex < 0 || tableIndex >= count) return
        let table = get(tableIndex)
        if (!table || !table.fields || fieldIndex < 0 || fieldIndex >= table.fields.count) return

        if (keyType === "PK") {
            // сбрасываем старый PK у остальных колонок таблицы
            for (let i = 0; i < table.fields.count; ++i) {
                if (i !== fieldIndex && table.fields.get(i).isPk) {
                    table.fields.setProperty(i, "isPk", false)
                }
            }
            table.fields.setProperty(fieldIndex, "isPk", true)
            table.fields.setProperty(fieldIndex, "isFk", false)
        } else if (keyType === "FK") {
            table.fields.setProperty(fieldIndex, "isPk", false)
            table.fields.setProperty(fieldIndex, "isFk", true)
        } else {
            // сброс в обычное поле без ключей
            table.fields.setProperty(fieldIndex, "isPk", false)
            table.fields.setProperty(fieldIndex, "isFk", false)
        }
    }

    // добавление новой дефолтной колонки в конец таблицы
    function addColumnToTable(tableIndex) {
        if (tableIndex < 0 || tableIndex >= count) return
        let table = get(tableIndex)
        if (table && table.fields) {
            table.fields.append({
                name: "column_" + (table.fields.count + 1),
                type: "varchar",
                isPk: false,
                isFk: false
            })
        }
    }
    // функция смены типа данных
    function setFieldType(tableIndex, fieldIndex, newType) {
        if (tableIndex < 0 || tableIndex >= count) return
        let table = get(tableIndex)
        if (!table || !table.fields || fieldIndex < 0 || fieldIndex >= table.fields.count) return
        table.fields.setProperty(fieldIndex, "type", newType)

    }
    // функция удаления таблицы
    function removeTable(tableIndex) {
        if(tableIndex >= 0 && tableIndex < count) {
            remove(tableIndex)
        }
    }

    // фунция синхронизации смены имени таблицы с сайдбаром
    function setTableName(tableIndex, newName) {
        if (tableIndex >= 0 && tableIndex < count) {
            setProperty(tableIndex, "tableName", newName)
        }
    }

    // функция лублирования таблицы
    function duplicateTable(tableIndex) {
        if (tableIndex < 0 || tableIndex >= count) return
        let src = get(tableIndex)

        let fieldsCopy = []
        for (let i = 0; i < src.fields.count; ++i) {
            let f = src.fields.get(i)
            fieldsCopy.push({ name: f.name, type: f.type, isPk: f.isPk, isFk: f.isFk })
        }

        append({
            tableName: src.tableName + "_copy",
            posX: src.posX + 40,
            posY: src.posY + 40,
            comment: src.comment,
            hasComment: src.hasComment,
            fields: fieldsCopy
        })
    }

    // открывает область комментария у таблицы
    function addComment(tableIndex) {
        if (tableIndex >= 0 && tableIndex < count) {
            setProperty(tableIndex, "hasComment", true)
        }
    }

    // сохраняет текст комментария пустой комментарий скрывает область
    function setTableComment(tableIndex, text) {
        if (tableIndex >= 0 && tableIndex < count) {
            setProperty(tableIndex, "comment", text)
            setProperty(tableIndex, "hasComment", text.trim() !== "")
        }
    }
}