#!/usr/bin/perl
use Spectre::Script qw($root);
use Spectre::Model;
use IPC::System::Simple qw(run);

unlink("$root/data/spectre.db");
run("sqlite3 $root/data/spectre.db < $root/db/spectre.sql");
my $dir   = "$root/data/incoming";
my @files = glob("$dir/*.tar.gz");
foreach my $archive_file (@files) {
    Spectre::Report->new_from_tap_archive($archive_file);
}
my $reports_count = Spectre::Reports->get_reports_count;
die "load failed -- reports_count = $reports_count"
  unless $reports_count == @files;

my $file = Spectre::File->new( name => 'Poet::t::Utils::Builtin' )->load;
$file->add_comment( 'swartz', 'Muted temporarily.' );
$file->add_comment( 'swartz', 'Seems to be working now.' );
