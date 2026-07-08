class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.district,
    this.phone = '',
    this.skill = '',
    this.role = 'user',
  });

  final String uid;
  final String email;
  final String name;
  final String district;
  final String phone;
  final String skill;
  final String role;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: '${json['firebase_uid'] ?? json['uid'] ?? ''}',
      email: '${json['email'] ?? ''}',
      name: '${json['name'] ?? ''}',
      district: '${json['district'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      skill: '${json['skill'] ?? ''}',
      role: '${json['role'] ?? 'user'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': uid,
      'email': email,
      'name': name,
      'district': district,
      'phone': phone,
      'skill': skill,
      'role': role,
    };
  }
}
