package Doc::Simply::App;

use Moose;
use Doc::Simply::Carp;

use Doc::Simply;
use Doc::Simply::Extractor;
use Doc::Simply::Assembler;
use Doc::Simply::Parser;
use Doc::Simply::Render::HTML;

use Getopt::Chain;

my %type = (
    (map { $_ => 'slash-star' } qw/slash-star js javascript c c++ cpp java/),
);
my @types = keys %type;

sub run {
    my $self = shift;

   Getopt::Chain->process(

        options => [qw/
            type:s
            style:s
            css-file:s css-link:s css:s
            js-file:s js-link:s js:s
            wrapper-file:s
        /],

       run => sub {
            my $context = shift;
#            my $type = $context->options->{type} or abort "What type of source is the input? (@types)";
            my $type = $context->options->{type} || 'slash-star';
            my $canonical_type = $type{$type} or $context->abort("Don't know type \"$type\" (@types)");

            my $source = join "", <STDIN>;

            my $extractor = Doc::Simply::Extractor::SlashStar->new;
            my $comments = $extractor->extract($source);

            my $assembler = Doc::Simply::Assembler->new;
            my $blocks = $assembler->assemble($comments);

            my $parser = Doc::Simply::Parser->new;
            my $document = $parser->parse($blocks);

            my $formatter = Doc::Simply::Render::HTML->new;
            my $render = $formatter->render(document => $document);

            print $render;
       },
   )

}
