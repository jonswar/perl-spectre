package Spectre::DB;
use Spectre qw($root);
use IPC::System::Simple qw(run);
use base qw(Rose::DB);

my $database;
if ($Spectre::IN_TESTS) {
    my $tempdir = tempdir( 'spectre-test-db-XXXX', TMPDIR => 1, CLEANUP => 1 );
    $database = "$tempdir/spectre.db";
    __PACKAGE__->load_schema();
}
else {
    $database = "$root/data/spectre.db";
}

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db(
    driver   => 'sqlite',
    database => $database,
);

sub load_schema {
    run("sqlite3 $database < $root/db/spectre.sql");
}

1;
