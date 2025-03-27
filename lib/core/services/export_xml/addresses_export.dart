import 'package:xml/xml.dart' as xml;

/// A class for exporting address-related data into an XML structure using an XmlBuilder.
class AddressesExport {
  /// Builds the XML structure for various address sections.
  ///
  /// This method uses the provided [xml.XmlBuilder] to construct XML elements for:
  /// - AddressCountries: including a count element and a default country element.
  /// - AddressCities: including a count element and a default city element.
  /// - AddressAreas: including a count element and a default area element.
  /// - CustomerAddresses: including a count element and a list of customer address elements.
  ///
  /// Each section is built using nested XML elements to represent the hierarchical structure.
  ///
  /// Parameters:
  /// - [builder]: An instance of [xml.XmlBuilder] used to create the XML elements.
  void buildAddresses(xml.XmlBuilder builder) {
    // Build the AddressCountries section.
    builder.element('AddressCountries', nest: () {
      // Add the count of address countries.
      builder.element('AddressCountriesCount', nest: '1.00');
      // Add a default country element.
      builder.element('Country', nest: () {
        builder.element('CountryNumber', nest: '1');
        builder.element('CountryGUID', nest: '86018e26-0115-4155-ba4e-e15c89cc8a85');
        builder.element('CountryCode', nest: '01');
        builder.element('CountryName', nest: 'الافتراضي');
        builder.element('CountryLatinName', nest: 'Default');
      });
    });

    // Build the AddressCities section.
    builder.element('AddressCities', nest: () {
      // Add the count of address cities.
      builder.element('AddressCitiesCount', nest: '1.00');
      // Add a default city element.
      builder.element('City', nest: () {
        builder.element('CityNumber', nest: '1');
        builder.element('CityGUID', nest: 'e30ecd86-6601-4631-a22e-61440b464da2');
        builder.element('CityCode', nest: '0101');
        builder.element('CityName', nest: 'الافتراضي');
        builder.element('CityLatinName', nest: 'Default');
        builder.element('CityParentGUID', nest: '86018e26-0115-4155-ba4e-e15c89cc8a85');
      });
    });

    // Build the AddressAreas section.
    builder.element('AddressAreas', nest: () {
      // Add the count of address areas.
      builder.element('AddressAreasCount', nest: '1.00');
      // Add a default area element.
      builder.element('Area', nest: () {
        builder.element('AreaNumber', nest: '1');
        builder.element('AreaGUID', nest: '65c1994c-f1f7-426b-b5a7-544920ba4636');
        builder.element('AreaCode', nest: '0101001');
        builder.element('AreaName', nest: 'الافتراضي');
        builder.element('AreaLatinName', nest: 'Default');
        builder.element('AreaParentGUID', nest: 'e30ecd86-6601-4631-a22e-61440b464da2');
      });
    });

    // Build the CustomerAddresses section.
    builder.element('CustomerAddresses', nest: () {
      // Add the count of customer addresses.
      builder.element('CustomerAddressesCount', nest: '19.00');

      // List of addresses data, each containing:
      // [AddressNumber, AddressGUID, AddressCustomerGUID, AddressZipCode]
      final addresses = [
        ['1', 'f4541b3d-fa00-4401-be82-0a4909038f4e', '0413653a-d684-4a6c-953a-8492bc117d9f', '100352445900003'],
        ['1', '9622842f-ef14-4ed6-aca3-280650b8e4e5', 'fb22fc10-7675-4d2f-b9ea-a2b56f3a5e06', '100066830900003'],
        ['1', 'ca165ee8-f6a9-4a4e-a5b3-3067f5948a4a', '6fa8cf0b-2c96-420f-ba3a-e4c60bf47100', '100202405500003'],
        ['1', 'b8ab6bc4-7e44-4de3-8f0e-5136517f70e5', 'e259dfd5-29a4-4a75-b0c8-f73904706837', '100426230700003'],
        ['1', '0ff32159-689c-41aa-902e-62904887d3af', 'ddecad39-7c26-433c-a6a8-6251339d1e75', '100330177500003'],
        ['1', '5ac8c43c-2fd6-4396-b02b-6b9e33d05ee7', '1472adc8-933e-45c3-adf8-7c33c7f4bed0', '100223928100003'],
        ['1', 'ff1e0b61-9226-4709-b030-73837e0ad445', 'ffac476c-aeb8-42c8-b6c5-81755faf97d3', '100336950900003'],
        ['1', '4dec8849-71ee-4352-845e-8236bd795537', '010e8407-a3df-4270-84e8-5cff1901bf9a', '100367994900003'],
        ['1', 'e23e02af-6335-4a1f-a118-8e7a967675a7', '58964fc5-ef40-409f-a2ff-a3225914dfc4', '100030794000003'],
        ['1', 'e1876e5c-ca21-4524-bc48-9294f05c278d', '4cdb828e-8f97-400b-9fb2-5ec62bed8eb2', '100369311400003'],
        ['1', 'cad3146a-ae0f-43e3-97af-97a503e0aa0a', '607a9f82-4b69-4e28-bc99-accfb0074371', '100046183800003'],
        ['1', '4351356d-66e1-46df-be6e-af5fef09cd7d', '45d24d87-35fd-4711-8207-d122ab3a1cba', '100341788600003'],
        ['1', 'f4dc29dd-8e3f-45a7-ae13-b1177996640e', '13091b1f-e9e4-404f-85ea-6cd849660c8c', '100620377000003'],
        ['1', '419e7c5f-43f8-4a17-9956-b3359260e0a3', 'd93437f5-86c1-4a13-b758-478b5f8cff0b', '100020757900003'],
        ['1', 'dd8685c8-29fc-40de-9cb6-bca96462898b', 'ae4209a0-fc21-4d1b-9d8a-dfc66078efeb', '100015477100003'],
        ['1', 'f56489d0-c988-42f9-a24f-d5f971359349', 'c4196020-f421-4c60-8e90-aef67de1368a', '100369311406003'],
        ['1', '76d8854a-4706-4c7f-acbc-e3940e4b4868', 'ee956298-77e3-4f68-95cc-d878084e5361', '100392590400003'],
        ['1', '226dc679-8952-412f-9fe8-e6366b812e15', 'e6832c29-4fda-4aa8-baa0-00ebd998bf73', '100046183800003'],
        ['1', 'b5701a02-d7a6-444b-bfb8-f9344ad6e66c', '8e57f3a7-d876-4a80-afcd-0ab4c584c6d1', '100073621300003'],
      ];

      // Iterate over the list of addresses and build an XML element for each address.
      for (var adder in addresses) {
        builder.element('Address', nest: () {
          builder.element('AddressNumber', nest: adder[0]);
          builder.element('AddressGUID', nest: adder[1]);
          // Set the default name for the address.
          builder.element('AddressName', nest: 'الرئيسي');
          builder.element('AddressLatinName', nest: 'Head Address');
          builder.element('AddressCustomerGUID', nest: adder[2]);
          // Use a default area GUID for all addresses.
          builder.element('AddressAreaGUID', nest: '65c1994c-f1f7-426b-b5a7-544920ba4636');
          // The following fields are set to null, indicating no data is provided.
          builder.element('AddressStreet', nest: null);
          builder.element('AddressBuildingNumber', nest: null);
          builder.element('AddressFloorNumber', nest: null);
          builder.element('AddressMoreDetails', nest: null);
          builder.element('AddressPOBox', nest: null);
          builder.element('AddressZipCode', nest: adder[3]);
          // Set default GPS coordinates.
          builder.element('AddressGPSX', nest: '0.00');
          builder.element('AddressGPSY', nest: '0.00');
          builder.element('AddressGPSZ', nest: '0.00');
        });
      }
    });
  }
}