String getFileExtension(String filepath) {
  return filepath.split('.').last;
}

String getFilename(String filepath) {
  return filepath.split("/").last;
}
