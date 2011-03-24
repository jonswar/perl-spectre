#
# Add the appropriate lib path to @INC and initialize environment.
#
package Spectre::Script;
use Cwd qw(realpath);
use File::Basename;
use File::Spec::Functions qw(rel2abs);
use strict;
use warnings;

my $root_marker_file = ".spectre_root";

sub import {
    my $pkg = shift;

    my $root_dir = determine_root_dir();
    my $lib_dir  = "$root_dir/lib";
    unshift( @INC, $lib_dir );

    require Spectre;
    Spectre->initialize_environment( root_dir => $root_dir );
    Spectre->export_to_level( 1, undef, @_ );
}

sub determine_root_dir {
    my $path1    = dirname( rel2abs($0) );
    my $path2    = dirname( realpath($0) );
    my $root_dir = search_upward($path1) || search_upward($path2);
    unless ( defined $root_dir ) {
        die sprintf( "could not find $root_marker_file upwards from %s",
            ( $path1 eq $path2 ) ? "'$path1'" : "'$path1' or '$path2'" );
    }
    return $root_dir;
}

sub search_upward {
    my ($path) = @_;

    my $count = 0;
    while ( realpath($path) ne '/' && $count++ < 10 ) {
        if ( -f "$path/$root_marker_file" ) {
            return realpath($path);
            last;
        }
        $path = dirname($path);
    }
    return undef;
}

1;
