use strict;
use warnings;

use Test::Most;
use XXX;

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

is($content = $document->content_from, <<_END_);
root 
head2 This is a node
body 
_END_

#$content =~ s/[ \t]/./g;
#warn $content;

__END__

my $source = <<'_END_';
/* 
 * @head2 Icky nesting
 * Some content
 *
 * @head1 Hello, World.
 *
 * @head2 Yikes. 
 * Some more content
 * With some *markdown* shiat!
 *
 *      And some more
 *      And some inline code
 *
 */
_END_
