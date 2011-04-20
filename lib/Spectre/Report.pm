package Spectre::Report;
use Spectre;
use Spectre::Result;
use Clone::Fast qw( clone );
use TAP::Harness::Archive;
use base qw(Spectre::DB::Object);

__PACKAGE__->meta->setup(
    table   => 'reports',
    columns => [
        id          => { type => 'serial' },
        create_time => { type => 'datetime', not_null => 1, default => DateTime->now },
        layer             => { type => 'text',     not_null => 1 },
        name              => { type => 'text',     not_null => 1 },
        passed_count      => { type => 'integer',  not_null => 1 },
        run_duration      => { type => 'integer',  not_null => 1 },
        run_time          => { type => 'datetime', not_null => 1 },
        skipped_count     => { type => 'integer',  not_null => 1 },
        todo_count        => { type => 'integer',  not_null => 1 },
        todo_passed_count => { type => 'integer',  not_null => 1 },
        total_count       => { type => 'integer',  not_null => 1 },
    ],
    primary_key_columns => ['id'],
);
__PACKAGE__->meta->make_manager_class( base_name => 'reports', class => 'Spectre::Reports' );

method link () { "/report/" . $self->id }

method all_results () {
    return values( %{ $self->_results_by_file_id } );
}

method result_for_file ($file_id) {
    return $self->_results_by_file_id->{$file_id};
}

method percent ()      { int( $self->passed_count / $self->total_count * 100 ) }
method has_failures () { $self->passed_count < $self->total_count }

method _results_by_file_id () {
    $self->{_results_by_file_id} ||=
      { map { ( $_->file_id, $_ ) }
          @{ Spectre::Results->get_results( query => [ report_id => $self->id ] ) } };
    $self->{_results_by_file_id};
}

# Adapted from Smolder::DB::SmokeReport::update_from_tap_archive
#
method new_from_tap_archive ($class: $archive_file) {

    my $report_name = basename($archive_file);

    # Our data structures for holding the info about the TAP parsing
    #
    my ( @tests, $file_name, $meta, $failed, $skipped, $tap_stream, @result_hashes );

    # keep track of some things on our own because TAP::Parser::Aggregator
    # doesn't handle total or failed right when a test exits early
    my %suite_data;
    my $aggregator = TAP::Harness::Archive->aggregator_from_archive(
        {
            archive              => $archive_file,
            made_parser_callback => sub {
                my ( $parser, $file, $full_path ) = @_;
                $file_name = basename($file);

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

                    my $file_id = Spectre::File->load_or_create($file_name)->id;

                    push(
                        @result_hashes,
                        {
                            file_id      => $file_id,
                            passed_count => $passed,
                            tests        => [@tests],
                            total_count  => $total,
                        }
                    );

                    $suite_data{total}  += $total;
                    $suite_data{failed} += $failed;
                  }
            },
        }
    );

    # Create report
    #
    my $report = $class->new(
        layer         => 'staging',
        name          => $report_name,
        passed_count  => scalar( $aggregator->passed ),
        run_duration  => $meta->{stop_time} - $meta->{start_time},
        run_time      => DateTime->from_epoch( epoch => $meta->{start_time}, time_zone => 'local' ),
        skipped_count => scalar( $aggregator->skipped ),
        todo_count    => scalar( $aggregator->todo ),
        todo_passed_count => scalar( $aggregator->todo_passed ),
        total_count       => $suite_data{total},
    );
    $report->save;

    # Create results
    #
    foreach my $result_hash (@result_hashes) {
        my $result = Spectre::Result->new( %$result_hash, report_id => $report->id, );
        $result->save;
    }

    return $report;
}

1;
