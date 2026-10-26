.pragma library

// имя: просто слово, "в кавычках", `в обратных кавычках` или [в скобках]
const ID = '(?:"[^"]+"|`[^`]+`|\\[[^\\]]+\\]|[\\w$]+)'
// имя со схемой: public.users
const NAME = ID + '(?:\\s*\\.\\s*' + ID + ')*'


const STOP_WORDS = [
    "PRIMARY", "NOT", "NULL", "DEFAULT", "REFERENCES", "UNIQUE", "CHECK",
    "CONSTRAINT", "AUTO_INCREMENT", "AUTOINCREMENT", "COLLATE", "GENERATED",
    "COMMENT", "ON", "CHARACTER", "CHARSET", "IDENTITY"
]

// "public"."Users" → Users  (берём последнюю часть и убираем кавычки)
function cleanName(raw) {
    const parts = raw.match(new RegExp(ID, "g"))
    return parts[parts.length - 1].replace(/^["`\[]|["`\]]$/g, "")
}

// "(user_id, role_id)" → ["user_id", "role_id"]
function nameList(raw) {
    return raw.split(",").map(s => cleanName(s.trim())).filter(s => s !== "")
}

// убираем комментарии -- до конца строки и /* ... */
function stripComments(sql) {
    return sql.replace(/\/\*[\s\S]*?\*\//g, " ").replace(/--[^\n]*/g, " ")
}

// индекс закрывающей скобки для скобки на позиции open (скобки внутри '...' не считаем)
function matchParen(text, open) {
    let depth = 0
    let inString = false
    for (let i = open; i < text.length; ++i) {
        const ch = text[i]
        if (ch === "'") inString = !inString
        if (inString) continue
        if (ch === "(") depth++
        if (ch === ")" && --depth === 0) return i
    }
    return -1
}

// делим по запятым верхнего уровня: запятые внутри DECIMAL(10, 2) не считаются
function splitTopLevel(text) {
    const parts = []
    let depth = 0
    let inString = false
    let start = 0
    for (let i = 0; i < text.length; ++i) {
        const ch = text[i]
        if (ch === "'") inString = !inString
        if (inString) continue
        if (ch === "(") depth++
        else if (ch === ")") depth--
        else if (ch === "," && depth === 0) {
            parts.push(text.slice(start, i).trim())
            start = i + 1
        }
    }
    parts.push(text.slice(start).trim())
    return parts.filter(p => p !== "")
}

// одна строка внутри CREATE TABLE (...): колонка или ограничение таблицы
function parseDefinition(def, table, foreignKeys) {
    // CONSTRAINT имя ... — имя ограничения нам не нужно, отрезаем
    def = def.replace(new RegExp("^CONSTRAINT\\s+" + ID + "\\s+", "i"), "")

    // PRIMARY KEY (id) или PRIMARY KEY (a, b)
    let m = def.match(/^PRIMARY\s+KEY\s*\(([^)]*)\)/i)
    if (m) {
        for (const col of nameList(m[1])) {
            const field = table.fields.find(f => f.name.toLowerCase() === col.toLowerCase())
            if (field) field.isPk = true
        }
        return
    }

    // FOREIGN KEY (user_id) REFERENCES users (id)
    m = def.match(new RegExp("^FOREIGN\\s+KEY\\s*\\(([^)]*)\\)\\s*REFERENCES\\s+(" + NAME + ")\\s*(?:\\(([^)]*)\\))?", "i"))
    if (m) {
        const from = nameList(m[1])
        const to = m[3] ? nameList(m[3]) : []
        for (let i = 0; i < from.length; ++i)
            foreignKeys.push({ fromTable: table.name, fromField: from[i],
                               toTable: cleanName(m[2]), toField: to[i] || "" })
        return
    }

    // индексы и проверки на схеме не показываем
    if (/^(UNIQUE|KEY|INDEX|CHECK|FULLTEXT|SPATIAL|EXCLUDE)\b/i.test(def)) return

    // иначе это колонка: имя, тип, ограничения
    m = def.match(new RegExp("^(" + ID + ")\\s*([\\s\\S]*)$"))
    if (!m) return
    const name = cleanName(m[1])
    // слова и группы в скобках: "DECIMAL", "(10, 2)", "NOT", "NULL"
    const tokens = m[2].match(/\([^()]*(?:\([^()]*\)[^()]*)*\)|'[^']*'|[^\s(]+/g) || []

    let type = ""
    let i = 0
    for (; i < tokens.length; ++i) {
        const word = tokens[i].toUpperCase()
        // CHARACTER в начале — это тип (CHARACTER VARYING), а после типа — CHARACTER SET
        if (STOP_WORDS.includes(word) && !(word === "CHARACTER" && type === "")) break
        type += tokens[i].startsWith("(") || type === "" ? tokens[i] : " " + tokens[i]
    }
    const rest = tokens.slice(i).join(" ")

    table.fields.push({ name: name, type: type, isPk: /\bPRIMARY\s+KEY\b/i.test(rest) })

    // user_id INT REFERENCES users (id)
    const ref = rest.match(new RegExp("\\bREFERENCES\\s+(" + NAME + ")\\s*(?:\\(([^)]*)\\))?", "i"))
    if (ref)
        foreignKeys.push({ fromTable: table.name, fromField: name,
                           toTable: cleanName(ref[1]), toField: ref[2] ? nameList(ref[2])[0] : "" })
}

function parse(sql) {
    const text = stripComments(sql)
    const tables = []
    const foreignKeys = []

    const createRe = new RegExp("CREATE\\s+(?:TEMP(?:ORARY)?\\s+)?TABLE\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?(" + NAME + ")\\s*\\(", "gi")
    let m
    while ((m = createRe.exec(text)) !== null) {
        const open = createRe.lastIndex - 1
        const close = matchParen(text, open)
        if (close < 0) break

        const table = { name: cleanName(m[1]), fields: [] }
        for (const def of splitTopLevel(text.slice(open + 1, close)))
            parseDefinition(def, table, foreignKeys)
        if (table.fields.length > 0) tables.push(table)

        createRe.lastIndex = close + 1
    }


    const alterFkRe = new RegExp("ALTER\\s+TABLE\\s+(?:ONLY\\s+)?(?:IF\\s+EXISTS\\s+)?(" + NAME + ")\\s+ADD\\s+(?:CONSTRAINT\\s+" + ID + "\\s+)?"
                                 + "FOREIGN\\s+KEY\\s*\\(([^)]*)\\)\\s*REFERENCES\\s+(" + NAME + ")\\s*(?:\\(([^)]*)\\))?", "gi")
    while ((m = alterFkRe.exec(text)) !== null) {
        const from = nameList(m[2])
        const to = m[4] ? nameList(m[4]) : []
        for (let i = 0; i < from.length; ++i)
            foreignKeys.push({ fromTable: cleanName(m[1]), fromField: from[i],
                               toTable: cleanName(m[3]), toField: to[i] || "" })
    }

    const alterPkRe = new RegExp("ALTER\\s+TABLE\\s+(?:ONLY\\s+)?(?:IF\\s+EXISTS\\s+)?(" + NAME + ")\\s+ADD\\s+(?:CONSTRAINT\\s+" + ID + "\\s+)?"
                                 + "PRIMARY\\s+KEY\\s*\\(([^)]*)\\)", "gi")
    while ((m = alterPkRe.exec(text)) !== null) {
        const table = tables.find(t => t.name.toLowerCase() === cleanName(m[1]).toLowerCase())
        if (!table) continue
        for (const col of nameList(m[2])) {
            const field = table.fields.find(f => f.name.toLowerCase() === col.toLowerCase())
            if (field) field.isPk = true
        }
    }

    return { tables: tables, foreignKeys: foreignKeys }
}
