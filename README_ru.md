# Nodal

Настольный редактор схем баз данных: ER-диаграммы, импорт и экспорт SQL.

![C++17](https://img.shields.io/badge/C%2B%2B-17-00599C?style=flat-square&logo=cplusplus&logoColor=white)
![Qt](https://img.shields.io/badge/Qt-6.11-41CD52?style=flat-square&logo=qt&logoColor=white)
![QML](https://img.shields.io/badge/UI-QML-41CD52?style=flat-square)
![CMake](https://img.shields.io/badge/build-CMake-064F8C?style=flat-square&logo=cmake&logoColor=white)
![Windows](https://img.shields.io/badge/platform-Windows-0078D6?style=flat-square&logo=windows&logoColor=white)

[English](README.md) • **Русский**

Расставьте таблицы на бесконечном холсте, соедините их связями и получите готовый SQL
для PostgreSQL, MySQL или SQLite. Или наоборот: вставьте готовый код `CREATE TABLE`
и получите диаграмму. Схема и SQL всегда совпадают — ничего не нужно переписывать вручную.

![Nodal](docs/demo.gif)

## Стек

| | |
|---|---|
| Языки | C++17, QML, JavaScript |
| Фреймворк | Qt 6.11 (Qt Quick, Quick Controls 2) |
| Сборка | CMake |
| Окно | [QWindowKit](https://github.com/stdware/qwindowkit) |
| Хранение | JSON (файлы `.schema`) |
| Платформа | Windows |

## Возможности

Всё, что нужно для проектирования схемы, — от первой таблицы до готового SQL.

- Бесконечный холст: зум, перемещение, поиск таблиц
- Таблицы: колонки, типы, PK / FK, цвета, комментарии
- Связи `1:1`, `1:M`, `M:1`
- PostgreSQL, MySQL, SQLite: типы переводятся при смене базы
- Импорт SQL (`CREATE TABLE`, `FOREIGN KEY`, `ALTER TABLE`)
- Экспорт SQL под выбранную базу, экспорт PNG
- Snap Layouts в Windows 11, своя шапка окна
- Английский / русский

## Сборка

Нужны Qt 6.5+, CMake 3.19+, MinGW или MSVC.

```bash
git clone --recursive https://github.com/Bibup607/Nodal.git
cd Nodal
cmake -S . -B build -DCMAKE_PREFIX_PATH=<путь-к-Qt>
cmake --build build --config Release
```

Или открыть `CMakeLists.txt` в Qt Creator. Не забудьте `--recursive`: библиотека окна
QWindowKit подключена как подмодуль git. Если уже склонировали без него, выполните `git submodule update --init --recursive`.

## Структура

C++ отвечает за файлы и модели, QML — за интерфейс, разбор и генерация SQL написаны на обычном JavaScript.

```
main.cpp, Main.qml        точка входа, окно
SqlTypes.qml              типы данных для каждой базы
storage/                  C++: сохранение и загрузка проектов
models/                   C++: поиск таблиц
Pages/ProjectLauncher/    стартовый экран
Pages/SchemaWorkspace/    редактор, холст, импорт и экспорт SQL
3rdparty/qwindowkit/      подмодуль git
```
