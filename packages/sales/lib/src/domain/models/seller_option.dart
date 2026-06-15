/// Staff member option for admin sales history filters.
class SellerOption {
  const SellerOption({
    required this.id,
    required this.displayName,
  });

  final String id;
  final String displayName;

  factory SellerOption.fromJson(Map<String, dynamic> json) {
    final creds = json['creds'] as String? ?? '';
    final id = json['id'] as String;

    return SellerOption(
      id: id,
      displayName: creds.isNotEmpty ? creds : id.substring(0, 8),
    );
  }
}
