import 'package:ba3_bs_mobile/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;
import '../../../features/customer/data/models/customer_model.dart';

/// A class responsible for exporting customer data into XML format.
class CustomersExport {
  /// Exports a list of CustomerModel objects as an XML element.
  ///
  /// This method creates an XML element with the tag 'Customers'. It begins by adding a child
  /// element 'CustomersCount' that represents the total number of customers (formatted with two decimals).
  /// Then, it maps each customer to its corresponding XML element by calling [_buildCustomerElement].
  ///
  /// Parameters:
  /// - [customers]: A list of CustomerModel objects to be exported.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the exported customers.
  xml.XmlElement exportCustomers(List<CustomerModel> customers) {
    final customerElements = <xml.XmlNode>[
      // Create an XML element to display the count of customers.
      xml.XmlElement(
        xml.XmlName('CustomersCount'),
        [],
        [xml.XmlText(customers.length.toStringAsFixed(2))],
      ),
      // Converts each CustomerModel to its XML representation.
      ...customers.map((c) => _buildCustomerElement(c)),
    ];

    // Returns the root 'Customers' XML element containing all customer elements.
    return xml.XmlElement(xml.XmlName('Customers'), [], customerElements);
  }

  /// Builds an XML element for a single customer.
  ///
  /// This helper method converts a [CustomerModel] object into an XML element with the tag 'Cu'.
  /// It utilizes [XmlHelpers.element] to create XML child elements for each property of the customer.
  ///
  /// Parameters:
  /// - [customer]: An instance of CustomerModel containing customer data.
  ///
  /// Returns:
  /// - An [xml.XmlElement] representing the customer.
  xml.XmlElement _buildCustomerElement(CustomerModel customer) {
    return xml.XmlElement(
      xml.XmlName('Cu'),
      [],
      [
        XmlHelpers.element('cptr', customer.id),
        XmlHelpers.element('CustName', customer.name),
        XmlHelpers.element('CustLatinName', customer.latinName),
        XmlHelpers.element('CustPrefix', customer.prefix),
        XmlHelpers.element('CustNation', customer.nation),
        XmlHelpers.element('phone1', customer.phone1),
        XmlHelpers.element('phone2', customer.phone2),
        XmlHelpers.element('Fax', customer.fax),
        XmlHelpers.element('Telex', customer.telex),
        XmlHelpers.element('Note', customer.note),
        XmlHelpers.element('AcGuid', customer.accountGuid),
        // Converts the customer's check date to ISO8601 format.
        XmlHelpers.element('CustCheckDate', customer.checkDate?.toIso8601String()),
        XmlHelpers.element('Security', customer.security?.toString()),
        XmlHelpers.element('CustType', customer.type?.toString()),
        XmlHelpers.element('DiscountRatio', customer.discountRatio?.toString()),
        XmlHelpers.element('DefaultPrice', customer.defaultPrice?.toString()),
        XmlHelpers.element('CustState', customer.state?.toString()),
        XmlHelpers.element('CustEmail', customer.email),
        XmlHelpers.element('CustHomePage', customer.homePage),
        XmlHelpers.element('CustSuffix', customer.suffix),
        XmlHelpers.element('CustMobile', customer.mobile),
        XmlHelpers.element('CustPager', customer.pager),
        XmlHelpers.element('CustHoppies', customer.hobbies),
        XmlHelpers.element('CustGender', customer.gender),
        XmlHelpers.element('CustCertificate', customer.certificate),
        // Uses a default GUID if the customer's defaultAddressGuid is null.
        XmlHelpers.element('CustDefaultAddressGuid', customer.defaultAddressGuid ?? '00000000-0000-0000-0000-000000000000'),
      ],
    );
  }
}