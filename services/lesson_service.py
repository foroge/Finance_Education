import re
import random
import json
from pathlib import Path
from urllib.parse import urlparse

from PySide6.QtCore import QObject, Slot, QUrl

from .color_definition import get_progress_color
from .training_generators import generate_training_task


class LessonService(QObject):
    """
    Сервис уроков, тестов, тренажеров и пользовательской статистики.
    """

    def __init__(self, db):
        """
        Инициализирует сервис с готовым подключением к базе данных.
        :param db: DataBase, объект для работы с базой данных
        """
        super().__init__()
        self.db = db
        self.project_root = Path(__file__).resolve().parent.parent

    @Slot(int, result="QVariant")
    def getTopics(self, user_id=0):
        """
        Возвращает список тем для главного меню с учетом прогресса пользователя.
        :param user_id: int, идентификатор пользователя
        :return: QVariant, список тем
        """
        topics = []
        progress_by_lesson = self._best_test_progress_by_lesson(user_id)

        for row in self.db.get_all_lessons():
            lesson_id = row["id"]
            questions = self.db.get_lesson_questions(lesson_id)
            training = self.db.get_training_templates(lesson_id)
            progress = progress_by_lesson.get(lesson_id, 0.0)

            topics.append({
                "id": lesson_id,
                "title": row["name"],
                "lecture": "Лекция",
                "test": "Тест" if questions else "",
                "trainer": "Тренажер" if training else "",
                "status": "done" if progress > 0.5 else ("partial" if progress > 0 else "empty"),
                "progressColor": get_progress_color(progress),
            })

        return topics

    @Slot(int, result="QVariant")
    def getLecture(self, lesson_id):
        """
        Возвращает данные лекции и ее слайды.
        :param lesson_id: int, идентификатор лекции
        :return: QVariant, структура лекции для QML
        """
        lesson = self.db.get_lesson(lesson_id)

        if lesson is None:
            return {"id": lesson_id, "title": "", "pages": []}

        pages = []
        for slide in self.db.get_lesson_slides(lesson_id):
            pages.append({
                "text": slide["slide_info"],
                "image": self._image_source_for_qml(slide["image_path"] or ""),
                "caption": slide["image_describe"] or "",
            })

        return {
            "id": lesson["id"],
            "title": lesson["name"],
            "pages": pages,
        }

    @Slot(int, int, result="QVariant")
    def getTest(self, user_id, lesson_id):
        """
        Формирует тест по выбранному уроку и сохраняет созданную попытку.
        :param user_id: int, идентификатор пользователя
        :param lesson_id: int, идентификатор урока
        :return: QVariant, данные теста
        """
        lesson = self.db.get_lesson(lesson_id)
        title = lesson["name"] if lesson else ""
        questions = []
        test_id = self.db.create_generated_test(user_id, lesson_id) if user_id > 0 else 0

        lesson_questions = list(self.db.get_lesson_questions(lesson_id))
        random.shuffle(lesson_questions)

        for question in lesson_questions[:10]:
            if test_id:
                self.db.add_generated_test_question(test_id, question["id"])

            answers = []

            for answer in self.db.get_question_answers(question["id"]):
                answers.append({
                    "id": answer["id"],
                    "text": answer["answer"],
                    "correct": answer["type"] == 1,
                })

            random.shuffle(answers)

            questions.append({
                "id": question["id"],
                "text": question["question"],
                "answers": answers,
            })

        return {
            "testId": test_id,
            "lessonId": lesson_id,
            "title": title,
            "questions": questions,
        }

    @Slot(int, result="QVariant")
    def getTraining(self, lesson_id):
        """
        Возвращает список тренировочных заданий для урока.
        :param lesson_id: int, идентификатор урока
        :return: QVariant, список заданий
        """
        slides = [row["slide_info"] for row in self.db.get_lesson_slides(lesson_id)]
        tasks = []

        for template in self.db.get_training_templates(lesson_id):
            generated_task = generate_training_task(
                template["function"],
                "",
                {"lesson_id": lesson_id, "slides": slides},
            )

            tasks.append({
                "id": template["id"],
                "type": "task",
                "function": template["function"],
                "text": generated_task["text"],
                "answer": generated_task["answer"],
            })

        return {
            "lessonId": lesson_id,
            "tasks": tasks,
        }

    @Slot(int, result="QVariant")
    def generateTrainingTask(self, lesson_id):
        """
        Генерирует одно случайное тренировочное задание по уроку.
        :param lesson_id: int, идентификатор урока
        :return: QVariant, данные задания
        """
        templates = self.db.get_training_templates(lesson_id)

        if not templates:
            return {
                "id": 0,
                "type": "task",
                "function": "",
                "text": "",
                "answer": "",
            }

        template = random.choice(templates)
        slides = [row["slide_info"] for row in self.db.get_lesson_slides(lesson_id)]
        generated_task = generate_training_task(
            template["function"],
            "",
            {"lesson_id": lesson_id, "slides": slides},
        )

        return {
            "id": template["id"],
            "type": "task",
            "function": template["function"],
            "text": generated_task["text"],
            "answer": generated_task["answer"],
        }

    @Slot(str, str, result=bool)
    def checkAnswer(self, expected, actual):
        """
        Проверяет ответ пользователя с учетом числового и текстового сравнения.
        :param expected: str, ожидаемый ответ
        :param actual: str, ответ пользователя
        :return: bool, совпал ли ответ
        """
        expected_number = self._parse_number(expected)
        actual_number = self._parse_number(actual)

        if expected_number is not None and actual_number is not None:
            return abs(expected_number - actual_number) < 0.01

        return self._normalize_answer(expected) == self._normalize_answer(actual)

    @Slot(int, int, int, int, int, str)
    def saveTestResult(self, user_id, lesson_id, test_id, correct, total, answers_json):
        """
        Сохраняет результат прохождения теста и выбранные ответы.
        :param user_id: int, идентификатор пользователя
        :param lesson_id: int, идентификатор урока
        :param test_id: int, идентификатор тестовой попытки
        :param correct: int, количество верных ответов
        :param total: int, общее количество вопросов
        :param answers_json: str, JSON со списком ответов пользователя
        :return: None
        """
        if user_id <= 0 or lesson_id <= 0 or total <= 0:
            return

        self.db.save_user_result(user_id, lesson_id, "test", correct, total)

        if test_id <= 0:
            return

        for answer in json.loads(answers_json or "[]"):
            question_id = int(answer.get("questionId", 0) or 0)
            answer_id = str(answer.get("answerId", "") or "")

            if question_id > 0:
                self.db.save_test_answer(user_id, question_id, test_id, answer_id)

    @Slot(int, int, int, int)
    def saveTrainingResult(self, user_id, lesson_id, correct, total):
        """
        Сохраняет результат прохождения тренажера.
        :param user_id: int, идентификатор пользователя
        :param lesson_id: int, идентификатор урока
        :param correct: int, количество верных ответов
        :param total: int, общее количество заданий
        :return: None
        """
        if user_id <= 0 or lesson_id <= 0 or total <= 0:
            return

        self.db.save_user_result(user_id, lesson_id, "training", correct, total)

    @Slot(int, result="QVariant")
    def getStatistics(self, user_id):
        """
        Возвращает статистику пользователя по тестам и тренажерам.
        :param user_id: int, идентификатор пользователя
        :return: QVariant, агрегированная статистика
        """
        lessons = self.db.get_all_lessons()
        test_lessons_count = sum(
            1 for lesson in lessons
            if self.db.get_lesson_questions(lesson["id"])
        )
        training_lessons_count = sum(
            1 for lesson in lessons
            if self.db.get_training_templates(lesson["id"])
        )
        results = self.db.get_user_results(user_id) if user_id > 0 else []

        return {
            "tests": self._build_stats(results, "test", test_lessons_count),
            "trainings": self._build_training_stats(results, training_lessons_count),
        }

    @staticmethod
    def _normalize_answer(value):
        """
        Нормализует текстовый ответ для сравнения.
        :param value: str, исходный ответ
        :return: str, нормализованный ответ
        """
        return re.sub(r"\s+", " ", str(value or "")).strip().lower().replace("ё", "е")

    @staticmethod
    def _parse_number(value):
        """
        Пытается преобразовать строковый ответ в число.
        :param value: str, исходный ответ
        :return: float | None, число или None
        """
        normalized = str(value or "").replace(" ", "").replace(",", ".")

        try:
            return float(normalized)
        except ValueError:
            return None

    def _image_source_for_qml(self, value):
        """
        Преобразует путь изображения из БД в источник для QML.
        :param value: str, относительный путь, абсолютный путь или URL
        :return: str, URL изображения для QML
        """
        if not value:
            return ""

        parsed = urlparse(value)
        if parsed.scheme in {"file", "qrc"}:
            return value

        path = Path(value)
        if not path.is_absolute():
            path = self.project_root / path

        return QUrl.fromLocalFile(str(path)).toString()

    def _best_test_progress_by_lesson(self, user_id):
        """
        Находит лучший тестовый прогресс пользователя по каждому уроку.
        :param user_id: int, идентификатор пользователя
        :return: dict, прогресс по идентификаторам уроков
        """
        if user_id <= 0:
            return {}

        progress_by_lesson = {}

        for result in self.db.get_user_results(user_id):
            if result["result_type"] != "test" or result["total"] <= 0:
                continue

            lesson_id = result["lesson_id"]
            progress = result["correct"] / result["total"]

            if progress > progress_by_lesson.get(lesson_id, 0.0):
                progress_by_lesson[lesson_id] = progress

        return progress_by_lesson

    @staticmethod
    def _build_stats(results, result_type, lessons_count):
        """
        Собирает статистику по тестам с учетом лучшего результата по каждой теме.
        :param results: list, строки результатов из базы данных
        :param result_type: str, тип результата
        :param lessons_count: int, общее количество уроков
        :return: dict, статистика для интерфейса
        """
        result_rows = [
            result for result in results
            if result["result_type"] == result_type and result["total"] > 0
        ]

        best_by_lesson = {}

        for result in result_rows:
            percent = round(result["correct"] * 100 / result["total"])
            lesson_id = result["lesson_id"]
            current = best_by_lesson.get(lesson_id)

            if current is None or percent > current["percent"]:
                best_by_lesson[lesson_id] = {
                    "lessonName": result["lesson_name"],
                    "percent": percent,
                }

        passed_lessons = {
            lesson_id: result
            for lesson_id, result in best_by_lesson.items()
            if result["percent"] > 50
        }
        completed_lessons = len(passed_lessons)
        average = round(
            sum(result["percent"] for result in best_by_lesson.values()) / len(best_by_lesson)
        ) if best_by_lesson else 0
        best = max(
            (result["percent"] for result in best_by_lesson.values()),
            default=0,
        )
        worst = min(best_by_lesson.values(), key=lambda result: result["percent"], default=None)
        worst_percent = worst["percent"] if worst else 0
        progress = round(completed_lessons * 100 / lessons_count) if lessons_count else 0

        return {
            "completed": completed_lessons,
            "total": lessons_count,
            "average": average,
            "best": best,
            "worstTopic": worst["lessonName"] if worst else "-",
            "worstPercent": worst_percent,
            "progress": progress,
        }

    @staticmethod
    def _build_training_stats(results, lessons_count):
        """
        Собирает отдельную статистику по тренажерам.
        :param results: list, строки результатов из базы данных
        :param lessons_count: int, общее количество уроков
        :return: dict, статистика тренажеров для интерфейса
        """
        training_results = [
            result for result in results
            if result["result_type"] == "training" and result["total"] > 0
        ]

        total_correct = sum(result["correct"] for result in training_results)
        total_attempts = sum(result["total"] for result in training_results)
        completed_lessons = len({result["lesson_id"] for result in training_results})
        average = round(total_correct * 100 / total_attempts) if total_attempts else 0
        best = max(
            (round(result["correct"] * 100 / result["total"]) for result in training_results),
            default=0,
        )
        worst = min(
            training_results,
            key=lambda result: round(result["correct"] * 100 / result["total"]),
            default=None,
        )
        worst_percent = round(worst["correct"] * 100 / worst["total"]) if worst else 0
        progress = round(completed_lessons * 100 / lessons_count) if lessons_count else 0

        return {
            "completed": total_correct,
            "total": total_attempts,
            "average": average,
            "best": best,
            "worstTopic": worst["lesson_name"] if worst else "-",
            "worstPercent": worst_percent,
            "progress": progress,
        }
