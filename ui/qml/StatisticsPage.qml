import QtQuick
import QtQuick.Controls

import "components"

Page {
    id: root

    property var stats: ({ tests: {}, trainings: {} })

    // Обновление статистики пользователя
    function refreshStats() {
        stats = lessonService.getStatistics(auth.currentUserId)
    }

    // Первичная загрузка статистики
    Component.onCompleted: {
        root.refreshStats()
    }

    // Обновление статистики при возврате на страницу
    onVisibleChanged: {
        if (visible) {
            root.refreshStats()
        }
    }

    // Фон страницы
    background: Rectangle {
        color: Constants.bgPrimaryColor
    }

    // Верхняя панель навигации
    NavigationBar {
        id: navBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        userName: auth.currentUserName
        title: "Статистика"

        onHomeClicked: stack.replace("MainMenuPage.qml")

        onLogoutClicked: {
            auth.logout()
            stack.replace("LoginPage.qml")
        }
    }

    // Карточка статистики тестов
    StatisticsCard {
        id: testsCard

        anchors.top: navBar.bottom
        anchors.topMargin: 120
        anchors.left: parent.left
        anchors.leftMargin: 36

        title: "Тесты"
        completed: root.stats.tests.completed || 0
        total: root.stats.tests.total || 0
        average: root.stats.tests.average || 0
        best: root.stats.tests.best || 0
        worstTopic: root.stats.tests.worstTopic || "-"
        worstPercent: root.stats.tests.worstPercent || 0
    }

    // Карточка статистики тренажеров
    StatisticsCard {
        id: trainingsCard

        anchors.top: navBar.bottom
        anchors.topMargin: 120
        anchors.right: parent.right
        anchors.rightMargin: 36

        title: "Тренажеры"
        completed: root.stats.trainings.completed || 0
        total: root.stats.trainings.total || 0
        average: root.stats.trainings.average || 0
        best: root.stats.trainings.best || 0
        worstTopic: root.stats.trainings.worstTopic || "-"
        worstPercent: root.stats.trainings.worstPercent || 0
    }

    // Заголовок прогресса тестов
    Text {
        text: "Прогресс тестов"

        anchors.top: testsCard.bottom
        anchors.topMargin: 36
        anchors.left: testsCard.left

        font.pixelSize: 20
        font.bold: true
        color: Constants.textMainColor
    }

    // Прогресс по тестам
    StatisticsProgressBar {
        anchors.top: parent.top
        anchors.topMargin: 555
        anchors.left: testsCard.left

        value: root.stats.tests.progress || 0
    }

    // Заголовок прогресса тренажеров
    Text {
        text: "Прогресс тренажеров"

        anchors.top: trainingsCard.bottom
        anchors.topMargin: 36
        anchors.left: trainingsCard.left

        font.pixelSize: 20
        font.bold: true
        color: Constants.textMainColor
    }

    // Прогресс по тренажерам
    StatisticsProgressBar {
        anchors.top: parent.top
        anchors.topMargin: 555
        anchors.left: trainingsCard.left

        value: root.stats.trainings.progress || 0
    }
}
