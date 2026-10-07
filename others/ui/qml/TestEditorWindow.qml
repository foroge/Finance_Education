import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root

    width: 980
    height: 680
    title: "Редактор теста"
    color: "#F8F5F0"

    property int lectureId: 1
    property int currentQuestion: 0

    // Модель вопросов теста
    ListModel {
        id: questionsModel

        ListElement {
            text: ""
            correct: ""
            wrong1: ""
            wrong2: ""
            wrong3: ""
        }
    }

    // Заполнение полей данными текущего вопроса
    function syncFieldsFromQuestion() {
        let question = questionsModel.get(root.currentQuestion)
        questionText.text = question.text
        correctAnswer.text = question.correct
        wrongAnswer1.text = question.wrong1
        wrongAnswer2.text = question.wrong2
        wrongAnswer3.text = question.wrong3
    }

    // Сохранение значений полей в текущий вопрос
    function syncQuestionFromFields() {
        questionsModel.setProperty(root.currentQuestion, "text", questionText.text)
        questionsModel.setProperty(root.currentQuestion, "correct", correctAnswer.text)
        questionsModel.setProperty(root.currentQuestion, "wrong1", wrongAnswer1.text)
        questionsModel.setProperty(root.currentQuestion, "wrong2", wrongAnswer2.text)
        questionsModel.setProperty(root.currentQuestion, "wrong3", wrongAnswer3.text)
    }

    // Добавление нового вопроса
    function addQuestion() {
        root.syncQuestionFromFields()
        questionsModel.append({
            "text": "",
            "correct": "",
            "wrong1": "",
            "wrong2": "",
            "wrong3": ""
        })
        root.currentQuestion = questionsModel.count - 1
        root.syncFieldsFromQuestion()
    }

    // Удаление текущего вопроса
    function removeQuestion() {
        if (questionsModel.count === 1) {
            questionText.text = ""
            correctAnswer.text = ""
            wrongAnswer1.text = ""
            wrongAnswer2.text = ""
            wrongAnswer3.text = ""
            root.syncQuestionFromFields()
            return
        }

        questionsModel.remove(root.currentQuestion)
        root.currentQuestion = Math.min(root.currentQuestion, questionsModel.count - 1)
        root.syncFieldsFromQuestion()
    }

    // Переход к выбранному вопросу
    function goToQuestion(index) {
        if (index < 0 || index >= questionsModel.count)
            return

        root.syncQuestionFromFields()
        root.currentQuestion = index
        root.syncFieldsFromQuestion()
    }

    // Подготовка вопросов к сохранению в JSON
    function questionsJson() {
        root.syncQuestionFromFields()

        let result = []
        for (let i = 0; i < questionsModel.count; i++) {
            let question = questionsModel.get(i)
            result.push({
                "text": question.text,
                "correct": question.correct,
                "wrong": [
                    question.wrong1,
                    question.wrong2,
                    question.wrong3
                ]
            })
        }

        return JSON.stringify(result)
    }

    // Сохранение теста в базу данных
    function saveTest() {
        if (typeof lectureEditorBackend === "undefined") {
            statusText.text = "Запустите редактор через others/lecture_editor.py"
            statusText.color = "#B94A48"
            return
        }

        let result = lectureEditorBackend.saveTest(root.lectureId, root.questionsJson())

        if (result.ok) {
            statusText.text = "Сохранено вопросов: " + result.savedQuestions
            statusText.color = "#2F7D32"
        } else {
            statusText.text = result.error
            statusText.color = "#B94A48"
        }
    }

    // Основная разметка редактора теста
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        // Верхняя строка редактора теста
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Тест к лекции ID " + root.lectureId
                font.pixelSize: 26
                font.bold: true
                color: "#2B2B2B"
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "Вопрос " + (root.currentQuestion + 1) + " из " + questionsModel.count
                font.pixelSize: 18
                color: "#2B2B2B"
            }
        }

        // Карточка редактирования вопроса
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#F6EEE2"
            border.width: 1
            border.color: "#202020"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 14

                // Текст вопроса
                TextArea {
                    id: questionText

                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    placeholderText: "Текст вопроса"
                    wrapMode: TextArea.Wrap
                    font.pixelSize: 18
                    color: "#2B2B2B"

                    background: Rectangle {
                        radius: 8
                        color: "#EFE7DC"
                        border.width: questionText.activeFocus ? 2 : 1
                        border.color: questionText.activeFocus ? "#6FAE75" : "#E0D5C6"
                    }

                    onTextChanged: root.syncQuestionFromFields()
                }

                // Правильный ответ
                TextField {
                    id: correctAnswer

                    Layout.fillWidth: true
                    placeholderText: "Правильный ответ"
                    font.pixelSize: 16

                    onTextChanged: root.syncQuestionFromFields()
                }

                // Неправильный ответ
                TextField {
                    id: wrongAnswer1

                    Layout.fillWidth: true
                    placeholderText: "Неправильный ответ 1"
                    font.pixelSize: 16

                    onTextChanged: root.syncQuestionFromFields()
                }

                // Неправильный ответ
                TextField {
                    id: wrongAnswer2

                    Layout.fillWidth: true
                    placeholderText: "Неправильный ответ 2"
                    font.pixelSize: 16

                    onTextChanged: root.syncQuestionFromFields()
                }

                // Неправильный ответ
                TextField {
                    id: wrongAnswer3

                    Layout.fillWidth: true
                    placeholderText: "Неправильный ответ 3"
                    font.pixelSize: 16

                    onTextChanged: root.syncQuestionFromFields()
                }

                Item {
                    Layout.fillHeight: true
                }

                // Нижняя строка действий
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Button {
                        text: "←"
                        enabled: root.currentQuestion > 0
                        Layout.preferredWidth: 52
                        onClicked: root.goToQuestion(root.currentQuestion - 1)
                    }

                    Button {
                        text: "→"
                        enabled: root.currentQuestion < questionsModel.count - 1
                        Layout.preferredWidth: 52
                        onClicked: root.goToQuestion(root.currentQuestion + 1)
                    }

                    Button {
                        text: "Добавить вопрос"
                        onClicked: root.addQuestion()
                    }

                    Button {
                        text: "Удалить вопрос"
                        onClicked: root.removeQuestion()
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        id: statusText

                        text: ""
                        font.pixelSize: 15
                        color: "#2B2B2B"
                    }

                    Button {
                        text: "Сохранить тест"
                        onClicked: root.saveTest()
                    }
                }
            }
        }
    }
}
