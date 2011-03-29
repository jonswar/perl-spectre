package Spectre::Environment;
use Carp;
use Spectre::Conf;
use Spectre::Util;
use Moose;

use constant standard_subdirs => [qw(bin comps conf lib logs state)];

has 'conf'           => ( is => 'ro' );
has 'is_development' => ( is => 'ro' );
has 'is_live'        => ( is => 'ro' );
has 'layer'          => ( is => 'ro' );
has 'name'           => ( is => 'ro' );
has 'root_dir'       => ( is => 'ro', required => 1 );

foreach my $subdir ( @{ standard_subdirs() } ) {
    my $method = $subdir . "_dir";
    has $method => ( is => 'ro' );
}

my $root_marker_file = ".spectre_root";

my ($current_env);

sub initialize_current_environment {
    my ( $class, %params ) = @_;

    if ( defined($current_env) ) {
        die sprintf( "initialize_current_environment called when current_env already set (%s)",
            $current_env->root_dir() );
    }
    die "root_dir required" unless $params{root_dir};
    $current_env = $class->new(%params);

    # Add extra paths to @INC: override/lib and env.extra_inc
    #
    my @paths = @{ $current_env->{conf}->get_list('env.extra_inc') };
    if ( -d ( my $override_dir = $current_env->root_dir . "/override/lib" ) ) {
        push( @paths, $override_dir );
    }
    unshift( @INC, @paths );

    # Turn off Carp::Assert assertions when live
    #
    $ENV{PERL_NDEBUG} = 1 if $current_env->is_live;
}

sub get_environment {
    my ($class) = @_;

    return $current_env;
}

sub BUILD {
    my ($self) = @_;

    my $root_dir = $self->root_dir();
    die
      "$root_dir is missing marker file $root_marker_file - is it really a Spectre environment root?"
      unless -f "$root_dir/$root_marker_file";
    $self->{name} = basename($root_dir);

    # Initialize configuration
    #
    $self->{conf} = Spectre::Conf->new(
        conf_dir => catdir( $root_dir, "conf" ),
        root_dir => $root_dir
    );
    $self->{layer} = $self->{conf}->get('layer')
      || die "could not determine layer from configuration";
    $self->{is_development} = ( $self->{layer} eq 'development' || $self->{layer} eq 'personal' );
    $self->{is_live} = $self->{is_production};

    # Determine where our standard subdirectories (comps, conf, etc.)
    # are. Use obvious defaults if not overriden in configuration.
    #
    foreach my $subdir ( @{ standard_subdirs() } ) {
        my $method = $subdir . "_dir";
        my $default = catdir( $root_dir, $subdir );
        $self->{$method} = $self->{conf}->get( "env.$method" => $default );
    }

    # Create log and state directories if necessary.
    #
    foreach my $dir ( $self->log_dir(), $self->state_dir() ) {
        mkpath( $dir, 0, 0755 )
          if ( !-d $dir );
    }
}

__PACKAGE__->meta->make_immutable();

1;
