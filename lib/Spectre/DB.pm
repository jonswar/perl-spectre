package Spectre::DB;
use Spectre qw($root);
use strict;
use warnings;
use base qw(Rose::DB);

my $database = "$root/data/spectre.db";

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db(
    driver   => 'sqlite',
    database => $database,
);

1;
