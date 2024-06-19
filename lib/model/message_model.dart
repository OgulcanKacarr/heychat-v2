class MessageModel {
  /*
messageId: Mesajın benzersiz kimlik numarası.
senderId: Mesajı gönderen kullanıcının UID'si.
receiverId: Mesajı alan kullanıcının UID'si.
content: Mesaj içeriği.
timestamp: Mesajın gönderilme zamanı
 */

  String messageId;
  String senderId;
  String receiverId;
  String content;
  DateTime timestamp;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });
}
