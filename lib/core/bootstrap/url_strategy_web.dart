import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Use clean paths (`/login`) instead of hash (`/#/login`) for GoRouter on web.
void configureWebUrlStrategy() {
  setUrlStrategy(PathUrlStrategy());
}
