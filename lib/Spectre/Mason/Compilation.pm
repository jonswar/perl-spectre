package Spectre::Mason::Compilation;
use Moose::Role;
use strict;
use warnings;

# Use Spectre at the top of every component class
#
override 'output_class_header' => sub {
    return join( "\n", super(), 'use Spectre qw($conf $env);' );
};
