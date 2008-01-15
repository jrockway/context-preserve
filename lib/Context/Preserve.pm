package Context::Preserve;
use strict;
use warnings;
use Carp;

use base 'Exporter';
our @EXPORT = qw(preserve_context);

our $VERSION = '0.01';

sub preserve_context(&@) {
    my $orig = shift;
    my %args = @_;

    my $replace = $args{replace};
    my $after   = $args{after};
    
    croak 'need an "after" or "replace" coderef'
      unless $replace || $after;
    
    if(!defined wantarray){
        $orig->();
        if($after){
            $after->();
        }
        else {
            $replace->();
        }
        return;
    }
    elsif(wantarray){
        my @result  = $orig->();
        if($after){
            my @ignored = $after->(@result);
        }
        else {
            @result = $replace->(@result);
        }
        return @result;
    }
    else {
        my $result  = $orig->();
        if($after){
            my $ignored = $after->($result);
        }
        else {
            $result = $replace->($result);
        }
        return $result;
    }
}

1;
__END__

=head1 NAME

Context::Preserve - run code after a subroutine call, preserving the context the subroutine would have seen if it were the last statement in the caller

=head1 SYNOPSIS

Have you ever written this?
  
    my ($result, @result);

    # run a sub in the correct context
    if(!defined wantarray){
        some::code();
    }
    elsif(wantarray){
        @result = some::code();
    }
    else {
        $result = some::code();
    }
  
    # do something after some::code
    $_ += 42 for (@result, $result);
  
    # finally return the correct value
    if(!defined wantarray){
        return;
    }
    elsif(wantarray){
        return @result;
    }
    else {
        return $result;
    }

Now you can just write this instead:

  use Context::Preserve;

  return preserve_context { some::code() }
             after => sub { $_ += 42 for @_ };

=head1 DESCRIPTION

Sometimes you need to call a function, get the results, act on the
results, then return the result of the function.  This is painful
because of contexts; the original function can behave different if
it's called in void, scalar, or list context.  You can ignore the
various cases and just pick one, but that's fragile.  To do things
right, you need to see which case you're being called in, and then
call the function in that context.  This results in 3 code paths,
which is a pain to type in (and maintain).

This module automates the process.  You provide a coderef that is the
"original function", and another coderef to run after the original
runs.  You can modify the return value (aliased to @_) here, and do
whatever else you need to do.  C<wantarray> is correct inside both
coderefs; in "after", though, the return value is ignored and the
value C<wantarray> returns is related to the context that the original
function was called in.

=head1 EXPORT

=head2 preserve_context

=head1 FUNCTIONS

=head2 preserve_context { original } [after|replace] => sub { after }

Invokes C<original> in the same context as C<preserve_context> was
called in, save the results, run C<after> in the same context, then
return the result of C<original>.  C<after>'s return value is ignored,
but C<wantarray> will be correct inside it, and the results of
C<original> will be available in C<@_> (and can be modified before
return).

Run C<preserve_context> like this:

  sub whatever {
      ...
      return preserve_context { orginal_function()     }
                 after => sub { modify(@_) or whatever };

Note that there's no comma between the first block and the C<< after
=> >> part.  This is how perl parses functions with the C<(&@)>
prototype.  The alternative is to say:

      preserve_context(sub { original }, after => sub { after }); 

You can do whatever, but the first version is much prettier.

=head1 AUTHOR AND COPYRIGHT

Jonathan Rockway C<< <jrockway@cpan.org> >>

Copyright (c) 2008 Infinity Interactive.  You may redistribute this
module under the same terms as Perl itself.


