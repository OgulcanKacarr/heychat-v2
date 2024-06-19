class UserModel {
  //Bir kullanıcı oluşturulduğunda ve sonrasında kullanıcıda olması gerekenler

  /*
 uid: Kullanıcının benzersiz kimlik numarası (UID).
email: Kullanıcının e-posta adresi.
username: Kullanıcı adı.
displayName: Kullanıcının görüntülenen adı.
bio: Kullanıcının profilinde gösterilecek kısa biyografi.
profileImageUrl: Profil fotoğrafının URL'si.
coverImageUrl: Kapak fotoğrafının URL'si.
followers: Kullanıcıyı takip eden diğer kullanıcıların listesi.
following: Kullanıcının takip ettiği diğer kullanıcıların listesi.
friends: Kullanıcının arkadaşları.
friendRequests: Kullanıcının gönderdiği/aldığı arkadaşlık istekleri.
posts: Kullanıcının paylaştığı postların listesi.
 */

  String uid;
  String email;
  String username;
  String displayName;
  String bio;
  String profileImageUrl;
  String coverImageUrl;
  List<String> followers;
  List<String> following;
  List<String> friends;
  List<String> friendRequests;
  List<String> posts;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.profileImageUrl = '',
    this.coverImageUrl = '',
    this.followers = const [],
    this.following = const [],
    this.friends = const [],
    this.friendRequests = const [],
    this.posts = const [],
  });
}
