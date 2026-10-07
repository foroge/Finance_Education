import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property bool completed: false
    property int correct: 0
    property int total: 0
    property int percent: total > 0 ? Math.round(correct * 100 / total) : 0
    property bool showGrade: false
    property int grade:
        percent > 85 ? 5
        : percent > 65 ? 4
        : percent > 50 ? 3
        : 2

    width: 500
    height: 150
    radius: 14
    color: Constants.bgAdditionalWhiteColor
    border.width: 1
    border.color: "#202020"

    // Контент карточки результата
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // Заголовок результата
        Text {
            text: root.title
            font.pixelSize: 28
            font.bold: true
            color: Constants.textMainColor
        }

        // Разделитель
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: Constants.accentDedicatedColor
        }

        // Основной результат
        Text {
            text: root.completed
                  ? "Правильно: " + root.correct + " из " + root.total + " (" + root.percent + "%)"
                  : root.title + " еще не пройден"
            font.pixelSize: 18
            color: Constants.textMainColor
        }

        // Оценка за тест
        Text {
            visible: root.completed && root.showGrade
            text: "Оценка: " + root.grade
            font.pixelSize: 18
            font.bold: true
            color: Constants.textMainColor
        }
    }
}
