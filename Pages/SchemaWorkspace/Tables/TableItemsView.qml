import QtQuick

ListModel {
    id: tablesModelRoot

    // дефолтная тестовая таблица для старта
    ListElement {
        tableName: "users"
        posX: 100
        posY: 100
        tableColor: "#60a5fa"
        comment: ""
        hasComment: false
        fields: [
            ListElement { name: "id"; type: "uuid"; isPk: true; isFk: false },
            ListElement { name: "username"; type: "varchar"; isPk: false; isFk: false }
        ]
    }

    // x y необязательные без них таблицы встают лесенкой
    function addNewTable(x, y) {
            append({
                tableName: "table_" + (count + 1),
                posX: x !== undefined ? Math.round(x) : 120 + (count * 40),
                posY: y !== undefined ? Math.round(y) : 120 + (count * 40),
                tableColor: "#60a5fa",
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

    function setFieldFk(tableIndex, fieldIndex, value) {
        if (tableIndex < 0 || tableIndex >= count) return
        let table = get(tableIndex)
        if (!table || !table.fields || fieldIndex < 0 || fieldIndex >= table.fields.count) return
        table.fields.setProperty(fieldIndex, "isFk", value)
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

    // снимок таблицы обычным объектом для буфера обмена (null если индекса нет)
    function tableData(tableIndex) {
        if (tableIndex < 0 || tableIndex >= count) return null
        let src = get(tableIndex)

        let fieldsCopy = []
        for (let i = 0; i < src.fields.count; ++i) {
            let f = src.fields.get(i)
            // fk не копируем потому что связи у копии нет
            fieldsCopy.push({ name: f.name, type: f.type, isPk: f.isPk, isFk: false })
        }

        return {
            tableName: src.tableName,
            posX: src.posX,
            posY: src.posY,
            tableColor: src.tableColor,
            comment: src.comment,
            hasComment: src.hasComment,
            fields: fieldsCopy
        }
    }

    // вставка снимка копией со сдвигом возвращает индекс новой таблицы
    function appendTable(data, offset) {
        if (!data) return -1
        append({
            tableName: data.tableName + "_copy",
            posX: data.posX + offset,
            posY: data.posY + offset,
            tableColor: data.tableColor,
            comment: data.comment,
            hasComment: data.hasComment,
            fields: data.fields
        })
        return count - 1
    }

    // функция лублирования таблицы
    function duplicateTable(tableIndex) {
        return appendTable(tableData(tableIndex), 40)
    }

    // смена цвета таблицы синхронно с сайдбаром и карточкой
    function setTableColor(tableIndex, newColor) {
        if (tableIndex >= 0 && tableIndex < count) {
            setProperty(tableIndex, "tableColor", newColor)
        }
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