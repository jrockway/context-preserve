use strict;
use warnings;
use Test::More tests => 5;
use Context::Preserve;
my $after = 0;

is $after, 0;
is_deeply [foo()], [qw/an array/];
is $after, 1;
$after = 0;
is scalar foo(), 'scalar';
is $after, 1;

sub foo {
    return preserve_context {
        if(wantarray){ 
            return qw/an array/ 
        } 
        else { 
            return 'scalar' 
        }
    } after => sub { $after = 1 };
}
