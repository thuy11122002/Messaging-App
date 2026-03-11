class NotificationModel {
  String sender_id, receiver_id, date;
  bool accepted;
  NotificationModel(
      {required this.sender_id,
      required this.receiver_id,
      required this.date,
      required this.accepted});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        sender_id: json['sender_id'],
        receiver_id: json['receiver_id'],
        date: json['created_at'],
        accepted: json['accepted']);
  }
}
