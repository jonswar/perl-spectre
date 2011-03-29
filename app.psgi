#!/usr/bin/perl
use Spectre::Script qw($env);
use Mason;
use Plack::Builder;
use warnings;
use strict;

my $root = $env->root_dir;

my @plugins = ('PSGIHandler', 'HTMLFilters');
my $interp = Mason->new(
    comp_root => "$root/comps",
    data_dir  => "$root/data",
    plugins   => \@plugins,
);

my $app = sub {
    my $env = shift;
    $interp->handle_psgi($env);
};
builder {
    enable 'Session';
    $app;
};
