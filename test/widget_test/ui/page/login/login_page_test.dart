import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockLoginViewModel extends StateNotifier<CommonState<LoginState>>
    with Mock
    implements LoginViewModel {
  MockLoginViewModel(super.state);
}

void main() {
  group(
    'LoginPage',
    () {
      testGoldens(
        'when login button is disabled',
        (tester) async {
          await tester.testWidget(
            filename: 'login_page/when_login_button_is_disabled',
            widget: const LoginPage(),
            overrides: [
              loginViewModelProvider.overrideWith((ref) => MockLoginViewModel(
                    const CommonState(
                      data: LoginState(),
                    ),
                  )),
            ],
          );
        },
      );

      testGoldens(
        'when login button is enabled',
        (tester) async {
          await tester.testWidget(
            filename: 'login_page/when_login_button_is_enabled',
            widget: const LoginPage(),
            onCreate: (tester) async {
              final primaryTextFieldFinder = find.byType(PrimaryTextField);
              expect(primaryTextFieldFinder, findsExactly(2));
              final emailTextField = primaryTextFieldFinder.first;
              final passwordTextField = primaryTextFieldFinder.at(1);
              await tester.enterText(
                emailTextField,
                'this is a long long long long email email email @ g m a i l . com',
              );
              await tester.enterText(passwordTextField, '1234567890987654321!@#%^&*()_+');
            },
            overrides: [
              loginViewModelProvider.overrideWith(
                (ref) => MockLoginViewModel(
                  const CommonState(
                    data: LoginState(
                      email: 'this is a long long long long email email email @ g m a i l . com',
                      password: '1234567890987654321!@#%^&*()_+',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );

      testGoldens(
        'when error text is visible',
        (tester) async {
          await tester.testWidget(
            filename: 'login_page/when_error_text_is_visible',
            widget: const LoginPage(),
            overrides: [
              loginViewModelProvider.overrideWith(
                (ref) => MockLoginViewModel(
                  const CommonState(
                    data: LoginState(onPageError: 'This is an error'),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
