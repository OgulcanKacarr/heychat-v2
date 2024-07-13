import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/services/storage_service.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class SettingsPageViewmodel extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic> data = {};
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  //bio güncelleme
  Future<void> updateBio(BuildContext context, String bio) async {
    data = {
      "bio": bio,
    };
    _update(context, bio, data, Constants.bio_is_not_empty);
    notifyListeners();
  }

  //Displayname güncelleme
  Future<void> updateNameAndSurname(
      BuildContext context, String nameAndSurname) async {
    data = {
      "displayName": nameAndSurname,
    };
    _auth.currentUser!.updateDisplayName(nameAndSurname);
    _update(
        context, nameAndSurname, data, Constants.name_and_surname_not_empty);
    notifyListeners();
  }

  Future<void> updateUsername(BuildContext context, String username) async {
    data = {
      "username": username,
    };
    _update(context, username, data, Constants.username_not_empty);
    notifyListeners();
  }

  Future<void> updateEmail(BuildContext context, String email) async {
    data = {
      "email": email,
    };
    _update(context, email, data, Constants.email_is_not_empty);
    notifyListeners();
  }

  Future<void> updatePassword(BuildContext context, String password) async {
    _auth.currentUser?.updatePassword(password).whenComplete(() {
      SnackbarUtil.showSnackbar(context, Constants.update_succes);
    });
    notifyListeners();
  }

  Future<void> _update(BuildContext context, String process,
      Map<String, dynamic> data, String errorMessage) async {
    if (process.isEmpty) {
      SnackbarUtil.showSnackbar(context, errorMessage);
    } else {
      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(_auth.currentUser!.uid)
          .update(data)
          .whenComplete(() {
        SnackbarUtil.showSnackbar(context, Constants.update_succes);
        notifyListeners();
      });
    }
  }

  Future<UserModel?> getUserInfo(BuildContext context) async {
    UserModel? user =
        await _firestoreService.getUserInfoDatabaseAndStorage(context);
    notifyListeners();
    return user;
  }

  Future<void> addCoverPhotoInFirebase(
      BuildContext context, coverImageUrl) async {
    data = {"coverImageUrl": coverImageUrl};
    await _firebaseFirestore
        .collection(Constants.fb_users)
        .doc(_auth.currentUser!.uid)
        .update(data)
        .whenComplete(() {
      SnackbarUtil.showSnackbar(context, Constants.update_succes);
    });
  }

  Future<void> addUserProfilePhotoInFirebase(
      BuildContext context, userImageUrl) async {
    data = {"profileImageUrl": userImageUrl};
    await _firebaseFirestore
        .collection(Constants.fb_users)
        .doc(_auth.currentUser!.uid)
        .update(data)
        .whenComplete(() {
      _auth.currentUser!.updatePhotoURL(userImageUrl);
      SnackbarUtil.showSnackbar(context, Constants.update_succes);
    });
  }

// Galeriden Kapak Fotoğrafı seç ve fb ekle
  Future<void> selectCoverImageInGallery(
      BuildContext context, bool cover) async {
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
            if (cover == true) {
              String imageUrl =
                  await _storageService.addCoverPhotoInStorage(resizedFile);
              await addCoverPhotoInFirebase(context, imageUrl);
            } else if (cover == false) {
              String imageUrl = await _storageService
                  .addUserProfilePhotoInStorage(resizedFile);
              await addUserProfilePhotoInFirebase(context, imageUrl);
            }
          }
        }
      }
    } catch (e) {
      SnackbarUtil.showSnackbar(context, "${Constants.error}");

    }
    notifyListeners();
  }

// cropImage'dan dönen CroppedFile'i File'a dönüştür
  Future<File?> convertCroppedFileToFile(CroppedFile croppedFile) async {
    return File(croppedFile.path);
  }

  Future<File?> resizeImage(
      BuildContext context, CroppedFile croppedImage) async {
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
      var resizedImage = img.copyResize(decodedImage,
          width: targetWidth, height: targetHeight);

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

  Widget loadPhoto(String imageUrl) {
    return CachedNetworkImage(
      alignment: Alignment.center,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        if (downloadProgress.totalSize != null) {
          final percent = (downloadProgress.progress! * 100).toStringAsFixed(0);
          return Center(
            child: Text("$percent% yükleme tamamlandı"),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
