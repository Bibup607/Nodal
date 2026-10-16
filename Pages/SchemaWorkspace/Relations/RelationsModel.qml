import QtQuick

ListModel {
    id: relationsRoot

    function addRelation(fromTable, fromField, toTable, toField, relType) {
        if (fromTable === toTable && fromField === toField) return false
        for (let i = 0; i < count; ++i) {
            let r = get(i)
            if (r.fromTable === fromTable && r.fromField === fromField
                    && r.toTable === toTable && r.toField === toField) return false
        }
        append({
            fromTable: fromTable,
            fromField: fromField,
            toTable: toTable,
            toField: toField,
            relType: relType
        })
        return true
    }

    function fkEnd(i) {
        let r = get(i)
        if (r.relType === "M:1")
            return { table: r.fromTable, field: r.fromField }
        return { table: r.toTable, field: r.toField }
    }

    function isFkUsed(tableIndex, fieldIndex) {
        for (let i = 0; i < count; ++i) {
            let e = fkEnd(i)
            if (e.table === tableIndex && e.field === fieldIndex) return true
        }
        return false
    }


    // порядковый номер связи среди тех что выходят из того же поля, нужен чтобы подписи не накладывались
    function endpointSlot(relIndex, tableIndex, fieldIndex) {
        let slot = 0
        for (let i = 0; i < count && i < relIndex; ++i) {
            let r = get(i)
            if ((r.fromTable === tableIndex && r.fromField === fieldIndex)
                    || (r.toTable === tableIndex && r.toField === fieldIndex)) ++slot
        }
        return slot
    }

    function removeTableRelations(tableIndex) {
        let freed = []
        for (let i = count - 1; i >= 0; --i) {
            let r = get(i)
            if (r.fromTable === tableIndex || r.toTable === tableIndex) {
                let e = fkEnd(i)
                if (e.table !== tableIndex) freed.push(e)
                remove(i)
            } else {
                if (r.fromTable > tableIndex) setProperty(i, "fromTable", r.fromTable - 1)
                if (r.toTable > tableIndex) setProperty(i, "toTable", r.toTable - 1)
            }
        }
        for (let e of freed) {
            if (e.table > tableIndex) e.table -= 1
        }
        return freed
    }
}
