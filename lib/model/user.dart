class User {
  String displayName;
  String email;
  int uid;
  bool isAuthenticated;
  bool isAdmin;
  bool isFamily;

  User({
    required this.displayName,
    required this.email,
    required this.uid,
    required this.isAuthenticated,
    required this.isAdmin,
    required this.isFamily,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      uid: json['uid'] as int,
      isAuthenticated: json['isAuthenticated'] as bool,
      isAdmin: json['isAdmin'] as bool,
      isFamily: json['isFamily'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'isAdmin': isAdmin,
      'isFamily': isFamily,
    };
  }
}
