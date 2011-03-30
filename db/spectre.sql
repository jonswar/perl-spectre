CREATE TABLE reports (
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   comments           TEXT NOT NULL DEFAULT "",
   create_time        INTEGER NOT NULL,
   layer              TEXT NOT NULL,
   name               TEXT NOT NULL,
   passed_count       INTEGER NOT NULL,
   run_duration       INTEGER NOT NULL,
   run_time           INTEGER NOT NULL,
   skipped_count      INTEGER NOT NULL,
   todo_count         INTEGER NOT NULL,
   todo_passed_count  INTEGER NOT NULL,
   total_count        INTEGER NOT NULL
);

CREATE TABLE results (
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   file_name          TEXT NOT NULL,
   passed_count       INTEGER NOT NULL,
   report_id          INTEGER NOT NULL,
   tests              TEXT NOT NULL,
   total_count        INTEGER NOT NULL,
   CONSTRAINT 'fk_results_reports' FOREIGN KEY ('report_id') REFERENCES 'reports' ('id') ON DELETE CASCADE
);