#!/usr/bin/perl
use Spectre::Script qw($env $root);
use Spectre::Schema;

rmtree("$root/tap");
Spectre::DB->clear_db;
my $dir = "$root/incoming";
foreach my $archive_file ( glob("$dir/*.tar.gz") ) {
    my ( $dir, $scope ) = Spectre::DB->new_scope;
    my $report = Spectre::Report->new_from_tap_archive($archive_file);
    $report->store;
}
