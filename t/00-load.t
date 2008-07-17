#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Doc::Simply' );
}

diag( "Testing Doc::Simply $Doc::Simply::VERSION, Perl $], $^X" );
