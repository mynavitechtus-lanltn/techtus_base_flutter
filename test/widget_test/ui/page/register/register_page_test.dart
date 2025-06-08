import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

class MockRegisterViewModel extends StateNotifier<CommonState<RegisterState>>
    with Mock
    implements RegisterViewModel {
  MockRegisterViewModel(super.state);
}

void main() {
  group(
    'RegisterPage',
    () {
      testGoldens(
        'when register button is disabled',
        (tester) async {
          await tester.testWidget(
            filename: 'register_page/${TestUtil.filename('when_register_button_is_disabled')}',
            widget: const RegisterPage(),
            overrides: [
              registerViewModelProvider.overrideWith(
                (ref) => MockRegisterViewModel(
                  const CommonState(
                    data: RegisterState(),
                  ),
                ),
              ),
            ],
          );
        },
      );

      testGoldens(
        'when register button is enabled',
        (tester) async {
          await tester.testWidget(
            filename: 'register_page/${TestUtil.filename('when_register_button_is_enabled')}',
            widget: const RegisterPage(),
            onCreate: (tester) async {
              final primaryTextFieldFinder = find.byType(PrimaryTextField);
              expect(primaryTextFieldFinder, findsExactly(3));
              final emailTextField = primaryTextFieldFinder.first;
              final passwordTextField = primaryTextFieldFinder.at(1);
              final passwordConfirmationTextField = primaryTextFieldFinder.at(2);
              await tester.enterText(
                emailTextField,
                'this is a long long long long email email email @ g m a i l . com',
              );
              await tester.enterText(passwordTextField, '1234567890987654321!@#%^&*()_+');
              await tester.enterText(passwordConfirmationTextField, '123456789098');
            },
            overrides: [
              registerViewModelProvider.overrideWith(
                (ref) => MockRegisterViewModel(
                  const CommonState(
                    data: RegisterState(
                      email: 'this is a long long long long email email email @ g m a i l . com',
                      password: '1234567890987654321!@#%^&*()_+',
                      confirmPassword: '123456789098',
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
            filename: 'register_page/${TestUtil.filename('when_error_text_is_visible')}',
            widget: const RegisterPage(),
            overrides: [
              registerViewModelProvider.overrideWith(
                (ref) => MockRegisterViewModel(
                  const CommonState(
                    data: RegisterState(onPageError: 'This is an error'),
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
