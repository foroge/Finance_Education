import QtQuick
import QtQuick.Controls

Button {
    id: root

    property color buttonColor: Constants.accentColor
    property color buttonHoverColor: Constants.accentDedicatedColor

    hoverEnabled: true

    implicitWidth: 140
    implicitHeight: 44

    font.pixelSize: 14

    // Текст кнопки
    contentItem: Text {
        text: root.text

        color: Constants.textMainColor

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font.pixelSize: 16
        font.bold: true
    }

    // Фон кнопки
    background: Rectangle {

        radius: 10

        border.width: 1
        border.color: "#202020"

        color: root.hovered
               ? root.buttonHoverColor
               : root.buttonColor

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    // Область наведения курсора
    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.NoButton

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
