package Doc::Simply::Render::HTML::TT;

use strict;
use warnings;

sub build {
    return
        BLOCKS => {
            frame => <<_END_
[% INSERT assets/tt/frame.tt.html %]
_END_
        },
}

1;
