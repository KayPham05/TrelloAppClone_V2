import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/core/constants/api_endpoints.dart';
import 'package:apptreolon/features/search/presentation/delegates/global_search_delegate.dart';
import 'package:apptreolon/init_dependencies.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    
    // Override serviceLocator for testing
    if (serviceLocator.isRegistered<Dio>()) {
      serviceLocator.unregister<Dio>();
    }
    serviceLocator.registerLazySingleton<Dio>(() => mockDio);
  });

  tearDown(() {
    serviceLocator.reset();
  });

  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(
      home: widget,
    );
  }

  testWidgets('GlobalSearchDelegate should display empty state when query is empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: GlobalSearchDelegate(userUId: 'test-uid'),
                  );
                },
                child: const Text('Search'),
              );
            },
          ),
        ),
      ),
    );

    // Open search
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify empty state is rendered (which shows "Nhập từ khóa để tìm kiếm" in buildResults but in suggestions it shows an empty container).
    // The search field should be focused.
    expect(find.byType(TextField), findsOneWidget);
    
    // Type a short query to see suggestions empty
    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump();
    
    // Wait for it
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('GlobalSearchDelegate should display results when query is provided', (WidgetTester tester) async {
    // Arrange mock response
    when(() => mockDio.get(
          ApiEndpoints.search,
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => Response(
          data: {
            'boards': [
              {
                'boardUId': 'b1',
                'boardName': 'Mock Board 1',
              }
            ],
            'cards': [
              {
                'cardUId': 'c1',
                'title': 'Mock Card 1',
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.search),
        ));

    await tester.pumpWidget(
      buildTestableWidget(
        Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: GlobalSearchDelegate(userUId: 'test-uid'),
                  );
                },
                child: const Text('Search'),
              );
            },
          ),
        ),
      ),
    );

    // Open search
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Enter a search query
    await tester.enterText(find.byType(TextField), 'mock query');
    // submit the search
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump(); // Start FutureBuilder
    
    // Verify CircularProgressIndicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    await tester.pumpAndSettle(); // Finish FutureBuilder

    // Verify results are rendered
    expect(find.text('BOARDS'), findsOneWidget);
    expect(find.text('Mock Board 1'), findsOneWidget);
    expect(find.text('CARDS'), findsOneWidget);
    expect(find.text('Mock Card 1'), findsOneWidget);
  });
  
  testWidgets('GlobalSearchDelegate should display error state if request fails', (WidgetTester tester) async {
    // Arrange mock response
    when(() => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        )).thenThrow(Exception('Network error'));

    await tester.pumpWidget(
      buildTestableWidget(
        Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: GlobalSearchDelegate(userUId: 'test-uid'),
                  );
                },
                child: const Text('Search'),
              );
            },
          ),
        ),
      ),
    );

    // Open search
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Enter a search query
    await tester.enterText(find.byType(TextField), 'mock error');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump(); // Start FutureBuilder
    await tester.pumpAndSettle(); // Finish FutureBuilder

    // Verify error state
    expect(find.textContaining('Đã có lỗi xảy ra:'), findsOneWidget);
  });
}
