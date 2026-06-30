// Smoke test for the TripMind app shell.
//
// The home and concierge screens read from FutureProviders that normally hit
// the FastAPI backend over HTTP. In a widget test there is no backend, so we
// override the repository provider with an in-memory fake that returns canned
// data. This keeps the tests hermetic and free of real network calls.
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tripmind/features/auth/application/auth_providers.dart';
import 'package:tripmind/features/auth/domain/app_user.dart';
import 'package:tripmind/features/concierge/domain/concierge_models.dart';
import 'package:tripmind/features/concierge/domain/trip_context_view.dart';
import 'package:tripmind/features/concierge/infrastructure/concierge_repository.dart';
import 'package:tripmind/features/trips/application/trips_repository.dart';
import 'package:tripmind/features/trips/domain/trip.dart';
import 'package:tripmind/main.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(Dio());

  @override
  Future<(String, AppUser)> login(String email, String name) async {
    return (
      'fake-token',
      AppUser(id: 'u1', email: email, name: name, photoUrl: ''),
    );
  }

  @override
  Future<AppUser> me() async {
    return const AppUser(
      id: 'u1',
      email: 'me@example.com',
      name: 'Tester',
      photoUrl: '',
    );
  }
}

class _FakeConciergeRepository implements ConciergeRepository {
  @override
  Future<ChatResponse> sendMessage(
    String message,
    List<ChatMessage> history,
  ) async {
    return const ChatResponse(text: 'Sure!', source: AnswerSource.ai);
  }

  @override
  Future<Briefing> fetchBriefing() async {
    return const Briefing(
      headline: 'Day 2 in Phuket',
      weatherLine: '31C, sunny',
      firstActivity: {'name': 'Big Buddha', 'time': '09:00'},
      budgetLine: 'THB 11,970 remaining',
      aiTip: 'Bring sunscreen for the kids.',
      alerts: [],
      source: AnswerSource.fallback,
    );
  }

  @override
  Future<TripContextView> fetchTripContext() async {
    return const TripContextView(
      area: 'Kata Beach',
      tempC: 31,
      condition: 'sunny',
      budgetRemainingThb: 11970,
      familySize: 4,
      hotelName: 'Kata Beach Resort',
    );
  }
}

Widget _bootApp() {
  return ProviderScope(
    overrides: [
      conciergeRepositoryProvider.overrideWithValue(_FakeConciergeRepository()),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      tripsListProvider.overrideWith((ref) async => <Trip>[]),
    ],
    child: const TripMindApp(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'tripmind_token': 'fake-token'});
  });

  testWidgets('App boots to the Trips home with bottom nav', (tester) async {
    await tester.pumpWidget(_bootApp());
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Where to next?'), findsOneWidget);
  });

  testWidgets('Tapping the AI tab opens the Concierge', (tester) async {
    await tester.pumpWidget(_bootApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI'));
    await tester.pump();

    expect(find.text('AI Concierge'), findsOneWidget);
  });
}
