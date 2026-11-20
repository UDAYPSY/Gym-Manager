import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_manager/main.dart';

void main() {
  testWidgets('Gym Manager exact view elements test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build the app
    await tester.pumpWidget(const GymManagerApp());
    await tester.pumpAndSettle();

    // Verify AppBar Title & Actions
    expect(find.text('Members'), findsNWidgets(2)); // AppBar and BottomNav
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);

    // Verify Notification Badge count '3'
    expect(find.text('3'), findsOneWidget);

    // Verify Search Hint and M ID toggle
    expect(find.text('Search for "Mobile"'), findsOneWidget);
    expect(find.text('M ID'), findsOneWidget);

    // Verify Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Needs Attention First'), findsOneWidget);
    expect(find.text('All Plans'), findsOneWidget);
    expect(find.text('Select Batch'), findsOneWidget);

    // Verify Center Empty State
    expect(find.text('No Members Found'), findsOneWidget);
    expect(
      find.text('You can add a new member by clicking\nthe button below'),
      findsOneWidget,
    );
    expect(find.text('OR'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Add Member'), findsOneWidget);

    // Verify Floating Action Button
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify Currency Notice Banner
    expect(find.text("You haven't selected a currency yet."), findsOneWidget);
    expect(find.text('Choose Currency'), findsOneWidget);

    // Verify Bottom Navigation Bar Tabs
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Gym'), findsOneWidget);
  });
}
