import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root_navbar

    property string userName: ""
    property string title: "Обучение финансам"

    signal homeClicked()
    signal logoutClicked()

    height: 48
    color: Constants.bgAdditionalWhiteColor

    RectangularShadow {
        anchors.fill: root_navbar

        offset.y: 4
        blur: 32

        color: '#22000000'

        radius: root_navbar.radius
    }   

    // Левый текст
    Text {
        text: "Давайте продолжим работу, " + root_navbar.userName

        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter

        color: Constants.textMainColor
        font.pixelSize: 14
    }

    // Заголовок строго по центру окна
    Text {
        text: root_navbar.title

        anchors.centerIn: parent

        color: Constants.textMainColor
        font.pixelSize: 24
        font.bold: true
    }

    // Кнопки справа
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter

        spacing: 20

        IconButton {
            iconSource: "qrc:/data_images/ui/data/2home_page.png"
            iconSize: 32
            onClicked: root_navbar.homeClicked()
        }

        IconButton {
            iconSource: "qrc:/data_images/ui/data/logout.png"
            iconSize: 26
            onClicked: root_navbar.logoutClicked()
        }
    }
}