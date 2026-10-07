import QtQuick
import QtQuick.Controls

import "components"

Rectangle {
    id: root

    anchors.fill: parent
    color: Constants.bgPrimaryColor

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: -150
        y: -170

        width: 500
        height: 500

        transformOrigin: Item.Center

        rotation: 60
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 1000
        y: -100

        width: 350
        height: 350

        transformOrigin: Item.Center

        rotation: -30
    }

    // Нижняя декоративная волна
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 1.05
        height: parent.height * 0.24

        color: Constants.accentInactiveColor
        opacity: 0.4

        radius: 200
    }

    // Нижняя декоративная волна
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width * 1.2
        height: parent.height * 0.18

        color: Constants.accentColor
        opacity: 0.3

        radius: 300
    }

   // Основной блок заставки
   Column {
        anchors.centerIn: parent

        spacing: 35

        width: childrenRect.width

        // Название приложения
        Text {
            text: "ОБУЧЕНИЕ ФИНАНСАМ"

            font.pixelSize: 40
            font.bold: true

            color: Constants.textMainColor

            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        // Подзаголовок приложения
        Text {
            text: "Интерактивное изучение материалов"

            font.pixelSize: 20
            color: Constants.accentDedicatedColor

            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        // Карточки возможностей
        Row {
            spacing: 30

            anchors.horizontalCenter: parent.horizontalCenter

            SplashCard {
                icon: "qrc:/images/book.png"
                title: "Лекции"
                description: "Изучение финансовых тем и понятий"
            }

            SplashCard {
                icon: "qrc:/images/test.png"
                title: "Тесты"
                description: "Проверка знаний и самоконтроль"
            }

            SplashCard {
                icon: "qrc:/images/chart.png"
                title: "Практика"
                description: "Закрепление навыков на заданиях"
            }
        }

        // Информация об авторе
        Column {
            spacing: 5

            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Автор: Шумихин Фёдор"

                font.pixelSize: 18
                color: Constants.textMainColor

                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Группа С422"

                font.pixelSize: 18
                color: Constants.accentDedicatedColor

                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
