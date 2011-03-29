package Spectre::Report;
use Clone::Fast qw( clone );
use TAP::Harness::Archive;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->table('reports');
__PACKAGE__->meta->auto_initialize;
__PACKAGE__->meta->make_manager_class('reports');

# Adapted from Smolder::DB::SmokeReport::update_from_tap_archive
#
method new_from_tap_archive ($class:) {
    my ( $class, $archive_file ) = @_;

    # Extract unique name, layer, and tap dir from base filename, e.g.
    #   report_name = development-03-14-14_59_45-bufl
    #   report_layer = development
    #
    my ($report_name) = ( basename($archive_file) =~ /^results-(.*).tar.gz/ )
      or die "cannot determine name from $archive_file";
    my ($report_layer) = ( $report_name =~ /^([^-]+)-/ )
      or die "cannot determine layer from $report_name";

    # Our data structures for holding the info about the TAP parsing
    #
    my ( @tests, $name, @test_file_results, $meta, $file_index, $failed, $skipped, $tap_stream );

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

                # save the raw TAP stream
                $tap_stream = read_file($full_path);
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

    # Create report
    #
    my $report = $class->new(
        create_time       => time,
        failed_count      => $suite_data{failed},
        layer             => $report_layer,
        name              => $report_name,
        passed_count      => scalar( $aggregator->passed ),
        run_duration      => $meta->{stop_time} - $meta->{start_time},
        run_time          => DateTime->from_epoch( epoch => $meta->{start_time} ),
        skipped_count     => scalar( $aggregator->skipped ),
        test_file_results => \@test_file_results,
        todo_count        => scalar( $aggregator->todo ),
        todo_passed_count => scalar( $aggregator->todo_passed ),
        total_count       => $suite_data{total},
    );
    $report->save;

    return $report;
}

# Stringify dates when dumping
#
method dump () {
    my $clone = clone($self);
    foreach my $field qw(process_time run_time) {
        $clone->{$field} = $clone->$field . "";
    }
    return $clone->SUPER::dump;
}

1;

__PACKAGE__->meta->make_immutable();
