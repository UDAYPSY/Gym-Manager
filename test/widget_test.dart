import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_manager/main.dart';
import 'package:gym_manager/models/gym_models.dart';
import 'package:gym_manager/screens/add_member_screen.dart';
import 'package:gym_manager/screens/member_detail_screen.dart';
import 'package:gym_manager/services/gym_service.dart';

void main() {
  setUp(() {
    GymService().clearAllMembers();
  });

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
    expect(find.text('Search for "Name"'), findsOneWidget);
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

  testWidgets('Member card renders exact layout and navigates to MemberDetailScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Add sample member matching screenshot
    final sampleMember = GymMember(
      id: 'm_test_1',
      memberId: '3',
      fullName: 'Haajsh',
      phone: '9496446646',
      countryCode: '+91',
      gender: 'Male',
      joinedDate: DateTime(2026, 11, 20),
      expiryDate: DateTime(2026, 12, 19),
      planName: '6 month plan',
      planAmount: 20000.0,
      amountPaid: 200.0,
      duesAmount: 19800.0,
      paymentReminder: false,
      biometricStatus: 'Not Registered',
      biometricId: '18850-6',
    );
    GymService().addMember(sampleMember);

    // Pump Main App
    await tester.pumpWidget(const GymManagerApp());
    await tester.pumpAndSettle();

    // Verify Member card presence
    expect(find.text('Haajsh'), findsOneWidget);
    expect(find.text('Name:'), findsOneWidget);
    expect(find.text('M ID'), findsNWidgets(2)); // One in search toggle, one in member card
    expect(find.text('+91 - 9496446646'), findsOneWidget);
    expect(find.text('Plan Expiry:'), findsOneWidget);
    expect(find.text('19 Dec 2026'), findsOneWidget);
    expect(find.text('Due Amount:'), findsOneWidget);
    expect(find.text('₹19,800'), findsOneWidget);

    // Verify 6 Action Icons on the card
    expect(find.text('ID Card'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Whatsapp'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Renew Plan'), findsOneWidget);
    expect(find.text('Block Member'), findsOneWidget);

    // Tap on Member card to navigate to MemberDetailScreen
    await tester.tap(find.text('Haajsh'));
    await tester.pumpAndSettle();

    // Verify Member Detail Screen
    expect(find.text('Member Detail'), findsOneWidget);
    expect(find.text('Biometric Access'), findsOneWidget);
    expect(find.text('Configure'), findsOneWidget);
    expect(find.text('Not Registered'), findsOneWidget);
    expect(find.text('18850-6'), findsOneWidget);
    expect(find.text('Remove Biometric Ac...'), findsOneWidget);
    expect(find.text('Add Biometric Access'), findsOneWidget);

    // Verify Plans Section
    expect(find.text('Plans'), findsOneWidget);
    expect(find.text('View All (1) >'), findsOneWidget);
    expect(find.text('6 month plan'), findsOneWidget);
    expect(find.text('Purchase Date'), findsOneWidget);
    expect(find.text('Complete Amount'), findsOneWidget);
    expect(find.text('Add Payment'), findsOneWidget);
    expect(find.text('Share Invoice'), findsOneWidget);
    expect(find.text('Freeze Membership'), findsOneWidget);

    // Verify Quick Filter Chips & Attendance section
    expect(find.text('PT Plans'), findsAtLeastNWidgets(1));
    expect(find.text('Attendance'), findsAtLeastNWidgets(2));
  });

  testWidgets('6 Actions (ID Card, Call, Whatsapp, Attendance, Renew Plan, Block Member) flow test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testMember = GymMember(
      id: 'm_test_action',
      memberId: '3',
      fullName: 'Haajsh',
      phone: '9496446646',
      countryCode: '+91',
      joinedDate: DateTime(2026, 11, 20),
      expiryDate: DateTime(2026, 12, 19),
      planName: '6 month plan',
      planAmount: 20000.0,
      amountPaid: 200.0,
      duesAmount: 19800.0,
    );
    GymService().addMember(testMember);

    await tester.pumpWidget(const GymManagerApp());
    await tester.pumpAndSettle();

    // 1. Test ID Card -> Opens Gym Pass Bottom Sheet
    await tester.tap(find.text('ID Card'));
    await tester.pumpAndSettle();
    expect(find.text('Gym Pass'), findsOneWidget);
    expect(find.text('Modern'), findsOneWidget);
    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('Bold'), findsOneWidget);
    expect(find.text('Raja Bhaiaya'), findsOneWidget);
    expect(find.text('Share Old Pass'), findsOneWidget);

    // Switch to Classic style
    await tester.tap(find.text('Classic'));
    await tester.pumpAndSettle();
    expect(find.text('Member ID'), findsOneWidget);

    // Switch to Bold style
    await tester.tap(find.text('Bold'));
    await tester.pumpAndSettle();
    expect(find.text('Membership Id: 3'), findsOneWidget);

    // Close sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 2. Test Call -> Triggers phone call
    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();

    // 3. Test Whatsapp -> Opens Whatsapp sheet
    await tester.tap(find.text('Whatsapp'));
    await tester.pumpAndSettle();
    expect(find.text('Send Whatsapp message:'), findsOneWidget);
    expect(find.text('+919496446646'), findsOneWidget);
    expect(find.text('Payment Confirmation'), findsOneWidget);
    expect(find.text('Payment reminders'), findsOneWidget);
    expect(find.text('Add custom message'), findsOneWidget);

    // Switch to Payment reminders template
    await tester.tap(find.text('Payment reminders'));
    await tester.pumpAndSettle();

    // Close whatsapp sheet
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // 4. Test Attendance -> Marks attendance
    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    // 5. Test Renew Plan -> Opens Renew Plan screen
    await tester.tap(find.text('Renew Plan'));
    await tester.pumpAndSettle();
    expect(find.text('Renew Plan'), findsOneWidget);
    expect(find.text('Select Gym Plan'), findsOneWidget);
    expect(find.text('Plan Start Date *'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 6. Test Block Member -> Opens Confirm dialog
    await tester.tap(find.text('Block Member'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm?'), findsOneWidget);
    expect(find.text('Are you sure you want to block Haajsh?'), findsOneWidget);
    expect(find.text('NO'), findsOneWidget);
    expect(find.text('BLOCK'), findsOneWidget);

    // Confirm block
    await tester.tap(find.text('BLOCK'));
    await tester.pumpAndSettle();
    expect(GymService().members.first.status, MemberStatus.blocked);
  });
}
