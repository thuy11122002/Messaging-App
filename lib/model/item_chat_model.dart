class ItemChatModel {
  String avatar, name, lastText, lastTime;
  int unreadCount;
  ItemChatModel(
      {required this.avatar,
      required this.name,
      required this.lastText,
      required this.lastTime,
      required this.unreadCount});

  factory ItemChatModel.fromJson(Map<String, dynamic> json) {
    return ItemChatModel(
        avatar: json['avatar'],
        name: json['name'],
        lastText: json['last_text'],
        lastTime: json['last_time'],
        unreadCount: json['unread_count']);
  }
}
