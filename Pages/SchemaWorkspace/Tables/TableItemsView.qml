import QtQuick
import NodalDB   // для SqlTypes

ListModel {
    id: tablesModelRoot

    // выбранная база: от неё зависят типы новых колонок
    property string dbEngine: "PostgreSQL"

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
                        type: SqlTypes.defaultIdType(dbEngine),
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
                type: SqlTypes.defaultColumnType(dbEngine),
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
    // переименование колонки
    function setFieldName(tableIndex, fieldIndex, newName) {
        if (tableIndex < 0 || tableIndex >= count) return
        let table = get(tableIndex)
        if (!table || !table.fields || fieldIndex < 0 || fieldIndex >= table.fields.count) return
        table.fields.setProperty(fieldIndex, "name", newName)
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

    // заменяет все таблицы данными из файла
    function load(tables) {
        clear()
        for (let t of tables) {
            append({
                tableName: t.tableName,
                posX: t.posX,
                posY: t.posY,
                tableColor: t.tableColor,
                comment: t.comment,
                hasComment: t.hasComment,
                fields: t.fields
            })
        }
    }

    // при смене базы переводим типы всех колонок из старой базы в новую
    function convertTypes(fromEngine, toEngine) {
        for (let t = 0; t < count; ++t) {
            let fields = get(t).fields
            for (let i = 0; i < fields.count; ++i) {
                let oldType = fields.get(i).type
                fields.setProperty(i, "type", SqlTypes.convert(oldType, fromEngine, toEngine))
            }
        }
    }

    // ---------- для импорта из SQL ----------

    // добавить готовую таблицу с колонками (fields — массив объектов {name, type, isPk, isFk})
    function addImportedTable(name, fields, x, y) {
        append({
            tableName: name,
            posX: Math.round(x),
            posY: Math.round(y),
            tableColor: "#60a5fa",
            comment: "",
            hasComment: false,
            fields: fields
        })
    }

    // индекс таблицы по имени без учёта регистра, -1 если нет
    // сначала ищем среди таблиц начиная с from (только что импортированных), потом среди старых
    function findTable(name, from) {
        name = name.toLowerCase()
        for (let t = from; t < count; ++t)
            if (get(t).tableName.toLowerCase() === name) return t
        for (let t = 0; t < from; ++t)
            if (get(t).tableName.toLowerCase() === name) return t
        return -1
    }

    // индекс колонки по имени, -1 если нет; пустое имя — колонка первичного ключа
    function findField(tableIndex, name) {
        let fields = get(tableIndex).fields
        for (let i = 0; i < fields.count; ++i) {
            let f = fields.get(i)
            if (name === "" ? f.isPk : f.name.toLowerCase() === name.toLowerCase()) return i
        }
        return -1
    }

    // все таблицы обычными объектами для сохранения в файл
    function serialize() {
        let result = []
        for (let t = 0; t < count; ++t) {
            let src = get(t)
            let fields = []
            for (let i = 0; i < src.fields.count; ++i) {
                let f = src.fields.get(i)
                fields.push({ name: f.name, type: f.type, isPk: f.isPk, isFk: f.isFk })
            }
            result.push({
                tableName: src.tableName,
                posX: src.posX,
                posY: src.posY,
                tableColor: String(src.tableColor),
                comment: src.comment,
                hasComment: src.hasComment,
                fields: fields
            })
        }
        return result
    }
}