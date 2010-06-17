package Doc::Simply::App;

use Any::Moose;
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

sub usage {
    print <<_END_;
Usage: $0 [OPTION] < [INFILE] > [OUTFILE]

Parse INFILE (stdin), which can be a .js, .java, .c, .cpp file and write to OUTFILE (stdout), an HTML document

Where OPTION can be:

    -h, --help      Show this help
_END_
    print <<'_END_';

Here is an example Doc::Simply-compatible JavaScript document:

    /* 
     * @head1 NAME
     *
     * Calculator - Add 2 + 2 and return the result
     *
     */

    // @head1 DESCRIPTION
    // @body Add 2 + 2 and return the result (which should be 4)

    /*
     * @head1 FUNCTIONS
     *
     * @head2 twoPlusTwo
     *
     * Add 2 and 2 and return 4
     *
     */

    function twoPlusTwo() {
        return 2 + 2; // Should return 4
    }

_END_
}

sub run {
    my $self = shift;

    Getopt::Chain->process(

        options => [qw/
            type:s
            style:s
            css-file:s css-link:s css:s
            js-file:s js-link:s js:s
            wrapper-file:s
            help|h
        /],

        run => sub {
            my $context = shift;

            if ($context->options->{help}) {
                usage;
                return;
            }

#            if ($context->arguments->[0]) {
#                return;
#            }

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

        commands => {

            help => sub {
                my $context = shift;
                usage;
            },

        },
   )

}
