import sys
import os
from pathlib import Path

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from constants import Constants
import qml_qrc_rc
from services import DataBase, LessonService
from services import AuthService



os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

# Создает приложение и сервисы, которые используются интерфейсом.
app = QApplication(sys.argv)

constants = Constants()
db = DataBase()
auth_service = AuthService(db)
lesson_service = LessonService(db)

engine = QQmlApplicationEngine()

# Передает объекты в QML-контекст.
engine.rootContext().setContextProperty("lessonService", lesson_service)
engine.rootContext().setContextProperty("topicsModel", lesson_service.getTopics(0))
engine.rootContext().setContextProperty("auth", auth_service)


engine.rootContext().setContextProperty(
    "Constants",
    constants
)

# Загружает главный QML файл приложения.
qml_file = Path(__file__).parent / "ui" / "qml" / "main.qml"
engine.load(str(qml_file))



print(engine.rootObjects(), engine)
# Завершает приложение с ошибкой, если главное окно не было создано.
if not engine.rootObjects():
    sys.exit(-1)
sys.exit(app.exec())
