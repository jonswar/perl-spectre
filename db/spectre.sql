CREATE TABLE reports (
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   comments           TEXT NOT NULL,
   create_time        INTEGER NOT NULL,
   failed_count       INTEGER NOT NULL,
   layer              TEXT NOT NULL,
   name               TEXT NOT NULL,
   passed_count       INTEGER NOT NULL,
   run_duration       INTEGER NOT NULL,
   run_time           INTEGER NOT NULL,
   skipped_count      INTEGER NOT NULL,
   stats              TEXT NOT NULL,
   todo_count         INTEGER NOT NULL,
   todo_passed_count  INTEGER NOT NULL,
   total_count        INTEGER NOT NULL
);

CREATE TABLE test_files (
   id     INTEGER PRIMARY KEY AUTOINCREMENT,
   name   TEXT NOT NULL
);

CREATE TABLE test_file_results (
   id                 INTEGER PRIMARY KEY AUTOINCREMENT,
   failed_count       INTEGER NOT NULL,
   passed_count       INTEGER NOT NULL,
   skipped_count      INTEGER NOT NULL,
   todo_count         INTEGER NOT NULL,
   todo_passed_count  INTEGER NOT NULL,
   total_count        INTEGER NOT NULL,
   test_file_id       INTEGER NOT NULL,
   report_id          INTEGER NOT NULL,
   CONSTRAINT 'fk_test_file_results_test_file' FOREIGN KEY ('test_file_id') REFERENCES 'test_files' ('id') ON DELETE CASCADE,
   CONSTRAINT 'fk_test_file_results_reports' FOREIGN KEY ('report_id') REFERENCES 'reports' ('id') ON DELETE CASCADE
);