package GeoIP2::Model::Omni;

use strict;
use warnings;

use GeoIP2::Types qw( HashRef object_isa_type );
use Sub::Quote qw( quote_sub );

use Moo;

with 'GeoIP2::Role::Model', 'GeoIP2::Role::Model::HasSubdivisions';

__PACKAGE__->_define_attributes_for_keys(
    qw( city continent country location registered_country represented_country traits )
);

1;

# ABSTRACT: Model class for the GeoIP2 Precision Omni end point

__END__

=head1 SYNOPSIS

  use 5.008;

  use GeoIP2::WebService::Client;

  my $client = GeoIP2::WebService::Client->new(
      user_id     => 42,
      license_key => 'abcdef123456',
  );

  my $omni = $client->city_isp_org( ip => '24.24.24.24' );

  my $city_rec = $omni->city();
  say $city_rec->name();

=head1 DESCRIPTION

This class provides a model for the data returned by the GeoIP2 Precision Omni
end point.

The only difference between the City, City/ISP/Org, and Omni model classes is
which fields in each record may be populated. See
http://dev.maxmind.com/geoip/geoip2/web-services for more details.

=head1 METHODS

This class provides the following methods, each of which returns a record
object.

=head2 $omni->city()

Returns a L<GeoIP2::Record::City> object representing country data for the
requested IP address.

=head2 $omni->continent()

Returns a L<GeoIP2::Record::Continent> object representing continent data for
the requested IP address.

=head2 $omni->country()

Returns a L<GeoIP2::Record::Country> object representing country data for the
requested IP address. This record represents the country where MaxMind
believes the IP is located in.

=head2 $omni->location()

Returns a L<GeoIP2::Record::Location> object representing country data for the
requested IP address.

=head2 $omni->registered_country()

Returns a L<GeoIP2::Record::Country> object representing the registered
country data for the requested IP address. This record represents the country
where the ISP has registered a given IP block in and may differ from the
user's country.

=head2 $omni->represented_country()

Returns a L<GeoIP2::Record::RepresentedCountry> object for the country
represented by the requested IP address. The represented country may differ
from the C<country> for things like military bases or embassies.

=head2 $omni->subdivisions()

Returns an array of L<GeoIP2::Record::Subdvision> objects representing the
country subdivisions for the requested IP address. The number and type of
subdivisions varies by country, but a subdivision is typically a state,
province, county, etc.

Some countries have multiple levels of subdivisions. For instance, the
subdivisions array for Oxford in the United Kingdom would have England as the
first element and Oxfordshire as the second element. The subdivisions array
for Minneapolis in the United States would have a single object for Minnesota.

If the response did not contain any subdivisions, this method returns an empty
list.

=head2 $omni->most_specific_subdivision()

Returns a single L<GeoIP2::Record::Subdivision> object representing the most
specific subdivision returned.

If the response did not contain any subdivisions, this method returns a
L<GeoIP2::Record::Subdivision> object with no values.

=head2 $omni->traits()

Returns a L<GeoIP2::Record::Traits> object representing the traits for the
request IP address.
