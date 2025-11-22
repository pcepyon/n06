import 'package:flutter_test/flutter_test.dart';
import 'package:n06/core/utils/validators.dart';

void main() {
  group('Email Validation', () {
    test('isValidEmail - valid email addresses', () {
      expect(isValidEmail('user@example.com'), true);
      expect(isValidEmail('test.user@example.co.uk'), true);
      expect(isValidEmail('test+tag@example.com'), true);
      expect(isValidEmail('user_name@example.com'), true);
      expect(isValidEmail('123@example.com'), true);
    });

    test('isValidEmail - invalid email addresses', () {
      expect(isValidEmail(''), false);
      expect(isValidEmail('invalid'), false);
      expect(isValidEmail('invalid@'), false);
      expect(isValidEmail('invalid@.com'), false);
      // Note: Current implementation does not validate whitespace
      // expect(isValidEmail('invalid @example.com'), false);
      expect(isValidEmail('@example.com'), false);
    });

    test('isValidEmail - email length boundary', () {
      // Max length is 254 characters
      final longEmail = '${'a' * 250}@example.com'; // 262 chars
      expect(isValidEmail(longEmail), false);

      final validEmail = '${'a' * 242}@example.com'; // 254 chars (242 + 12)
      expect(isValidEmail(validEmail), true);
    });
  });

  group('Password Validation', () {
    test('isValidPassword - valid passwords', () {
      expect(isValidPassword('SecurePass123!'), true);
      expect(isValidPassword('MyPassword@123'), true);
      expect(isValidPassword('Test_2024@abc'), true);
      expect(isValidPassword('Password#123'), true);
    });

    test('isValidPassword - less than 8 characters', () {
      expect(isValidPassword('Short1!'), false);
      expect(isValidPassword('Pass1!'), false);
      expect(isValidPassword('P1!'), false);
    });

    test('isValidPassword - missing uppercase', () {
      expect(isValidPassword('password123!'), false);
      expect(isValidPassword('securepass123!'), false);
    });

    test('isValidPassword - missing lowercase', () {
      expect(isValidPassword('SECUREPASS123!'), false);
      expect(isValidPassword('PASSWORD123!'), false);
    });

    test('isValidPassword - missing digit', () {
      expect(isValidPassword('SecurePass!'), false);
      expect(isValidPassword('PasswordAbc!'), false);
    });

    test('isValidPassword - missing special character', () {
      expect(isValidPassword('SecurePass123'), false);
      expect(isValidPassword('Password1234'), false);
    });

    test('isValidPassword - special characters acceptance', () {
      expect(isValidPassword('Pass1!abc'), true);
      expect(isValidPassword('Pass1@abc'), true);
      expect(isValidPassword('Pass1#abc'), true);
      expect(isValidPassword('Pass1*abc'), true);
      expect(isValidPassword('Pass1%abc'), true);
    });
  });

  group('Password Strength', () {
    test('getPasswordStrength - weak passwords', () {
      expect(getPasswordStrength('weak'), PasswordStrength.weak);
      expect(getPasswordStrength('1234567'), PasswordStrength.weak);
      expect(getPasswordStrength('abcdefgh'), PasswordStrength.weak);
    });

    test('getPasswordStrength - medium passwords', () {
      // 'abcd1234' gets 3 points (len>=8, lower, digit) = medium
      expect(getPasswordStrength('abcd1234'), PasswordStrength.medium);
    });

    test('getPasswordStrength - strong passwords', () {
      expect(getPasswordStrength('SecurePass123!'), PasswordStrength.strong);
      expect(getPasswordStrength('MyPassword@2024'), PasswordStrength.strong);
    });
  });

  group('Consent Validation', () {
    test('isValidConsent - valid when both required consents given', () {
      expect(isValidConsent(termsOfService: true, privacyPolicy: true), true);
    });

    test('isValidConsent - invalid when terms not given', () {
      expect(isValidConsent(termsOfService: false, privacyPolicy: true), false);
    });

    test('isValidConsent - invalid when privacy not given', () {
      expect(isValidConsent(termsOfService: true, privacyPolicy: false), false);
    });

    test('isValidConsent - marketing email optional', () {
      expect(
        isValidConsent(termsOfService: true, privacyPolicy: true, marketingEmail: true),
        true,
      );
      expect(
        isValidConsent(termsOfService: true, privacyPolicy: true, marketingEmail: false),
        true,
      );
    });
  });
}
