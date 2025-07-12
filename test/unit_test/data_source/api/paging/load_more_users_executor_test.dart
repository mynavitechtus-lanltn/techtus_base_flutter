// ignore_for_file: variable_type_mismatch
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

void main() {
  late LoadMoreUsersExecutor loadMoreUsersExecutor;

  setUp(() {
    loadMoreUsersExecutor = LoadMoreUsersExecutor(appApiService);
  });

  group('execute', () {
    test('when data of the first page is not empty', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      final users = List.generate(
        10,
        (index) => ApiUserData(
          id: index,
          email: 'email$index',
        ),
      );
      final response = PagingDataResponse(
        results: users,
      );
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      // Assert
      expect(
        result,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: Constant.initialPage + 1,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );

      const initialState = LoadMoreOutput<ApiUserData>(data: []);
      expect(initialState != result, true);
    });

    test('when data of the first page is empty', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      const response = PagingDataResponse(results: <ApiUserData>[]);
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      // Assert
      expect(
        result,
        const LoadMoreOutput<ApiUserData>(
          data: [],
          page: Constant.initialPage,
          offset: 0,
          isLastPage: true,
          isRefreshSuccess: true,
        ),
      );

      const initialState = LoadMoreOutput<ApiUserData>(data: []);
      expect(initialState != result, true);
    });

    test('when data of the second page is not empty', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      final users = List.generate(
        10,
        (index) => ApiUserData(
          id: index,
          email: 'email$index',
        ),
      );
      final response = PagingDataResponse(
        results: users,
      );
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      const nextPage = page + 1;

      expect(
        result,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );

      // fetch the next page
      when(() => appApiService.getUsers(page: nextPage, limit: limit))
          .thenAnswer((_) async => response);

      final nextPageResult = await loadMoreUsersExecutor.execute(isInitialLoad: false);

      expect(
        nextPageResult,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage + 1,
          offset: users.length * 2,
          isLastPage: false,
          isRefreshSuccess: false,
        ),
      );
    });

    test('when fetching more page failed', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      final users = List.generate(
        10,
        (index) => ApiUserData(
          id: index,
          email: 'email$index',
        ),
      );
      final response = PagingDataResponse(results: users);
      final exception = RemoteException(kind: RemoteExceptionKind.noInternet);
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      const nextPage = page + 1;

      expect(
        result,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );

      // fetch the next page
      when(() => appApiService.getUsers(page: nextPage, limit: limit)).thenThrow(exception);

      expect(
        loadMoreUsersExecutor.execute(isInitialLoad: false),
        throwsA(exception),
      );
    });

    test('when the second page is the last page', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      final users = List.generate(
        10,
        (index) => ApiUserData(
          id: index,
          email: 'email$index',
        ),
      );
      final response = PagingDataResponse(
        results: users,
      );
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);
      const nextPage = page + 1;

      expect(
        result,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );

      // fetch the next page
      const lastPageResponse = PagingDataResponse(
        results: <ApiUserData>[],
      );
      when(() => appApiService.getUsers(page: nextPage, limit: limit))
          .thenAnswer((_) async => lastPageResponse);

      final nextPageResult = await loadMoreUsersExecutor.execute(isInitialLoad: false);

      expect(
        nextPageResult,
        LoadMoreOutput<ApiUserData>(
          data: [],
          page: nextPage,
          offset: users.length,
          isLastPage: true,
          isRefreshSuccess: false,
        ),
      );
    });

    test('when fetching more page failed but retry success', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      final users = List.generate(
        10,
        (index) => ApiUserData(
          id: index,
          email: 'email$index',
        ),
      );
      final response = PagingDataResponse(results: users);
      final exception = RemoteException(kind: RemoteExceptionKind.noInternet);
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      const nextPage = page + 1;

      expect(
        result,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );

      // fetch the next page
      when(() => appApiService.getUsers(page: nextPage, limit: limit)).thenThrow(exception);

      expect(
        loadMoreUsersExecutor.execute(isInitialLoad: false),
        throwsA(exception),
      );

      // retry
      when(() => appApiService.getUsers(page: nextPage, limit: limit))
          .thenAnswer((_) async => response);

      final nextPageResult = await loadMoreUsersExecutor.execute(isInitialLoad: false);

      expect(
        nextPageResult,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage + 1,
          offset: users.length * 2,
          isLastPage: false,
          isRefreshSuccess: false,
        ),
      );
    });

    test('when fetching more page failed and retry failed', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      final users = List.generate(
        10,
        (index) => ApiUserData(
          id: index,
          email: 'email$index',
        ),
      );
      final response = PagingDataResponse(results: users);
      final exception = RemoteException(kind: RemoteExceptionKind.noInternet);
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      const nextPage = page + 1;

      expect(
        result,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );

      // fetch the next page
      when(() => appApiService.getUsers(page: nextPage, limit: limit)).thenThrow(exception);

      expect(
        loadMoreUsersExecutor.execute(isInitialLoad: false),
        throwsA(exception),
      );

      // retry
      when(() => appApiService.getUsers(page: nextPage, limit: limit)).thenThrow(exception);

      expect(
        loadMoreUsersExecutor.execute(isInitialLoad: false),
        throwsA(exception),
      );
    });

    test('when fetching more page failed but refreshing success', () async {
      // Arrange
      const page = Constant.initialPage;
      const limit = Constant.itemsPerPage;
      final users = List.generate(
        10,
        (index) => ApiUserData(
          id: index,
          email: 'email$index',
        ),
      );
      final response = PagingDataResponse(results: users);
      final exception = RemoteException(kind: RemoteExceptionKind.noInternet);
      when(() => appApiService.getUsers(page: page, limit: limit))
          .thenAnswer((_) async => response);

      // Act
      final result = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      const nextPage = page + 1;

      expect(
        result,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: nextPage,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );

      // fetch the next page
      when(() => appApiService.getUsers(page: nextPage, limit: limit)).thenThrow(exception);

      expect(
        loadMoreUsersExecutor.execute(isInitialLoad: false),
        throwsA(exception),
      );

      // refresh success
      final nextPageResult = await loadMoreUsersExecutor.execute(isInitialLoad: true);

      expect(
        nextPageResult,
        LoadMoreOutput<ApiUserData>(
          data: users,
          page: page + 1,
          offset: users.length,
          isLastPage: false,
          isRefreshSuccess: true,
        ),
      );
    });
  });
}
