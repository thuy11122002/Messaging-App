class Message {
  String sender_id, receiver_id, text;
  Message(
      {required this.sender_id, required this.receiver_id, required this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender_id: json['sender_id'],
      receiver_id: json['receiver_id'],
      text: json['text'],
    );
  }
}
