package Spectre::Result;
use Spectre;
use JSON;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'results',
    columns => [
        id           => { type => 'serial' },
        file_id      => { type => 'integer', not_null => 1 },
        passed_count => { type => 'integer', not_null => 1 },
        report_id    => { type => 'integer', not_null => 1 },
        tests => {
            type     => 'text',
            not_null => 1,
            inflate  => sub { JSON::decode_json( $_[1] ) },
            deflate  => sub { JSON::encode_json( $_[1] ) }
        },
        total_count => { type => 'integer', not_null => 1 },
    ],
    primary_key_columns => ['id'],
    foreign_keys        => [
        report => { class => 'Spectre::Report', key_columns => { report_id => 'id' } },
        file   => { class => 'Spectre::File',   key_columns => { file_id   => 'id' } }
    ],
);
__PACKAGE__->meta->make_manager_class( base_name => 'results', class => 'Spectre::Results' );

method percent () {
    $self->total_count ? int( $self->passed_count / $self->total_count * 100 ) : 0;
}
method has_failures () { $self->passed_count < $self->total_count }
method link ()         { "/result/" . $self->id }

method desc () {
    sprintf( "%s - %s", $self->file->name, $self->report->run_time->strftime("%m-%d %l%P") );
}

1;
