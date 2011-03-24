package Spectre::Report;
use Clone::Fast qw( clone );
use Spectre qw($env);
use TAP::Harness::Archive;
use strict;
use warnings;
use base qw(Spectre::DB::Object);

has 'comments'          => ( default => sub { [] } );
has 'failed'            => ();
has 'layer'             => ();
has 'name'              => ();
has 'passed'            => ();
has 'percent'           => ();
has 'process_time'      => ( default => sub { DateTime->now } );
has 'run_duration'      => ();
has 'run_time'          => ();
has 'skipped'           => ();
has 'tap_dir'           => ();
has 'test_file_results' => ( default => sub { [] } );
has 'todo'              => ();
has 'todo_passed'       => ();
has 'total'             => ();

# Adapted from Smolder::DB::SmokeReport::update_from_tap_archive
#
sub new_from_tap_archive {
    my ( $class, $archive_file ) = @_;

    # Extract unique name, layer, and tap dir from base filename, e.g.
    #   report_name = development-03-14-14_59_45-bufl
    #   report_layer = development-03-14-14_59_45-bufl
    #   report_tap_dir = /.../tap/development-03-14-14_59_45-bufl
    #
    my ($report_name) = ( basename($archive_file) =~ /^results-(.*).tar.gz/ )
      or die "cannot determine name from $archive_file";
    my ($report_layer) = ( $report_name =~ /^([^-]+)-/ )
      or die "cannot determine layer from $report_name";
    my $report_tap_dir = $env->root_dir . "/tap/$report_name";
    die "Directory $report_tap_dir already exists" if ( -d $report_tap_dir );
    mkpath( $report_tap_dir, 0, 0775 );
    die "Could not create directory $report_tap_dir: $!" unless ( -d $report_tap_dir );

    # Our data structures for holding the info about the TAP parsing
    #
    my ( @tests, $name, @test_file_results, $meta, $file_index, $failed, $skipped );
    my $next_file_index = 0;

    # keep track of some things on our own because TAP::Parser::Aggregator
    # doesn't handle total or failed right when a test exits early
    my %suite_data;
    my $aggregator = TAP::Harness::Archive->aggregator_from_archive(
        {
            archive              => $archive_file,
            made_parser_callback => sub {
                my ( $parser, $file, $full_path ) = @_;
                $name = basename($file);

                # clear them out for a new run
                @tests = ();
                ( $failed, $skipped ) = ( 0, 0, 0 );

                # save the raw TAP stream somewhere we can use it later
                $file_index = $next_file_index++;
                my $new_file = catfile( $report_tap_dir, "$file_index.tap" );
                copy( $full_path, $new_file ) or die "Could not copy $full_path to $new_file. $!\n";
            },
            meta_yaml_callback => sub {
                my $yaml = shift;
                $meta = $yaml->[0];
            },
            parser_callbacks => {
                ALL => sub {
                    my $line = shift;
                    if ( $line->type eq 'test' ) {
                        my %details = (
                            ok      => ( $line->is_ok     || 0 ),
                            skip    => ( $line->has_skip  || 0 ),
                            todo    => ( $line->has_todo  || 0 ),
                            comment => ( $line->as_string || 0 ),
                        );
                        $failed++ if !$line->is_ok && !$line->has_skip && !$line->has_todo;
                        $skipped++ if $line->has_skip;
                        push( @tests, \%details );
                    }
                    elsif ( $line->type eq 'comment' || $line->type eq 'unknown' ) {
                        my $slot = $line->type eq 'comment' ? 'comment' : 'unknown';

                        # TAP doesn't have an explicit way to associate a comment
                        # with a test (yet) so we'll assume it goes with the last
                        # test. Look backwards through the stack for the last test
                        my $last_test = $tests[-1];
                        if ($last_test) {
                            $last_test->{$slot} ||= '';
                            $last_test->{$slot} .= ( "\n" . $line->as_string );
                        }
                    }
                },
                EOF => sub {
                    my $parser = shift;

                    # did we run everything we planned to?
                    my $planned = $parser->tests_planned;
                    my $run     = $parser->tests_run;
                    my $total;
                    if ( $planned && $planned > $run ) {
                        $total = $planned;
                        foreach ( 1 .. $planned - $run ) {
                            $failed++;
                            push(
                                @tests,
                                {
                                    ok      => 0,
                                    skip    => 0,
                                    todo    => 0,
                                    comment => "test died after test # $run",
                                    died    => 1,
                                }
                            );
                        }
                    }
                    else {
                        $total = $run;
                    }
                    my $passed = $total - $failed;

                    my $percent =
                      $total ? sprintf( '%i', ( ( $total - $failed ) / $total ) * 100 ) : 100;

                    # record the individual test file and test file result
                    my $test_file = Spectre::TestFile->new( name => $name );
                    my $test_file_result = Spectre::TestFileResult->new(
                        test_file => $test_file,
                        total     => $total,
                        passed    => $passed,
                        failed    => $failed,
                        percent   => $percent,
                        tests     => [@tests],
                    );
                    push( @test_file_results, $test_file_result );

                    $suite_data{total}  += $total;
                    $suite_data{failed} += $failed;
                  }
            },
        }
    );

    # Create report and assign a weak reference to each test file result
    #
    my $report = Spectre::Report->new(
        name              => $report_name,
        layer             => $report_layer,
        passed            => scalar( $aggregator->passed ),
        failed            => $suite_data{failed},
        total             => $suite_data{total},
        skipped           => scalar( $aggregator->skipped ),
        todo              => scalar( $aggregator->todo ),
        todo_passed       => scalar( $aggregator->todo_passed ),
        test_file_results => \@test_file_results,
        run_time          => DateTime->from_epoch( epoch => $meta->{start_time} ),
        run_duration      => $meta->{stop_time} - $meta->{start_time},

    );
    foreach my $test_file_result (@test_file_results) {
        $test_file_result->report($report);
    }

    return $report;
}

# Stringify dates when dumping
#
method dump () {
    local $self->{db} = undef;
    my $clone = clone($self);
    foreach my $field qw(process_time run_time) {
        $clone->{$field} = $clone->$field . "";
    }
    return $clone->SUPER::dump;
}

1;

__PACKAGE__->meta->make_immutable();
