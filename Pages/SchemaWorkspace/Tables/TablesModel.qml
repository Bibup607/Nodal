import QtQuick


ListModel {
    id: schemaTableModels

    function addNewTable(spawnX, spawnY) {
        let nextNumber = count + 1
        let defaultName = "table_" + nextNumber

        append({
            tableName: defaultName,
            posX: spawnX,
            posY: spawnY,
            fields: [
               {
                    name: "id",
                    type: "uuid",
                    isPk: true,       // флаг Primary Key включён
                    isFk: false       // флаг Foreign Key выключен
               }
            ]
        })
    }

    function addColumnToTable(tableIndex) {
        let table = get(tableIndex)

        if(table) {
            table.fields.append({
                name: "column_" + (table.fields.count + 1),
                type: "varchar",
                isPk: false,
                isFk: false
            })
        }
    }
}
