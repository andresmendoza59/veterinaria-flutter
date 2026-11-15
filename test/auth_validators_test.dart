import 'package:flutter_app/validators/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    test('rechaza correo vacío', () {
      expect(AuthValidators.validateEmail(''), 'El correo es obligatorio');
      expect(AuthValidators.validateEmail(null), 'El correo es obligatorio');
      expect(AuthValidators.validateEmail('   '), 'El correo es obligatorio');
    });

    test('rechaza correo sin @ o sin punto', () {
      expect(
        AuthValidators.validateEmail('ana.com'),
        'Ingrese un correo válido',
      );
      expect(
        AuthValidators.validateEmail('ana@correo'),
        'Ingrese un correo válido',
      );
    });

    test('acepta un correo válido aunque tenga espacios alrededor', () {
      expect(AuthValidators.validateEmail('ana@correo.com'), isNull);
      expect(AuthValidators.validateEmail('  ana@correo.com  '), isNull);
    });
  });

  group('validatePassword', () {
    test('rechaza contraseña vacía', () {
      expect(
        AuthValidators.validatePassword(''),
        'La contraseña es obligatoria',
      );
      expect(
        AuthValidators.validatePassword(null),
        'La contraseña es obligatoria',
      );
    });

    test('exige mínimo 6 caracteres', () {
      expect(
        AuthValidators.validatePassword('12345'),
        'La contraseña debe tener mínimo 6 caracteres',
      );
      expect(AuthValidators.validatePassword('123456'), isNull);
    });
  });
}
