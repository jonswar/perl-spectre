package Spectre;
use Carp;
use Method::Signatures::Simple;
use Spectre::Util;
use strict;
use warnings;

# export_to_level() is used by bootstrap modules like Spectre::Script.
#
sub import {
    my $pkg = shift;
    $pkg->export_to_level( 1, undef, @_ );
}

sub export_to_level {
    my ( $pkg, $level, $ignore, @params ) = @_;
    my ($caller) = caller($level);

    Method::Signatures::Simple->import( into => $caller );
    strict->import;
    warnings->import;
    {
        no strict 'refs';
        *{ $caller . '::CLASS' } = sub () { $caller };    # like CLASS.pm
    }

    # Import Spectre::Util functions into caller.
    #
    Spectre::Util->export_to_level( $level + 1 );

    # Import requested globals into caller.
    #
    my @vars = grep { /^\$/ } @params;
    my @valid_import_params = qw($cache $conf $env $log $root);
    if (@vars) {
        foreach my $var (@vars) {
            my $value;
            if ( $var eq '$db' ) {
                require Spectre::DB;
                $value = Spectre::DB->new();
            }
            elsif ( $var eq '$cache' ) {
                require Spectre::Cache;
                $value = Spectre::Cache->new( namespace => $caller );
            }
            elsif ( $var eq '$conf' ) {
                $value = Spectre::Environment->get_environment()->conf();
            }
            elsif ( $var eq '$env' ) {
                $value = Spectre::Environment->get_environment();
            }
            elsif ( $var eq '$log' ) {
                $value = Log::Any->get_logger( category => $caller );
            }
            elsif ( $var eq '$root' ) {
                $value = Spectre::Environment->get_environment()->root_dir();
            }
            else {
                die sprintf(
                    "unknown import parameter '$var' passed to Spectre: valid import parameters are %s",
                    join( ", ", map { "'$_'" } @valid_import_params ) );
            }
            my $no_sigil_var = substr( $var, 1 );
            no strict 'refs';
            *{"$caller\::$no_sigil_var"} = \$value;
        }
    }
}

sub initialize_environment {
    my $class = shift;
    Spectre::Environment->initialize_current_environment(@_);
}

sub initialize_environment_if_needed {
    my $class = shift;
    if ( !Spectre::Environment->get_environment() ) {
        Spectre::Environment->initialize_current_environment(@_);
    }
}

use Spectre::Conf;
use Spectre::Environment;

1;

__END__
