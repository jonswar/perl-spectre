package Spectre::Moose::Role;
use Moose::Role                ();
use Method::Signatures::Simple ();
use Moose::Exporter;
Moose::Exporter->setup_import_methods( also => ['Moose::Role'] );

sub init_meta {
    my $class     = shift;
    my %params    = @_;
    my $for_class = $params{for_class};
    Method::Signatures::Simple->import( into => $for_class );
    Moose::Role->init_meta(@_);
    Spectre->export_to_level(2);
}

1;

__END__

=pod

=head1 NAME

Spectre::Moose::Role - Spectre Moose role policies

=head1 SYNOPSIS

    # instead of use Moose::Role;
    use Spectre::Moose::Role;

=head1 DESCRIPTION

Sets certain Moose behaviors for Spectre's internal roles. Using this module is
equivalent to

    use Moose::Role;
    use Method::Signatures::Simple;
