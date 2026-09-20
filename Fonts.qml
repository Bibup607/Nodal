import QtQuick

QtObject {
    property FontLoader interBoldLoader: FontLoader {
        id: interBoldLoaderInner // из-за ошибки делаем через айли
        source: "qrc:/fonts/Inter_18pt-Bold.ttf"
    }

    property FontLoader jetBrainsLoader: FontLoader {
        id: jetBrainsLoaderInner
        source: "qrc:/fonts/JetBrainsMono-Bold.ttf"
    }

    property alias interBold: interBoldLoaderInner.font
    property alias jetBrainsMB: jetBrainsLoaderInner.font
}

// QtObject не хранит вложенные элементы как Item
// поэтому FontLoader пишем через property а не просто кладём внутрь