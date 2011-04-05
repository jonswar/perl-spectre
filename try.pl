#!/usr/bin/perl
use Cwd qw(realpath);
use File::Basename;
use Test::WWW::Mechanize::PSGI;
use Plack::Util;
use warnings;
use strict;

my $url = shift(@ARGV) or die "usage: $0 url";
my $cwd = dirname(realpath($0));
my $app = Plack::Util::load_psgi("$cwd/app.psgi");
my $mech = Test::WWW::Mechanize::PSGI->new(
    app => $app,
    );
$mech->get('http://localhost:5000' . $url);
if ($mech->success) {
    print $mech->content;
}
else {
    printf("error getting '%s': %d\n%s", $url, $mech->status, $mech->content ? $mech->content . "\n" : '');
}

