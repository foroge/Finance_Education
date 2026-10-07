import QtQuick
import QtQuick.Controls

import "components"

Page {
    id: root

    property bool testCompleted: false
    property int testCorrect: 0
    property int testTotal: 10

    property bool trainerCompleted: false
    property int trainerCorrect: 0
    property int trainerTotal: 10

    property bool hasTrainer: true
    property int lessonId: 0

    // Фон страницы
    background: Rectangle {
        color: Constants.bgPrimaryColor
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 0
        y: 435

        width: 280
        height: 280

        transformOrigin: Item.Center

        rotation: -35
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 700
        y: 0

        width: 320
        height: 320

        transformOrigin: Item.Center

        rotation: -45
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 800
        y: 450

        width: 320
        height: 320

        transformOrigin: Item.Center

        rotation: -110
    }

    // Верхняя панель навигации
    NavigationBar {
        id: navBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        userName: auth.currentUserName
        title: "Результаты"

        onHomeClicked: {
            stack.replace("MainMenuPage.qml")
        }

        onLogoutClicked: {
            auth.logout()
            stack.replace("LoginPage.qml")
        }
    }

    // Карточки с результатами
    Row {

        anchors.top: navBar.bottom
        anchors.topMargin: 140

        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 30

        // Результат теста
        ResultCard {

            width: 450
            height: 280

            title: "Тест"

            completed: root.testCompleted

            correct: root.testCorrect
            total: root.testTotal
            showGrade: true
        }

        // Результат тренажера
        ResultCard {

            width: 450
            height: 280

            visible: root.hasTrainer

            title: "Тренажёр"

            completed: root.trainerCompleted

            correct: root.trainerCorrect
            total: root.trainerTotal
        }
    }

    // Нижняя панель переходов
    FinishPanel {
        id: finishPanel

        anchors.horizontalCenter: parent.horizontalCenter

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24

        firstButtonText: root.hasTrainer
                         ? "К тренажёру"
                         : ""

        secondButtonText: "К темам"

        onFirstButtonClicked: {
            stack.push(
                "TrainingPage.qml",
                {
                    lessonId: root.lessonId,
                    testCompleted: root.testCompleted,
                    testCorrect: root.testCorrect,
                    testTotal: root.testTotal
                }
            )
        }

        onSecondButtonClicked: {
            stack.pop()
        }
    }
}
