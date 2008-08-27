package Doc::Simply::Render::HTML::TT;

use strict;
use warnings;

sub build {
    return
        BLOCKS => {
            frame => <<_END_,
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

<div id="doc2">

[% IF document.appendix.title %]
<div class="hd">
    <span class="name">[% document.appendix.name %]</span> <span class="subtitle">[% document.appendix.subtitle %]</span>
</div>
[% END %]

    <div class="bd">
[% content %]
    </div>
    
</div>

[% FOREACH item = js %]
[% item %]
[% END %]

</body>
</html>

_END_
            document => <<_END_,
[% WRAPPER frame title = document.appendix.title %]

[% IF index %]
    <ul class="index">
    [% FOREACH node = index %]
        <li class="index-[% node.tag %]"><a href="#[% node.content %]">[% node.content %]</a></li>
    [% END %]
    </ul>
[% END %]

[% content %]

[% END %]

_END_
        },
}

sub css_standard {
    return <<_END_;
a {
    color: #069;
}

.index a {
    text-decoration: none;
}

.index a:hover {
    text-decoration: underline;
}

ul.index {
    margin-left: 0;
}

.index li {
    list-style-type: none;
}

.index li.index-head1 {
    margin-left: 0;
    font-weight: 700;
}

.index li.index-head2 {
    margin-left: 1em;
}

.index li.index-head3 {
    margin-left: 2em;
}

.index li.index-head4 {
    margin-left: 3em;
}

h1.content-head {
    text-decoration: underline;
}

.content-head {
    color: #333;
}

pre {
    border: 1px solid #888;
    background: #eee;
    padding: 1em;
    font-family: monospace;
    line-height: 100%;
}

.hd {
    background: #def;
    border-bottom: 2px solid #ccc;
    padding: 0.25em 1em;
    text-align: left;
    color: #555;
    font-size: 131%;
}

.bd {
    padding: 0 1em;
}

.name {
    font-weight: 700;
}

.subtitle {
    font-size: 85%;
}


_END_
}


1;
