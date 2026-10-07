import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components"

Item {
    width: 1280
    height: 720

    // Фон страницы
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

    // Надпись регистрация
    Text {
        text: "Регистрация"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40

        font.pixelSize: 28
        font.bold: true

        color: Constants.textMainColor
    }

    // Карточка с полями регистрации
    AppCard {
        id: registerCard

        width: 400
        height: 420

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
                    id: nameField

                    width: parent.width

                    labelText: "Имя"
                    placeholderText: "Введите имя"
                }

                InputBox {
                    id: passwordField

                    width: parent.width

                    labelText: "Пароль"
                    placeholderText: "Введите пароль"

                    echoMode: TextInput.Password
                }

                InputBox {
                    id: confirmPasswordField

                    width: parent.width

                    labelText: "Повтор пароля"
                    placeholderText: "Повторите пароль"

                    echoMode: TextInput.Password
                }
            }
        }

    // Кнопка зарегистрироваться
    AppButton {
        id: registerButton

        width: registerCard.width - 80
        height: 52

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: errorText.visible ? errorText.bottom : registerCard.bottom
        anchors.topMargin: 20

        text: "Зарегистрироваться"

        onClicked: {
            if (auth.register(
                loginField.text,
                nameField.text,
                passwordField.text,
                confirmPasswordField.text
            )) {
                stack.replace("MainMenuPage.qml")
            }
        }
    }

    // Текст ошибки регистрации
    Text {
        id: errorText

        width: registerCard.width

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: registerCard.bottom
        anchors.topMargin: 12

        text: auth.errorMessage
        visible: text.length > 0

        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap

        font.pixelSize: 14
        color: "#B00020"
    }

    // Ссылка на авторизацию
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: registerButton.bottom
        anchors.topMargin: 18

        spacing: 5

        Text {
            text: "Есть аккаунт?"

            font.pixelSize: 15
            color: Constants.textMainColor
        }

        AppLink {
            text: "Войти"

            onClicked: {
                stack.push("LoginPage.qml")
            }
        }
    }
}
