import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AppHelperFunctions {
  AppHelperFunctions._();

  /// Shows a snackbar with the provided message
  /// Uses ScaffoldMessenger for Material Design consistency
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a snackbar with success styling
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a snackbar with error styling
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a modal bottom sheet to select image source
  /// Returns the selected XFile or null if cancelled
  static Future<XFile?> showImageSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {
                  context.pop(); // Using GoRouter's context.pop()
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (context.mounted) {
                    context.pop(image); // Return the picked image
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  context.pop(); // Using GoRouter's context.pop()
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (context.mounted) {
                    context.pop(image); // Return the picked image
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows an alert dialog with title and message
  static Future<void> showAlert(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.pop(), // Using GoRouter's context.pop()
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog with Yes/No options
  /// Returns true if user confirms, false otherwise
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Navigate to a route using GoRouter's context.push()
  /// Use this for stack navigation (user can go back)
  /// Example: AppHelperFunctions.navigateToRoute(context, '/profile')
  static void navigateToRoute(BuildContext context, String route) {
    context.push(route);
  }

  /// Navigate to a route using GoRouter's context.go()
  /// Use this for replacing the current route (cannot go back)
  /// Example: AppHelperFunctions.goToRoute(context, '/home')
  static void goToRoute(BuildContext context, String route) {
    context.go(route);
  }

  /// Navigate to a named route with path parameters
  /// Example: navigateToRouteWithParams(context, '/profile/:id', {'id': '123'})
  static void navigateToRouteWithParams(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) {
    String finalRoute = route;
    params.forEach((key, value) {
      finalRoute = finalRoute.replaceAll(':$key', value);
    });
    context.push(finalRoute);
  }

  /// Navigate to a route with extra data
  /// Example: navigateToRouteWithExtra(context, '/profile', {'user': userObject})
  static void navigateToRouteWithExtra(
    BuildContext context,
    String route,
    Object extra,
  ) {
    context.push(route, extra: extra);
  }

  /// Go back to previous screen
  /// Optional: Pass result data back to previous screen
  static void goBack(BuildContext context, [Object? result]) {
    if (result != null) {
      context.pop(result);
    } else {
      context.pop();
    }
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static String getFormattedDate(
    DateTime date, {
    String format = 'dd MMM yyyy',
  }) {
    return DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(
        i,
        i + rowSize > widgets.length ? widgets.length : i + rowSize,
      );
      wrappedList.add(Row(children: rowChildren));
    }
    return wrappedList;
  }
}
