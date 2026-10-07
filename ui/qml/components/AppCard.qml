import QtQuick
import QtQuick.Effects

Item {
    id: root

    property color cardColor: Constants.bgAdditionalWhiteColor
    property int radius: 18

    default property alias content: contentItem.data

    // Тень карточки
    RectangularShadow {
        anchors.fill: card

        radius: card.radius

        offset.y: 4
        blur: 18
        spread: 0

        color: "#22000000"
    }

    // Фон карточки
    Rectangle {
        id: card

        anchors.fill: parent

        radius: root.radius
        color: root.cardColor

        // Контент внутри карточки
        Item {
            id: contentItem
            anchors.fill: parent
        }
    }
}
