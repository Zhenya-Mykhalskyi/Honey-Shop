import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:honey/widgets/app_colors.dart';

class EditFormImage extends StatefulWidget {
  final String? currentProfileImage;
  final void Function(File? image) onImagePicked;
  const EditFormImage(
      {super.key,
      required this.onImagePicked,
      required this.currentProfileImage});

  @override
  State<EditFormImage> createState() => _EditFormImageState();
}

class _EditFormImageState extends State<EditFormImage> {
  File? _pickedImage;

  Future<String?> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      widget.onImagePicked(_pickedImage);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.only(top: 8, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryColor,
        ),
      ),
      child: _pickedImage == null
          ? widget.currentProfileImage == null
              ? InkWell(
                  onTap: pickProfileImage,
                  child: const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Icon(
                      Icons.add_a_photo,
                      color: AppColors.whiteColor,
                      size: 60,
                    ),
                  ),
                )
              : InkWell(
                  onTap: pickProfileImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.currentProfileImage!,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
          : InkWell(
              onTap: pickProfileImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _pickedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }
}
