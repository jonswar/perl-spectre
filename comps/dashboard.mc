<%method javascript>
% (my $menutext = $m->scomp('file_menu.mi')) =~ s/\s+/ /g;
var menutext = '<% javascript_value_escape($menutext) %>';

function menuClickMute (elem, mute_for) {
  var file_row = $(elem).parents('.file_row');
  var file_id = file_row.attr('id');
  $.post('/file/action/set_mute', { file_id: file_id, mute_for: mute_for }, function () {
    if (mute_for == "Unmute") {
      file_row.removeClass('muted hidden_files');
    }
    else {
      file_row.addClass('muted hidden_files');
    }
    showOrHideHiddenFiles();
  });
  hideMenu();
}

function hideMenu () {
  $("ul.menu").hideSuperfishUl();
}

function showOrHideHiddenFiles () {
  if ($("#show_all_files").is(":checked")) {
    $('.hidden_files').show();
  } else {
    $('.hidden_files').hide();
  }
}

$(function() {
  $("input:checkbox:checked").attr("checked", "");
  $('#show_all_files').click(function() {
    showOrHideHiddenFiles();
  });
  $('.menu').hover(
      function() {
        $(this).parent().parent().find(".menuhover").css("background", "#ddd")
        var elem = $(this).find(".menutext");
        if (elem.html() == "") {
          elem.html(menutext);
          $('ul.menu').superfish(superfishOptions);
        }
      },
      function() {
        $(this).parent().parent().find(".menuhover").css("background", "#ffffff")
      }
  );
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

<table class="grid">
  <tr>
  <th colspan=2></th>
% foreach my $report (@reports) {
  <th class="<% $report->has_failures ? 'fail' : 'ok' %>">
    <a href="<% $report->link %>">
      <% $report->run_time->strftime("%m-%d<br>%l%P") %>
    </a>
  </th>
% }
  </tr>
% foreach my $dash_file (@dash_files) {
%   my $has_fail = $dash_file->{has_fail};
%   my $muted    = $dash_file->{file}->is_muted ? "muted" : "";
%   my $hidden   = ($muted || !$has_fail) ? "hidden_files" : "";
  <tr class="file_row <% $hidden %> <% $muted %>" id="<% $dash_file->{file}->id %>" <% $hidden ? 'style="display: none"' : '' %>>
    <td class="menuhover">
      <ul class="menu">
        <li>
          <a href="#a"><img src="/static/i/gear.png"></a>
          <div class="menutext"></div>
        </li>
      </ul>
    </td>
    <td class="menuhover <% $dash_file->{has_fail} ? "fail" : "ok" %>">
      <a href="<% $dash_file->{file}->link %>"><% $dash_file->{file}->name %></a>
    </td>
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
