package # hide from PAUSE
    DAO::Trait::Provider;
use strict;
use warnings;

use Method::Traits ':for_providers';

sub FindOne : OverwritesMethod {
    my ($meta, $method_name, $SQL, %opts) = @_;

    my $num_params =()= $SQL =~ /\?/;

    my $arg_types   = $opts{accepts} // [];
    my $return_type = $opts{returns};
    my $attributes  = $opts{attrs} // {};

    $meta->add_method( $method_name => sub {
        my ($dao, @params) = @_;

        die "Expected $num_params but only got " . scalar(@_)
            unless scalar(@_) == $num_params;

        if ( $arg_types ) {
            foreach my $i ( 0 .. $num_params ) {
                $dao->validate( $params[ $i ], $arg_types->[ $i ] );
            }
        }

        my @row = $dao->dbh->selectrow_array( $SQL, $attributes, @params );
        return @row unless $return_type;

        my $val = $dao->build_return_value( \@row, $return_type );
        $dao->validate( $val, $return_type );
        return $val;
    });
}

sub FindMany : OverwritesMethod {
    my ($meta, $method_name, $SQL, %opts) = @_;

    my $num_params =()= $SQL =~ /\?/;

    my $arg_types   = $opts{accepts} // [];
    my $return_type = $opts{returns};
    my $attributes  = $opts{attrs} // {};

    $meta->add_method( $method_name => sub {
        my ($dao, @params) = @_;

        die "Expected $num_params but only got " . scalar(@_)
            unless scalar(@_) == $num_params;

        if ( $arg_types ) {
            foreach my $i ( 0 .. $num_params ) {
                $dao->validate( $params[ $i ], $arg_types->[ $i ] );
            }
        }

        my @rows = $dao->dbh->selectall_array( $SQL, $attributes, @params );
        return @rows if $return_type;

        my @vals = $dao->build_return_values( \@rows, $return_type );
        $dao->validate( \@vals, $return_type );
        return @vals;
    });
}

1;
