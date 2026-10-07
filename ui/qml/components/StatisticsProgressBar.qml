import QtQuick

Rectangle {
    id: root

    property int value: 50

    width: 520
    height: 30

    radius: height / 2

    color: Constants.bgPrimaryDarkColor

    // Заполненная часть прогресса
    Rectangle {

        width: parent.width * root.value / 100
        height: parent.height

        radius: parent.radius

        color: Constants.accentDedicatedColor
    }

    // Текст процента
    Text {

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 24

        text: root.value + "%"

        font.pixelSize: 16
        font.bold: true

        color: Constants.textMainColor
    }
}
