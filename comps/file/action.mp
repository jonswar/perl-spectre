route ":handle_method";

has 'content';
has 'file_id';
has 'mute_for';

has 'file' => (init_arg => undef, lazy_build => 1);

method handle () {
    $.file = Spectre::File->new(id => $.file_id)->load(speculative => 1) or $m->not_found;
    my $method = "handle_" . $.handle_method() ;
    $.can($method) ? $self->$method() : $m->not_found() ;
}

method handle_add_comment () {
    if ($.content =~ /\S/) {
        $.file->add_comment('swartz', $.content);
    }
    $m->redirect($.file->link . "#comments");
}

method handle_set_mute () {
    my $mute_until =
      ( $.mute_for eq 'Unmute' )
      ? undef
      : DateTime->now->add( seconds => Time::Duration::Parse::parse_duration( $.mute_for ) );
    $.file->mute_until($mute_until);
    $.file->save;
    $m->redirect( $.file->link );
}
