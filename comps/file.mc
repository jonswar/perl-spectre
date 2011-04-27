%% route ":file_id";

<%method javascript>
$(function() {
  $("input:checkbox").attr("checked", "");
  $('#show_passing_tests').click(function() {
     if ($(this).is(":checked")) {
        $('.ok_tests').show();
     } else {
        $('.ok_tests').hide();
     }
  });
});
</%method>

<div id="file">

<p>
  <% NO("result", scalar(@results)) %>, <% $results_with_fail %> with failures
</p>

<form action="/file/action/set_mute" method=POST>
<p>
% if ($file->is_muted) {
<span class="mute">Muted until <% $file->mute_until->strftime("%a %m-%d %l%P") %>.</span>
% }
Mute for:
<select name="mute_for">
% if ($file->is_muted) {
<option selected>Unmute
% }
<option>1 hour
<option>4 hours
<option>8 hours
<option>1 day
<option>2 days
<option>3 days
</select>
<input type=submit value="Set">
<p>

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

<hr>

<h3>History</h3>

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

<hr>

<h3>Comments</h3>

% if (@comments) {
<table class="comments">
%   foreach my $comment (@comments) {
<tr>
<td><% $comment->create_time->strftime("%a %m-%d %l:%M %P") %></td>
<td>[<% $comment->author %>]</td>
<td><% $comment->content %></td>
</tr>
%   }
</table>
% }
% else {
<p>No comments.</p>
% }

<a name="#comments">
<form action="/file/action/add_comment" method=POST>
<p>Add a comment:
<input type=hidden name=file_id value=<% $file->id %>>
<input type=text name=content size=50>
<input type=submit value="Add">
</p>

</div>

<%init>
my $file = Spectre::File->new(id => $.file_id)->load(speculative => 1) or $m->not_found;
my @results = @{ $file->all_results };
my $results_with_fail = grep { $_->has_failures } @results;
my @comments = @{ $file->all_comments };
$.title = "Test file - " . $file->name;
</%init>
