package Method::Traits::Trait;
# ABSTRACT: The Trait object

use strict;
use warnings;

our $VERSION   = '0.02';
our $AUTHORITY = 'cpan:STEVAN';

use Carp ();

use UNIVERSAL::Object;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        original => sub { die '`original` is required' },
        name     => sub { die '`name` is required' },
        args     => sub { +[] },
        handler  => sub {},
    )
}

sub BUILDARGS {
    my $class = shift;

    if ( scalar(@_) == 1 && not ref $_[0] ) {
        my $original = shift;

        # we are not terribly sophisticated, but
        # we accept `foo` calls (no-parens) and
        # we accept `foo(1, 2, 3)` calls (parens
        # with comma seperated args).

        # NOTE:
        # None of the args are eval-ed and they are
        # basically just a list of strings.

        if ( $original =~ m/([a-zA-Z_]*)\(\s*(.*)\s*\)/ms ) {
            #warn "parsed paren/args form for ($_)";
            return +{
                original => $original,
                name     => $1,
                args     => [
                    # NOTE:
                    # This parses arguments badly,
                    # it makes no attempt to enforce
                    # anything, just splits on the
                    # comma, both skinny and fat,
                    # then strips away any quotes
                    # and treats everything as a
                    # simple string.
                    map {
                        my $arg = $_;
                        $arg =~ s/^['"]//;
                        $arg =~ s/['"]$//;
                        $arg;
                    } split /\s*(?:\,|\=\>)\s*/ => $2
                ]
            };
        }
        elsif ( $original =~ m/^([a-zA-Z_]*)$/ ) {
            #warn "parsed no-parens form for ($_)";
            return +{
                original => $original,
                name     => $1,
            };
        }
        else {
            Carp::croak('Unable to parse trait (' . $original . ')');
        }

    } else {
        $class->SUPER::BUILDARGS( @_ );
    }
}

sub original { $_[0]->{original} }

sub name { $_[0]->{name} }
sub args { $_[0]->{args} }

sub handler {
    $_[0]->{handler} = $_[1] if defined $_[1];
    $_[0]->{handler}
}

1;

__END__

=pod

=head1 DESCRIPTION

This is just a simple object to parse and store the
trait invocation information.

=head1 METHODS

=head2 C<new( $attribute_string )>

=head2 C<original>

=head2 C<name>

=head2 C<args>

=head2 C<handler>

=cut
