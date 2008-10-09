package Doc::Simply;

use warnings;
use strict;

=head1 NAME

Doc::Simply - Generate POD-like documentation from embedded comments in JavaScript, Java, C, C++ source

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    doc-simply < source.js > documentation.html

    doc-simply --help

=head1 DESCRIPTION

Doc::Simply is bundled with C<doc-simply>, a command-line application that transforms (special) comments into documentation

It is modeled after Plain Old Documentation but it is not an exact mimic

=head1 OVERVIEW

    * The input document is expected to have JavaScript, Java, C, C++-style comments: /* ... */ // ...
    * The output document is HTML
    * The markup style is POD-like, e.g. =head1, =head2, =body, ...
    * The formatting style is Markdown (instead of the usual C<>, L<>, ...)

=head1 Example JavaScript document

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

=head1 SEE ALSO

L<Text::Markdown>

L<http://daringfireball.net/projects/markdown/syntax>

=head1 SOURCE

You can contribute or fork this project via GitHub:

L<http://github.com/robertkrimen/doc-simply/tree/master>

    git clone git://github.com/robertkrimen/doc-simply.git Doc-Simply

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-doc-simply at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Doc-Simply>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Doc::Simply


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Doc-Simply>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Doc-Simply>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Doc-Simply>

=item * Search CPAN

L<http://search.cpan.org/dist/Doc-Simply>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Doc::Simply
