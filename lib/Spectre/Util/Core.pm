package Spectre::Util::Core;
use Data::UUID;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
  unique_id
);

{

    # For efficiency, use Data::UUID to generate an initial unique id, then suffix it to
    # generate a series of 0x10000 unique ids. Not to be used for hard-to-guess ids, obviously.

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
}

1;
