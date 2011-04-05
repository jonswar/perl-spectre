package Spectre::File;
use URI::Escape;
use Spectre::Moose;

has 'name' => ( required => 1 );

method link  () { "/file/" . uri_escape( $self->name ) }

1;
