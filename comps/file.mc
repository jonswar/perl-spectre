%% route ":file_id";

<%method javascript>
$j(function() {
  $j("input:checkbox").attr("checked", "");
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
  <% NO("result", scalar(@results)) %>, <% $results_with_fail %> with failures
</p>

<p>
<span id="open_all_results">
  <a href="#" onclick="sp.openAllResults(); return false">Open all results</a>
</span>
<span id="close_all_results" style="display: none">
  <a href="#" onclick="sp.closeAllResults(); return false">Close all results</a>
</span>
|
<input id="show_passing_tests" type=checkbox>Show passing tests
</p>

<div id="file">

  <ul class="result_list">
% foreach my $result (@results) {
%   my $id = $result->id;
    <li class="<% $result->has_failures ? "fail" : "ok" %>">
      <a href="#" onclick="sp.toggleResult(<% $id %>); return false">
        <img class="triangle_right" id="triangle_right<% $id %>" src="/static/i/triangle_right.gif">
        <img class="triangle_down" id="triangle_down<% $id %>" src="/static/i/triangle_down.gif" style="display: none">
        <% $result->report->run_time->strftime("%a %m-%d %l%P") %> - <% $result->percent %>%
      </a>
      <div class="single_result" id="result<% $id %>" style="display: none">
        <& single_result.mi, result => $result &>
      </div>
    </li>
% }
  </ul>

</div>

<%init>
my $file = Spectre::File->new(id => $.file_id)->load(speculative => 1) or $m->not_found;
my @results = @{ $file->all_results };
my $results_with_fail = grep { $_->has_failures } @results;
$.title = "Test file - " . $file->name;
</%init>
