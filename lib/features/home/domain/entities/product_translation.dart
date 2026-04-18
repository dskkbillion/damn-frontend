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

  /// 是否包含有效的翻译内容
  bool get hasTranslation =>
      (translatedName != null && translatedName!.isNotEmpty) ||
      (translatedDescription != null && translatedDescription!.isNotEmpty);

  /// 返回翻译名称，若无翻译则回退到原始名称
  String nameOrOriginal(String original) {
    if (translatedName != null && translatedName!.isNotEmpty) {
      return translatedName!;
    }
    return original;
  }

  /// 返回翻译描述，若无翻译则回退到原始描述
  String descriptionOrOriginal(String original) {
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
