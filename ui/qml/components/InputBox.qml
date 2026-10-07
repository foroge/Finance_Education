import QtQuick
import QtQuick.Controls

Column {
    id: root

    property alias text: field.text
    property alias placeholderText: field.placeholderText
    property alias echoMode: field.echoMode

    property string labelText: ""

    spacing: 6

    // Подпись поля
    Text {
        text: root.labelText

        font.pixelSize: 20
        font.bold: true

        color: Constants.textMainColor
    }

    // Поле ввода
    TextField {
        id: field

        width: parent.width
        height: 48

        font.pixelSize: 14
        color: Constants.textMainColor

        placeholderTextColor: "#8A8A8A"

        leftPadding: 16
        rightPadding: 16

        // Фон поля ввода
        background: Rectangle {
            radius: 24

            color: Constants.bgAdditionalColor

            border.width: field.activeFocus ? 2 : 1
            border.color: field.activeFocus ? Constants.accentDedicatedColor : Constants.bgPrimaryDarkColor
        }
    }
}
