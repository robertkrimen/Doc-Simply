package Doc::Simply::Extractor;

use Moose;
use Doc::Simply::Carp;

has filter => qw/is ro required 0/;
has matcher => qw/is ro required 1/;

sub extract {
    my $self = shift;
    my $source = shift;

    return unless $source;

    my @source;
    if (ref $source eq "ARRAY") {
        @source = @$source;
    }
    elsif (ref $source eq "") {
        @source = split m/\n/, $source;
    }
    else {
        croak "Don't understand source $source";
    }

    my $filter = $self->filter;
    my $matcher = $self->matcher;

    my (@extract, %state);
EXTRACT:    
    for my $line (@source) {

        if ($line) {
            local $_ = $line;
            if ($filter->($_)) {
                $line = $_;
            }
            else {
                undef $line;
            }
        }

        unless ($line) {
            delete $state{collect};
            next EXTRACT;
        }
        
#        no warnings 'uninitialized';

        my (%line, $head, $body);
        {
            local $_ = $line;
            ($head, $body) = $matcher->($line);
            if ($head) {
                %line = (head => $head);
                $line{body} = $body if defined $body && length $body;
            }
            else {
                next EXTRACT unless $state{collect};
                $body = $line;
                %line = (body => $body);
            }
        }

        unless ($state{collect}) {
            $line{begin} = 1;
        }

        if ($head && $head =~ m/^cut\b/i) {
            delete $state{collect};
        }
        else {
            $state{collect} = 1;
        }

        push @extract, \%line;

    }

    return @extract;
}

1;
