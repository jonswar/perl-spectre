#!/usr/bin/perl
use Spectre::Script qw($root);
use Spectre::Report;
use IPC::System::Simple qw(run);

unlink("$root/data/spectre.db");
run("sqlite3 $root/data/spectre.db < $root/db/spectre.sql");
my $dir = "$root/data/incoming";
foreach my $archive_file ( glob("$dir/*.tar.gz") ) {
    Spectre::Report->new_from_tap_archive($archive_file);
}
my $reports_count = Spectre::Reports->get_reports_count;
die "load failed -- reports_count = $reports_count" unless $reports_count == 6;
