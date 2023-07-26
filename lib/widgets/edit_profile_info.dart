// import 'package:flutter/material.dart';

// import 'orders_screen.dart';
// import 'package:honey/widgets/app_colors.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 150,
//           height: 150,
//           margin: const EdgeInsets.only(top: 8, right: 10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: AppColors.primaryColor,
//             ),
//           ),
//           child: widget.isAdd // додаємо чи редагуємо товар?
//               ? _pickedImage == null
//                   ? InkWell(
//                       onTap: pickAndUploadImage,
//                       child: Padding(
//                         padding: const EdgeInsets.all(25.0),
//                         child: Image.asset('assets/img/add_photo.png'),
//                       ),
//                     )
//                   : InkWell(
//                       onTap: pickAndUploadImage,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           _pickedImage!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     )
//               // редагуємо
//               : _pickedImage != null
//                   ? InkWell(
//                       onTap: pickAndUploadImage,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           _pickedImage!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     )
//                   : InkWell(
//                       onTap: pickAndUploadImage,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           _currentImageUrl!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: CustomTextField(
//             hintText: 'Назва товару',
//             maxLength: 230,
//             maxLines: 1,
//             controller: _titleController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Будь ласка, введіть назву товару';
//               }
//               if (value.toString().length >= 30) {
//                 return 'Повинна бути коротшою 30 символів';
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'package:honey/widgets/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
      child: const Icon(
        Icons.add_a_photo,
        color: Colors.white,
        size: 60,
      ),
    );
  }
}
