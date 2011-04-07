<%shared>
$.title => undef
</%shared>

<%method javascript>
</%method>

<%method head>
  <% $.Defer { %>
    <link rel="stylesheet" href="/static/spectre.css">
    <title>Spectre<% $.title ? ": " . $.title : "" %></title>
    <& javascript.mi &>
    <script type="text/javascript">
      <% $.javascript %>
    </script>
  </%>
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

    <a href="/dashboard"><img src="/static/i/spectre1.jpg"></a>
    <h2><% $.Defer { %><% $.title %></%></h2>

      <% inner() %>
    </body>
  </html>
</%augment>
