import QtQuick

MouseArea {
    id: root

    property string iconSource: ""
    property int iconSize: 22

    width: 40
    height: 40

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    // Иконка кнопки
    Image {
        anchors.centerIn: parent

        width: root.iconSize
        height: root.iconSize

        source: root.iconSource
        fillMode: Image.PreserveAspectFit
    }
    // Нажатие на кнопку
    onClicked: root.clicked()
}

    
