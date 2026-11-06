import sqlite3
from pathlib import Path
import json

# Keep the database inside the backend directory.
BASE_DIR = Path(__file__).resolve().parent
DATABASE_PATH = BASE_DIR / "triviatrainer.db"
SCHEMA_PATH = BASE_DIR / "schema.sql"


def get_connection(db_path=DATABASE_PATH):
    """Create and return a connection to the SQLite database."""
    connection = sqlite3.connect(db_path)
    connection.row_factory = sqlite3.Row
    return connection


def initialize_database(db_path=DATABASE_PATH):
    """Create database tables using the SQL schema."""
    connection = get_connection(db_path)

    try:
        with open(SCHEMA_PATH, "r", encoding="utf-8") as schema_file:
            schema = schema_file.read()

        connection.executescript(schema)
        connection.commit()

    finally:
        connection.close()

def save_explanation(explanation, db_path=DATABASE_PATH):
    """Save a question explanation to the database."""
    connection = get_connection(db_path)

    try:
        connection.execute(
            """
            INSERT INTO question_explanations (
                question_id,
                question,
                category,
                correct_answer,
                explanation,
                reasoning_steps,
                related_facts,
                takeaway,
                source,
                review_status
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                explanation["question_id"],
                explanation["question"],
                explanation["category"],
                explanation["correct_answer"],
                explanation["explanation"],
                json.dumps(explanation["reasoning_steps"]),
                json.dumps(explanation["related_facts"]),
                explanation["takeaway"],
                explanation["source"],
                explanation["review_status"],
            ),
        )

        connection.commit()

    finally:
        connection.close()


def get_explanation(question_id, db_path=DATABASE_PATH):
    """Retrieve an explanation using its question fingerprint."""
    connection = get_connection(db_path)

    try:
        result = connection.execute(
            """
            SELECT *
            FROM question_explanations
            WHERE question_id = ?
            """,
            (question_id,),
        ).fetchone()

        if result is None:
            return None

        explanation = dict(result)

        explanation["reasoning_steps"] = json.loads(
            explanation["reasoning_steps"]
        )

        explanation["related_facts"] = json.loads(
            explanation["related_facts"]
        )

        return explanation

    finally:
        connection.close()
