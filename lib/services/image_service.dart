import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class ImageService {
  // Cloudinary instance
  final cloudinary = CloudinaryPublic(
    'daf6mdwkh',  // Your Cloudinary cloud name
    'taskhub',    // Your upload preset
    cache: false
  );

  // Convert XFile to File
  Future<List<File>> xFilesToFiles(List<XFile> xFiles) async {
    List<File> files = [];
    for (var xFile in xFiles) {
      files.add(File(xFile.path));
    }
    return files;
  }

  // Upload images to Cloudinary directly
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      List<String> imageUrls = [];
      print('Starting to upload ${images.length} images to Cloudinary...');
      
      for (var image in images) {
        try {
          final fileName = path.basename(image.path);
          print('Uploading image: $fileName');
          
          final response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              image.path,
              resourceType: CloudinaryResourceType.Image,
              folder: 'taskhub/images',
            ),
          );
          
          // Add the secure URL to our list
          print('Image uploaded successfully: ${response.secureUrl}');
          imageUrls.add(response.secureUrl);
        } catch (e) {
          print('Error uploading image: $e');
          throw Exception('Failed to upload image: ${e.toString()}');
        }
      }
      
      print('Successfully uploaded ${imageUrls.length} images');
      return imageUrls;
    } catch (e) {
      print('Exception in uploadImages method: $e');
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }
} 