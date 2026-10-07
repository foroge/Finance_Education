import QtQuick

Row {
    id: root

    property string firstButtonText: ""
    property string secondButtonText: ""
    property string thirdButtonText: ""
    property color buttonColor: Constants.bgPrimaryDarkColor
    property color buttonHoverColor: Constants.accentInactiveColor

    signal firstButtonClicked()
    signal secondButtonClicked()
    signal thirdButtonClicked()

    spacing: 20

    // Первая кнопка панели
    AppButton {

        visible: firstButtonText.length > 0

        text: firstButtonText
        buttonColor: root.buttonColor
        buttonHoverColor: root.buttonHoverColor

        onClicked: root.firstButtonClicked()
    }

    // Вторая кнопка панели
    AppButton {

        visible: secondButtonText.length > 0

        text: secondButtonText
        buttonColor: root.buttonColor
        buttonHoverColor: root.buttonHoverColor

        onClicked: root.secondButtonClicked()
    }

    // Третья кнопка панели
    AppButton {

        visible: thirdButtonText.length > 0

        text: thirdButtonText
        buttonColor: root.buttonColor
        buttonHoverColor: root.buttonHoverColor

        onClicked: root.thirdButtonClicked()
    }
}
