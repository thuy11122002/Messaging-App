class Message {
  String senderId, receiverId, text, image;
  Message(
      {required this.senderId,
      required this.receiverId,
      required this.text,
      required this.image});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        senderId: json['sender_id'],
        receiverId: json['receiver_id'],
        text: json['text'],
        image: json['image']);
  }
}
