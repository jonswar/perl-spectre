<%shared>
$.title => undef
</%shared>

<%method head>
  <link rel="stylesheet" href="/static/spectre.css">
  <% $.Defer { %><title>Spectre<% $.title ? ": " . $.title : "" %></title></%>
  <& javascript.mi &>
</%method>

<%augment wrap>
  <html>
    <body>
    <head>
      <% $.head() %>
    </head>
% if (my $message = delete($m->req->session->{message})) {
      <div class="message"><% $message %></div>
% }      

      <% inner() %>
    </body>
  </html>
</%augment>
