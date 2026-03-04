class ItemChatModel {
  String avatar, name, last_text, last_time;
  int unread_count;
  ItemChatModel(
      {required this.avatar,
      required this.name,
      required this.last_text,
      required this.last_time,
      required this.unread_count});

  factory ItemChatModel.fromJson(Map<String, dynamic> json) {
    return ItemChatModel(
        avatar: json['avatar'],
        name: json['name'],
        last_text: json['last_text'],
        last_time: json['last_time'],
        unread_count: json['unread_count']);
  }
}
