import QtQuick

Rectangle {
    id: root

    property string title: ""
    property int completed: 0
    property int total: 0
    property int average: 0
    property int best: 0
    property string worstTopic: "-"
    property int worstPercent: 0

    width: 552
    height: 322
    radius: 14
    color: Constants.bgAdditionalWhiteColor

    // Контент карточки статистики
    Column {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 18

        // Заголовок блока статистики
        Text {
            text: root.title
            font.pixelSize: 20
            font.bold: true
            color: Constants.textMainColor
        }

        // Количество прохождений
        Text {
            text: "Пройдено: " + root.completed + "/" + root.total
            font.pixelSize: 18
            font.bold: true
            color: Constants.textMainColor
        }

        // Средний результат
        Text {
            text: "Средний результат: " + root.average + "%"
            font.pixelSize: 18
            font.bold: true
            color: Constants.textMainColor
        }

        // Лучший результат
        Text {
            text: "Лучший результат: " + root.best + "%"
            font.pixelSize: 18
            font.bold: true
            color: Constants.textMainColor
        }

        // Самая слабая тема
        Text {
            text: "Слабая тема: " + root.worstTopic + " (" + root.worstPercent + "%)"
            font.pixelSize: 18
            font.bold: true
            color: Constants.textMainColor
        }
    }
}
