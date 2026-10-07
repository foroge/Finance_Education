import QtQuick

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string description: ""

    width: 220
    height: 200

    radius: 18

    color: Constants.bgAdditionalWhiteColor

    border.width: 2
    border.color: Constants.accentInactiveColor

    // Контент карточки заставки
    Column {
        anchors.top: parent.top
        anchors.topMargin: 8

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.centerIn: parent

        spacing: 14

        // Заголовок карточки
        Text {
            text: root.title

            width: parent.width
            horizontalAlignment: Text.AlignHCenter

            font.pixelSize: 24
            font.bold: true

            color: Constants.textMainColor
        }

        // Описание карточки
        Text {
            text: root.description

            width: parent.width - 10

            anchors.horizontalCenter: parent.horizontalCenter

            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter

            font.pixelSize: 14
            color: "#666666"
        }

        // Нижняя декоративная линия
        Rectangle {
            width: 80
            height: 5

            radius: 3

            color: Constants.accentDedicatedColor

            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
