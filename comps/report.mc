%% route ":report_id";

<%init>
my $report = Spectre::Report->load($.report_id) or $m->not_found;
$.title = "Report - " . $report->name;

# Get results for this report in reverse date order
#
my @results = sort { $b->run_time <=> $a->run_time } $report->all_results;
</%init>
