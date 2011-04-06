package Spectre::File;
use URI::Escape;
use Spectre::Moose;

has 'name' => ( required => 1 );

method link () { "/file/" . uri_escape( $self->name ) }

method all_results () {
    Spectre::Results->get_results( query => [ file_name => $self->name ] );
}

1;
