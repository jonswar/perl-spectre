%% route ":report_id";

<%method javascript>
$j(function() {
  $j("input:checkbox:checked").attr("checked", "");
  $j('#show_passing_files').click(function() {
     if ($j(this).is(":checked")) {
        $j('.ok_files').show();
     } else {
        $j('.ok_files').hide();
     }
  });
  $j('#show_passing_tests').click(function() {
     if ($j(this).is(":checked")) {
        $j('.ok_tests').show();
     } else {
        $j('.ok_tests').hide();
     }
  });
});
</%method>

<p>
  <% NO("file", scalar(@results)) %>, <% $results_with_fail %> with failures
</p>

<p>
<span id="open_all_results">
  <a href="#" onclick="sp.openAllResults(); return false">Open all</a>
</span>
<span id="close_all_results" style="display: none">
  <a href="#" onclick="sp.closeAllResults(); return false">Close all</a>
</span>
|
<input id="show_passing_files" type=checkbox>Show passing files
|
<input id="show_passing_tests" type=checkbox>Show passing tests

</p>

<div id="report">

  <ul class="file_list">
% foreach my $result (@results) {
%   my $id = $result->id;
%   if ($result->has_failures) {
    <li class="fail">
%   }
%   else {
    <li class="ok ok_files" style="display: none">
%   }
      <a href="#" onclick="sp.toggleResult(<% $id %>); return false">
        <img class="triangle_right" id="triangle_right<% $id %>" src="/static/i/triangle_right.gif">
        <img class="triangle_down" id="triangle_down<% $id %>" src="/static/i/triangle_down.gif" style="display: none">
        <% $result->file->name %> - <% $result->percent %>%
      </a>
      <div class="single_result" id="result<% $id %>" style="display: none">
        <& single_result.mi, result => $result &>
      </div>
    </li>
% }
  </ul>

</div>

<%init>
my $report = Spectre::Report->new(id => $.report_id)->load(speculative => 1) or $m->not_found;

# Get results for this report in file name order
#
my @results = sort { $a->file->name <=> $b->file->name } $report->all_results;
my $results_with_fail = grep { $_->has_failures } @results;

$.title = "Report - " . $report->run_time->strftime("%a %m-%d %l%P");
</%init>
