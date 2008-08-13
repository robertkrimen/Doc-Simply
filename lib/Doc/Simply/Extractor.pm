package Doc::Simply::Extractor;

use Moose;
use Doc::Simply::Carp;

package Doc::Simply::Extractor::SlashStar;

use Moose;
use Doc::Simply::Carp;

use String::Comments::Extract;

sub extract {
    my $self = shift;
    my $source = shift;

    return unless $source;

    my @comments = String::Comments::Extract::JavaScript->collect($source);

    return \@comments;
}

package Doc::Simply::Extractor::SimplePound;

use Moose;
use Doc::Simply::Carp;

# TODO Does not deal with multi-line strings, etc.

has _extractor => qw/is ro lazy_build 1/;
sub _build__extractor {
    my $self = shift;
    return Doc::Simply::Extract::Match->new(filter => sub { s/^\s*#// });
}

sub extract {
    my $self = shift;
    return $self->_extractor->extract(@_);
}

package Doc::Simply::Extractor::Filter;

use Moose;
use Doc::Simply::Carp;

has filter => qw/is ro required 1 isa CodeRef/;

sub extract {
    my $self = shift;
    my $source = shift;

    return unless $source;

    my (@source, @comments)
    ;
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

    {
        local $_;
        for my $line (@source) {
            next unless $line;
            $_ = $line;
            next unless $filter->($_);
            push @comments, $_;
        }
    }

    return \@comments;
}

1;

__END__

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
__END__

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
