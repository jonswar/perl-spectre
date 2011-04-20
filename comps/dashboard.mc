<%method javascript>
$j(function() {
  $j("input:checkbox:checked").attr("checked", "");
  $j('#show_all_files').click(function() {
     if ($j(this).is(":checked")) {
        $j('.ok_files').show();
     } else {
        $j('.ok_files').hide();
     }
  });
  $j('.actions_cell').hover(function(){$j(this).children().toggle()});
});
</%method>

<div id="dashboard">

<p>
  <% NO("report", scalar(@reports)) %>,
  <% NO("test file", scalar(@dash_files)) %>
    (<% $files_with_fail %> with failures)
</p>

<p>
  <input id="show_all_files" type=checkbox>Show all test files
</p>

<table border=1>
  <tr>
  <th></th>
% foreach my $report (@reports) {
  <th class="<% $report->has_failures ? 'fail' : 'ok' %>">
    <a href="<% $report->link %>">
      <% $report->run_time->strftime("%m-%d<br>%l%P") %>
    </a>
  </th>
% }
  <th>Actions</th>
  </tr>
% foreach my $dash_file (@dash_files) {
%   my $muted = ($dash_file->{file}->is_muted ? "muted" : "");
%   if ($dash_file->{has_fail}) {
  <tr class="<% $muted %>">
%   }
%   else {
  <tr class="ok_files <% $muted %>" style="display: none">
%   }
    <td class="<% $dash_file->{has_fail} ? "fail" : "ok" %>"><a href="<% $dash_file->{file}->link %>"><% $dash_file->{file}->name %></a></td>
%   foreach my $result (@{$dash_file->{results}}) {
%     if (defined $result) {
%       my $percent = $result->percent;
%       if ($percent == 100) {
    <td align=center class="ok"><a href="<% $result->link %>"><img width=16 height=16 src="/static/i/check2.png"></a></td>
%       }
%       else {
    <td align=center class="fail"><a href="<% $result->link %>"><% $percent %>%</a></td>
%       }
%     } 
%     else {
    <td class="notrun">-</td>
%     }
%   }
  <td class="actions_cell" style="width:75px">&nbsp;<span style="display: none"><a href="#"><nobr>Actions<img style="vertical-align: text-bottom" width="16" height="16" src="/static/i/triangle_down.gif"></nobr></a></span></td>
  </tr>
% }
</table>
</div>

<%init>
$.title = 'Dashboard';
my @reports = @{ Spectre::Reports->get_reports(sort_by => 'run_time desc') };
my @all_results = map { $_->all_results } @reports;
my (%found_file);
my @dash_files = map { $found_file{$_->file_id}++ ? () : ({ file => $_->file }) } @all_results;
@dash_files = sort { $a->{file}->name cmp $b->{file}->name } @dash_files;
foreach my $dash_file (@dash_files) {
    $dash_file->{results} = [map { $_->result_for_file($dash_file->{file}->id) } @reports];
    $dash_file->{has_fail} = any { defined($_) && $_->has_failures } @{$dash_file->{results}};
}
my $files_with_fail = grep { $_->{has_fail} } @dash_files;
</%init>
