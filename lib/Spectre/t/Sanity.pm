package Spectre::t::Sanity;
use Test::Class::Most parent => 'Spectre::Test::Class';

sub test_ok : Tests {
    ok( 1, '1 is ok' );
}

1;
