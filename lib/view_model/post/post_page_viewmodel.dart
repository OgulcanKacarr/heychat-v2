import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:heychat_2/utils/progress_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar_util.dart';

class PostPageViewmodel extends ChangeNotifier{

  StorageService _storageService = StorageService();
  FirestoreService _firestoreService = FirestoreService();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth =FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  var uuid = Uuid();
  File? selectedImage;


  Future<void> addPost(BuildContext context,String description) async{

    ProgressDialog.showProgressDialog(context);

    String image_url = await _storageService.addPostInStorage(selectedImage!);
    if(image_url.isNotEmpty){
      await _firestoreService.addPostInfoInFb(context, image_url,description).whenComplete((){
        ProgressDialog.hideProgressDialog(context);
        notifyListeners();
      });
    }else{
      ProgressDialog.hideProgressDialog(context);
    }


  }

  // Galeriden Kapak Fotoğrafı seç ve fb ekle
  Future<void> selectCoverImageInGallery(BuildContext context) async {
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
            selectedImage = resizedFile;
            notifyListeners();

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
      int targetHeight = (MediaQuery.of(context).size.height / 2).toInt();

      // Resmi yeniden boyutlandır
      var resizedImage = img.copyResize(decodedImage, width: targetWidth, height: targetHeight);


      // Yeni dosya yolu belirle
      final resizedFilePath = '${imageFile.path}_${uuid.v4()}.png';
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