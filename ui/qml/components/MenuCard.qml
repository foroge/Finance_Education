import QtQuick
import QtQuick.Effects

Item {
    id: root

    property string title: ""
    property string description: ""
    property string iconSource: ""

    signal clicked()

    width: 320
    height: 180

    // Тень карточки меню
    RectangularShadow {
        anchors.fill: card

        radius: card.radius

        offset.y: 4
        blur: 18

        color: "#22000000"
    }

    // Фон карточки меню
    Rectangle {
        id: card

        anchors.fill: parent

        radius: 18

        color: mouse.containsMouse
               ? Constants.accentDedicatedColor
               : Constants.accentColor

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        scale: mouse.containsMouse ? 1.02 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 150
            }
        }

        // Контент карточки
        Column {
            anchors.centerIn: parent

            width: parent.width - 40

            spacing: 20

            // Заголовок и иконка
            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: 10

                Text {
                    text: root.title

                    color: Constants.textMainColor

                    font.pixelSize: 28
                    font.bold: true
                }

                Image {
                    source: root.iconSource

                    width: 32
                    height: 32

                    anchors.verticalCenter: parent.verticalCenter

                    fillMode: Image.PreserveAspectFit
                }
            }

            // Описание раздела
            Text {
                text: root.description

                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap

                color: Constants.textMainColor

                font.pixelSize: 18
            }
        }

        // Кликабельная область карточки
        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: root.clicked()
        }
    }
}
