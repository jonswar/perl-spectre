package Spectre::File;
use Spectre;
use Spectre::Result;
use JSON;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'files',
    columns => [
        id       => { type => 'serial' },
        comments => { type => 'text', not_null => 1, default => '""' },
        name       => { type => 'text', not_null => 1 },
        mute_until => { type => 'datetime' },
    ],
    unique_key          => 'name',
    primary_key_columns => ['id']
);
__PACKAGE__->meta->make_manager_class( base_name => 'file', class => 'Spectre::Files' );

method link () { "/file/" . $self->id }

method all_results () {
    Spectre::Results->get_results( query => [ file_id => $self->id ] );
}

method load_or_create ($class: $name) {
    my $file = $class->new( name => $name )->load( speculative => 1 );
    if ( !$file ) {
        $file = $class->new( name => $name );
        $file->save;
    }
    return $file;
}

1;
