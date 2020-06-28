import 'package:country_code/country_code.dart';

class AltruAddress {
  final String line1;
  final String line2;
  final String city;
  final String state;
  final CountryCode country;
  final String zip;

  AltruAddress({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.country,
    this.zip,
  });
}

class AltruUser {
  final String firstName;
  final String lastName;
  final AltruAddress address;
  final String email;

  AltruUser({this.firstName, this.lastName, this.address, this.email});
}
