package Spectre::TestFileResult;
use Spectre::Moose;

# Passed attributes
has 'failed'    => ();
has 'passed'    => ();
has 'percent'   => ();
has 'report'    => ( is => 'rw', weak_ref => 1 );
has 'test_file' => ( weak_ref => 1 );
has 'tests'     => ();
has 'total'     => ();

1;

__PACKAGE__->meta->make_immutable();
