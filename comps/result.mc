%% route ":result_id";

<%method javascript>
$(function() {
  $("input:checkbox:checked").attr("checked", "");
  $('#show_passing_tests').click(function() {
     if ($(this).is(":checked")) {
        $('.ok_tests').show();
     } else {
        $('.ok_tests').hide();
     }
  });
});
</%method>

<h2>
<a href="<% $file->link %>"><% $file->name %></a>
-
<a href="<% $report->link %>"><% $report->run_time->strftime("%m-%d %l%P") %></a>
</h2>

<p>
  <% NO("test", $result->total_count) %>, <% $result->passed_count %> passed
  (<% $result->percent %>%)
</p>

<p>
<input id="show_passing_tests" type=checkbox>Show passing tests
</p>

<div id="single_result">
  <& single_result.mi, result => $result &>
</div>

<%init>
my $result = Spectre::Result->new(id => $.result_id)->load(speculative=>1) or $m->not_found;
$.title = "Result - " . $result->desc;
my @tests = @{$result->tests};
my $file = $result->file;
my $report = $result->report;
</%init>
