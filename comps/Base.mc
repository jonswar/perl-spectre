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
    <head>
      <% $.head() %>
    </head>
    <body>
    <div id="page_container">
% if (my $message = delete($m->req->session->{message})) {
      <div class="message"><% $message %></div>
% }      

    <!--<div style="float: right"><a href="/"><img src="/static/i/spectre1.jpg"></a>
    <br>
    <span style='padding-left: 5px; font: 16px "Lucida Grande", "Arial", "sans-serif"'>SPECTRE</span>
    </div>-->
    
    <h2><% $.Defer { %><% $.title %></%></h2>

      <% inner() %>
    </div>
    </body>
  </html>
</%augment>
