cmake_minimum_required(VERSION 3.16)

project(NodalDB VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_GENERATE_QMLLS_INI ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 Qml)

# Отключает предупреждение QTP0004 для вложенных папок QML
qt_policy(SET QTP0004 NEW)

qt_standard_project_setup(REQUIRES 6.5)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

qt_add_executable(appNodalDB
    main.cpp
)

# Иконка exe для проводника, ярлыков и закрепления в панели задач
if(WIN32)
    target_sources(appNodalDB PRIVATE app.rc)
endif()

qt_add_qml_module(appNodalDB
    URI NodalDB
    VERSION 1.0
    QML_FILES
        Main.qml
        Fonts.qml
        Pages/ProjectLauncher/ProjectLauncherPage.qml
        Pages/ProjectLauncher/LauncherButtons/LauncherNavItem.qml
        Pages/ProjectLauncher/LauncherButtons/LauncherSidebar.qml
        Pages/ProjectLauncher/LauncherButtons/LanguagePopup.qml
        Pages/ProjectLauncher/LauncherButtons/ActionCard.qml
        Pages/SchemaWorkspace/SchemaWorkspacePage.qml
        Pages/SchemaWorkspace/InfiniteCanvas.qml
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
)

# Подключение путей к заголовкам для корректной генерации метатипов
target_include_directories(appNodalDB PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/models
)

set_target_properties(appNodalDB PROPERTIES
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
)

install(TARGETS appNodalDB
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)