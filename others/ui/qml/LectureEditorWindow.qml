import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: root

    visible: true
    width: 1280
    height: 720
    title: "Редактор лекции"

    property int currentPage: 0
    property int lectureId: lectureIdField.value
    property var pages: [
        {
            "text": "",
            "image": "",
            "storedImage": "",
            "caption": ""
        }
    ]

    // Получение следующего id лекции при запуске редактора
    Component.onCompleted: {
        if (typeof lectureEditorBackend !== "undefined") {
            lectureIdField.value = lectureEditorBackend.nextLessonId()
        }
    }

    // Текущая страница лекции
    function page() {
        return pages[currentPage]
    }

    // Заполнение полей данными текущей страницы
    function syncFieldsFromPage() {
        let item = page()
        lectureText.text = item.text
        imagePathField.text = item.image
        storedImagePathField.text = item.storedImage || ""
        captionField.text = item.caption
    }

    // Сохранение значений полей в текущую страницу
    function syncPageFromFields() {
        pages[currentPage] = {
            "text": lectureText.text,
            "image": imagePathField.text,
            "storedImage": storedImagePathField.text,
            "caption": captionField.text
        }
    }

    // Добавление нового слайда
    function addPage() {
        syncPageFromFields()
        pages.push({
            "text": "",
            "image": "",
            "storedImage": "",
            "caption": ""
        })
        currentPage = pages.length - 1
        syncFieldsFromPage()
    }

    // Удаление текущего слайда
    function removePage() {
        if (pages.length === 1) {
            lectureText.text = ""
            imagePathField.text = ""
            storedImagePathField.text = ""
            captionField.text = ""
            syncPageFromFields()
            return
        }

        pages.splice(currentPage, 1)
        currentPage = Math.min(currentPage, pages.length - 1)
        syncFieldsFromPage()
    }

    // Переход к выбранному слайду
    function goToPage(index) {
        if (index < 0 || index >= pages.length)
            return

        syncPageFromFields()
        currentPage = index
        syncFieldsFromPage()
    }

    // Сохранение лекции в базу данных
    function saveLecture() {
        syncPageFromFields()

        if (typeof lectureEditorBackend === "undefined") {
            statusText.text = "Запустите окно через others/lecture_editor.py, чтобы сохранить в базу"
            statusText.color = "#B94A48"
            return
        }

        let result = lectureEditorBackend.saveLecture(root.lectureId, titleField.text, JSON.stringify(root.pages))

        if (result.ok) {
            statusText.text = "Сохранено: лекция " + result.lessonId + ", слайдов: " + result.savedSlides
            statusText.color = "#2F7D32"
        } else {
            statusText.text = result.error
            statusText.color = "#B94A48"
        }
    }

    color: "#F8F5F0"

    // Диалог выбора изображения
    FileDialog {
        id: imageDialog

        title: "Выберите изображение для слайда"
        fileMode: FileDialog.OpenFile
        nameFilters: [
            "Images (*.png *.jpg *.jpeg *.webp *.gif)",
            "All files (*)"
        ]

        onAccepted: {
            if (typeof lectureEditorBackend !== "undefined") {
                let result = lectureEditorBackend.importImage(selectedFile, root.lectureId)
                imagePathField.text = result.displayPath
                storedImagePathField.text = result.ok ? result.storedPath : ""
                copiedPathText.text = result.ok ? result.storedPath : result.error
            } else {
                imagePathField.text = selectedFile
                storedImagePathField.text = ""
                copiedPathText.text = "Файл выбран без копирования. Для копирования запустите others/lecture_editor.py"
            }
            root.syncPageFromFields()
        }
    }

    // Окно редактирования теста
    TestEditorWindow {
        id: testEditorWindow

        lectureId: root.lectureId
    }

    // Основная разметка редактора
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        // Верхняя строка редактора
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Редактор лекции"
                font.pixelSize: 28
                font.bold: true
                color: "#2B2B2B"
            }

            TextField {
                id: titleField

                Layout.preferredWidth: 300
                placeholderText: "Название лекции"
                text: "Новая лекция"
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "ID лекции"
                font.pixelSize: 16
                color: "#2B2B2B"
            }

            SpinBox {
                id: lectureIdField

                from: 1
                to: 999
                value: 1
                editable: true
                Layout.preferredWidth: 96
            }

            Text {
                text: "Слайд " + (root.currentPage + 1) + " из " + root.pages.length
                font.pixelSize: 18
                color: "#2B2B2B"
            }
        }

        // Рабочая область с текстом и изображением
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#F6EEE2"
            border.width: 1
            border.color: "#202020"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 24

                // Левая часть редактора с текстом слайда
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 6
                    spacing: 14

                    // Заголовок поля текста
                    Text {
                        text: "Текст слайда"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2B2B2B"
                    }

                    // Текст слайда
                    TextArea {
                        id: lectureText

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        placeholderText: "Введите текст лекции..."
                        font.pixelSize: 20
                        color: "#2B2B2B"

                        background: Rectangle {
                            radius: 8
                            color: "#EFE7DC"
                            border.width: lectureText.activeFocus ? 2 : 1
                            border.color: lectureText.activeFocus ? "#6FAE75" : "#E0D5C6"
                        }

                        onTextChanged: root.syncPageFromFields()
                    }

                    // Кнопки навигации и управления слайдами
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Добавить слайд"
                            onClicked: root.addPage()
                        }

                        Button {
                            text: "Удалить слайд"
                            onClicked: root.removePage()
                        }
                    }
                }

                // Правая часть редактора с изображением
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 4
                    spacing: 14

                    // Заголовок блока изображения
                    Text {
                        text: "Изображение"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#2B2B2B"
                    }

                    // Предпросмотр изображения
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: "#EFE7DC"
                        border.width: 1
                        border.color: "#E0D5C6"
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 14
                            source: imagePathField.text
                            fillMode: Image.PreserveAspectFit
                            visible: imagePathField.text.length > 0
                        }

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 48
                            text: "Изображение не выбрано"
                            visible: imagePathField.text.length === 0
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font.pixelSize: 18
                            color: "#777777"
                        }
                    }

                    // Поле отображения пути изображения
                    TextField {
                        id: imagePathField

                        Layout.fillWidth: true
                        readOnly: true
                        placeholderText: "Путь к изображению"
                        font.pixelSize: 14

                        background: Rectangle {
                            radius: 8
                            color: "#EFE7DC"
                            border.width: 1
                            border.color: "#E0D5C6"
                        }

                        onTextChanged: root.syncPageFromFields()
                    }

                    // Скрытое поле сохраненного пути изображения
                    TextField {
                        id: storedImagePathField

                        visible: false
                    }

                    // Кнопка выбора изображения
                    Button {
                        text: "Выбрать изображение"
                        Layout.fillWidth: true
                        onClicked: imageDialog.open()
                    }

                    // Текст с результатом копирования изображения
                    Text {
                        id: copiedPathText

                        Layout.fillWidth: true
                        text: ""
                        wrapMode: Text.WordWrap
                        font.pixelSize: 13
                        color: "#555555"
                    }

                    // Поле подписи к изображению
                    TextField {
                        id: captionField

                        Layout.fillWidth: true
                        placeholderText: "Подпись к изображению"
                        font.pixelSize: 14

                        background: Rectangle {
                            radius: 8
                            color: "#EFE7DC"
                            border.width: captionField.activeFocus ? 2 : 1
                            border.color: captionField.activeFocus ? "#6FAE75" : "#E0D5C6"
                        }

                        onTextChanged: root.syncPageFromFields()
                    }
                }
            }
        }

        // Нижняя строка действий
        RowLayout {
            Layout.fillWidth: true

            // Статус сохранения
            Text {
                id: statusText

                text: ""
                font.pixelSize: 15
                color: "#2B2B2B"
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: "Тест к лекции"
                onClicked: {
                    testEditorWindow.lectureId = root.lectureId
                    testEditorWindow.show()
                    testEditorWindow.raise()
                    testEditorWindow.requestActivate()
                }
            }

            Button {
                text: "Сохранить в БД"
                onClicked: root.saveLecture()
            }
        }
    }
}
