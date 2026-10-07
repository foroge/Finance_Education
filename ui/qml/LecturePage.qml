import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components"

Page {
    id: root

    property int lessonId: 0
    property string lecturePath: ""

    property var lectureData: ({})
    property int currentPage: 0

    property string currentImage: ""
    property string currentCaption: ""

    // property bool showThemeButton: false

    // Проверка, что пользователь дошел до последнего слайда
    property bool lectureFinished:
        lectureData.pages
        && currentPage === lectureData.pages.length - 1

    // Фон страницы
    background: Rectangle {
        color: Constants.bgPrimaryColor
    }

    // Загрузка лекции при открытии страницы
    Component.onCompleted: {

        if (lessonId > 0) {
            lectureData = lessonService.getLecture(lessonId)
        } else {
            lectureData = lectureLoader.loadLecture(lecturePath)
        }

        if (lectureData.pages && lectureData.pages.length > 0) {

            let firstPage = lectureData.pages[0]

            if (firstPage.image !== "") {
                currentImage = firstPage.image
                currentCaption = firstPage.caption
            }
        }
    }

    // Обновление изображения при смене слайда
    onCurrentPageChanged: {

        if (!lectureData.pages)
            return

        let page = lectureData.pages[currentPage]

        if (page.image !== "") {
            currentImage = page.image
            currentCaption = page.caption
        }
    }

    // Верхняя панель навигации
    NavigationBar {
        id: navBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        userName: auth.currentUserName
        title: "Лекция"

        onHomeClicked: stack.replace("MainMenuPage.qml")

        onLogoutClicked: {
            auth.logout()
            stack.replace("LoginPage.qml")
        }
    }

    // Название лекции
    Text {
        id: lectureTitle

        text: lectureData.title || ""

        anchors.top: navBar.bottom
        anchors.topMargin: 24

        anchors.horizontalCenter: parent.horizontalCenter

        font.pixelSize: 28
        font.bold: true

        color: Constants.textMainColor
    }

    // Карточка с текстом и изображением слайда
    Rectangle {
        id: contentCard

        anchors.top: lectureTitle.bottom
        anchors.topMargin: 24

        anchors.left: parent.left
        anchors.leftMargin: 34

        anchors.right: parent.right
        anchors.rightMargin: 34

        anchors.bottom: finishPanel.top

        anchors.bottomMargin: 24

        radius: 14

        color: Constants.bgAdditionalWhiteColor

        border.width: 1
        border.color: "#202020"

        RowLayout {
            anchors.fill: parent

            anchors.margins: 24

            spacing: 24

            // Левая часть карточки с текстом лекции
            ColumnLayout {

                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.preferredWidth: 6

                spacing: 16

                // Текст текущего слайда
                ScrollView {

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    clip: true

                    TextArea {

                        width: parent.width

                        readOnly: true

                        text: lectureData.pages
                              ? lectureData.pages[currentPage].text
                              : ""

                        wrapMode: TextArea.Wrap

                        selectByMouse: true

                        color: Constants.textMainColor

                        font.pixelSize: 20

                        background: null
                    }
                }

                // Разделитель
                Rectangle {

                    Layout.fillWidth: true

                    height: 1

                    color: "#202020"
                }

                // Навигация по слайдам
                LectureNavigation {

                    currentPage: root.currentPage

                    pageCount: lectureData.pages
                            ? lectureData.pages.length
                            : 0

                    nextEnabled: currentPage < pageCount - 1

                    onPreviousClicked: root.currentPage--

                    onNextClicked: root.currentPage++
                }
            }

            // Правая часть карточки с изображением лекции
            Column {

                Layout.fillHeight: true
                Layout.fillWidth: true

                Layout.preferredWidth: 4

                spacing: 8

                // Изображение слайда
                Image {
                    id: lectureImage

                    width: parent.width

                    height: parent.height * 0.85

                    source: currentImage

                    fillMode: Image.PreserveAspectFit
                }

                // Подпись к изображению
                Text {
                    width: lectureImage.paintedWidth

                    anchors.horizontalCenter: lectureImage.horizontalCenter

                    text: currentCaption

                    visible: text.length > 0

                    horizontalAlignment: Text.AlignHCenter

                    wrapMode: Text.WordWrap

                    color: Constants.textMainColor

                    font.pixelSize: 14
                }
            }
        }
    }

    // Панель действий после завершения лекции
    FinishPanel {
        id: finishPanel

        visible: lectureFinished

        anchors.horizontalCenter: parent.horizontalCenter

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24

        firstButtonText: "Тренажёр"
        secondButtonText: "Тест"
        thirdButtonText: "К темам"

        onFirstButtonClicked: {
            stack.push(
                "TrainingPage.qml",
                {
                    lessonId: root.lessonId
                }
            )
        }

        onSecondButtonClicked: {
            stack.push(
                "TestPage.qml",
                {
                    lessonId: root.lessonId
                }
            )
        }

        onThirdButtonClicked: {
            stack.pop()
        }
    }
}
