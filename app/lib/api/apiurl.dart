import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['API_URL'] ?? "http://localhost:5000";
final mlUrl = dotenv.env['ML_URL'] ?? "http://localhost:8000";
