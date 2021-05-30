// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
//
// class FileUtil{
//   static Future<String> createFolderInDesireDir(String folderName) async {
//     //Get this App Document Directory OR externalStorageDirectory
//     final Directory _appDocDir = await getExternalStorageDirectory();
//     //print('appDir=> ${_appDocDir.parent.parent.parent.parent}');
//     //App Document Directory + folder name
//     final Directory _appDocDirFolder =  Directory('${_appDocDir.parent.parent.parent.parent.path}/$folderName/');
//
//     if(await _appDocDirFolder.exists()){ //if folder already exists return path
//       return _appDocDirFolder.path;
//     }else{//if folder not exists create folder and then return its path
//       final Directory _appDocDirNewFolder=await _appDocDirFolder.create(recursive: true);
//       return _appDocDirNewFolder.path;
//     }
//   }
// }