import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string title: ""
    property int lessonId: 0
    property string lecture: ""
    property string test: ""
    property string trainer: ""

    property string lecturePath: ""
    signal lectureRequested(int lessonId, string lecturePath)
    signal testRequested(int lessonId)
    signal trainingRequested(int lessonId)

    property color progressColor: Constants.completedGrayEmptyColor

    property bool expanded: false
    property bool lastItem: false
    

    signal toggled()

    width: 724
    height: expanded ? detailsColumn.implicitHeight + 60 : 47

    // Верхняя строка темы
    Item {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 47

        Text {
            visible: lecture.length > 0

            text: root.title

            anchors.left: parent.left 
            anchors.leftMargin: 18 
            anchors.verticalCenter: parent.verticalCenter 
            color: Constants.textMainColor 
            font.pixelSize: 18

        }   

        ExpandButton {
            id: expandButton

            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            expanded: root.expanded
        }

        ProgressCircle {
            anchors.right: expandButton.left
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter

            fillColor: root.progressColor
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.toggled()
                root.expanded = !root.expanded
            }
        }
    }

    // Детали темы
    Column {
        id: detailsColumn

        visible: root.expanded

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        

        anchors.leftMargin: 26
        anchors.rightMargin: 26

        spacing: 18

        Text {
            visible: lecture.length > 0

            text: lecture

            color: Constants.textMainColor
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.lectureRequested(root.lessonId, root.lecturePath)
                }
            }
        }

        Text {
            visible: test.length > 0

            text: test

            color: Constants.textMainColor
            font.pixelSize: 16
            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.testRequested(root.lessonId)
                }
            }
        }

        Text {
            visible: trainer.length > 0

            text: trainer

            color: Constants.textMainColor
            font.pixelSize: 16
            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.trainingRequested(root.lessonId)
                }
            }
        }
    }

    // Разделитель
    Rectangle {
        visible: !root.lastItem

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1

        color: "#202020"
    }
}
