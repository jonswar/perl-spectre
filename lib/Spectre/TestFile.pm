package Spectre::TestFile;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->table('test_files');
__PACKAGE__->meta->auto_initialize;
__PACKAGE__->meta->make_manager_class('test_files');

1;
