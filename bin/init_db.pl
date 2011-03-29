#!/usr/bin/perl
use Spectre::Script qw($root);
use IPC::System::Simple qw(run);

unlink("$root/data/blog.db");
run("sqlite3 $root/data/blog.db < $root/db/spectre.sql");
