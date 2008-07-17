use inc::Module::Install;

name 'Doc-Simply';
all_from 'lib/Doc/Simply.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

