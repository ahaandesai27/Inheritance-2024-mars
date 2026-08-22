// Supplied at build time. Put the values in env.json (see env.example.json) and
// build with --dart-define-from-file=env.json, or pass --dart-define=API_URL=...
const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: "https://recipe-server-xc6l.onrender.com",
);
const String mlUrl = String.fromEnvironment(
  'ML_URL',
  defaultValue: "https://recipe-ml-965807896618.asia-south1.run.app",
);
