from constants import Constants


def get_progress_color(progress):
    """
    Возвращает константу нужного цвета
    :param progress: int, прогресс
    :return: функцию цветаф
    """
    constants = Constants()

    if progress == 0.0:
        return constants.completedGrayEmptyColor

    if progress <= 0.5:
        return constants.completedYellowPartiallyColor

    return constants.completedGreenFullColor
