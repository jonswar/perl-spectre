package Spectre::Result;
use Spectre;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->table('results');
__PACKAGE__->meta->auto_initialize;
__PACKAGE__->meta->make_manager_class( base_name => 'results', class => 'Spectre::Results' );

1;
