class ServiceProvider {
  final String centerName;
  final String? description;
  final double? price;
  final String? location;
  final String? contactNumber;

  ServiceProvider({
    required this.centerName,
    this.description,
    this.price,
    this.location,
    this.contactNumber,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      centerName: json['centerName'] ?? '',
      description: json['description'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      location: json['location'],
      contactNumber: json['contactNumber'],
    );
  }
}
