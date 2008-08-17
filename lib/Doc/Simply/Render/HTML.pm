package Doc::Simply::Render::HTML;

use Moose;
use Doc::Simply::Carp;

use Doc::Simply::Render::HTML::TT;

use Text::MultiMarkdown qw/markdown/;
use Template;
use JS::YUI::Loader;
use HTML::Declare qw/LINK SCRIPT/;

has tt => qw/is ro lazy_build 1 isa Template/;
sub _build_tt {
    my $self = shift;
    my $method = "build_tt";
    croak "Don't have method \"$method\"" unless my $build = $self->can($method);
    my $got = $build->($self, @_);

    return $got if blessed $got && $got->isa("Template");
    return Template->new($got) if ref $got eq "HASH";
    return Template->new unless $got;

    croak "Don't know how to build Template with $got";
}

sub build_tt {
    return {
        Doc::Simply::Render::HTML::TT->build,
    };
}

sub process_tt {
    my $self = shift;
    my %given = @_;

    my ($input, $output, $context, @process);

    {
        $input = $given{input};
        croak "Wasn't given input" unless defined $input;
    }

    {
        $output = $given{output};
        my $output_content;
        $output = \$output_content unless exists $given{output};

        if (blessed $output) {
            if ($output->isa("Path::Resource")) {
                $output = $output->file;
            }
            if ($output->isa("Path::Class::File")) {
                $output = "$output";
            }
        }

        if (defined $output && ! ref $output) {
            $output = Path::Class::File->new($output);
            $output->parent->mkpath unless -d $output->parent;
            $output = "$output";
        }
    }

    {
        $context = $given{context} || {};
    }

    if ($given{process}) {
        @process = @{ $given{process} };
    }
    else {
        @process = qw/binmode :utf8/;
    }

    my $tt = $self->tt;
    $tt->process($input, $context, $output, @process) or croak "Couldn't process $input => $output: ", $tt->error;

    return $$output unless exists $given{output};

    return $output if ref $output eq "SCALAR";
}

sub css_render {
    my $self = shift;
    my $given = shift;

    croak "Don't understand $given" unless ref $given eq "HASH";

    my $value;
    if ($value = $given->{link}) {
        return LINK { rel => 'stylesheet', type => 'text/css', href => $value };
    }
    else {
        croak "Don't understand \"@{[ %$given ]}\"";
    }
}

sub js_render {
    my $self = shift;
    my $given = shift;

    croak "Don't understand $given" unless ref $given eq "HASH";

    my $value;
    if ($value = $given->{link}) {
        return SCRIPT { type => 'text/jascript', src => $value, content => [] };
    }
    else {
        croak "Don't understand \"@{[ %$given ]}\"";
    }
}

sub render {
    my $self = shift;
    my %given = @_;

    my $document = $given{document} or croak "Wasn't given document to format";

    my ($content, @css, @js);

    {
        $content = "";
        $document->walk_down({ callback => sub {
            my $node = shift;
            $content .= $self->_format_tag($node->tag, $node->content);
            return 1;
        } });
        $content = markdown $content, { heading_ids => 0 };
    }

    my $style = lc ($given{style} || "standard");

    my $yui = JS::YUI::Loader->new_from_yui_host;
    if ($style eq "standard") {
        push @css, $self->css_render({ link =>  $yui->uri('reset-fonts-grids') });
        push @css, $self->css_render({ link =>  $yui->uri('base') });
    }
    elsif ($style eq "base") {
        push @css, $self->css_render({ link =>  $yui->uri('reset-fonts-grids') });
        push @css, $self->css_render({ link =>  $yui->uri('base') });
    }
    elsif ($style eq "reset") {
        push @css, $self->css_render({ link =>  $yui->uri('reset') });
    }
    else {
        croak "Don't understand style \"$style\"";
    }

    {
        my $css = $given{css} || [];
        for (@$css) {
            push @css, $self->css_render($_);
        }
    }

    {
        my $css = $given{js} || [];
        for (@$css) {
            push @css, $self->js_render($_);
        }
    }

    $self->process_tt(input => \<<_END_, context => { content => $content, css => \@css, js => \@js });
[% WRAPPER frame %]
[% content %]
[% END %]
_END_
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
