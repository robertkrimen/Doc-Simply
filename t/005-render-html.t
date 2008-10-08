use strict;
use warnings;

use Test::Most;
#use XXX;

use Doc::Simply;
use Doc::Simply::Extractor;
use Doc::Simply::Assembler;
use Doc::Simply::Parser;
use Doc::Simply::Render::HTML;

plan qw/no_plan/;

my $source = <<'_END_';
/* 
 * @head2 Icky nesting
 * Some content
 *
 * @head1 Hello, World.
 *
 * @head2 Yikes. 
 * Some more content
 * With some *markdown* content!
 *
 *      And some more
 *      And some inline code
 *
 */

/* Ignore this...
*/

/* @body 
 * ...but grab **this**!
        */
_END_

my $extractor = Doc::Simply::Extractor::SlashStar->new;
my $comments = $extractor->extract($source);

my $assembler = Doc::Simply::Assembler->new;
my $blocks = $assembler->assemble($comments);

my $parser = Doc::Simply::Parser->new;
my $document = $parser->parse($blocks);

my $formatter = Doc::Simply::Render::HTML->new;
my $render = $formatter->render(document => $document);

like($render, qr/reset-fonts-grids\.css/);
like($render, qr/base\/base\.css/);
unlike($render, qr/Ignore this/);
like($render, qr/\.\.\.but grab <strong>this<\/strong>!/);
like($render, qr{<li class="index-head2"><a href="#Icky nesting">Icky nesting</a></li>});
like($render, qr{<h2 class="content-head2 content-head"><a name="Icky nesting"></a>Icky nesting</h2>});

__END__
 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
 <html xmlns="http://www.w3.org/1999/xhtml">
 <head>
 <title></title>
 <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
 
 <link rel="stylesheet" href="http://yui.yahooapis.com/2.5.1/build/reset-fonts-grids/reset-fonts-grids.css" type="text/css"/>
 
 <link rel="stylesheet" href="http://yui.yahooapis.com/2.5.1/build/base/base.css" type="text/css"/>
 
 <style type="text/css">body {
     font-size: 116%;
     background: #eee;
 }
 
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
 /*    border-bottom: 2px solid #ccc;*/
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
 
 
 .dcmt-document {
     border: 3px solid #ccc;
     border-top: none;
     border-bottom: none;
     background: #fff;
 }
 
 .dcmt-content {
 /*    border-left: 2px solid #aaa;*/
 }
 
 </style>
 
 </head>
 <body>
 
 <div id="doc2">
 
 <div class="dcmt-document">
     
 
         <div class="bd">
     
 
 <div class="dcmt-content">
     
         <ul class="index">
         
             <li class="index-head2"><a href="#Icky nesting">Icky nesting</a></li>
         
             <li class="index-head1"><a href="#Hello, World.">Hello, World.</a></li>
         
             <li class="index-head2"><a href="#Yikes.">Yikes.</a></li>
         
         </ul>
     
 
     <h2 class="content-head2 content-head"><a name="Icky nesting"></a>Icky nesting</h2>
 
 <p>Some content</p>
 
 <h1 class="content-head1 content-head"><a name="Hello, World."></a>Hello, World.</h1>
 
 <h2 class="content-head2 content-head"><a name="Yikes."></a>Yikes.</h2>
 
 <p>Some more content
 With some <em>markdown</em> content!</p>
 
 <pre><code> And some more
  And some inline code
 </code></pre>
 
 <p>...but grab <strong>this</strong>!</p>
 
 </div>
 
 
         </div>
         
     </div>
 </div>
 
 
 
 </body>
 </html>
 
 
 
