#!/usr/bin/perl
use Spectre::Script qw($root);
use Spectre::Report;
use String::Random;
use IPC::System::Simple qw(run);

my $count = shift(@ARGV) or die "usage: $0 count";
my $dir = "$root/data/incoming";
rmtree($dir);
mkpath( $dir, 0, 0775 );
my $start_time =
  DateTime->now( time_zone => 'local' )->truncate( to => 'hour' )
  ->subtract( hours => ( $count + 1 ) );
foreach my $i ( 0 .. $count - 1 ) {
    $start_time = $start_time->add( hours => 1 );
    my $name = sprintf(
        "development-%s-%s",
        $start_time->strftime("%m-%d-%H_%M_%S"),
        String::Random->new->randpattern("cccc")
    );
    my $cmd = "/Users/swartz/hm/bin/hmtest -c Poet::t::Utils --smolder $name";
    print "$cmd\n";
    system($cmd);
}
