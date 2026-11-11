CREATE TABLE projects (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 title TEXT NOT NULL CHECK(length(trim(title)) BETWEEN 1 AND 80),
 category TEXT NOT NULL,
 craft_type TEXT NOT NULL CHECK(craft_type IN ('needles','hook','other')),
 icon_id TEXT NOT NULL,
 palette INTEGER NOT NULL CHECK(palette BETWEEN 0 AND 3),
 status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','finished','archived')),
 created_at TEXT NOT NULL,
 updated_at TEXT NOT NULL
);
CREATE TABLE counters (
 project_id INTEGER PRIMARY KEY REFERENCES projects(id) ON DELETE RESTRICT,
 current_row INTEGER NOT NULL DEFAULT 0 CHECK(current_row >= 0),
 repeat_length INTEGER CHECK(repeat_length > 0),
 updated_at TEXT NOT NULL
);
CREATE TABLE row_events (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE RESTRICT,
 timestamp_utc TEXT NOT NULL,
 local_day TEXT NOT NULL,
 delta INTEGER NOT NULL,
 work_delta INTEGER NOT NULL,
 before_row INTEGER NOT NULL CHECK(before_row >= 0),
 after_row INTEGER NOT NULL CHECK(after_row >= 0),
 reason TEXT NOT NULL CHECK(reason IN ('knit','unravel','undo')),
 undo_of INTEGER UNIQUE REFERENCES row_events(id),
 CHECK(after_row = before_row + delta),
 CHECK((reason = 'knit' AND delta = 1 AND work_delta = 1 AND undo_of IS NULL)
    OR (reason = 'unravel' AND delta = -1 AND work_delta = 0 AND undo_of IS NULL)
    OR (reason = 'undo' AND undo_of IS NOT NULL))
);
CREATE INDEX events_project ON row_events(project_id, id);
CREATE INDEX events_day ON row_events(local_day);
CREATE TABLE settings (
 id INTEGER PRIMARY KEY CHECK(id = 1),
 active_project_id INTEGER REFERENCES projects(id),
 reduced_motion INTEGER NOT NULL DEFAULT 0 CHECK(reduced_motion IN (0,1)),
 haptics INTEGER NOT NULL DEFAULT 1 CHECK(haptics IN (0,1))
);
INSERT INTO settings(id) VALUES(1);
