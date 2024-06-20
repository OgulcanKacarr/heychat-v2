import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:heychat_2/utils/constants.dart';

class StorageService{
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  //Firestorage'e kapak fotoğrafı yükle ve linkini gönder
  Future<String> addCoverPhotoInStorage(File image) async {
    Reference _ref = _firebaseStorage.ref().child(Constants.fb_users).child(_auth.currentUser!.uid).child(Constants.fb_cover_photo);
    UploadTask task = _ref.putFile(image);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }
  //Profile fotoğrafını fb yükle
  Future<String> addUserProfilePhotoInStorage(File image) async {
    Reference _ref = _firebaseStorage.ref().child(Constants.fb_users).child(_auth.currentUser!.uid).child(Constants.fb_profile_photo);
    UploadTask task = _ref.putFile(image);
    TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  //Firestorage'den kapak fotoğrafını getir
  Future<String> getCoverPhotoInStorage(String cover_photo_url) async {
    Reference _ref = _firebaseStorage.refFromURL(cover_photo_url).child(Constants.fb_users).child(_auth.currentUser!.uid).child(Constants.fb_cover_photo);
    String download_url = await _ref.getDownloadURL();
    return download_url;
  }
  //Firestorage'den kapak fotoğrafını getir
  Future<String> getUserProfilePhotoInStorage(String cover_photo_url) async {
    Reference _ref = _firebaseStorage.refFromURL(cover_photo_url).child(Constants.fb_users).child(_auth.currentUser!.uid).child(Constants.fb_profile_photo);
    String download_url = await _ref.getDownloadURL();
    return download_url;
  }
}
