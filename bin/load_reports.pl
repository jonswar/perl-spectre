#!/usr/bin/perl
use Spectre::Script qw($db $env $root);
use IPC::System::Simple qw(run);
BEGIN { run("$root/bin/init_db.pl") }

use Spectre::Report;

my $dir = "$root/data/incoming";
foreach my $archive_file ( glob("$dir/*.tar.gz") ) {
    Spectre::Report->new_from_tap_archive($archive_file);
}
