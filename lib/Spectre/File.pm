package Spectre::File;
use Spectre qw($conf);
use Spectre::Comment;
use Spectre::Result;
use JSON;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'files',
    columns => [
        id         => { type => 'serial' },
        name       => { type => 'text', not_null => 1 },
        mute_until => { type => 'datetime' },
    ],
    unique_key          => 'name',
    primary_key_columns => ['id']
);
__PACKAGE__->meta->make_manager_class( base_name => 'file', class => 'Spectre::Files' );

method true_filename () {
    ( my $filename = $self->name ) =~ s/::/\//g;
    return join( "/", $conf->get('test_file_root'), $filename );
}

method link () { "/file/" . $self->id }

method all_results () {
    Spectre::Results->get_results( query => [ file_id => $self->id ] );
}

method all_comments () {
    Spectre::Comments->get_comments(
        query   => [ file_id => $self->id ],
        sort_by => 'create_time desc'
    );
}

method is_muted () {
    return
      defined( $self->mute_until ) && $self->mute_until > DateTime->now( time_zone => 'local' );
}

method load_or_create ($class: $name) {
    my $file = $class->new( name => $name )->load( speculative => 1 );
    if ( !$file ) {
        $file = $class->new( name => $name );
        $file->save;
    }
    return $file;
}

method add_comment ($user, $content) {
    my $comment =
      Spectre::Comment->new( author => $user, content => $content, file_id => $self->id );
    $comment->save;
}

1;
