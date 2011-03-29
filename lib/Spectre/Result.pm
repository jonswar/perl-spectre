package Spectre::TestFileResult;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->table('test_file_results');
__PACKAGE__->meta->auto_initialize;
__PACKAGE__->meta->make_manager_class('test_file_results');

1;
