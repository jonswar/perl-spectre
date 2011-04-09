CREATE TABLE comments (
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   file_id            INTEGER NOT NULL,
   content            TEXT NOT NULL,
   author             TEXT NOT NULL,
   create_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   CONSTRAINT 'fk_comments_files' FOREIGN KEY ('file_id') REFERENCES 'files' ('id') ON DELETE CASCADE
);

CREATE TABLE files (
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   name               TEXT NOT NULL UNIQUE,
   mute_until         DATETIME
);

CREATE TABLE reports (
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   create_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   layer              TEXT NOT NULL,
   name               TEXT NOT NULL,
   passed_count       INTEGER NOT NULL,
   run_duration       INTEGER NOT NULL,
   run_time           DATETIME NOT NULL,
   skipped_count      INTEGER NOT NULL,
   todo_count         INTEGER NOT NULL,
   todo_passed_count  INTEGER NOT NULL,
   total_count        INTEGER NOT NULL
);

CREATE TABLE results (
   file_id            TEXT NOT NULL,
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   passed_count       INTEGER NOT NULL,
   report_id          INTEGER NOT NULL,
   tests              TEXT NOT NULL,
   total_count        INTEGER NOT NULL,
   CONSTRAINT 'fk_results_reports' FOREIGN KEY ('report_id') REFERENCES 'reports' ('id') ON DELETE CASCADE
   CONSTRAINT 'fk_results_files' FOREIGN KEY ('file_id') REFERENCES 'files' ('id') ON DELETE CASCADE
);