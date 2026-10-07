import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from others.lecture_editor_backend import LectureEditorBackend


os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

# Создает отдельное Qt-приложение для редактора лекций.
app = QApplication(sys.argv)
engine = QQmlApplicationEngine()

# Передает backend редактора в QML-контекст.
lecture_editor_backend = LectureEditorBackend()
engine.rootContext().setContextProperty("lectureEditorBackend", lecture_editor_backend)

# Загружает QML-файл окна редактора лекций.
qml_file = Path(__file__).parent / "ui" / "qml" / "LectureEditorWindow.qml"
engine.load(str(qml_file))

# Завершает приложение с ошибкой, если окно не было создано.
if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())
