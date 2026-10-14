import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../glob/products.dart';
import '../theme/app_colors.dart';
import 'product_image.dart';

// Bottom sheet for choosing a photo: gallery, camera or built-in photos.
// Returns the image text ("b64:..." or "asset:...") or null if cancelled.
Future<String?> pickPhoto(BuildContext context, {bool builtIn = true}) async {
  String? choice = await showModalBottomSheet<String>(
    context: context,
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
              title: const Text("Choose from Gallery"),
              onTap: () => Navigator.pop(c, "gallery"),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.accent),
              title: const Text("Take a Photo"),
              onTap: () => Navigator.pop(c, "camera"),
            ),
            if (builtIn) const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Text("Or use a built-in photo", style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ),
            if (builtIn)
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AllProducts.builtInImages.length,
                  separatorBuilder: (x, i) => const SizedBox(width: 10),
                  itemBuilder: (x, i) => GestureDetector(
                    onTap: () => Navigator.pop(c, AllProducts.builtInImages[i]),
                    child: Container(
                      width: 76,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                      child: ProductImage(AllProducts.builtInImages[i]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  if (choice == null) return null;
  if (choice.startsWith("asset:")) return choice;

  try {
    XFile? file = await ImagePicker().pickImage(
      source: choice == "camera" ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (file == null) return null;
    List<int> bytes = await file.readAsBytes();
    return "b64:${base64Encode(bytes)}";
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unable to open the camera/gallery on this device.")));
    }
    return null;
  }
}
