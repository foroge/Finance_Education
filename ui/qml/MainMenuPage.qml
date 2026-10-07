import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"

Page {
    id: root

    // Фон страницы
    background: Rectangle {
        color: Constants.bgPrimaryColor
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: -100
        y: -80

        width: 350
        height: 350

        transformOrigin: Item.Center

        rotation: 65
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 1000
        y: 0

        width: 375
        height: 375

        transformOrigin: Item.Center

        rotation: 65
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 380
        y: 435

        width: 420
        height: 420

        transformOrigin: Item.Center

        rotation: -35
    }

    // Верхняя панель навигации
    NavigationBar {
        id: root_navbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        userName: auth.currentUserName

        onHomeClicked: {
            stack.replace("MainMenuPage.qml")
        }

        onLogoutClicked: {
            auth.logout()
            stack.replace("LoginPage.qml")
        }
    }


    // Заголовок выбора раздела
    Text {
        text: "Выберите раздел"
        color: Constants.textMainColor
        font.pixelSize: 34
        font.bold: true

        anchors.top: root_navbar.bottom
        anchors.topMargin: 140
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Карточки основных разделов
    Row {
        spacing: 140

        anchors.top: parent.verticalCenter
        anchors.topMargin: -50
        anchors.horizontalCenter: parent.horizontalCenter

        // Карточка статистики
        MenuCard {
            title: "Статистика"
            description: "Ваш прогресс и результаты тестов"

            iconSource: "qrc:/data_images/ui/data/graph.png"

            onClicked: {
                stack.push("StatisticsPage.qml")
            }
        }

        // Карточка тем
        MenuCard {
            title: "Темы"
            description: "Изучение лекций и прохождение тестов"

            iconSource: "qrc:/data_images/ui/data/courses.png"

            onClicked: {
                stack.push("ThemesPage.qml")
            }
        }
    }
}
