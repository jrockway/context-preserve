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

    my $after = $args{after} || croak 'need an "after" coderef';
    
    if(!defined wantarray){
        $orig->();
        $after->();
        return;
    }
    elsif(wantarray){
        my @result = $orig->();
        my @ignored = $after->(@result);
        return @result;
    }
    else {
        my $result = $orig->();
        my $ignored = $after->($result);
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



=head1 EXPORT

=head2 preserve_context
