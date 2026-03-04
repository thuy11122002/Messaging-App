class Profile {
  String user_name, user_image, user_id;

  Profile(
      {required this.user_name,
      required this.user_image,
      required this.user_id});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
        user_name: json['user_name'],
        user_image: json['user_image'],
        user_id: json['id']);
  }
}
