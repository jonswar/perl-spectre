package Spectre::TestFile;
use Spectre::Moose;

has 'mute_until'        => ();
has 'name'              => ();
has 'owner'             => ();
has 'test_file_results' => ();

1;

__PACKAGE__->meta->make_immutable();
