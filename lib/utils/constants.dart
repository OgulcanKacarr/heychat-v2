import 'package:flutter/cupertino.dart';

class Constants {
  static const String appName = "Hey Chat";
  static const double padding = 16.0;
  static const double avatarRadius = 50.0;
  static const String email = "Email";
  static const String password = "Parola";
  static const String password_match = "Parola tekrar";
  static const String title_login = "Giriş yap";
  static const String or = "Ya da";
  static const String register = "Kayıt ol";
  static const String name_and_surname = "Ad soyad";
  static const String username = "Kullanıcı adı";
  static const String name_and_surname_not_empty = "Ad Soyad boş olamaz";
  static const String username_not_empty = "Kullanıcı adı boş olamaz";
  static const String not_use_space = "Kullanıcı adı boşluk içeremez";
  static const String email_is_not_empty = "Email boş olamaz";
  static const String password_is_not_empty = "Parola boş olamaz";
  static const String re_password_is_not_empty = "Parola tekrar boş olamaz";
  static const String enter_info = "Boş alanları doldurun";
  static const String not_match_password = "Parolalar eşleşmiyor";
  static const String reset_password = "Şifreni mi unuttun?";
  static const String already_email = "Böyle bir email zaten var";
  static const String invalid_email = "Hatalı email";
  static const String error = "Sistemden kaynaklı bir hata oluştu";
  static const String wrong_password = "Yanlış şifre";
  static const String wrong_info = "Bilgiler uyuşmuyor";
  static const String user_disabled = "Kullanıcı engellendi";
  static const String user_not_found = "Kullanıcı bulunamadı";
  static const String exit = "Çıkış yap";
  static const String chats = "Sohbetler";
  static const String feed = "Akış";
  static const String search = "Ara";
  static const String profile = "Profil";
  static const String update_info = " Bilgileri güncelle";
  static const String bio = "Bio";
  static const String bio_is_not_empty = "Bio boş olamaz";
  static const String update = "Güncelle";
  static const String update_succes = "Güncelleme başarılı";
  static const String empty_cover_photo = "Kapak fotoğrafı yok";
  static const String empty_profile_photo = "Profil fotoğrafı yok";
  static const String add_friend = "Arkadaş ekle";
  static const String accept_friend = "Kabul et";
  static const String cencel_friend = "İptal et";
  static const String remove_friend = "Çıkar";
  static const String send_friend_failed = "İstek gönderilmedi";
  static const String accept_friend_failed = "İstek kabul edilmedi";
  static const String post = "Posts";
  static const String add_post = "Post ekle";
  static const String add_post_succes = "Post başarıyla paylaşıldı";
  static const String select_photo = "Lütfen bir fotoğraf seçin.";
  static const String add_caption = "Açıklama ekle...";
  static const String send_message = "Mesaj gönder";
  static const String enter_message = "Mesajınızı girin..";
  static const String empty_chat = "Henüz sohbet etmediniz..";
  static const String last_chat = "Son konuşma: ";
  static const String be_register = "Kayıt olmayı deneyebilirsin";
  static const String empty_currentuser_post = "Henüz paylaşım yapmadın";
  static const String empty_currentuser_friend = "Henüz arkadaşın yok";
  static const String get_friends_request = "İstekler";
  static const String remove_post = "Post silindi";

  static const String empty_searchuser_post = "Gönderi yok";
  static const String empty_searchuser_friend = "Arkadaşları yok";


  static const String fb_users = "Users";
  static const String fb_cover_photo = "coverPhoto";
  static const String fb_profile_photo = "profilePhoto";
  static const String fb_friendRequests = "friendRequests";
  static const String fb_post = "Posts";
  static const String fb_messages = "Messages";
  static const String fb_chats = "Chats";


  static const String logo_path = "assets/images/logo.png";

  static double screenWith(BuildContext context){return MediaQuery.of(context).size.width;}
  static double screenHeight(BuildContext context){return MediaQuery.of(context).size.height;}


}