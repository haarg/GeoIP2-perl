package GeoIP2::Role::Model;

use strict;
use warnings;

use GeoIP2::Record::City;
use GeoIP2::Record::Continent;
use GeoIP2::Record::Country;
use GeoIP2::Record::Location;
use GeoIP2::Record::RepresentedCountry;
use GeoIP2::Record::Traits;
use GeoIP2::Types qw( ArrayRef HashRef );
use Sub::Quote qw( quote_sub );

use Moo::Role;

with 'GeoIP2::Role::HasLanguages';

has raw => (
    is       => 'ro',
    isa      => HashRef,
    init_arg => 'raw',
    lazy     => 1,
    builder  => '_build_raw',
);

sub _define_attributes_for_keys {
    my $class = shift;
    my @keys  = @_;

    my $has = $class->can('has');

    for my $key (@keys) {
        my $record_class = __PACKAGE__->_record_class_for_key($key);

        my $raw_attr = '_raw_' . $key;

        $has->(
            $raw_attr => (
                is       => 'ro',
                isa      => HashRef,
                init_arg => $key,
                default  => quote_sub(q{ {} }),
            ),
        );

        $has->(
            $key => (
                is  => 'ro',
                isa => quote_sub(
                    sprintf(
                        q{ GeoIP2::Types::object_isa_type( $_[0], %s ) },
                        B::perlstring($record_class)
                    )
                ),
                init_arg => undef,
                lazy     => 1,
                default  => quote_sub(
                    sprintf(
                        q{ $_[0]->_build_record( %s, %s ) },
                        map { B::perlstring($_) } $key, $raw_attr
                    )
                )
            )
        );
    }
}

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;

    my $p = $self->$orig(@_);

    delete $p->{raw};

    # We make a copy to avoid a circular reference
    $p->{raw} = { %{$p} };

    return $p;
};

sub _build_record {
    my $self   = shift;
    my $key    = shift;
    my $method = shift;

    my $raw = $self->$method();

    return $self->_record_class_for_key($key)
        ->new( %{$raw}, languages => $self->languages() );
}

sub _record_class_for_key {
    my $self = shift;
    my $key  = shift;

    return 'GeoIP2::Record::Country' if $key eq 'registered_country';

    return 'GeoIP2::Record::RepresentedCountry'
        if $key eq 'represented_country';

    return 'GeoIP2::Record::' . ucfirst $key;
}

1;
