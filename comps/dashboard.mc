<h2>Spectre Dashboard</h2>

<div id="dashboard">

<p>
  <% NO("report", scalar(@reports)) %>,
  <% NO("test file", scalar(@files)) %>
    (<% $files_with_fail %> with failures)
</p>

<p>
<a href="#" onclick="sp.toggleOkRows(); return false">
  <span class="toggle_ok">Show all test files</span>
  <span class="toggle_ok" style="display: none">Show only test files with failures</span>
</a>
</p>

<table border=1>
  <tr>
  <th></th>
% foreach my $report (@reports) {
  <th>
    <a href="<% $report->link %>">
      <% $report->run_time->strftime("%m-%d<br>%l%P") %>
    </a>
  </th>
% }
  <th>Actions</th>
  </tr>
% foreach my $file (@files) {
%   if ($file->{has_fail}) {
  <tr>
%   }
%   else {
  <tr class="toggle_ok" style="display: none">
%   }
    <td><a href="<% $file->link %>"><% $file->name %></a></td>
%   foreach my $result (@{$file->{results}}) {
%     if (defined $result) {
%       my $percent = $result->percent;
%       if ($percent == 100) {
    <td align=center class="ok"><a href="<% $result->link %>"><img width=16 height=16 src="/static/i/green_check_mark.gif"></a></td>
%       }
%       else {
    <td class="fail"><a href="<% $result->link %>"><% $percent %>%</a></td>
%       }
%     } 
%     else {
    <td class="notrun">-</td>
%     }
%   }
  <td align=center><img src="/static/i/mute2.jpg"></td>
  </tr>
% }
</table>
</div>

<%init>
$.title = 'Dashboard';
my @reports = @{ Spectre::Reports->get_reports };
my @all_results = map { $_->all_results } @reports;
my @files = map { Spectre::File->new(name => $_) } sort(uniq(map { $_->file_name } @all_results));
foreach my $file (@files) {
    $file->{results} = [map { $_->result_for_file($file->name) } @reports];
    $file->{has_fail} = any { defined($_) && $_->has_failures } @{$file->{results}};
}
my $files_with_fail = grep { $_->{has_fail} } @files;
</%init>
