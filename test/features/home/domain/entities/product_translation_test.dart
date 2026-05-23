import 'package:dskk_flutter_refactor/features/home/domain/entities/product_translation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductTranslation _sameLanguage 回退 (#341)', () {
    test('源/目标同语言 → nameOrOriginal 强制回退到原文', () {
      const t = ProductTranslation(
        translatedName: '不应展示的译文',
        sourceLang: 'zh',
        targetLang: 'zh',
      );
      expect(t.nameOrOriginal('原文'), '原文');
    });

    test('源/目标同语言 (大小写不同) → 仍判定同语言', () {
      const t = ProductTranslation(
        translatedName: 'wont show',
        sourceLang: 'EN',
        targetLang: 'en',
      );
      expect(t.nameOrOriginal('original'), 'original');
    });

    test('源/目标同语言 → descriptionOrOriginal 强制回退到原文', () {
      const t = ProductTranslation(
        translatedDescription: '不应展示',
        sourceLang: 'zh',
        targetLang: 'zh',
      );
      expect(t.descriptionOrOriginal('原描述'), '原描述');
    });

    test('源/目标同语言 → hasTranslation 为 false', () {
      const t = ProductTranslation(
        translatedName: '不应算翻译',
        sourceLang: 'zh',
        targetLang: 'zh',
      );
      expect(t.hasTranslation, isFalse);
    });

    test('源/目标不同 → 仍走正常翻译路径', () {
      const t = ProductTranslation(
        translatedName: '中文',
        sourceLang: 'en',
        targetLang: 'zh',
      );
      expect(t.nameOrOriginal('English'), '中文');
      expect(t.hasTranslation, isTrue);
    });

    test('sourceLang 为 null → 走正常翻译路径', () {
      const t = ProductTranslation(translatedName: '中文', targetLang: 'zh');
      expect(t.nameOrOriginal('English'), '中文');
      expect(t.hasTranslation, isTrue);
    });

    test('targetLang 为 null → 走正常翻译路径', () {
      const t = ProductTranslation(translatedName: '中文', sourceLang: 'en');
      expect(t.nameOrOriginal('English'), '中文');
    });

    test('无翻译 + 源目标同语言 → 仍回退到原文', () {
      const t = ProductTranslation(sourceLang: 'zh', targetLang: 'zh');
      expect(t.nameOrOriginal('原文'), '原文');
      expect(t.hasTranslation, isFalse);
    });
  });
}
