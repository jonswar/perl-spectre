create table reports (
id int primary key autoincrement,
comments text,
failed int,
layer text,
name text,
passed int,
percent int,
process_time int,
run_duration int,
run_time int,
skipped int,
tap_dir text,
todo int
todo_passed int
total
);