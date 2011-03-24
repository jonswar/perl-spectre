package Spectre::Conf;
use Carp;
use Memoize;
use Moose;
use Spectre::Util;
use Try::Tiny;
use YAML::AppConfig;
use strict;
use warnings;

use YAML::XS qw(Dump Load);
my $yaml_class = 'YAML::XS';

has 'app_conf' => ( is => 'ro' );
has 'conf_dir' => ( is => 'ro', required => 1 );
has 'root_dir' => ( is => 'ro' );

sub BUILD {
    my ( $self, $params ) = @_;

    $self->{app_conf} = $self->parse_config_files;
}

sub parse_config_files {
    my ($self) = @_;
    my $conf_dir = $self->{conf_dir};

    # First get layer from layer.cfg or local.cfg
    my $layer_cfg_file = catfile( $conf_dir, "layer.cfg" );
    my $layer_cfg =
      ( -f $layer_cfg_file )
      ? Load( $self->_read_yaml_file($layer_cfg_file) )
      : {};
    my $local_cfg_file = catfile( $conf_dir, "local.cfg" );
    my $local_cfg =
      ( -f $local_cfg_file )
      ? Load( $self->_read_yaml_file($local_cfg_file) )
      : {};
    my $layer =
         $layer_cfg->{layer}
      || $local_cfg->{layer}
      || die "must specify layer in '$layer_cfg_file' or '$local_cfg_file'";
    die "invalid layer '$layer'"
      unless $layer =~ /^(?:personal|development|staging|production)$/;

    # Unfortunately YAML::AppConfig crashes on empty config files, or config files with
    # nothing but comments. We add a single "_init: 0" pair to prevent this.
    #
    my $app_conf = YAML::AppConfig->new( yaml_class => $yaml_class, string => "_init: 0" );

    # Provide some convenience globals.
    #
    $app_conf->set( root_dir => $self->root_dir );

    # Collect list of config files in appropriate order
    #
    my @conf_files = (
        "$conf_dir/layer.cfg",
        "$conf_dir/env.cfg",
        glob("$conf_dir/global/*.cfg"),
        (
            $layer =~ /^(?:staging|production)$/
            ? ("$conf_dir/layer/live.cfg")
            : ()
        ),
        "$conf_dir/layer/$layer.cfg",
        "$conf_dir/local.cfg",
        "$conf_dir/host.cfg",
        "$conf_dir/protected.cfg",
        $self->root_dir . "/override/override.cfg",
        $ENV{POET_EXTRA_CONF_FILE},
    );

    # Stores the file where each global/* key is declared.
    #
    my %global_keys;

    foreach my $file (@conf_files) {
        if ( defined $file && -f $file ) {
            my $yaml = $self->_read_yaml_file($file);
            flush_memoize_cache();    # because merge() may use get()
            $app_conf->merge( string => $yaml );

            # Make sure no keys are defined in multiple global config files
            #
            if ( $file =~ m{/global/} ) {
                my $global_cfg = Load($yaml);
                foreach my $key ( keys(%$global_cfg) ) {
                    next if $key eq '_init';
                    if ( my $previous_file = $global_keys{$key} ) {
                        die sprintf(
                            "top-level key '%s' defined in both '%s' and '%s' - global conf files must be mutually exclusive",
                            $key, $previous_file, $file );
                    }
                    else {
                        $global_keys{$key} = $file;
                    }
                }
            }
        }
    }

    return $app_conf;
}

sub _read_yaml_file {
    my ( $self, $file ) = @_;

    # Read a yaml file, adding a dummy key pair to handle empty files or
    # files with nothing but comments. Forbid tabs and duplicate keys, and
    # check for errors before returning. This means parsing files twice
    # (here and above) but makes the code cleaner.
    #
    my $yaml = read_file($file) . "\n\n_init: 0";
    try {
        if ( ( my $tab_char = index( $yaml, "\t" ) ) != -1 ) {
            my $tab_line = ( substr( $yaml, 0, $tab_char ) =~ tr/\n/\n/ ) + 1;
            die
              "tab character found on line $tab_line, char $tab_char - convert to regular space\n";
        }
        my $href           = Load($yaml);
        my $file_key_count = grep { /^[^\#\-\s]/ } split( "\n", $yaml );
        my $hash_key_count = scalar( keys(%$href) );
        if ( $file_key_count != $hash_key_count ) {
            die
              "duplicate top-level keys - file key count ($file_key_count) != hash key count ($hash_key_count)";
        }
    }
    catch {
        die "error parsing config file '$file': $_";
    };
    return $yaml;
}

# Memoize YAML::AppConfig::get, since conf can normally not change at runtime. This will benefit all
# get() and get_*() calls. Clear cache on set_local.
#
memoize('YAML::AppConfig::get');

sub flush_memoize_cache {
    Memoize::flush_cache('YAML::AppConfig::get');
}

sub get {
    my ( $self, $key, $default ) = @_;

    if ( defined( my $value = $self->{app_conf}->get($key) ) ) {
        return $value;
    }
    else {
        return $default;
    }
}

sub get_or_die {
    my ( $self, $key ) = @_;

    if ( defined( my $value = $self->{app_conf}->get($key) ) ) {
        return $value;
    }
    else {
        die "could not get conf for '$key'";
    }
}

sub get_list {
    my ( $self, $key, $default ) = @_;

    if ( defined( my $value = $self->{app_conf}->get($key) ) ) {
        if ( ref($value) eq 'ARRAY' ) {
            return $value;
        }
        else {
            my $error =
              sprintf( "list value expected for config key '%s', got non-list '%s'", $key, $value );
            $self->handle_conf_error($error);
            return [];
        }
    }
    elsif ( defined $default ) {
        return $default;
    }
    else {
        return [];
    }
}

sub get_hash {
    my ( $self, $key, $default ) = @_;

    if ( defined( my $value = $self->{app_conf}->get($key) ) ) {
        if ( ref($value) eq 'HASH' ) {
            return $value;
        }
        else {
            my $error =
              sprintf( "hash value expected for config key '%s', got non-hash '%s'", $key, $value );
            $self->handle_conf_error($error);
            return {};
        }
    }
    elsif ( defined $default ) {
        return $default;
    }
    else {
        return {};
    }
}

# Find all keys with the given prefix, and return a hashref containing just
# those keys and values with the prefix stripped off.
#
sub get_hash_from_common_prefix {
    my ( $self, $prefix ) = @_;

    my $prefix_length = length($prefix);
    return {
        map { ( substr( $_, $prefix_length ), $self->get($_) ) }
        grep { /^\Q$prefix\E(.+)$/ } keys( %{ $self->{app_conf}->config } )
    };
}

sub handle_conf_error {
    my ( $self, $msg ) = @_;

    croak $msg;
}

sub get_boolean {
    my ( $self, $key ) = @_;

    return $self->{app_conf}->get($key) ? 1 : 0;
}

sub dump_conf {
    my ( $self, ) = @_;

    return $self->{app_conf}->dump;
}

__PACKAGE__->meta->make_immutable();

1;
