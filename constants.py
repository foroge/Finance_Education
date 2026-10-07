from PySide6.QtCore import QObject, Property


class Constants(QObject):
    """
    Хранит общие константы интерфейса и отдает их в QML через Qt-свойства.
    """

    @Property(str, constant=True)
    def appName(self):
        """
        Возвращает название приложения.
        :return: str, название приложения
        """
        return "Финансовое обучение"

    @Property(str, constant=True)
    def bgPrimaryColor(self):
        """
        Возвращает основной цвет фона.
        :return: str, HEX-код цвета
        """
        return "#F8F5F0"

    @Property(str, constant=True)
    def bgAdditionalColor(self):
        """
        Возвращает дополнительный цвет фона.
        :return: str, HEX-код цвета
        """
        return "#EFE7DC"

    @Property(str, constant=True)
    def bgAdditionalWhiteColor(self):
        """
        Возвращает светлый дополнительный цвет фона.
        :return: str, HEX-код цвета
        """
        return "#F6EEE2"

    @Property(str, constant=True)
    def bgPrimaryDarkColor(self):
        """
        Возвращает темный оттенок основного фона.
        :return: str, HEX-код цвета
        """
        return "#E0D5C6"

    @Property(str, constant=True)
    def accentColor(self):
        """
        Возвращает основной акцентный цвет.
        :return: str, HEX-код цвета
        """
        return "#9BC59E"

    @Property(str, constant=True)
    def accentLighterColor(self):
        """
        Возвращает светлый акцентный цвет.
        :return: str, HEX-код цвета
        """
        return "#9BC59E"

    @Property(str, constant=True)
    def accentDedicatedColor(self):
        """
        Возвращает выделенный акцентный цвет.
        :return: str, HEX-код цвета
        """
        return "#6FAE75"

    @Property(str, constant=True)
    def accentInactiveColor(self):
        """
        Возвращает цвет неактивного акцента.
        :return: str, HEX-код цвета
        """
        return "#B7D6BA"

    @Property(str, constant=True)
    def completedYellowPartiallyColor(self):
        """
        Возвращает цвет частично выполненного урока.
        :return: str, HEX-код цвета
        """
        return "#EFE77C"

    @Property(str, constant=True)
    def completedGreenFullColor(self):
        """
        Возвращает цвет полностью выполненного урока.
        :return: str, HEX-код цвета
        """
        return "#6FAE75"

    @Property(str, constant=True)
    def completedGrayEmptyColor(self):
        """
        Возвращает цвет урока без прогресса.
        :return: str, HEX-код цвета
        """
        return "#D0D0D0"

    @Property(str, constant=True)
    def textMainColor(self):
        """
        Возвращает основной цвет текста.
        :return: str, HEX-код цвета
        """
        return "#2B2B2B"

