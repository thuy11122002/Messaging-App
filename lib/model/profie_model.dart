class Profile {
  String userName, userImage, userId;

  Profile(
      {required this.userName, required this.userImage, required this.userId});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
        userName: json['user_name'],
        userImage: json['user_image'],
        userId: json['id']);
  }
}
