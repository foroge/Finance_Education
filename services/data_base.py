import sqlite3 as db
import os
from pathlib import Path

from data import (USER, LESSON, LESSON_QUESTION, LESSON_LECTURE, LESSON_QUESTION_ANSWER,
                  GENERATED_TEST, GENERATED_TEST_INFO, TEST_STAT, TRAINING_TEMPLATES, USER_RESULTS)

# DLL для создания таблиц
DLLS = [USER, LESSON, LESSON_QUESTION, LESSON_LECTURE, LESSON_QUESTION_ANSWER, GENERATED_TEST,
        GENERATED_TEST_INFO, TEST_STAT, TRAINING_TEMPLATES, USER_RESULTS]


class DataBase:
    """
    Класс для работы с базой данных
    """
    def __init__(self):
        project_root = Path(__file__).resolve().parent.parent
        path = project_root / "data" / "data_base" / "data.db"

        self.create_db_file(str(path))

        self.base = db.connect(path)
        self.base.row_factory = db.Row
        # Создание ограничений для
        self.base.execute("PRAGMA foreign_keys = ON")

        self.add_tables()

    @staticmethod
    def create_db_file(path: str) -> None:
        """
        Создает файл базы данных
        :param path: Путь
        :return: None
        """
        os.makedirs(os.path.dirname(path), exist_ok=True)

        if not os.path.exists(path):
            open(path, "w").close()

    def add_tables(self):
        """
        Добавляет все таблицы
        :return: None
        """
        for ddl in DLLS:
            self.create_table(ddl)

    def create_table(self, ddl: str):
        """
        Создает таблицу
        :param ddl: скрипт для создания таблицы
        :return: None
        """
        with self.base:
            self.base.execute(ddl)

    def get_all_tables(self):
        """
        Получение всех таблиц
        :return: None
        """
        with self.base:
            cur = self.base.cursor()

            return cur.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()

    def create_user(self, username: str, name: str, password_hash: str, salt: str):
        """
        Создание пользователя
        :param username: Логин
        :param name: Имя
        :param password_hash: Хэш
        :param salt: Соль
        :return: None
        """
        with self.base:
            cur = self.base.cursor()
            sql = "INSERT INTO users (login, name, password_hash, salt) VALUES (?, ?, ?, ?)"
            cur.execute(sql,(username, name, password_hash, salt))

    def delete_user(self, username: str):
        """
        Удаление пользователя по логину
        :param username: Логин
        :return: None
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("DELETE FROM users WHERE login = ?",(username,))

    def get_user_is_exist(self, username: str) -> bool:
        """
        Создан ли пользователь
        :param username: Логин
        :return: None
        """
        with self.base:
            cur = self.base.cursor()
            result = cur.execute("SELECT 1 FROM users WHERE login = ?",(username,)).fetchone()
        return result is not None

    def get_user_info_by_username(self, username: str):
        """
        Получение информации по логину
        :param username: Логин
        :return: None
        """
        with self.base:
            cur = self.base.cursor()
            return cur.execute("SELECT * FROM users WHERE login = ?", (username,)).fetchone()

    def get_user_id(self, username: str):
        """
        Получение айди по логину
        :param username: Логин
        :return: None
        """
        with self.base:
            cur = self.base.cursor()
            result = cur.execute("SELECT id FROM users WHERE login = ?",(username,)).fetchone()
        return result[0] if result else None

    def get_hash_password(self, username: str):
        """
        Получение хэша пароля
        :param username: Логин
        :return: None
        """
        with self.base:
            cur = self.base.cursor()
            return cur.execute("SELECT password_hash, salt FROM users WHERE login = ?",
                               (username,)).fetchone()

    def create_lesson_with_id(self, lesson_id: int, lesson_name: str):
        """
        Создание лекции по айди
        :param lesson_id:
        :param lesson_name:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("INSERT INTO lesson(id, name) VALUES (?, ?)", (lesson_id, lesson_name))

    def update_lesson_name(self, lesson_id: int, lesson_name: str):
        """
        Обновление имени лекции
        :param lesson_id:
        :param lesson_name:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("UPDATE lesson SET name = ? WHERE id = ?", (lesson_name, lesson_id))

    def get_next_lesson_id(self):
        """
        Получение айди след лекции
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            result = cur.execute("SELECT COALESCE(MAX(id), 0) + 1 FROM lesson").fetchone()
        return result[0]

    def get_all_lessons(self):
        """
        Получение всех лекций
        :return:
        """
        with self.base:
            cur = self.base.cursor()

            return cur.execute("SELECT * FROM lesson ORDER BY id").fetchall()

    def get_lesson(self, lesson_id: int):
        """
        Получение лекции по айди
        :param lesson_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            return cur.execute("SELECT * FROM lesson WHERE id = ?",(lesson_id,)).fetchone()

    def get_lesson_by_name(self, lesson_name: str):
        """
        Получение лекции по имени
        :param lesson_name:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            return cur.execute("SELECT * FROM lesson WHERE name = ?", (lesson_name,)).fetchone()

    def create_question(self, lesson_id: int, question: str):
        """
        Создание вопроса
        :param lesson_id:
        :param question:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("INSERT INTO lesson_question (id_lesson, question) VALUES (?, ?)",
                        (lesson_id, question))

    def get_lesson_questions(self, lesson_id: int):
        """
        Получение вопросов по айди лекции
        :param lesson_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            return cur.execute("SELECT * FROM lesson_question WHERE id_lesson = ?",
                               (lesson_id,)).fetchall()

    def delete_lesson_questions(self, lesson_id: int):
        """
        Удаление вопросов по айди лекции
        :param lesson_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            question_ids = cur.execute(
                "SELECT id FROM lesson_question WHERE id_lesson = ?",
                (lesson_id,),
            ).fetchall()

            for question_id in question_ids:
                cur.execute(
                    "DELETE FROM lesson_question_answer WHERE question_id = ?",
                    (question_id["id"],),
                )

            cur.execute("DELETE FROM lesson_question WHERE id_lesson = ?", (lesson_id,))

    def get_question(self, question_id: int):
        """
        Получение вопроса по айди вопроса
        :param question_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()

            return cur.execute("SELECT * FROM lesson_question WHERE id = ?",
                               (question_id,)).fetchone()

    def create_answer(self, question_id: int, answer: str, answer_type: int):
        """
        Создание ответа для вопроса
        :param question_id:
        :param answer:
        :param answer_type: тип вопроса (ошибочный или нет)
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("INSERT INTO lesson_question_answer (question_id, type, answer) VALUES (?, ?, ?)",
                        (question_id, answer_type, answer))

    def get_question_answers(self, question_id: int):
        """
        Получение ответов на вопрос
        :param question_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()

            return cur.execute("SELECT * FROM lesson_question_answer WHERE question_id = ?",
                               (question_id,)).fetchall()

    def get_correct_answer(self, question_id: int):
        """
        Получение корректного ответа на вопрос
        :param question_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()

            return cur.execute("SELECT * FROM lesson_question_answer WHERE question_id = ? AND type = 1",
                               (question_id,)).fetchone()

    def create_generated_test(self, user_id: int, lesson_id: int):
        """
        Сохранение сгенерированного теста
        :param user_id:
        :param lesson_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute(
                "INSERT INTO generated_test (user_id, lesson_id) VALUES (?, ?)",
                (user_id, lesson_id),
            )
            return cur.lastrowid

    def add_generated_test_question(self, test_id: int, question_id: int):
        """
        Добавление вопросов к сгенерированному тесту
        :param test_id:
        :param question_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute(
                "INSERT INTO generated_test_info (test_id, question_id) VALUES (?, ?)",
                (test_id, question_id),
            )

    def save_test_answer(self, user_id: int, question_id: int, test_id: int, user_answer: str):
        """
        Сохранение ответов пользователей
        :param user_id:
        :param question_id:
        :param test_id:
        :param user_answer:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("""
                INSERT INTO test_stat (user_id, question_id, test_id, user_answer)
                VALUES (?, ?, ?, ?)
            """, (user_id, question_id, test_id, user_answer))

    def create_slide(
            self,
            lesson_id: int,
            slide_info: str,
            slide_number: int,
            image_path: str | None = None,
            image_describe: str | None = None,
    ):
        """
        Создание слайда с информацией по айди лекции
        :param lesson_id:
        :param slide_info:
        :param slide_number:
        :param image_path:
        :return:
        """
        with self.base:
            cur = self.base.cursor()

            cur.execute("""
                INSERT INTO lesson_lecture (id_lesson, slide_info, image_path, image_describe, slide)
                VALUES (?, ?, ?, ?, ?)
            """, (lesson_id, slide_info, image_path, image_describe, slide_number))

    def delete_lesson_slides(self, lesson_id: int):
        """
        Удаление слайдов к лекции по айди лекции
        :param lesson_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("DELETE FROM lesson_lecture WHERE id_lesson = ?", (lesson_id,))

    def get_lesson_slides(self, lesson_id: int):
        """
        Получение слайдов по айди лекции
        :param lesson_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()

            return cur.execute("SELECT * FROM lesson_lecture WHERE id_lesson = ? ORDER BY slide",
                               (lesson_id,)).fetchall()

    def create_training_template(self, lesson_id: int, function: str):
        """
        Создание тренажера
        :param lesson_id:
        :param function:
        :return:
        """
        with self.base:
            cur = self.base.cursor()

            cur.execute("INSERT INTO training_template (id_lesson, function) VALUES (?, ?)",
                        (lesson_id, function))

    def get_training_templates(self, lesson_id: int):
        """
        Получение всех тренажеров к лекции
        :param lesson_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            return cur.execute("""
                SELECT
                    training_template.id,
                    training_template.id_lesson,
                    training_template.function
                FROM training_template
                WHERE training_template.id_lesson = ?
                ORDER BY training_template.id
            """,
                               (lesson_id,)).fetchall()

    def save_user_result(self, user_id: int, lesson_id: int, result_type: str, correct: int, total: int):
        """
        Сохранение статистики пользователя
        :param user_id:
        :param lesson_id:
        :param result_type:
        :param correct:
        :param total:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            cur.execute("""
                INSERT INTO user_result (user_id, lesson_id, result_type, correct, total)
                VALUES (?, ?, ?, ?, ?)
            """, (user_id, lesson_id, result_type, correct, total))

    def get_user_results(self, user_id: int):
        """
        Получение статистики пользователя
        :param user_id:
        :return:
        """
        with self.base:
            cur = self.base.cursor()
            return cur.execute("""
                SELECT
                    user_result.id,
                    user_result.user_id,
                    user_result.lesson_id,
                    lesson.name AS lesson_name,
                    user_result.result_type,
                    user_result.correct,
                    user_result.total,
                    user_result.created_at
                FROM user_result
                LEFT JOIN lesson ON lesson.id = user_result.lesson_id
                WHERE user_result.user_id = ?
                ORDER BY user_result.created_at DESC, user_result.id DESC
            """, (user_id,)).fetchall()

    def close(self):
        """
        Закрывает подключение к базе данных.
        :return: None
        """
        self.base.close()