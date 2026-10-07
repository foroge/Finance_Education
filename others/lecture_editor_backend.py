import json
import os
import shutil
from pathlib import Path
from urllib.parse import unquote, urlparse

from PySide6.QtCore import QObject, Slot, QUrl
from PySide6.QtQml import QJSValue

from services.data_base import DataBase


class LectureEditorBackend(QObject):
    """
    Класс для редактирования лекций
    """
    def __init__(self):
        super().__init__()
        self.project_root = Path(__file__).resolve().parent.parent
        self.lectures_root = self.project_root / "ui" / "data" / "lectures"
        self.db = DataBase()

    @Slot(result=int)
    def nextLessonId(self):
        """
        Следующий айди лекции
        :return:
        """
        return self.db.get_next_lesson_id()

    @Slot(str, int, result="QVariant")
    def importImage(self, source_url, lecture_number):
        """
        Импорт изображения
        :param source_url:
        :param lecture_number:
        :return:
        """
        source_path = self._url_to_path(source_url)

        # Файл не создан или это не файл
        if not source_path.exists() or not source_path.is_file():
            return {
                "ok": False,
                "error": "Файл изображения не найден",
                "displayPath": source_url,
                "storedPath": "",
            }

        safe_lecture_number = max(1, int(lecture_number or 1))
        target_dir = self.lectures_root / f"lecture_{safe_lecture_number}"
        target_dir.mkdir(parents=True, exist_ok=True)

        #Создает путь с нужной лекцией и названием файла
        target_path = self._next_available_path(target_dir / source_path.name)
        shutil.copy2(source_path, target_path)

        return {
            "ok": True,
            "error": "",
            "displayPath": QUrl.fromLocalFile(str(target_path)).toString(),
            "storedPath": str(target_path.relative_to(self.project_root)).replace(os.sep, "/"),
        }

    @Slot(int, str, str, result="QVariant")
    def saveLecture(self, lesson_id, title, pages):
        """
        Сохранение лекции в бд
        :param lesson_id:
        :param title:
        :param pages:
        :return:
        """
        safe_lesson_id = max(1, int(lesson_id or 1))
        lesson_title = (title or "").strip() or f"Лекция {safe_lesson_id}"
        lesson = self.db.get_lesson(safe_lesson_id)

        # Есть ли лекция, если нет, то создает, иначе обновляет
        if lesson is None:
            self.db.create_lesson_with_id(safe_lesson_id, lesson_title)
        else:
            self.db.update_lesson_name(safe_lesson_id, lesson_title)

        # Удаляет старые слайды по этой лекции
        self.db.delete_lesson_slides(safe_lesson_id)

        saved_count = 0
        for index, page in enumerate(self._to_python_pages(pages), start=1):
            text = str(page.get("text", "")).strip()
            image_path = self._image_source_for_db(
                str(page.get("storedImage", "") or page.get("image", "")).strip()
            )
            image_describe = str(page.get("caption", "")).strip() or None

            if not text and not image_path:
                continue

            # Создание и сохранение слайда
            self.db.create_slide(
                lesson_id=safe_lesson_id,
                slide_info=text or " ",
                slide_number=index,
                image_path=image_path,
                image_describe=image_describe,
            )
            saved_count += 1

        return {
            "ok": saved_count > 0,
            "lessonId": safe_lesson_id,
            "savedSlides": saved_count,
            "error": "" if saved_count > 0 else "Добавьте хотя бы один слайд с текстом или изображением",
        }

    @Slot(int, str, result="QVariant")
    def saveTest(self, lesson_id, questions):
        """
        Сохранение тестов
        :param lesson_id:
        :param questions:
        :return:
        """
        safe_lesson_id = max(1, int(lesson_id or 1))
        lesson = self.db.get_lesson(safe_lesson_id)

        if lesson is None:
            return {
                "ok": False,
                "savedQuestions": 0,
                "error": "Сначала сохраните лекцию в БД",
            }

        parsed_questions = self._to_python_pages(questions)
        valid_questions = []

        for question in parsed_questions:
            text = str(question.get("text", "")).strip()
            correct = str(question.get("correct", "")).strip()
            wrong_answers = [
                str(answer).strip()
                for answer in question.get("wrong", [])
                if str(answer).strip()
            ]

            if text and correct and wrong_answers:
                valid_questions.append((text, correct, wrong_answers))

        if not valid_questions:
            return {
                "ok": False,
                "savedQuestions": 0,
                "error": "Добавьте хотя бы один вопрос, правильный ответ и неправильные варианты",
            }

        self.db.delete_lesson_questions(safe_lesson_id)

        for text, correct, wrong_answers in valid_questions:
            self.db.create_question(safe_lesson_id, text)
            question_id = self.db.base.execute("SELECT last_insert_rowid()").fetchone()[0]
            self.db.create_answer(question_id, correct, 1)

            for answer in wrong_answers:
                self.db.create_answer(question_id, answer, 0)

        return {
            "ok": True,
            "savedQuestions": len(valid_questions),
            "error": "",
        }

    @staticmethod
    def _to_python_pages(pages):
        """
        Преобразует список страниц из QML/JSON в обычный Python-список словарей.
        :param pages: str | QJSValue | list, страницы из интерфейса
        :return: list, страницы в формате Python
        """
        if isinstance(pages, str):
            return json.loads(pages or "[]")

        if isinstance(pages, QJSValue):
            pages = pages.toVariant()

        if pages is None:
            return []

        result = []
        for page in pages:
            if isinstance(page, QJSValue):
                page = page.toVariant()
            result.append(dict(page))

        return result

    def _image_source_for_db(self, value):
        """
        Преобразует путь изображения в относительный путь для хранения в БД.
        :param value: str, исходный путь или URL
        :return: str | None, относительный путь, qrc-url или None
        """
        if not value:
            return None

        parsed = urlparse(value)
        if parsed.scheme == "qrc":
            return value

        if parsed.scheme == "file":
            path = self._url_to_path(value)
        else:
            path = Path(value)

        if not path.is_absolute():
            return str(path).replace(os.sep, "/")

        try:
            return str(path.relative_to(self.project_root)).replace(os.sep, "/")
        except ValueError:
            return str(path).replace(os.sep, "/")

    def _image_source_for_qml(self, value):
        """
        Преобразует путь изображения из БД в источник, который может открыть QML.
        :param value: str, относительный путь, абсолютный путь или URL
        :return: str | None, URL изображения для QML
        """
        if not value:
            return None

        parsed = urlparse(value)
        if parsed.scheme in {"file", "qrc"}:
            return value

        path = Path(value)
        if not path.is_absolute():
            path = self.project_root / path

        return QUrl.fromLocalFile(str(path)).toString()

    @staticmethod
    def _url_to_path(value):
        """
        Преобразует file-url или обычную строку пути в Path.
        :param value: str, URL или путь
        :return: Path, путь к файлу
        """
        parsed = urlparse(value)

        if parsed.scheme == "file":
            return Path(unquote(parsed.path.lstrip("/")))

        return Path(value)

    @staticmethod
    def _next_available_path(path):
        """
        Подбирает свободное имя файла, если файл с таким именем уже существует.
        :param path: Path, желаемый путь
        :return: Path, свободный путь
        """
        if not path.exists():
            return path

        stem = path.stem
        suffix = path.suffix
        parent = path.parent
        index = 2

        while True:
            candidate = parent / f"{stem}_{index}{suffix}"
            if not candidate.exists():
                return candidate
            index += 1
