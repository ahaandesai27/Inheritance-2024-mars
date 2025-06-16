import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiUrl = dotenv.env['API_URL'] ?? "http://localhost:5000";
final String mlUrl = dotenv.env['ML_URL'] ?? "http://localhost:8000";
final String webscrapingUrl = dotenv.env['WEBSCRAPING_URL'] ?? "https://recipe-webscraping-965807896618.asia-south1.run.app/api/getingredientss";
