use strict;
use warnings;

use Test::Most;
use t::Test;

use Doc::Simply;
use Doc::Simply::Extractor;
use Doc::Simply::Assembler;
use Doc::Simply::Parser;

plan qw/no_plan/;

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

#warn "\n";
#warn map { "$_\n" } @{ $document->draw_ascii_tree };

is($content = $document->root->content_from, <<_END_);
root 
head2 This is a node
body 
_END_
