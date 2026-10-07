import QtQuick

Rectangle {
    id: root

    property bool expanded: false
    property color fillColor: "#3F9447"

    width: 37.6
    height: 28

    radius: 3

    color: "transparent"

    // Иконка раскрытия
    Image {
    source: "qrc:/data_images/ui/data/triangle.svg"

    rotation: root.expanded ? 180 : 0

    // Анимация поворота стрелки
    Behavior on rotation {
        NumberAnimation {
            duration: 200
        }
    }
}
}
