use strict;
use warnings;

use Test::Most;
use t::Test;

use Doc::Simply;
use Doc::Simply::Extractor;
use Doc::Simply::Assembler;
use Doc::Simply::Parser;

plan qw/no_plan/;

sub normalize {
    local $_ = shift;
    return join "\n", map { s/^\s*//; s/\s*$//; $_ } split m/\n/;
}

{
    my $content;
    my $source = <<'_END_';
/* 
 * @head2 This is a node
 */

// This should not be
_END_

    my $extractor = Doc::Simply::Extractor::SlashStar->new;
    my $comments = $extractor->extract($source);

    my $assembler = Doc::Simply::Assembler->new;
    my $blocks = $assembler->assemble($comments);

    my $parser = Doc::Simply::Parser->new;
    my $document = $parser->parse($blocks);

    is($content = $document->root->content_from, <<_END_);
root 
head2 This is a node
body 
_END_
}

{

    my $content;
    my $source = <<'_END_';
/*
 * @head2 Icky nesting
 * Some content
 *
 * @head1 Hello, World.
 *
 * @head2 Yikes. 
 * Some more content
 * With some *markdown* content!
 *
 *      And some more
 *      And some inline code
 *
 */

/* Ignore this...
*/

/* @body 
 * ...but grab **this**!
        */

// Another ignoreable comment
_END_

    my $extractor = Doc::Simply::Extractor::SlashStar->new;
    my $comments = $extractor->extract($source);

    my $assembler = Doc::Simply::Assembler->new;
    my $blocks = $assembler->assemble($comments);

    my $parser = Doc::Simply::Parser->new;
    my $document = $parser->parse($blocks);
    local @_ = map { normalize $_ } ($content = $document->root->content_from, <<_END_);
root 
head2 Icky nesting
body Some content
body 
head1 Hello, World.
body 
head2 Yikes.
body Some more content
body With some *markdown* content!
body 
body      And some more
body      And some inline code
body 
body 
body 
body ...but grab **this**!
body 
_END_
    is($_[0], $_[1]);
}
