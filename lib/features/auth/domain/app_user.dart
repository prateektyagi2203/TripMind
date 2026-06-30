/// Authenticated user (dev login now; Google sign-in later).
class AppUser {
  final String id;
  final String email;
  final String name;
  final String photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl = '',
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    name: json['name'] as String? ?? '',
    photoUrl: json['photo_url'] as String? ?? '',
  );
}
