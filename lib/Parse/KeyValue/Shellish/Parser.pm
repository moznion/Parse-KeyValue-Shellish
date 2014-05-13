package Parse::KeyValue::Shellish::Parser;
use strict;
use warnings;

sub new {
    my ($class, $str) = @_;

    bless {
        index  => 0,
        key    => '',
        str    => $str,
        strlen => length $str,
    }, $class;
}

sub parse {
    my ($self) = @_;

    my %parsed;
    my $token   = '';
    my $escaped = '';

    my $strlen = $self->{strlen};
    for ($self->{index} = 0; $self->{index} < $strlen; $self->{index}++) {
        my $ch = substr($self->{str}, $self->{index}, 1);

        if ($ch eq '=') {
            if ($self->{key}) {
                $token .= $ch;
                next;
            }
            $self->{key} = $token;
            $token = '';
            next;
        }

        if ($ch =~ /\s/) {
            $token .= '\\' if $escaped;
            if ($self->{key}) {
                $parsed{$self->{key}} = $token;
            }
            $self->{key} = '';
            $token = '';
            next;
        }

        if ($ch eq "'" || $ch eq '"') {
            $token .= $self->_parse_in_quote($ch);
            next;
        }

        if ($ch eq '(' && !$escaped) {
            my @array;

            for ($self->{index}++; $self->{index} < $strlen; $self->{index}++) {
                my $ch = substr($self->{str}, $self->{index}, 1);

                if ($ch eq ')') {
                    last;
                }

                if ($ch =~ /\s/) {
                    push @array, $token;
                    $token = '';
                    next;
                }

                if ($ch eq "'" || $ch eq '"') {
                    $token .= $self->_parse_in_quote($ch);
                    next;
                }

                $token .= $ch;
            }

            if ($self->{key} && $token) {
                $token .= '\\' if $escaped;
                push @array, $token;
                $token = '';
            }

            $parsed{$self->{key}} = \@array;
            $self->{key} = '';
            next;
        }

        if ($ch eq '\\') {
            $escaped = 1;
            next;
        }

        $token .= $ch;
        $escaped = 0;
    }

    if ($self->{key} && $token) {
        $token .= '\\' if $escaped;
        $parsed{$self->{key}} = $token;
    }

    return \%parsed;
}

sub _parse_in_quote {
    my ($self, $quote) = @_;

    my $escaped = 0;
    my $token = '';
    my $strlen = $self->{strlen};

    for ($self->{index}++; $self->{index} < $strlen; $self->{index}++) {
        my $ch = substr $self->{str}, $self->{index}, 1;

        last if $ch eq $quote && !$escaped;

        if ($ch eq '\\') {
            if ($quote eq "'") {
                $token .= $ch;
                next;
            }
            $escaped = 1;
            next;
        }

        $token .= $ch;
        $escaped = 0;
    }

    return $token;
}

sub _parse_in_paren {
}

1;

