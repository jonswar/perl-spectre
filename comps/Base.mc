<%shared>
$.title => undef
</%shared>

<%method javascript>
</%method>

<%method head>
  <% $.Defer { %>
    <link rel="stylesheet" href="/static/css/spectre.css">
    <link rel="stylesheet" href="/static/css/superfish.css">
    <title>Spectre<% $.title ? ": " . $.title : "" %></title>
    <& javascript.mi &>
    <script type="text/javascript">
      <% $.javascript %>
    </script>
  </%>
</%method>

<%augment wrap>
  <html>
    <head>
      <% $.head() %>
    </head>
    <body>
    <div id="page_container">
% if (my $message = delete($m->req->session->{message})) {
      <div class="message"><% $message %></div>
% }      

<!--    <div style="float: right"><a href="/"><img src="/static/i/spectre2.jpg"></a></div>-->
    
    <h2><% $.Defer { %><% $.title %></%></h2>

      <% inner() %>
    </div>
    </body>
  </html>
</%augment>
