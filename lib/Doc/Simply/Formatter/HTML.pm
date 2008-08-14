package Doc::Simply::Formatter::HTML;

use Moose;
use Doc::Simply::Carp;

use Text::MultiMarkdown qw/markdown/;

sub format {
    my $self = shift;
    my %given = @_;

    my $document = $given{document} or croak "Wasn't given document to format";

    my $content = "";
    $document->walk_down({ callback => sub {
        my $node = shift;
        $content .= $self->_format_tag($node->tag, $node->content);
        return 1;
    } });
    return markdown $content, { heading_ids => 0 };
}

sub _format_tag {
    my $self = shift;
    my $tag = shift;
    my $content = shift;

    if ($tag =~ m/^head(\d)/) {
        return "#" x $1 . "$content\n";
    }

    return $content;
}

#my $content = $document->content_from;
#warn markdown $content;

1;
