package Doc::Simply::Assembler;

use Moose;
use Doc::Simply::Carp;

has normalizer => qw/is ro lazy_build 1 isa CodeRef/;
sub _build_normalizer {
    return sub {
        s/^( \*)?\s{0,1}//; $_;
    }
}

sub assemble {
    my $self = shift;
    my $comments = shift;

    my (@blocks, @block);
    my $normalizer = $self->normalizer;

    for my $comment (@$comments) {
        my ($type, $content) = @$comment;
        my @content = split m/\n/, $content;
        @content = map { $normalizer->($_) } @content;
        if ($type eq "line") {
            push @block, @content;
        }
        else {
            push @blocks, \@block if @block;
            push @blocks, [ @content ];
        }
    }

    push @blocks, \@block if @block;

    return \@blocks;
}

1;

__END__

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
