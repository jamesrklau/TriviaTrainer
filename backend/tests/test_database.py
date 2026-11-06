import sqlite3

import pytest

from database import (
    get_connection,
    get_explanation,
    initialize_database,
    save_explanation,
)


def sample_explanation():
    return {
        "question_id": "mars-roman-mythology-test-001",
        "question": "In Roman mythology, who is the god of war?",
        "category": "Mythology",
        "correct_answer": "Mars",
        "explanation": "Mars was the Roman god of war.",
        "reasoning_steps": [
            {
                "title": "Identify the mythology",
                "detail": "The question specifically refers to Roman mythology.",
            },
            {
                "title": "Connect the deity",
                "detail": "Mars was the Roman equivalent of the Greek god Ares.",
            },
        ],
        "related_facts": [
            {
                "title": "Greek mythology",
                "detail": "Ares was the Greek god of war.",
            },
            {
                "title": "Planet Mars",
                "detail": "The planet was named after the Roman god.",
            },
        ],
        "takeaway": "Mars is the Roman god of war.",
        "source": "curated",
        "review_status": "reviewed",
    }


def test_initialize_database_creates_table(tmp_path):
    db_path = tmp_path / "test.db"

    initialize_database(db_path)

    connection = get_connection(db_path)

    try:
        result = connection.execute(
            """
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
            AND name = 'question_explanations'
            """
        ).fetchone()

        assert result is not None
        assert result["name"] == "question_explanations"

    finally:
        connection.close()


def test_database_has_expected_columns(tmp_path):
    db_path = tmp_path / "test.db"

    initialize_database(db_path)

    connection = get_connection(db_path)

    try:
        columns = connection.execute(
            "PRAGMA table_info(question_explanations)"
        ).fetchall()

        column_names = [column["name"] for column in columns]

        expected_columns = [
            "question_id",
            "question",
            "category",
            "correct_answer",
            "explanation",
            "reasoning_steps",
            "related_facts",
            "takeaway",
            "source",
            "review_status",
            "created_at",
            "updated_at",
        ]

        assert column_names == expected_columns

    finally:
        connection.close()


def test_save_and_retrieve_explanation(tmp_path):
    db_path = tmp_path / "test.db"
    initialize_database(db_path)

    original = sample_explanation()

    save_explanation(original, db_path)
    retrieved = get_explanation(original["question_id"], db_path)

    assert retrieved is not None
    assert retrieved["question_id"] == original["question_id"]
    assert retrieved["question"] == original["question"]
    assert retrieved["correct_answer"] == original["correct_answer"]
    assert retrieved["reasoning_steps"] == original["reasoning_steps"]
    assert retrieved["related_facts"] == original["related_facts"]
    assert retrieved["takeaway"] == original["takeaway"]


def test_get_explanation_returns_none_when_not_found(tmp_path):
    db_path = tmp_path / "test.db"
    initialize_database(db_path)

    result = get_explanation("nonexistent-question", db_path)

    assert result is None


def test_duplicate_question_id_is_rejected(tmp_path):
    db_path = tmp_path / "test.db"
    initialize_database(db_path)

    explanation = sample_explanation()

    save_explanation(explanation, db_path)

    with pytest.raises(sqlite3.IntegrityError):
        save_explanation(explanation, db_path)
