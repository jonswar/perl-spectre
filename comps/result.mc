%% route ":result_id";

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
<a href="#" onclick="sp.toggleOkRows(); return false">
  <span class="toggle_ok">Show all tests</span>
  <span class="toggle_ok" style="display: none">Show only failures</span>
</a>
</p>

<div id="result">

  <ul class="test_list">
% foreach my $test (@tests) {
%   if ($test->{ok}) {
    <li class="test_ok toggle_ok" style="display:none">
%   }
%   else {
    <li class="test_fail">
%   }
      <% $test->{comment} %>
    </li>
% }
  </ul>

</div>

<%init>
my $result = Spectre::Result->new(id => $.result_id)->load(speculative=>1) or $m->not_found;
$.title = "Result - " . $result->desc;
my @tests = @{$result->tests};
my $file = Spectre::File->new(name => $result->file_name);
my $report = $result->report;
</%init>
