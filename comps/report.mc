%% route ":report_id";

<h2>Report - <% $report->run_time->strftime("%a %m-%d %l%P") %>

<p>
  <% NO("file", scalar(@results)) %>, <% $results_with_fail %> with failures
</p>

<p>
<span id="open_all_results">
  <a href="#" onclick="sp.openAllResults(); return false">Open all files</a>
</span>
<span id="close_all_results" style="display: none">
  <a href="#" onclick="sp.closeAllResults(); return false">Close all files</a>
</span>
|
<a href="#" onclick="sp.toggleOkFiles(); return false">
  <span class="toggle_ok_files">Show passing files</span>
  <span class="toggle_ok_files" style="display: none">Show only files with failures</span>
</a>
|
<a href="#" onclick="sp.toggleOkRows(); return false">
  <span class="toggle_ok">Show passing tests</span>
  <span class="toggle_ok" style="display: none">Show only failing tests</span>
</a>
</p>

<div id="report">

  <ul class="result_list">
% foreach my $result (@results) {
%   my $id = $result->id;
%   if ($result->has_failures) {
    <li class="fail">
%   }
%   else {
    <li class="ok toggle_ok_files" style="display: none">
%   }
      <a href="#" onclick="sp.toggleResult(<% $id %>); return false">
        <img class="triangle_right" id="triangle_right<% $id %>" src="/static/i/triangle_right.gif">
        <img class="triangle_down" id="triangle_down<% $id %>" src="/static/i/triangle_down.gif" style="display: none">
        <% $result->file_name %> - <% $result->percent %>%
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
my @results = sort { $a->file_name <=> $b->file_name } $report->all_results;
my $results_with_fail = grep { $_->has_failures } @results;

$.title = "Report - " . $report->name;
</%init>
