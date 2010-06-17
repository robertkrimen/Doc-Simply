package Doc::Simply::Extractor;

use strict;
use warnings;

# This is a dummy package containing Extractor::SlashStar & Extractor::SimplePound 
#
# The ->extract method returns an ARRAY (reference) yielding either:
#   
#       line => <content>
#       block => <content>

use Text::FixEOL;
our $fixer = Text::FixEOL->new;

package Doc::Simply::Extractor::SlashStar;

=head1 NAME

Doc::Simply::Extractor::SlashStar - Extract content from /* ...  */ and // ... style commentary

=head1 DESCRIPTION

Doc::Simply::Extractor::SlashStar uses L<String::Comments::Extract> to parse JavaScript, Java, C, C++ content and extract
only the comments

=cut

use Any::Moose;
use Doc::Simply::Carp;

use String::Comments::Extract;

sub extract {
    my $self = shift;
    my $source = shift;

    return unless $source;

    $source = $fixer->fix_eol($source);
    my $comments = String::Comments::Extract::SlashStar->extract($source);

    my @comments;
    while ($comments =~ m{/\*(.*?)\*/|//(.*?)$}msg) {
        next unless defined $1 || defined $2;
        push @comments, defined $1 ? [ block => $1 ] : [ line => $2 ];
    }     

    return \@comments;
}

package Doc::Simply::Extractor::SimplePound;

=head1 NAME

Doc::Simply::Extractor::SimplePound - Extract content from # ... style commentary

=cut

use Any::Moose;
use Doc::Simply::Carp;

# TODO Does not deal with multi-line strings, etc.

has _extractor => qw/is ro lazy_build 1/;
sub _build__extractor {
    my $self = shift;
    return Doc::Simply::Extract::Match->new(filter => sub { return unless s/^\s*#//; $_ });
}

sub extract {
    my $self = shift;
    return $self->_extractor->extract(@_);
}

package Doc::Simply::Extractor::Filter;

use Any::Moose;
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
        $source = $fixer->fix_eol($source);
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
            next unless defined ($line = $filter->($_));
            push @comments, [ line => $line ];
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
