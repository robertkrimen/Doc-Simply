use inc::Module::Install;

name 'Doc-Simply';
all_from 'lib/Doc/Simply.pm';

{
    require ExtUtils::MakeMaker;
    use strict;
    no strict 'refs';

    my $libscan = \&{"ExtUtils::MM_Any::libscan"};
    *{"ExtUtils::MM_Any::libscan"} = sub {
        return '' unless $libscan->(@_);
        return '' if $_[1] =~ /\.sw[p-z]$/;
        return $_[1];
    };
}

{
    map { my ($pk, $vr) = split m/\s/; build_requires $pk => $vr || 0 } grep { ! /^\s*#/ } split m/\n/, <<_END_;
Test::Most
_END_

    map { my ($pk, $vr) = split m/\s/; requires $pk => $vr || 0 } grep { ! /^\s*#/ } split m/\n/, <<_END_;
Carp::Clan::Share
Getopt::Chain
HTML::Declare
JS::YUI::Loader
Moose
Parse::Yapp::Driver
String::Comments::Extract
Template
Text::FixEOL
Text::MultiMarkdown
Tree::DAG_Node
_END_
}

install_script glob('script/doc-simply');

auto_install;

WriteAll;

