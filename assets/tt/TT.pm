package Doc::Simply::Render::HTML::TT;

use strict;
use warnings;

sub build {
    return
        BLOCKS => {
            frame => <<_END_,
[% INSERT assets/tt/frame.tt.html -%]
_END_
            document => <<_END_,
[% INSERT assets/tt/document.tt.html -%]
_END_
        },
}

sub css_standard {
    return <<_END_;
[% INSERT assets/css/standard.css -%]
_END_
}


1;
