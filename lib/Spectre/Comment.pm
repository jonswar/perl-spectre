package Spectre::Comment;
use Spectre;
use JSON;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'comments',
    columns => [
        id          => { type => 'serial' },
        author      => { type => 'text', not_null => 1 },
        content     => { type => 'text', not_null => 1 },
        file_id     => { type => 'integer', not_null => 1 },
        create_time => { type => 'datetime', not_null => 1, default => DateTime->now },
    ],
    primary_key_columns => ['id'],
    foreign_keys => [ file => { class => 'Spectre::File', key_columns => { file_id => 'id' } } ],
);
__PACKAGE__->meta->make_manager_class( base_name => 'comments', class => 'Spectre::Comments' );

1;
