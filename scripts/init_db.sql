CREATE TABLE classes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    hit_die INTEGER NOT NULL
);

INSERT INTO classes (id, name, hit_die) VALUES
    ('fighter', 'Fighter', 10),
    ('wizard', 'Wizard', 6),
    ('thief', 'Thief', 8),
    ('cleric', 'Cleric', 8);
