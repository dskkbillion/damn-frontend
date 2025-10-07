import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/core/utils/phone_validator.dart';

void main() {
  group('PhoneValidator', () {
    group('中国 (CN)', () {
      test('应接受11位以1开头的手机号', () {
        final result = PhoneValidator.validate('13812345678', 'CN');
        expect(result.isValid, true);
      });

      test('应拒绝不以1开头的11位号码', () {
        final result = PhoneValidator.validate('23812345678', 'CN');
        expect(result.isValid, false);
      });

      test('应拒绝不足11位的号码', () {
        final result = PhoneValidator.validate('1381234567', 'CN');
        expect(result.isValid, false);
      });

      test('应拒绝超过11位的号码', () {
        final result = PhoneValidator.validate('138123456789', 'CN');
        expect(result.isValid, false);
      });
    });

    group('美国 (US)', () {
      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('2025551234', 'US');
        expect(result.isValid, true);
      });

      test('应拒绝11位中国手机号 (Issue #158)', () {
        final result = PhoneValidator.validate('13812345678', 'US');
        expect(result.isValid, false);
        expect(result.errorMessage, contains('10-digit'));
      });

      test('应拒绝9位号码', () {
        final result = PhoneValidator.validate('202555123', 'US');
        expect(result.isValid, false);
      });
    });

    group('加拿大 (CA)', () {
      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('4165551234', 'CA');
        expect(result.isValid, true);
      });

      test('应拒绝11位号码', () {
        final result = PhoneValidator.validate('41655512345', 'CA');
        expect(result.isValid, false);
      });
    });

    group('日本 (JP)', () {
      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('9012345678', 'JP');
        expect(result.isValid, true);
      });

      test('应拒绝11位号码', () {
        final result = PhoneValidator.validate('90123456789', 'JP');
        expect(result.isValid, false);
      });
    });

    group('韩国 (KR)', () {
      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('1012345678', 'KR');
        expect(result.isValid, true);
      });

      test('应拒绝9位号码', () {
        final result = PhoneValidator.validate('101234567', 'KR');
        expect(result.isValid, false);
      });
    });

    group('英国 (GB)', () {
      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('7912345678', 'GB');
        expect(result.isValid, true);
      });

      test('应拒绝9位号码', () {
        final result = PhoneValidator.validate('791234567', 'GB');
        expect(result.isValid, false);
      });
    });

    group('德国 (DE)', () {
      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('1512345678', 'DE');
        expect(result.isValid, true);
      });

      test('应拒绝9位号码', () {
        final result = PhoneValidator.validate('151234567', 'DE');
        expect(result.isValid, false);
      });
    });

    group('澳大利亚 (AU)', () {
      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('0412345678', 'AU');
        expect(result.isValid, true);
      });

      test('应拒绝9位号码', () {
        final result = PhoneValidator.validate('041234567', 'AU');
        expect(result.isValid, false);
      });
    });

    group('法国 (FR)', () {
      test('应接受9位手机号', () {
        final result = PhoneValidator.validate('612345678', 'FR');
        expect(result.isValid, true);
      });

      test('应拒绝10位号码', () {
        final result = PhoneValidator.validate('6123456789', 'FR');
        expect(result.isValid, false);
      });
    });

    group('泰国 (TH)', () {
      test('应接受9位手机号', () {
        final result = PhoneValidator.validate('812345678', 'TH');
        expect(result.isValid, true);
      });

      test('应拒绝10位号码', () {
        final result = PhoneValidator.validate('8123456789', 'TH');
        expect(result.isValid, false);
      });
    });

    group('新加坡 (SG)', () {
      test('应接受8位手机号', () {
        final result = PhoneValidator.validate('81234567', 'SG');
        expect(result.isValid, true);
      });

      test('应拒绝9位号码', () {
        final result = PhoneValidator.validate('812345678', 'SG');
        expect(result.isValid, false);
      });

      test('应拒绝7位号码', () {
        final result = PhoneValidator.validate('8123456', 'SG');
        expect(result.isValid, false);
      });
    });

    group('马来西亚 (MY)', () {
      test('应接受9位手机号', () {
        final result = PhoneValidator.validate('123456789', 'MY');
        expect(result.isValid, true);
      });

      test('应接受10位手机号', () {
        final result = PhoneValidator.validate('1234567890', 'MY');
        expect(result.isValid, true);
      });

      test('应拒绝8位号码', () {
        final result = PhoneValidator.validate('12345678', 'MY');
        expect(result.isValid, false);
      });

      test('应拒绝11位号码', () {
        final result = PhoneValidator.validate('12345678901', 'MY');
        expect(result.isValid, false);
      });
    });

    group('其他国家 (默认)', () {
      test('应接受7位号码', () {
        final result = PhoneValidator.validate('1234567', 'XX');
        expect(result.isValid, true);
      });

      test('应接受15位号码', () {
        final result = PhoneValidator.validate('123456789012345', 'XX');
        expect(result.isValid, true);
      });

      test('应拒绝6位号码', () {
        final result = PhoneValidator.validate('123456', 'XX');
        expect(result.isValid, false);
      });

      test('应拒绝16位号码', () {
        final result = PhoneValidator.validate('1234567890123456', 'XX');
        expect(result.isValid, false);
      });
    });

    group('isValid 便捷方法', () {
      test('应返回true当号码有效', () {
        expect(PhoneValidator.isValid('13812345678', 'CN'), true);
      });

      test('应返回false当号码无效', () {
        expect(PhoneValidator.isValid('23812345678', 'CN'), false);
      });
    });

    group('格式处理', () {
      test('应接受带有格式字符的号码', () {
        final result = PhoneValidator.validate('138-1234-5678', 'CN');
        expect(result.isValid, true);
      });

      test('应接受带有空格的号码', () {
        final result = PhoneValidator.validate('138 1234 5678', 'CN');
        expect(result.isValid, true);
      });

      test('应接受带有括号的号码', () {
        final result = PhoneValidator.validate('(138) 1234-5678', 'CN');
        expect(result.isValid, true);
      });
    });
  });
}
