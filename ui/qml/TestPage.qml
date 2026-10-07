import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components"

Page {
    id: root

    property int lessonId: 0
    property var testData: ({ testId: 0, questions: [] })
    property var selectedAnswers: []

    property int currentQuestion: 0
    property int selectedAnswer: -1
    property int totalQuestions: testData.questions ? testData.questions.length : 0
    property var currentQuestionData:
        totalQuestions > 0
        ? testData.questions[currentQuestion]
        : ({ text: "", answers: [] })

    property bool hasTrainer: true
    property bool isLastQuestion: totalQuestions > 0 && currentQuestion === totalQuestions - 1

    // Подсчет правильных ответов
    function correctCount() {
        let count = 0

        if (!testData.questions)
            return count

        for (let i = 0; i < testData.questions.length; i++) {
            let question = testData.questions[i]
            let selectedId = selectedAnswers[i]

            for (let j = 0; j < question.answers.length; j++) {
                let answer = question.answers[j]

                if (answer.id === selectedId && answer.correct) {
                    count++
                    break
                }
            }
        }

        return count
    }

    // Подготовка ответов пользователя для сохранения
    function answersJson() {
        let result = []

        if (!testData.questions)
            return "[]"

        for (let i = 0; i < testData.questions.length; i++) {
            result.push({
                "questionId": testData.questions[i].id,
                "answerId": selectedAnswers[i] || 0
            })
        }

        return JSON.stringify(result)
    }

    // Загрузка теста при открытии страницы
    Component.onCompleted: {
        testData = lessonService.getTest(auth.currentUserId, lessonId)
        selectedAnswer = selectedAnswers[currentQuestion] || -1
    }

    // Восстановление выбранного ответа при смене вопроса
    onCurrentQuestionChanged: {
        selectedAnswer = selectedAnswers[currentQuestion] || -1
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

        onHomeClicked: stack.replace("MainMenuPage.qml")

        onLogoutClicked: {
            auth.logout()
            stack.replace("LoginPage.qml")
        }
    }

    // Заголовок страницы
    Text {
        id: pageTitle

        text: "Тест"

        anchors.top: navBar.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter

        font.pixelSize: 28
        font.bold: true
        color: Constants.textMainColor
    }

    // Карточка теста
    Rectangle {
        id: testCard

        width: 800
        height: 500

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: pageTitle.bottom
        anchors.topMargin: 30

        radius: 14
        color: Constants.bgAdditionalWhiteColor
        border.width: 1
        border.color: "#202020"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            // Номер текущего вопроса
            Text {
                text: totalQuestions > 0
                      ? "Вопрос " + (currentQuestion + 1) + " из " + totalQuestions
                      : "Нет вопросов"
                font.pixelSize: 18
                font.bold: true
                color: Constants.textMainColor
            }

            // Разделитель
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#202020"
            }

            // Текст вопроса
            Text {
                Layout.fillWidth: true
                text: currentQuestionData.text || "Вопросы для этой темы не найдены"
                wrapMode: Text.WordWrap
                font.pixelSize: 22
                color: Constants.textMainColor
            }

            // Сетка вариантов ответа
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                rowSpacing: 16
                columnSpacing: 16

                // Кнопки ответов
                Repeater {
                    model: currentQuestionData.answers || []

                    AnswerButton {
                        Layout.fillWidth: true
                        text: modelData.text
                        selected: selectedAnswer === modelData.id

                        onClicked: {
                            selectedAnswer = modelData.id
                            selectedAnswers[currentQuestion] = modelData.id
                        }
                    }
                }
            }

            // Разделитель
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#202020"
            }

            // Навигация по вопросам
            LectureNavigation {
                Layout.fillWidth: true
                currentPage: currentQuestion
                pageCount: totalQuestions
                nextText: "→"
                nextEnabled: totalQuestions > 0 && selectedAnswer !== -1

                onPreviousClicked: {
                    root.currentQuestion--
                }

                onNextClicked: {
                    if (!root.isLastQuestion) {
                        root.currentQuestion++
                        return
                    }

                    let correct = root.correctCount()

                    lessonService.saveTestResult(
                        auth.currentUserId,
                        root.lessonId,
                        root.testData.testId,
                        correct,
                        root.totalQuestions,
                        root.answersJson()
                    )

                    stack.push(
                        "ResultPage.qml",
                        {
                            hasTrainer: root.hasTrainer,
                            lessonId: root.lessonId,
                            testCompleted: true,
                            testCorrect: correct,
                            testTotal: root.totalQuestions
                        }
                    )
                }
            }
        }
    }

    // Панель перехода к тренажеру или темам
    FinishPanel {
        id: finishPanel

        anchors.top: testCard.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        visible: hasTrainer

        firstButtonText: "К тренажеру"
        secondButtonText: "К темам"

        onFirstButtonClicked: {
            stack.push(
                "TrainingPage.qml",
                {
                    lessonId: root.lessonId
                }
            )
        }

        onSecondButtonClicked: {
            stack.pop()
        }
    }
}
