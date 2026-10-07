import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Обучение финансам"

    // Стек экранов приложения
    StackView {
        id: stack
        anchors.fill: parent

        initialItem: SplashScreen {}
    }

    // Таймер перехода со сплэш-скрина на авторизацию
    Timer {
        interval: 7000
        running: true
        repeat: false

        onTriggered: {
            stack.replace("LoginPage.qml")
        }
    }
}
