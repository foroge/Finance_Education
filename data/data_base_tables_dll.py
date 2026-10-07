# Таблица пользователей и данных для проверки пароля.
USER = """
CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        login TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        salt INTEGER NOT NULL
    );
"""
# Таблица уроков, которые отображаются как темы курса.
LESSON = """
CREATE TABLE IF NOT EXISTS lesson (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
  );
"""

# Таблица вопросов, привязанных к конкретному уроку.
LESSON_QUESTION = """
CREATE TABLE IF NOT EXISTS lesson_question (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_lesson integer REFERENCES lesson (id),
    question TEXT NOT NULL
  );
"""

# Таблица слайдов лекции с текстом и необязательным изображением.
LESSON_LECTURE = """
CREATE TABLE IF NOT EXISTS lesson_lecture (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_lesson integer REFERENCES lesson (id),
    slide_info TEXT NOT NULL,
    image_path TEXT,
    image_describe TEXT,
    slide int NOT NULL,
    UNIQUE (id_lesson, slide)
  );
"""

# Таблица вариантов ответов для вопросов теста.
LESSON_QUESTION_ANSWER = """
CREATE TABLE IF NOT EXISTS lesson_question_answer (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id integer REFERENCES lesson_question (id),
    type INTEGER NOT NULL, -- информация о том, верный ответ или нет, мб лучше boolean
    answer TEXT NOT NULL
  );
"""

# Таблица созданных попыток прохождения теста.
GENERATED_TEST = """
CREATE TABLE IF NOT EXISTS generated_test (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users (id),
    lesson_id INTEGER REFERENCES lesson (id)
  );
"""

# Таблица вопросов, которые вошли в конкретную тестовую попытку.
GENERATED_TEST_INFO = """
CREATE TABLE IF NOT EXISTS generated_test_info (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    test_id INTEGER REFERENCES generated_test (id),
    question_id INTEGER REFERENCES lesson_question (id)
  );
"""

# Таблица ответов пользователя в рамках тестовой попытки.
TEST_STAT = """
CREATE TABLE IF NOT EXISTS test_stat (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users (id),
    question_id INTEGER REFERENCES lesson_question (id),
    test_id INTEGER REFERENCES generated_test (id),
    user_answer TEXT
  );
"""

# Таблица шаблонов генерации тренировочных заданий.
TRAINING_TEMPLATES = """
CREATE TABLE IF NOT EXISTS training_template (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_lesson integer REFERENCES lesson (id),
    function TEXT
    );
"""

# Таблица агрегированных результатов пользователя по тестам и тренажерам.
USER_RESULTS = """
CREATE TABLE IF NOT EXISTS user_result (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users (id),
    lesson_id INTEGER REFERENCES lesson (id),
    result_type TEXT NOT NULL,
    correct INTEGER NOT NULL,
    total INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
"""
