pragma Singleton   // один объект на всё приложение
import QtQuick

QtObject {
    readonly property var types: ({
        "PostgreSQL": [
            "uuid", "smallserial", "serial", "bigserial",
            "smallint", "integer", "bigint",
            "numeric", "real", "double precision", "money",
            "varchar", "char", "text",
            "boolean", "bit", "varbit",
            "date", "time", "timetz", "timestamp", "timestamptz", "interval",
            "json", "jsonb", "xml",
            "bytea",
            "inet", "cidr", "macaddr",
            "point", "line", "lseg", "box", "path", "polygon", "circle",
            "tsvector", "tsquery"
        ],
        "MySQL": [
            "char(36)",
            "tinyint", "smallint", "mediumint", "int", "bigint",
            "decimal", "float", "double",
            "boolean", "bit",
            "char", "varchar", "tinytext", "text", "mediumtext", "longtext",
            "binary", "varbinary", "tinyblob", "blob", "mediumblob", "longblob",
            "enum", "set",
            "date", "time", "datetime", "timestamp", "year",
            "json",
            "geometry", "point", "linestring", "polygon"
        ],
        "SQLite": [
            "integer", "real", "numeric", "text", "blob"
        ]
    })

    readonly property var toGeneric: ({
        "PostgreSQL": {
            "uuid": "uuid",
            "smallserial": "autoIncSmall", "serial": "autoInc", "bigserial": "autoIncBig",
            "smallint": "smallInt", "integer": "int", "bigint": "bigInt",
            "numeric": "decimal", "real": "float",
            "double precision": "double", "double": "double",   // "double" — для старых проектов
            "money": "money",
            "varchar": "string", "char": "char", "text": "text",
            "boolean": "bool", "bit": "bit", "varbit": "varbit",
            "date": "date", "time": "time", "timetz": "timeTz",
            "timestamp": "datetime", "timestamptz": "datetimeTz", "interval": "interval",
            "json": "json", "jsonb": "jsonb", "xml": "xml",
            "bytea": "binary",
            "inet": "ip", "cidr": "cidr", "macaddr": "mac",
            "point": "point", "line": "line", "lseg": "lseg", "box": "box",
            "path": "path", "polygon": "polygon", "circle": "circle",
            "tsvector": "tsvector", "tsquery": "tsquery"
        },
        "MySQL": {
            "char(36)": "uuid",
            "tinyint": "tinyInt", "smallint": "smallInt", "mediumint": "mediumInt",
            "int": "int", "bigint": "bigInt",
            "decimal": "decimal", "float": "float", "double": "double",
            "boolean": "bool", "bit": "bit",
            "char": "char", "varchar": "string",
            "tinytext": "tinyText", "text": "text", "mediumtext": "mediumText", "longtext": "longText",
            "binary": "binary", "varbinary": "binary", "tinyblob": "binary",
            "blob": "binary", "mediumblob": "binary", "longblob": "binary",
            "enum": "enum", "set": "set",
            "date": "date", "time": "time", "datetime": "datetime",
            "timestamp": "datetimeTz", "year": "year",
            "json": "json",
            "geometry": "geometry", "point": "point", "linestring": "path", "polygon": "polygon"
        },
        "SQLite": {
            "integer": "int", "real": "double", "numeric": "decimal", "text": "text", "blob": "binary"
        }
    })

    readonly property var fromGeneric: ({
        "PostgreSQL": {
            "uuid": "uuid",
            "autoIncSmall": "smallserial", "autoInc": "serial", "autoIncBig": "bigserial",
            "tinyInt": "smallint", "smallInt": "smallint", "mediumInt": "integer",
            "int": "integer", "bigInt": "bigint", "year": "smallint",
            "decimal": "numeric", "float": "real", "double": "double precision", "money": "money",
            "bool": "boolean", "bit": "bit", "varbit": "varbit",
            "string": "varchar", "char": "char",
            "tinyText": "text", "text": "text", "mediumText": "text", "longText": "text",
            "enum": "text", "set": "text",
            "binary": "bytea",
            "date": "date", "time": "time", "timeTz": "timetz",
            "datetime": "timestamp", "datetimeTz": "timestamptz", "interval": "interval",
            "json": "json", "jsonb": "jsonb", "xml": "xml",
            "ip": "inet", "cidr": "cidr", "mac": "macaddr",
            "geometry": "text",
            "point": "point", "line": "line", "lseg": "lseg", "box": "box",
            "path": "path", "polygon": "polygon", "circle": "circle",
            "tsvector": "tsvector", "tsquery": "tsquery"
        },
        "MySQL": {
            "uuid": "char(36)",
            "autoIncSmall": "smallint", "autoInc": "int", "autoIncBig": "bigint",
            "tinyInt": "tinyint", "smallInt": "smallint", "mediumInt": "mediumint",
            "int": "int", "bigInt": "bigint", "year": "year",
            "decimal": "decimal", "float": "float", "double": "double", "money": "decimal",
            "bool": "boolean", "bit": "bit", "varbit": "bit",
            "string": "varchar", "char": "char",
            "tinyText": "tinytext", "text": "text", "mediumText": "mediumtext", "longText": "longtext",
            "enum": "enum", "set": "set",
            "binary": "blob",
            "date": "date", "time": "time", "timeTz": "time",
            "datetime": "datetime", "datetimeTz": "timestamp", "interval": "varchar",
            "json": "json", "jsonb": "json", "xml": "longtext",
            "ip": "varchar", "cidr": "varchar", "mac": "varchar",
            "geometry": "geometry",
            "point": "point", "line": "linestring", "lseg": "linestring", "box": "polygon",
            "path": "linestring", "polygon": "polygon", "circle": "geometry",
            "tsvector": "text", "tsquery": "text"
        },
        "SQLite": {
            "uuid": "text",
            "autoIncSmall": "integer", "autoInc": "integer", "autoIncBig": "integer",
            "tinyInt": "integer", "smallInt": "integer", "mediumInt": "integer",
            "int": "integer", "bigInt": "integer", "year": "integer",
            "decimal": "numeric", "float": "real", "double": "real", "money": "numeric",
            "bool": "integer", "bit": "integer", "varbit": "text",
            "string": "text", "char": "text",
            "tinyText": "text", "text": "text", "mediumText": "text", "longText": "text",
            "enum": "text", "set": "text",
            "binary": "blob",
            "date": "text", "time": "text", "timeTz": "text",
            "datetime": "text", "datetimeTz": "text", "interval": "text",
            "json": "text", "jsonb": "text", "xml": "text",
            "ip": "text", "cidr": "text", "mac": "text",
            "geometry": "blob",
            "point": "text", "line": "text", "lseg": "text", "box": "text",
            "path": "text", "polygon": "text", "circle": "text",
            "tsvector": "text", "tsquery": "text"
        }
    })


    // список типов для меню выбранной базы
    function typesFor(engine) {
        return types[engine] || types["PostgreSQL"]
    }

    // перевести тип из одной базы в другую; незнакомый тип оставляем как есть
    function convert(type, fromEngine, toEngine) {
        if (fromEngine === toEngine) return type
        const generic = (toGeneric[fromEngine] || {})[type]
        if (!generic) return type
        return (fromGeneric[toEngine] || {})[generic] || type
    }

    // тип для колонки id у новой таблицы
    function defaultIdType(engine) {
        return convert("uuid", "PostgreSQL", engine)
    }

    // тип для новой обычной колонки
    function defaultColumnType(engine) {
        return convert("varchar", "PostgreSQL", engine)
    }
}
