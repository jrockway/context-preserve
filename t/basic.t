use strict;
use warnings;
use Test::More tests => 9;
use Context::Preserve;
my $after = 0;

is $after, 0;
is_deeply [foo()], [qw/an array/];
is $after, 1;
$after = 0;
is scalar foo(), 'scalar';
is $after, 1;

is_deeply [bar()], [qw/an42 array42/];
is scalar bar(), 'scalar42';

is_deeply [baz()], [qw/anARRAY arrayARRAY/];
is scalar baz(), 'scalarSCALAR';


sub code {
    if(wantarray){ 
        return qw/an array/ 
    } 
    else { 
        return 'scalar' 
    }
};

sub foo {
    return preserve_context {
        return code();
    } after => sub { $after = 1 };
}

sub bar {
    return preserve_context {
        return code();
    } after => sub { $_ .= "42" for @_ };
}

sub baz {
    return preserve_context {
        return code();
    } after => sub { 
        my $wa = wantarray ? "ARRAY" : "SCALAR";
        $_ .= "$wa" for @_ 
    };
    
}
