import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components"

Page {
    id: root

    property int lessonId: 0
    property var currentTaskData: ({ text: "", answer: "" })
    property int taskNumber: 0
    property bool answerVisible: false
    property bool answerChecked: false
    property bool answerCorrect: false
    property bool currentTaskSolved: false
    property int solvedCount: 0
    property bool testCompleted: false
    property int testCorrect: 0
    property int testTotal: 0
    property bool resultSaved: false
    property bool hasTask: currentTaskData.text.length > 0

    // Загрузка первого задания
    Component.onCompleted: {
        root.nextTask()
    }

    // Сброс состояния текущего задания
    function resetTaskState() {
        answerVisible = false
        answerChecked = false
        answerCorrect = false
        currentTaskSolved = false
        answerField.text = ""
    }

    // Генерация следующего задания
    function nextTask() {
        let task = lessonService.generateTrainingTask(root.lessonId)
        root.currentTaskData = task
        if (task.text.length > 0) {
            root.taskNumber++
        }
        root.resetTaskState()
    }

    // Завершение тренажера и переход к результатам
    function finishTraining() {
        if (!root.resultSaved) {
            lessonService.saveTrainingResult(
                auth.currentUserId,
                root.lessonId,
                root.solvedCount,
                root.taskNumber
            )
            root.resultSaved = true
        }

        stack.push(
            "ResultPage.qml",
            {
                hasTrainer: true,
                lessonId: root.lessonId,
                testCompleted: root.testCompleted,
                testCorrect: root.testCorrect,
                testTotal: root.testTotal,
                trainerCompleted: true,
                trainerCorrect: root.solvedCount,
                trainerTotal: root.taskNumber
            }
        )
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

        text: "Тренажер"

        anchors.top: navBar.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter

        font.pixelSize: 28
        font.bold: true
        color: Constants.textMainColor
    }

    // Карточка тренажера
    Rectangle {
        id: trainerCard

        width: 900
        height: 500

        anchors.top: pageTitle.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter

        radius: 14
        color: Constants.bgAdditionalWhiteColor
        border.width: 1
        border.color: "#202020"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 16

            // Верхняя строка с номером задания и счетчиком
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: root.hasTask ? "Задание " + root.taskNumber : "Нет заданий"
                    font.pixelSize: 18
                    font.bold: true
                    color: Constants.textMainColor
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "Решено: " + root.solvedCount
                    font.pixelSize: 16
                    color: Constants.textMainColor
                }
            }

            // Разделитель
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#202020"
            }

            // Текст задания
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.hasTask
                      ? root.currentTaskData.text
                      : "Задания тренажера для этой темы не найдены"
                wrapMode: Text.WordWrap
                font.pixelSize: 22
                color: Constants.textMainColor
            }

            // Результат проверки ответа
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                text: root.answerCorrect ? "Верно" : "Неверно"
                opacity: root.answerChecked ? 1 : 0
                font.pixelSize: 18
                font.bold: true
                color: root.answerCorrect ? Constants.accentDedicatedColor : "#B94A48"
            }

            // Поле ответа и кнопка проверки
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                InputBox {
                    id: answerField

                    Layout.preferredWidth: 350
                    placeholderText: "Введите ответ"
                }

                AppButton {
                    text: "Проверить"
                    Layout.preferredWidth: 140
                    enabled: root.hasTask && answerField.text.length > 0

                    onClicked: {
                        root.answerCorrect = lessonService.checkAnswer(root.currentTaskData.answer, answerField.text)
                        root.answerChecked = true

                        if (root.answerCorrect && !root.currentTaskSolved) {
                            root.solvedCount++
                            root.currentTaskSolved = true
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            // Правильный ответ
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                text: "Правильный ответ: " + root.currentTaskData.answer
                opacity: root.answerVisible ? 1 : 0
                font.pixelSize: 18
                font.bold: true
                color: Constants.accentDedicatedColor
            }

            // Кнопки показа ответа и следующего задания
            RowLayout {
                Layout.fillWidth: true

                AppButton {
                    text: "Показать ответ"
                    enabled: root.hasTask

                    onClicked: {
                        root.answerVisible = true
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                AppButton {
                    text: "→"
                    Layout.preferredWidth: 52
                    enabled: root.hasTask

                    onClicked: {
                        root.nextTask()
                    }
                }
            }
        }
    }

    // Нижняя панель переходов
    FinishPanel {
        id: finishPanel

        anchors.top: trainerCard.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        firstButtonText: "К результатам"
        secondButtonText: "К теме"
        thirdButtonText: "К лекции"

        onFirstButtonClicked: {
            root.finishTraining()
        }

        onSecondButtonClicked: {
            stack.pop()
        }

        onThirdButtonClicked: {
            stack.push(
                "LecturePage.qml",
                {
                    lessonId: root.lessonId
                }
            )
        }
    }
}
