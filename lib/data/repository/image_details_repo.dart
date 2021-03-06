import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_app/core/utils/color_resources.dart';

class ImageDetailsRepo {
  List<String> imagePaths = [];

  Future<bool> shareImage(BuildContext context, String imageUrl) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    imagePaths.add(file.path);
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareFiles(imagePaths,
        text: '',
        subject: '',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);

    return true;
  }

  Future<bool> setWallpaper(BuildContext context,String imageUrl) async {
    try {
      int location = WallpaperManager
          .BOTH_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(imageUrl);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      showSnackbar('wallpaper changed successfully', ColorResources.successSnackbarColor, context);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      showSnackbar('uffs! fail to changing wallpaper pls try again.', ColorResources.errorSnackbarColor, context);
      return false;
    }
  }

  Future<bool> saveImage(BuildContext context,String imageUrl) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll(".", "_")
        .replaceAll(":", '_');
    final name = 'aits_$time';
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    await ImageGallerySaver.saveImage(file.readAsBytesSync(), name: name);
    showSnackbar('successfully image save in gallery',ColorResources.successSnackbarColor, context);
    return true;
  }

  void showSnackbar(
      String message, Color backgroundColor, BuildContext context) {
    //hideFabMenu();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 2),
    ));
  }
}
