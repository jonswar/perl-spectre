#!/usr/bin/perl
use Spectre::Script qw($env $root);
use Spectre::Schema;

rmtree("$root/tap");
my $file = shift(@ARGV) or die "usage: $0 file";
my $report = Spectre::Report->new_from_tap_archive($file);
print $report->dump;
