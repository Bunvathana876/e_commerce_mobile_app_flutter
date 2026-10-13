import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerc_mobile_app/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('email validator accepts standard and modern domains', () {
      expect(Validators.email('student@example.com'), isNull);
      expect(Validators.email('bun.vathana@university.edu.kh'), isNull);
      expect(Validators.email('dev@startup.tech'), isNull);
      expect(Validators.email('support@online.store'), isNull);
    });

    test('email validator rejects invalid emails', () {
      expect(Validators.email(null), 'Please enter your email');
      expect(Validators.email(''), 'Please enter your email');
      expect(Validators.email('   '), 'Please enter your email');
      expect(Validators.email('notanemail'), 'Enter a valid email address');
      expect(Validators.email('@nodomain.com'), 'Enter a valid email address');
      expect(Validators.email('user@'), 'Enter a valid email address');
    });

    test('password validator enforces 6+ characters', () {
      expect(Validators.password(null), 'Please enter your password');
      expect(Validators.password(''), 'Please enter your password');
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters long',
      );
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('securePassword!'), isNull);
    });
  });
}
