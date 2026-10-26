cmake_minimum_required(VERSION 3.16)

project(NodalDB VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_GENERATE_QMLLS_INI ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickPrivate QuickControls2 Qml LinguistTools)

# Отключает предупреждение QTP0004 для вложенных папок QML
qt_policy(SET QTP0004 NEW)

qt_standard_project_setup(REQUIRES 6.5
    I18N_SOURCE_LANGUAGE en
    I18N_TRANSLATED_LANGUAGES ru
)


set(QWINDOWKIT_BUILD_QUICK ON CACHE BOOL "" FORCE)
set(QWINDOWKIT_BUILD_WIDGETS OFF CACHE BOOL "" FORCE)
set(QWINDOWKIT_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(QWINDOWKIT_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory(3rdparty/qwindowkit)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

# SqlTypes.qml — синглтон со списками типов для каждой базы
set_source_files_properties(SqlTypes.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_executable(appNodalDB
    main.cpp
)

if(WIN32)
    target_sources(appNodalDB PRIVATE app.rc)
endif()

qt_add_qml_module(appNodalDB
    URI NodalDB
    VERSION 1.0
    QML_FILES
        Main.qml
        Fonts.qml
        LineIcon.qml
        SqlTypes.qml
        Components/SaveNotification.qml
        Pages/ProjectLauncher/ProjectLauncherPage.qml
        Pages/ProjectLauncher/NewProjectPopup.qml
        Pages/ProjectLauncher/LauncherButtons/LauncherNavItem.qml
        Pages/ProjectLauncher/LauncherButtons/LauncherSidebar.qml
        Pages/ProjectLauncher/LauncherButtons/LanguagePopup.qml
        Pages/ProjectLauncher/LauncherButtons/ActionCard.qml
        Pages/ProjectLauncher/RecentProjects/RecentProjectRow.qml
        Pages/SchemaWorkspace/SchemaWorkspacePage.qml
        Pages/SchemaWorkspace/InfiniteCanvas.qml
        Pages/SchemaWorkspace/ImportPopup.qml
        Pages/SchemaWorkspace/SqlParser.js
        Pages/SchemaWorkspace/SqlExporter.js
        Pages/SchemaWorkspace/ExportPopup.qml
        Pages/SchemaWorkspace/ConfirmPopup.qml
        Pages/SchemaWorkspace/Tables/TableCard.qml
        Pages/SchemaWorkspace/Tables/TableItemsView.qml
        Pages/SchemaWorkspace/Relations/RelationsModel.qml
        Pages/SchemaWorkspace/Relations/RelationLine.qml
        Pages/SchemaWorkspace/Colors/ColorPalette.qml
        Pages/SchemaWorkspace/Colors/ColorPickerPopup.qml
        Pages/SchemaWorkspace/CustomButtons/ImportButton.qml
        Pages/SchemaWorkspace/CustomButtons/ToolbarButton.qml
        Pages/SchemaWorkspace/CustomButtons/WindowControls.qml
    RESOURCES
        resourse.qrc
    SOURCES
        models/tablesmodel.h
        models/tablesmodel.cpp
        models/tablesfilterproxymodel.h
        models/tablesfilterproxymodel.cpp
        storage/projectstorage.h
        storage/projectstorage.cpp
)

qt_add_translations(appNodalDB
    RESOURCE_PREFIX /qt/qml/NodalDB/i18n
    TS_FILE_BASE qml
    TS_FILE_DIR i18n
)

# Подключение путей к заголовкам для корректной генерации метатипов
target_include_directories(appNodalDB PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/models
    ${CMAKE_CURRENT_SOURCE_DIR}/storage
)

set_target_properties(appNodalDB PROPERTIES
    OUTPUT_NAME "Nodal"   # файл называется Nodal.exe; appNodalDB остаётся внутренним именем для CMake
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appNodalDB PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
    QWindowKit::Quick
)

install(TARGETS appNodalDB
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)