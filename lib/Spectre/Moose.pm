package Spectre::Moose;
use Moose                      ();
use MooseX::HasDefaults::RO    ();
use MooseX::StrictConstructor  ();
use Method::Signatures::Simple ();
use Moose::Exporter;
use strict;
use warnings;
Moose::Exporter->setup_import_methods( also => ['Moose'] );

sub init_meta {
    my $class     = shift;
    my %params    = @_;
    my $for_class = $params{for_class};
    Method::Signatures::Simple->import( into => $for_class );
    Moose->init_meta(@_);
    MooseX::StrictConstructor->init_meta(@_);
    MooseX::HasDefaults::RO->init_meta(@_);
    {
        no strict 'refs';
    }
    Spectre->export_to_level(1);
}

1;

__END__

=pod

=head1 NAME

Spectre::Moose - Spectre Moose policies

=head1 SYNOPSIS

    # instead of use Moose;
    use Spectre::Moose;

=head1 DESCRIPTION

Sets certain Moose behaviors for Spectre's internal classes. Using this module
is equivalent to

    use CLASS;
    use Moose;
    use MooseX::HasDefaults::RO;
    use MooseX::StrictConstructor;
    use Method::Signatures::Simple;
    use Spectre::Util;
