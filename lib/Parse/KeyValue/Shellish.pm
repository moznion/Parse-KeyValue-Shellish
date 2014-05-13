package Parse::KeyValue::Shellish;
use 5.008005;
use strict;
use warnings;
use parent qw/Exporter/;
use Parse::KeyValue::Shellish::Parser;

our @EXPORT_OK = qw/parse_key_value/;
our $VERSION   = "0.01";

sub parse_key_value {
    my ($str) = @_;

    my $parser = Parse::KeyValue::Shellish::Parser->new($str);
    $parser->parse;
}

1;
__END__

=encoding utf-8

=head1 NAME

Parse::KeyValue::Shellish - It's new $module

=head1 SYNOPSIS

    use Parse::KeyValue::Shellish;

=head1 DESCRIPTION

Parse::KeyValue::Shellish is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

