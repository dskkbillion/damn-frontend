import 'package:equatable/equatable.dart';

/// 商品翻译值对象，承载 UGC 翻译服务返回的翻译数据
class ProductTranslation extends Equatable {
  /// 翻译后的商品名称
  final String? translatedName;

  /// 翻译后的商品描述
  final String? translatedDescription;

  /// 源语言代码（如 zh, en, ja）
  final String? sourceLang;

  /// 目标语言代码
  final String? targetLang;

  /// 翻译提供方（如 deepl）
  final String? provider;

  const ProductTranslation({
    this.translatedName,
    this.translatedDescription,
    this.sourceLang,
    this.targetLang,
    this.provider,
  });

  /// 源/目标同语言 — 后端可能仍返回 translation 数据但实际无翻译需求,
  /// 此时应回退到原文,避免显示空翻译或与原文相同的内容 (#341)。
  bool get _sameLanguage =>
      sourceLang != null &&
      targetLang != null &&
      sourceLang!.toLowerCase() == targetLang!.toLowerCase();

  /// 是否包含有效的翻译内容
  bool get hasTranslation =>
      !_sameLanguage &&
      ((translatedName != null && translatedName!.isNotEmpty) ||
          (translatedDescription != null && translatedDescription!.isNotEmpty));

  /// 返回翻译名称，若无翻译则回退到原始名称
  String nameOrOriginal(String original) {
    if (_sameLanguage) return original;
    if (translatedName != null && translatedName!.isNotEmpty) {
      return translatedName!;
    }
    return original;
  }

  /// 返回翻译描述，若无翻译则回退到原始描述
  String descriptionOrOriginal(String original) {
    if (_sameLanguage) return original;
    if (translatedDescription != null && translatedDescription!.isNotEmpty) {
      return translatedDescription!;
    }
    return original;
  }

  @override
  List<Object?> get props => [
        translatedName,
        translatedDescription,
        sourceLang,
        targetLang,
        provider,
      ];
}
