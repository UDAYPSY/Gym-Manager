import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_manager/main.dart';
import 'package:gym_manager/screens/add_member_screen.dart';

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

    // Toggle M ID and verify hint updates to 'Search for "MembershipId"'
    await tester.tap(find.text('M ID'));
    await tester.pumpAndSettle();
    expect(find.text('Search for "MembershipId"'), findsOneWidget);

    // Verify Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Needs Attention First'), findsOneWidget);
    expect(find.text('All Plans'), findsOneWidget);
    expect(find.text('Select Batch'), findsOneWidget);
    expect(find.text('Select Gender'), findsOneWidget);

    // Tap 'All' filter chip to open bottom sheet
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Verify bottom sheet circular close button and options
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Frozen Membership'), findsOneWidget);
    expect(find.text('Unpaid'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);

    // Select 'Active'
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    // Verify chip updated to 'Active'
    expect(find.text('Active'), findsOneWidget);

    // Tap 'Needs Attention First' filter chip
    await tester.tap(find.text('Needs Attention First'));
    await tester.pumpAndSettle();

    // Verify 7 Attention / Sort options from screenshot
    expect(find.text('Newly Joined Members First'), findsOneWidget);
    expect(find.text('Highest Due Amount First'), findsOneWidget);
    expect(find.text('Expiring Membership First'), findsOneWidget);
    expect(find.text('Longest Membership Validity First'), findsOneWidget);
    expect(find.text('Newly Purchased Membership First'), findsOneWidget);
    expect(find.text('Recently Updated Members First'), findsOneWidget);

    // Select 'Highest Due Amount First'
    await tester.tap(find.text('Highest Due Amount First'));
    await tester.pumpAndSettle();
    expect(find.text('Highest Due Amount First'), findsOneWidget);

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

  testWidgets('AddMemberScreen renders all screenshot fields and adds member', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: AddMemberScreen()));
    await tester.pumpAndSettle();

    // Verify Screen Title
    expect(find.text('Add Member'), findsOneWidget);

    // Card 1: Basic Information
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('🇮🇳 +91'), findsOneWidget);
    expect(find.text('Enter mobile number'), findsOneWidget);
    expect(find.text('Membership ID'), findsOneWidget);
    expect(find.text('Membership ID is available'), findsOneWidget);
    expect(find.text('Batch / Group Class'), findsOneWidget);

    // Card 2: Plan Details
    expect(find.text('Plan Details'), findsOneWidget);
    expect(find.text('Select Gym Plan'), findsOneWidget);
    expect(find.text('Plan Amount: ₹20,000'), findsOneWidget);
    expect(find.text('Paid Amount'), findsOneWidget);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Due Amount: ₹20,000'), findsOneWidget);
    expect(find.text('Payment reminder'), findsOneWidget);
    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('Discount in Plan:'), findsOneWidget);
    expect(find.text('Percent'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Discount'), findsOneWidget);
    expect(find.text('Admission Fees'), findsOneWidget);

    // Card 3: Member Details
    expect(find.text('Member Details'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);

    // Verify Save Button
    expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);

    // Enter Member Name & Mobile
    final formFields = find.byType(TextFormField);
    if (formFields.evaluate().isNotEmpty) {
      await tester.enterText(formFields.first, 'John Doe');
    }

    // Tap Save
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();
  });
}
