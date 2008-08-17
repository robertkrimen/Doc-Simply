package Doc::Simply::Render::HTML::TT;

use strict;
use warnings;

sub build {
    return
        BLOCKS => {
            frame => <<_END_
[% CLEAR -%]
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>[% title %]</title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
[% FOREACH item = css %]
[% item %]
[% END %]
</head>
<body>

<div id="doc">

[% content %]
    
</div>

[% FOREACH item = js %]
[% item %]
[% END %]

</body>
</html>

_END_
        },
}

1;
