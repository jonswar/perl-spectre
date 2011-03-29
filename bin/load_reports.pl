#!/usr/bin/perl
use Spectre::Script qw($env $root);
use Spectre::Schema;

Spectre::DB->clear_db;
my $dir = "$root/data/incoming";
foreach my $archive_file ( glob("$dir/*.tar.gz") ) {
    my ( $dir, $scope ) = Spectre::DB->new_scope;
    my $report = Spectre::Report->new_from_tap_archive($archive_file);
    $report->store;
}
