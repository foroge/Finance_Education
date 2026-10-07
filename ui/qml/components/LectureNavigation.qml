import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property int currentPage: 0
    property int pageCount: 0

    property string nextText: "→"
    property string previousText: "←"
    property bool nextEnabled: true

    signal previousClicked()
    signal nextClicked()

    Layout.fillWidth: true

    // Кнопка назад
    AppButton {
        text: root.previousText
        Layout.preferredWidth: 52
        enabled: root.currentPage > 0

        onClicked: root.previousClicked()
    }

    // Отступ слева от счетчика
    Item {
        Layout.fillWidth: true
    }

    // Счетчик страниц
    Text {
        text: "Страница " + (root.currentPage + 1) + " из " + root.pageCount
        font.pixelSize: 18
        color: Constants.textMainColor
    }

    // Отступ справа от счетчика
    Item {
        Layout.fillWidth: true
    }

    // Кнопка вперед
    AppButton {
        text: root.nextText
        Layout.preferredWidth: 52
        enabled: root.nextEnabled

        onClicked: root.nextClicked()
    }
}
