#!/usr/bin/perl
use Spectre::Script qw($root);
use IPC::System::Simple qw(run);

unlink("$root/data/spectre.db");
run("sqlite3 $root/data/spectre.db < $root/db/spectre.sql");
