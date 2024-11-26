class ServiceProvider {
  final String centerName;
  final String centerId;
  final String? description;
  final double? price;
  final String? location;
  final String? phoneNumber;

  ServiceProvider({
    required this.centerName,
    required this.centerId,
    this.description,
    this.price,
    this.location,
    this.phoneNumber,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      centerName: json['centerName'] ?? '',
      description: json['description'],
      centerId: json['centerId'] ?? '',
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      location: json['location'],
      phoneNumber: json['contactNumber'],
    );
  }
}
