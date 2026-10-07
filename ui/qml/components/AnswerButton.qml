import QtQuick
import QtQuick.Controls

Button {
    id: root

    property bool selected: false

    hoverEnabled: true

    implicitWidth: 280
    implicitHeight: 60

    // Текст варианта ответа
    contentItem: Text {
        text: root.text

        color: Constants.textMainColor

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        wrapMode: Text.WordWrap

        font.pixelSize: 16
        font.bold: root.selected
    }

    // Фон варианта ответа
    background: Rectangle {

        radius: 10

        border.width: 2

        border.color: root.selected
                      ? Constants.accentDedicatedColor
                      : "#202020"

        color: root.selected
               ? Constants.accentInactiveColor
               : (root.hovered
                  ? Constants.accentColor
                  : Constants.bgAdditionalWhiteColor)

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
