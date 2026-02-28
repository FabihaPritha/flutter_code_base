import 'package:flutter/material.dart';
import 'package:flutter_code_base/app.dart';
import 'package:flutter_code_base/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ProviderScope(child: MyApp()));
}
