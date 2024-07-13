import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';
import 'package:heychat_2/view_model/post/post_page_viewmodel.dart';

final view_model = ChangeNotifierProvider((ref) => PostPageViewmodel());

class PostPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  TextEditingController descriptionController = TextEditingController();
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(view_model);
    var read = ref.read(view_model);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(Constants.add_post),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              try {
                if (selectedImage != null) {
                  await read.addPost(context, descriptionController.text).whenComplete(() {
                    SnackbarUtil.showSnackbar(context, Constants.add_post_succes);
                    Navigator.pushNamed(context, "home_page");
                  });

                  selectedImage = null;
                } else {
                  SnackbarUtil.showSnackbar(context, Constants.select_photo);
                }
              } catch (e) {
                print('Error sharing post: $e');
                SnackbarUtil.showSnackbar(context, Constants.error);
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () async {
                    await watch.selectCoverImageInGallery(context);
                    setState(() {
                      selectedImage = watch.selectedImage; // Update selectedImage
                    });
                  },
                  child: Container(
                    width: screenWidth,
                    child: AspectRatio(
                      aspectRatio: 1, // Square aspect ratio (1:1)
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.camera_alt,
                          size: 64.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: Constants.add_caption,
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  style: const TextStyle(color: Colors.white),
                  minLines: 3,
                  maxLines: 5,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
