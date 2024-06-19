class PostModel {
  //bir kullanıcı post paylaştığında o post'da olacak özellikler

/*
  postId: Postun benzersiz kimlik numarası.
  userId: Postu paylaşan kullanıcının UID'si.
  imageUrl: Posta ait görselin URL'si.
  caption: Postun açıklaması.
  likes: Postu beğenen kullanıcıların listesi.
  comments: Posta yapılan yorumların listesi.
 */

  String postId;
  String userId;
  String imageUrl;
  String caption;
  List<String> likes;
  List<String> comments;

  PostModel({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    this.caption = '',
    this.likes = const [],
    this.comments = const [],
  });

}