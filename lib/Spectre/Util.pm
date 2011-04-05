package Spectre::Util;
use Class::MOP;
use DateTime;
use strict;
use warnings;

my %package_methods = (
    'Cwd'                   => [qw(realpath cwd)],
    'Date::Format'          => [qw(time2str)],
    'Date::Parse'           => [qw(str2time)],
    'File::Basename'        => [qw(basename dirname)],
    'File::Copy'            => [qw(copy)],
    'File::Copy::Recursive' => [qw(dircopy)],
    'File::Find'            => [qw(find)],
    'File::Find::Wanted'    => [qw(find_wanted)],
    'File::Path'            => [qw(mkpath rmtree)],
    'File::Slurp'           => [qw(read_file write_file read_dir)],
    'File::Spec::Functions' => [qw(catdir catfile splitpath splitdir file_name_is_absolute tmpdir)],
    'File::Temp'            => [qw(tempfile tempdir)],
    'Lingua::EN::Inflect'   => [qw(NO)],
    'List::MoreUtils' =>
      [qw(all any none apply first_index first_value indexes last_index last_value uniq)],
    'List::Util'          => [qw(first min max reduce shuffle)],
    'Module::Loaded'      => [qw(is_loaded)],
    'Scalar::Util'        => [qw(blessed weaken)],
    'Spectre::Util::Core' => [qw(dd dh dhs dp dps dc dcs dump_one_line unique_id)],
    'Text::Elide'         => [qw(elide)],
    'Text::Trim'          => [qw(trim rtrim ltrim)],
);

foreach my $package ( sort keys(%package_methods) ) {
    Class::MOP::load_class($package);
}

sub import {
    my $class = shift;
    $class->export_to_level(1);
}

sub export_to_level {
    my ( $class, $level, $ignore ) = @_;

    while ( my ( $package, $methods ) = each(%package_methods) ) {
        $package->export_to_level( $level + 1, $package, @$methods );
    }
}

1;
