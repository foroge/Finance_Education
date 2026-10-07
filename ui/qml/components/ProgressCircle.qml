import QtQuick

Rectangle {
    property color fillColor: Constants.completedGrayEmptyColor

    // Кружок прогресса темы
    width: 25
    height: 25

    radius: 12.5

    color: fillColor

    border.width: 1
    border.color: Constants.textMainColor
}
