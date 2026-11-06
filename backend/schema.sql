CREATE TABLE IF NOT EXISTS question_explanations (
    question_id TEXT PRIMARY KEY,

    question TEXT NOT NULL,
    category TEXT NOT NULL,
    correct_answer TEXT NOT NULL,

    explanation TEXT NOT NULL,
    reasoning_steps TEXT NOT NULL,
    related_facts TEXT NOT NULL,
    takeaway TEXT NOT NULL,

    source TEXT NOT NULL
        CHECK (source IN ('curated', 'aiGenerated')),

    review_status TEXT NOT NULL
        CHECK (review_status IN ('reviewed', 'needsReview')),

    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
