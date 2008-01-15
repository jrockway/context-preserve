use inc::Module::Install;

name 'Context-Preserve';
all_from 'lib/Context/Preserve.pm';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
