import 'package:flutter_test/flutter_test.dart';
import 'package:nalsflutter/index.dart';

void main() {
  late JsonArrayErrorResponseDecoder jsonArrayErrorResponseDecoder;

  setUp(() {
    jsonArrayErrorResponseDecoder = JsonArrayErrorResponseDecoder();
  });

  group('map', () {
    test('should return correct ServerError when using valid data response', () async {
      // arrange
      final errorResponse = [
        {
          'code': 400,
          'message': 'The request is invalid',
        },
      ];
      const expected = ServerError(
        errors: [
          ServerErrorDetail(
            serverStatusCode: 400,
            message: 'The request is invalid',
          ),
        ],
      );
      // act
      final result = jsonArrayErrorResponseDecoder.map(
        errorResponse: errorResponse,
        apiInfo: ApiInfo(method: 'GET', url: '/test'),
      );
      // assert
      expect(result, expected);
    });

    test('should return correct ServerError when some JSON keys are incorrect', () async {
      // arrange
      final errorResponse = [
        {
          'code': 400, // correct key
          'error_message': 'The request is invalid', // incorrect key
        },
      ];
      const expected = ServerError(errors: [ServerErrorDetail(serverStatusCode: 400)]);
      // act
      final result = jsonArrayErrorResponseDecoder.map(
        errorResponse: errorResponse,
        apiInfo: ApiInfo(method: 'GET', url: '/test'),
      );
      // assert
      expect(result, expected);
    });

    test(
      'should return corresponding ServerError when all JSON keys are incorrect',
      () async {
        // arrange
        final errorResponse = [
          {
            'er_code': 400, // incorrect key
            'error_message': 'The request is invalid', // incorrect key
          },
        ];
        const expected = ServerError(errors: [ServerErrorDetail()]);
        final result = jsonArrayErrorResponseDecoder.map(
          errorResponse: errorResponse,
          apiInfo: ApiInfo(method: 'GET', url: '/test'),
        );
        // assert
        expect(result, expected);
      },
    );

    test('should thow RemoteException.decodeError when using invalid data type', () async {
      // arrange
      final errorResponse = [
        {
          'code': '400',
          'message': true,
        },
      ];
      // assert
      expect(
        () => jsonArrayErrorResponseDecoder.map(
          errorResponse: errorResponse,
          apiInfo: ApiInfo(method: 'GET', url: '/test'),
        ),
        throwsA((e) => e is RemoteException && e.kind == RemoteExceptionKind.decodeError),
      );
    });
  });
}
