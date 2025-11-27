import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get publishableKey => dotenv.env['PUBLISHABLE_KEY'] ?? '';
  static String get secretKey => dotenv.env['SECRET_KEY'] ?? '';
}
