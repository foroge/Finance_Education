import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components"

Item {
    width: 1280
    height: 720

    Rectangle {
        anchors.fill: parent
        color: Constants.bgPrimaryColor
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: -150
        y: -150

        width: 500
        height: 500

        transformOrigin: Item.Center

        rotation: 60
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 950
        y: -50

        width: 350
        height: 350

        transformOrigin: Item.Center

        rotation: -20
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 0
        y: 420

        width: 300
        height: 300

        transformOrigin: Item.Center

        rotation: 0
    }

    // Денежки
    Image {
        source: "qrc:/data_images/ui/data/money-money-money.png"

        x: 800
        y: 250

        width: 550
        height: 550

        transformOrigin: Item.Center

        rotation: 235
    }

    // Надпись авторизация
    Text {
        text: "Авторизация"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40

        font.pixelSize: 28
        font.bold: true

        color: Constants.textMainColor
    }

    // Карточка с инпут боксами (логин и пароль)
    AppCard {
        id: loginCard

        width: 400
        height: 230

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 100

        Column {
            anchors.fill: parent
            anchors.margins: 24

            spacing: 16

            InputBox {
                id: loginField

                width: parent.width

                labelText: "Логин"
                placeholderText: "Введите логин"
            }

            InputBox {
                id: passwordField

                width: parent.width

                labelText: "Пароль"
                placeholderText: "Введите пароль"

                echoMode: TextInput.Password
            }
        }
    }

    // Кнопка войти
    AppButton {
        id: loginButton

        width: loginCard.width - 80
        height: 52

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: errorText.visible ? errorText.bottom : loginCard.bottom
        anchors.topMargin: 20

        text: "Войти"

        onClicked: {
            if (auth.login(
                loginField.text,
                passwordField.text
            )) {
                stack.replace("MainMenuPage.qml")
            }
        }
    }

    // Текст ошибки (по умолчанию пустой)
    Text {
        id: errorText

        width: loginCard.width

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loginCard.bottom
        anchors.topMargin: 12

        text: auth.errorMessage
        visible: text.length > 0

        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap

        font.pixelSize: 14
        color: "#B00020"
    }

    // Ссылка на регистрацию
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loginButton.bottom
        anchors.topMargin: 18

        spacing: 5

        Text {
            text: "Нет аккаунта?"

            font.pixelSize: 15
            color: Constants.textMainColor
        }

        AppLink {
            text: "Зарегистрироваться"

            onClicked: {
                stack.push("RegistrationPage.qml")
            }
        }
    }
}
