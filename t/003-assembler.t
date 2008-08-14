use strict;
use warnings;

use Test::Most;
use XXX;

use Doc::Simply;
use Doc::Simply::Assembler;

plan qw/no_plan/;

{
    my $assembler = Doc::Simply::Assembler->new;
}


ok(1);

__END__

my $extractor = Doc::Simply::Extractor->new(
    filter => sub {
        s/^\s*#\s*//;
    }, 
    matcher => sub {
        return unless m/^(?:=|\@)([\w]+)(.*)$/; ($1, $2);
    }
);

cmp_deeply(reverse [], [ $extractor->extract(<<'_END_') ]);
@head2
@cut
# cut
_END_

cmp_deeply(reverse [
    { qw/begin 1 head head2/, body => " Xyzzy" },
    ], [ $extractor->extract(<<'_END_') ]);
@head2
# @head2 Xyzzy
_END_

cmp_deeply(reverse [
    { qw/head head2 begin 1/, body => " Xyzzy" },
    { qw/body More/ },
    { qw/head cut/ },
    ], [ $extractor->extract(<<'_END_') ]);
@head2
# @head2 Xyzzy
# More
# @cut
# Ignore this 
_END_

cmp_deeply(reverse [
    { qw/head head2 begin 1/, body => " Xyzzy" },
    { qw/body More/ },
    { body => "And more" },
    { qw/head cut begin 1/ },
    ], [ $extractor->extract(<<'_END_') ]);
@head2
# @head2 Xyzzy
# More
# And more

# But not this
@head3 Ignore this
# @cut
# Or this 
_END_

1;
