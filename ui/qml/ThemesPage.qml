import QtQuick
import QtQuick.Controls

import "components"

Page {
    id: root

    property var topics: []

    // Обновление списка тем с учетом пользователя
    function refreshTopics() {
        topics = lessonService.getTopics(auth.currentUserId)
    }

    // Первичная загрузка тем
    Component.onCompleted: root.refreshTopics()

    // Обновление тем при возврате на страницу
    onVisibleChanged: {
        if (visible) {
            root.refreshTopics()
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

        onHomeClicked: {
            stack.replace("MainMenuPage.qml")
        }

        onLogoutClicked: {
            auth.logout()
            stack.replace("LoginPage.qml")
        }
    }

    // Заголовок страницы
    Text {
        id: pageTitle

        text: "Выбор темы"

        anchors.top: navBar.bottom
        anchors.topMargin: 28

        anchors.left: parent.left
        anchors.leftMargin: 48

        font.pixelSize: 28
        font.bold: true

        color: Constants.textMainColor
    }

    // Карточка со списком тем
    Rectangle {
        id: topicsCard

        width: 724
        height: 554

        radius: 14

        color: Constants.bgAdditionalWhiteColor

        border.width: 1
        border.color: "#202020"

        clip: true

        anchors.top: pageTitle.bottom
        anchors.topMargin: 32

        anchors.left: parent.left
        anchors.leftMargin: 34

        ScrollView {
            anchors.fill: parent

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            // Список тем курса
            ListView {
                id: topicsList

                anchors.fill: parent

                model: root.topics

                clip: true

                // Строка темы с кнопками лекции, теста и тренажера
                delegate: TopicRow {

                    width: topicsList.width
                    lessonId: modelData.id

                    title: "Тема " + (index + 1) + ": " + modelData.title

                    lecture: modelData.lecture
                    lecturePath: modelData.lecture
                    test: modelData.test
                    trainer: modelData.trainer

                    progressColor: modelData.progressColor
                    onLectureRequested: function(lessonId, path) {
                        stack.push(
                            "LecturePage.qml",
                            {
                                lessonId: lessonId,
                                lecturePath: path
                            }
                        )
                    }
                    onTestRequested: function(lessonId) {
                        stack.push(
                            "TestPage.qml",
                            {
                                lessonId: lessonId
                            }
                        )
                    }
                    onTrainingRequested: function(lessonId) {
                        stack.push(
                            "TrainingPage.qml",
                            {
                                lessonId: lessonId
                            }
                        )
                    }
                }
                
            }
        }
    }

    // Картинка рядом со списком тем
    Image {
        id: sideImage

        source: "qrc:/data_images/ui/data/obligation.jpeg"

        width: 430
        height: 320

        fillMode: Image.PreserveAspectFit

        anchors.left: topicsCard.right
        anchors.leftMargin: 50

        anchors.verticalCenter: topicsCard.verticalCenter
    }
    
    
}
