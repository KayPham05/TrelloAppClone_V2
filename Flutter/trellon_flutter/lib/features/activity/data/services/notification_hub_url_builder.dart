class NotificationHubUrlBuilder {
  static String build(String apiBaseUrl) {
    final uri = Uri.parse(apiBaseUrl);
    final basePath = uri.path.replaceFirst(RegExp(r'/v1/api/?$'), '');
    return uri.replace(path: '$basePath/hubs/notifications').toString();
  }
}
