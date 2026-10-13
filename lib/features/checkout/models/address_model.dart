class AddressModel {
  final int id;
  final String label; // e.g. "Home", "Office"
  final String recipientName;
  final String phoneNumber;
  final String streetAddress;
  final String city;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.city,
    this.isDefault = false,
  });

  // Clone address with updated default flag
  AddressModel copyWith({bool? isDefault}) {
    return AddressModel(
      id: id,
      label: label,
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      streetAddress: streetAddress,
      city: city,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
