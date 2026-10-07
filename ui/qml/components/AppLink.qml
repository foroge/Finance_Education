import QtQuick

Text {
    id: root

    property string normalColor: Constants.textMainColor
    property string hoverColor: Constants.accentDedicatedColor

    signal clicked()

    color: mouse.containsMouse ? hoverColor : normalColor
    opacity: mouse.containsMouse ? 1.0 : 0.65

    font.bold: true
    font.pixelSize: 15

    font.underline: mouse.containsMouse

    // Кликабельная область ссылки
    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
