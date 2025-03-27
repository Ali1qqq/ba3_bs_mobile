// // Firebase-Specific Implementation
// import 'dart:io';
//
// import 'package:firebase_storage/firebase_storage.dart';
//
// import '../../interfaces/i_remote_storage_service.dart';
//
// // FirebaseStorageService Implementation
// class FirebaseStorageService extends IRemoteStorageService<String> {
//   final FirebaseStorage _firebaseStorageInstance;
//
//   FirebaseStorageService(FirebaseStorage instance) : _firebaseStorageInstance = instance;
//
//   @override
//   Future<String> uploadImage({required String imagePath, required String path}) async {
//     File imageFile = File(imagePath);
//
//     String fileName = "$path/${DateTime.now().millisecondsSinceEpoch}.jpg";
//
//     Reference storageRef = _firebaseStorageInstance.ref().child(fileName);
//
//     UploadTask uploadTask = storageRef.putFile(imageFile);
//
//     TaskSnapshot snapshot = await uploadTask;
//
//     String downloadUrl = await snapshot.ref.getDownloadURL();
//
//     return downloadUrl;
//   }
// }
