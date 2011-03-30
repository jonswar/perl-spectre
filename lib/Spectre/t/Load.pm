package Spectre::t::Load;
BEGIN { $Spectre::IN_TESTS = 1 }
use Spectre qw($root);
use Test::More;
use Spectre::DB;
use Spectre::Report;
use base qw(Spectre::Test::Class);

my $load_dir = dirname(__FILE__) . "/load";

sub test_load : Tests {
    is( Spectre::Report::Manager->get_reports_count, 0, "no reports" );
    foreach my $archive_file ( glob("$load_dir/*.tar.gz") ) {
        Spectre::Report->new_from_tap_archive($archive_file);
    }
    is( Spectre::Report::Manager->get_reports_count, 6, "6 reports" );

    my $reports =
      Spectre::Report::Manager->get_reports(
        query => [ name => 'development-03-14-14_59_45-bufl' ] );
    ok( @$reports == 1, '1 matching report' );
    my $report = $reports->[0];
    isa_ok( $report, 'Spectre::Report' );
    is( $report->passed_count, 15, 'passed count' );
    is( $report->total_count,  17, 'total_count' );
}

1;
