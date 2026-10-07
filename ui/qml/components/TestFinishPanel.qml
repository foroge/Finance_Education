import QtQuick

Row {

    id: root

    signal trainerClicked()
    signal themeClicked()

    spacing: 20

    // Кнопка возврата к теме
    AppButton {

        text: "К теме"

        onClicked: root.themeClicked()
    }

    // Кнопка перехода к тренажеру
    AppButton {

        text: "Перейти к тренажёру"

        onClicked: root.trainerClicked()
    }
}
