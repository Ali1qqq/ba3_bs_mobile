abstract class IRemoteStorageService<T> {
  Future<T> uploadImage({required String imagePath, required String path});
}
