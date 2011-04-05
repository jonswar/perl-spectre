package Spectre::Util::Core;
use Carp qw(longmess);
use Data::Dumper;
use Data::UUID;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
  dc
  dcs
  dd
  dh
  dhs
  dp
  dps
  dump_one_line
  unique_id
);

# For efficiency, use Data::UUID to generate an initial unique id, then suffix it to
# generate a series of 0x10000 unique ids. Not to be used for hard-to-guess ids, obviously.
#
my $uuid;
my $suffix = 0;

sub unique_id {
    if ( !$suffix || !defined($uuid) ) {
        my $ug = Data::UUID->new();
        $uuid = $ug->create_hex();
    }
    my $hex = sprintf( '%s%04x', $uuid, $suffix );
    $suffix = ( $suffix + 1 ) & 0xffff;
    return $hex;
}

sub dump_one_line {
    my ($value) = @_;

    return Data::Dumper->new( [$value] )->Indent(0)->Sortkeys(1)->Quotekeys(0)->Terse(1)->Dump();
}

sub _dump_value_with_caller {
    my ($value) = @_;

    my $dump =
      Data::Dumper->new( [$value] )->Indent(1)->Sortkeys(1)->Quotekeys(0)->Terse(1)->Dump();
    my @caller = caller(1);
    return sprintf( "[dp at %s line %d.] %s\n", $caller[1], $caller[2], $dump );
}

sub dd {
    die _dump_value_with_caller(@_);
}

sub dh {
    print _dump_value_with_caller(@_);
}

sub dhs {
    print longmess( _dump_value_with_caller(@_) );
}

sub dp {
    print STDERR _dump_value_with_caller(@_);
}

sub dps {
    print STDERR longmess( _dump_value_with_caller(@_) );
}

sub dc {
    my $fh = _open_console_log();
    $fh->print( _dump_value_with_caller(@_) );
}

sub dcs {
    my $fh = _open_console_log();
    $fh->print( longmess( _dump_value_with_caller(@_) ) );
}

my $console_log;

sub _open_console_log {
    $console_log ||= Spectre::Environment->get_environment->logs_dir . "/console.log";
    open( my $fh, ">>$console_log" );
    return $fh;
}

1;
