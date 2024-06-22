import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heychat_2/model/post_model.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/services/storage_service.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class SettingsPageViewmodel extends ChangeNotifier{

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth =FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic> data = {};
  StorageService _storageService = StorageService();
  FirestoreService _firestoreService = FirestoreService();

  //bio güncelleme
  Future<void> updateBio(BuildContext context, String bio) async{
    data = {
      "bio":bio,
    };
    _update(context,bio,data,Constants.bio_is_not_empty);
    notifyListeners();
  }

  //Displayname güncelleme
  Future<void> updateNameAndSurname(BuildContext context, String name_and_surname) async{
    data = {
      "displayName":name_and_surname,
    };
    _auth.currentUser!.updateDisplayName(name_and_surname);
    _update(context,name_and_surname,data,Constants.name_and_surname_not_empty);
    notifyListeners();
  }
  Future<void> updateUsername(BuildContext context, String username) async{
    data = {
      "username":username,
    };
    _update(context,username,data,Constants.username_not_empty);
    notifyListeners();
  }
  Future<void> updateEmail(BuildContext context, String email) async{
    data = {
      "email":email,
    };
    _update(context,email,data,Constants.email_is_not_empty);
    notifyListeners();
  }
  Future<void> updatePassword(BuildContext context, String password) async{
    _auth.currentUser?.updatePassword(password).whenComplete((){
      SnackbarUtil.showSnackbar(context, Constants.update_succes);
    });
    notifyListeners();
  }

  Future<void> _update(BuildContext context, String process,Map<String, dynamic> data,  String error_message) async {
    if(process.isEmpty){
      SnackbarUtil.showSnackbar(context, error_message);
    }else{
      await _firebaseFirestore.collection(Constants.fb_users)
          .doc(_auth.currentUser!.uid)
          .update(data)
          .whenComplete((){
        SnackbarUtil.showSnackbar(context, Constants.update_succes);
        notifyListeners();
      });
    }
  }


  Future<UserModel?> getUserInfo(BuildContext context) async {
    UserModel? user = await _firestoreService.getUserInfoDatabaseAndStorage(context);
    notifyListeners();
    return user;
  }

  Future<void> addCoverPhotoInFirebase(BuildContext context, cover_image_url) async {
    data = {
      "coverImageUrl":cover_image_url
    };
    await _firebaseFirestore.collection(Constants.fb_users)
        .doc(_auth.currentUser!.uid)
        .update(data).whenComplete((){
      SnackbarUtil.showSnackbar(context, Constants.update_succes);
    });
  }
  Future<void> addUserProfilePhotoInFirebase(BuildContext context, user_image_url) async {
    data = {
      "profileImageUrl":user_image_url
    };
    await _firebaseFirestore.collection(Constants.fb_users)
        .doc(_auth.currentUser!.uid)
        .update(data).whenComplete((){
          _auth.currentUser!.updatePhotoURL(user_image_url);
      SnackbarUtil.showSnackbar(context, Constants.update_succes);
    });
  }


// Galeriden Kapak Fotoğrafı seç ve fb ekle
  Future<void> selectCoverImageInGallery(BuildContext context, bool cover) async {
    try {
      var pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        var image = File(pickedFile.path);
        var croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
          ],
        );

        if (croppedImage != null) {
          // Kapak fotoğrafını yeniden boyutlandır
          File? resizedFile = await resizeImage(context, croppedImage);
          if (resizedFile != null) {
            // Dosya başarılı bir şekilde yeniden boyutlandırıldı, buradan Firebase'e yükleyebilirsiniz
            if(cover == true){
              print("cover");
              String image_url = await _storageService.addCoverPhotoInStorage(resizedFile);
              await addCoverPhotoInFirebase(context, image_url);
            }else if(cover == false){
              print("pp");
              String image_url = await _storageService.addUserProfilePhotoInStorage(resizedFile);
              await addUserProfilePhotoInFirebase(context,image_url);
            }
          }
        }
      }
    } catch (e) {
      SnackbarUtil.showSnackbar(context, "${Constants.error}");
      print("${e.toString()}");
    }
    notifyListeners();
  }


// cropImage'dan dönen CroppedFile'i File'a dönüştür
  Future<File?> convertCroppedFileToFile(CroppedFile croppedFile) async {
    return File(croppedFile.path);
  }

  Future<File?> resizeImage(BuildContext context, CroppedFile croppedImage) async {
    try {
      // CroppedFile'i File'a dönüştür
      File? imageFile = await convertCroppedFileToFile(croppedImage);
      // Resmi oku ve decode et
      var decodedImage = img.decodeImage(await imageFile!.readAsBytes());
      if (decodedImage == null) {
        SnackbarUtil.showSnackbar(context, Constants.error);
        return null;
      }

      // Yeniden boyutlandırma için hedef genişlik ve yükseklik belirle
      int targetWidth = MediaQuery.of(context).size.width.toInt();
      int targetHeight = (MediaQuery.of(context).size.height * 0.4).toInt();

      // Resmi yeniden boyutlandır
      var resizedImage = img.copyResize(decodedImage, width: targetWidth, height: targetHeight);

      // Yeni dosya yolu belirle
      final resizedFilePath = '${imageFile.path}_${_auth.currentUser?.uid}.png';
      File resizedFile = File(resizedFilePath);

      // Yeniden boyutlandırılmış resmi dosyaya yaz
      resizedFile.writeAsBytesSync(img.encodePng(resizedImage));

      return resizedFile;
    } catch (e) {
      SnackbarUtil.showSnackbar(context, Constants.error);
      return null;
    }
  }





  }