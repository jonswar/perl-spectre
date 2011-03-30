package Spectre::Test::Class;
use Spectre;
use base qw(Test::Class);

method runtests ($class:) {

    # Only run tests directly in $class.
    #
    my $test_obj = $class->new();
    Test::Class::runtests($test_obj);
}

1;
