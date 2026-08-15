import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_mini_game/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FootballMiniGame());

    expect(find.text('FOOTBALL'), findsOneWidget);
    expect(find.text('MINI GAME'), findsOneWidget);
    expect(find.text('PLAY GAME'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });
}
