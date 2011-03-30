package Spectre::DB::Object;
use Spectre qw($root);
use Spectre::DB;
use strict;
use warnings;
use base qw(Rose::DB::Object);

sub init_db { Spectre::DB->new }

1;
