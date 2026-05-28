import '../../domain/entities/notification_entity.dart';

class NotificationTabAction {
  final bool animateToPage;
  final bool fetchNotifications;
  final NotificationTab tab;

  const NotificationTabAction({
    required this.animateToPage,
    required this.fetchNotifications,
    required this.tab,
  });
}

class NotificationTabCoordinator {
  int _selectedIndex;

  NotificationTabCoordinator({int selectedIndex = 0}) : _selectedIndex = selectedIndex;

  int get selectedIndex => _selectedIndex;

  NotificationTabAction onTap(int index) {
    if (index == _selectedIndex) {
      return NotificationTabAction(
        animateToPage: false,
        fetchNotifications: false,
        tab: tabForIndex(index),
      );
    }

    _selectedIndex = index;
    return NotificationTabAction(
      animateToPage: true,
      fetchNotifications: false,
      tab: tabForIndex(index),
    );
  }

  NotificationTabAction onPageChanged(int index) {
    _selectedIndex = index;
    return NotificationTabAction(
      animateToPage: false,
      fetchNotifications: true,
      tab: tabForIndex(index),
    );
  }

  static NotificationTab tabForIndex(int index) {
    return switch (index) {
      1 => NotificationTab.sentToMe,
      2 => NotificationTab.read,
      _ => NotificationTab.all,
    };
  }
}
