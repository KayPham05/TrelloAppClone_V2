// NotificationRealtimeService integration tests are split into two parts:
//
//  1. Hub URL generation — tested below with no platform plugins.
//  2. Live SignalR event forwarding (NotificationCreated, UnreadCountChanged,
//     NotificationRead, NotificationDeleted) — these require the
//     signalr_netcore HubConnection which is a platform plugin and cannot run
//     in the pure-Dart test VM.  Manual verification steps are documented in
//     PLAN.md §"Behaviors To Verify – Realtime/lifecycle/UI behavior".

import 'package:flutter_test/flutter_test.dart';
import 'package:apptreolon/features/activity/data/services/notification_hub_url_builder.dart';

void main() {
  group('buildNotificationHubUrl', () {
    test('strips /v1/api and appends /hubs/notifications', () {
      const base = 'https://api.example.com/v1/api';
      expect(
        NotificationHubUrlBuilder.build(base),
        'https://api.example.com/hubs/notifications',
      );
    });

    test('handles trailing slash on /v1/api/', () {
      const base = 'https://api.example.com/v1/api/';
      expect(
        NotificationHubUrlBuilder.build(base),
        'https://api.example.com/hubs/notifications',
      );
    });

    test('works with an IP address and port', () {
      const base = 'http://192.168.1.10:5001/v1/api';
      expect(
        NotificationHubUrlBuilder.build(base),
        'http://192.168.1.10:5001/hubs/notifications',
      );
    });
  });
}
