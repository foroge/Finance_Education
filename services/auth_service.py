import base64
import hashlib
import re
import secrets
from unittest import case

from PySide6.QtCore import QObject, Property, Signal, Slot


ALGORITHM = "pbkdf2_sha256"


def hash_password(password: str, salt: str | None = None, iterations: int = 100000) -> tuple[str, str]:
    """
    Создает хэш пароля
    :param password: str, пароль
    :param salt: str, соль
    :param iterations: количество итераций
    :return: tuple[str, str] - хэш, пароль
    """
    if salt is None:
        salt = secrets.token_hex(16)

    pw_hash = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt.encode("utf-8"),
        iterations,
    )

    b64_hash = base64.b64encode(pw_hash).decode("ascii")

    return b64_hash, salt


class AuthService(QObject):
    """
    Сервис для окна авторизации и регистрации
    """
    currentUserChanged = Signal()
    errorMessageChanged = Signal()

    def __init__(self, db):
        super().__init__()
        self.db = db
        self._current_user_id = None
        self._current_user_login = ""
        self._current_user_name = ""
        self._error_message = ""

    @Property(str, notify=currentUserChanged)
    def currentUserLogin(self) -> str:
        """
        Возвращает текущего юзера (логин)
        :return: str, логин текущего юзера
        """
        return self._current_user_login

    @Property(str, notify=currentUserChanged)
    def currentUserName(self) -> str:
        """
        Возвращает имя текущего юзера
        :return: str, имя текущего юзера
        """
        return self._current_user_name

    @Property(int, notify=currentUserChanged)
    def currentUserId(self) -> int:
        """
        Возвращает айди текущего юзера
        :return: int, айди текущего юзера
        """
        return self._current_user_id or 0

    @Property(bool, notify=currentUserChanged)
    def isAuthenticated(self) -> bool:
        """
        Возвращает аутентифицирован ли пользователь
        :return: bool, аутентифицирован ли пользователь
        """
        return self._current_user_id is not None

    @Property(str, notify=errorMessageChanged)
    def errorMessage(self) -> str:
        """
        Возвращает сообщение об ошибке
        :return: str, сообщение об ошибк
        """
        return self._error_message

    def set_error(self, message: str) -> None:
        """
        Устанавливает нужное сообщение об ошибке
        :param message: Текущее сообщение об ошибке
        :return: None
        """
        if self._error_message == message:
            return

        self._error_message = message
        self.errorMessageChanged.emit()

    def clear_error(self) -> None:
        """
        Очищает сообщение об ошибке
        :return: None
        """
        self.set_error("")

    def set_current_user(self, username: str) -> None:
        """
        Устанавливает текущего юзера и информацию о нем
        :param username: Логин пользователя
        :return: None
        """
        user_info = self.db.get_user_info_by_username(username)

        if user_info is None:
            self._current_user_id = None
            self._current_user_login = ""
            self._current_user_name = ""
        else:
            self._current_user_id = user_info[0]
            self._current_user_login = user_info[1]
            self._current_user_name = user_info[2]

        self.currentUserChanged.emit()

    def check_username(self, username: str) -> int:
        """
        Возвращает статус авторизации
        0 - Все нормально
        1 - Пустой логин
        2 - Пользователь не найден
        :param username: Логин пользователя
        :return: int
        """
        if not username.strip():
            return 1

        if not self.db.get_user_is_exist(username):
            return 2

        return 0

    def check_hash(self, username: str, password: str) -> bool:
        """
        Проверяет соответствие введенного пароля сохраненному
        :param username: Логин пользователя
        :param password: Пароль пользователя
        :return: bool, правильный ли пароль
        """
        password_data = self.db.get_hash_password(username)

        if password_data is None:
            return False

        user_password_hash, salt = password_data
        password_hash, _ = hash_password(password, salt)

        return password_hash == user_password_hash

    def check_password_auth(self, username: str, password: str) -> int:
        """
        Возвращает статус проверки пароля
        0 - Все норм
        1 - Пустой пароль
        2 - Некорректный пароль
        :param username: Логин пользователя
        :param password: Пароль пользователя
        :return: int, Статус пароля
        """
        if not password:
            return 1
        if not self.check_hash(username, password):
            return 2
        return 0

    def get_auth_error(self, username: str, password: str) -> int | str:
        """
        Получает сообщение об ошибке авторизации
        :param username: Логин пользователя
        :param password: Пароль пользователя
        :return: str, сообщение ошибки
        """
        username_result = self.check_username(username)

        match username_result:
            case 0:
                pass
            case 1:
                return "Логин не должен быть пустым"
            case 2:
                return "Пользователь не найден"

        password_result = self.check_password_auth(username, password)

        match password_result:
            case 0:
                return 0
            case 1:
                return "Пароль не должен быть пустым"
            case 2:
                return "Неверный пароль"

        return "Неизвестная ошибка"

    @Slot(str, str, result=bool)
    def login(self, username: str, password: str) -> bool:
        """
        Процесс аутентификации пользователя
        :param username: Логин пользователя
        :param password: Пароль пользователя
        :return: bool, результат авторизации
        """
        result = self.get_auth_error(username, password)

        if result == 0:
            self.clear_error()
            self.set_current_user(username)
            return True

        self.set_error(result)
        return False

    @staticmethod
    def check_length(password: str) -> bool:
        """
        Проверка соответствия длины пароля
        :param password: Пароль
        :return: bool, результат проверки
        """
        return 8 <= len(password) <= 24

    @staticmethod
    def check_latin_letters(password: str) -> bool:
        """
        Проверка наличия латинских букв
        :param password: Пароль
        :return: bool, результат проверки
        """
        return bool(re.search(r"[A-Za-z]", password))

    @staticmethod
    def check_digits(password: str) -> bool:
        """
        Проверка наличия цифр
        :param password: Пароль
        :return: bool, результат проверки
        """
        return bool(re.search(r"\d", password))

    @staticmethod
    def check_special_chars(password: str) -> bool:
        """
        Проверка наличия специальных символов в пароле
        :param password: Пароль
        :return: bool, результат проверки
        """
        return bool(re.search(r"[!@#$%*()+\-=\\|/?]", password))

    @staticmethod
    def check_spaces(password: str) -> bool:
        return bool(re.search(r'\s', password))

    @staticmethod
    def check_only_latin_letters_and_digits(text: str) -> bool:
        """
        Проверка только латинских букв и _
        :return:
        """
        return bool(re.match(r'^[a-zA-Z0-9_]+$', text))

    def validate_password_strength(self, password: str) -> int:
        """
        0 - Все нормально
        1 - Пустой пароль
        2 - Неправильная длина пароля
        3 - Нет латинских букв
        4 - Нет цифр
        5 - Нет специальных символов
        """

        if not password:
            return 1
        if not self.check_length(password):
            return 2
        if not self.check_latin_letters(password):
            return 3
        if not self.check_digits(password):
            return 4
        if not self.check_special_chars(password):
            return 5
        if self.check_spaces(password):
            return 6
        return 0

    def validate_login(self, login: str) -> int:
        """
        0 - Все нормально
        1 - Есть недопустимые символы
        :param login:
        :return:
        """
        if not self.check_only_latin_letters_and_digits(login):
            return 1
        return 0

    def get_login_validation_error(self, login: str):
        """
        Получает сообщение об ошибке логина
        :param login: Логин пользователя
        :return: str, сообщение ошибки
        """
        result = self.validate_login(login)

        match result:
            case 0:
                return 0
            case 1:
                return "Логин должен состоять только из латинских букв, цифр и _"
            case _:
                return "Неизвестная ошибка"

    def get_password_validation_error(self, password: str):
        """
        Получает сообщение об ошибке некорректности пароля
        :param password: Пароль пользователя
        :return: str, сообщение ошибки
        """
        result = self.validate_password_strength(password)

        match result:
            case 0:
                return 0
            case 1:
                return "Пароль не должен быть пустым"
            case 2:
                return "Длина пароля должна быть от 8 до 24 символов"
            case 3:
                return "Пароль должен содержать латинские буквы"
            case 4:
                return "Пароль должен содержать цифры"
            case 5:
                return "Пароль должен содержать спецсимволы"
            case 6:
                return "Пароль не должен содержать пробелы"
            case _:
                return "Неизвестная ошибка"

    def get_registration_error(self, username: str, name: str, password: str, confirm_password: str) -> str | int:
        """
        Получение ошибки регистрации
        :param username: Логин пользователя
        :param name: Имя
        :param password: Пароль
        :param confirm_password: Подтверждение пароля
        :return: str, сообщение об ошибке
        """
        if not username.strip():
            return "Логин не должен быть пустым"

        if not name.strip():
            return "Имя не должно быть пустым"

        if len(username) > 30 or len(name) > 30:
            return "Имя/Логин не должны быть длиннее 30 символов"

        if len(username) < 4 or len(name) < 2:
            return "Имя/Логин не должны быть короче 2/4 символов"

        if self.db.get_user_is_exist(username):
            return "Пользователь уже существует"

        login_check = self.get_login_validation_error(username)

        if login_check != 0:
            return login_check

        password_check = self.get_password_validation_error(password)

        if password_check != 0:
            return password_check

        if password != confirm_password:
            return "Пароли не совпадают"

        return 0

    @Slot(str, str, str, str, result=bool)
    def register(self, username: str, name: str, password: str, confirm_password: str) -> bool:
        """
        Процесс регистрации
        :param username: Логин пользователя
        :param name: Имя пользователя
        :param password: Пароль
        :param confirm_password: Подтверждение пароля
        :return: bool, результат регистрации
        """
        result = self.get_registration_error(username, name, password, confirm_password)

        if result != 0:
            self.set_error(result)
            return False

        password_hash, salt = hash_password(password)

        self.db.create_user(username=username, name=name, password_hash=password_hash, salt=salt)

        self.clear_error()
        self.set_current_user(username)
        return True

    @Slot()
    def logout(self):
        """
        Выход из аккаунта
        :return: None
        """
        self.clear_error()
        self._current_user_id = None
        self._current_user_login = ""
        self._current_user_name = ""
        self.currentUserChanged.emit()
