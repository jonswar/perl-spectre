#!/usr/bin/perl
use Spectre::Script qw($env);
use DateTime;
use JSON;
use Mason;
use Plack::App::File;
use Plack::Builder;
use Spectre::File;
use Spectre::Report;
use Spectre::Result;
use warnings;
use strict;

my $root = $env->root_dir;

my @plugins = ( 'HTMLFilters', 'LvalueAttributes', 'PSGIHandler', 'RouterSimple', '+Spectre::Mason' );
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
    mount "/static" => Plack::App::File->new(root => "$root/static");
    mount "/" => builder {
        enable 'Session';
        $app;
    };
};
