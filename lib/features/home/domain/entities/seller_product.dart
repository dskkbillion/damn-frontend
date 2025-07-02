class SellerProduct {
  final int id;
  final int tenantId;
  final List<String> images;
  final String name;
  final String description;
  final double sellingPrice;
  final int viewNumber;
  final int buyedNumber;
  final List<SellerProductVariant> variants;
  final SellerInfo? tenant;

  SellerProduct({
    required this.id,
    required this.tenantId,
    required this.images,
    required this.name,
    required this.description,
    required this.sellingPrice,
    required this.viewNumber,
    required this.buyedNumber,
    required this.variants,
    this.tenant,
  });

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    final List<dynamic> variantsJson = json['variants'] ?? [];
    final List<SellerProductVariant> variants = variantsJson
        .map((variant) => SellerProductVariant.fromJson(variant))
        .toList();

    // 处理嵌套的图片URL数组
    List<String> processImages(dynamic imagesData) {
      if (imagesData == null) return [];
      
      List<String> result = [];
      if (imagesData is List) {
        for (var item in imagesData) {
          if (item is String) {
            // 直接是字符串的情况
            result.add(item);
          } else if (item is List) {
            // 嵌套数组的情况，如[["url"]]
            for (var subItem in item) {
              if (subItem is String) {
                result.add(subItem);
              }
            }
          } else if (item.toString().startsWith('[') && item.toString().endsWith(']')) {
            // JSON字符串的情况，如"[\"url\"]"
            try {
              // 简单处理，提取引号之间的内容
              final regex = RegExp(r'"([^"]*)"');
              final matches = regex.allMatches(item.toString());
              for (var match in matches) {
                if (match.group(1) != null) {
                  result.add(match.group(1)!);
                }
              }
            } catch (e) {
              print('Error parsing image URL: $e');
            }
          }
        }
      }
      return result;
    }

    return SellerProduct(
      id: json['id'] ?? 0,
      tenantId: json['tenantId'] ?? 0,
      images: processImages(json['images']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sellingPrice: double.tryParse(json['sellingPrice']?.toString() ?? '0') ?? 0.0,
      viewNumber: json['viewNumber'] ?? 0,
      buyedNumber: json['buyedNumber'] ?? 0,
      variants: variants,
      tenant: json['tenant'] != null ? SellerInfo.fromJson(json['tenant']) : null,
    );
  }
}

class SellerProductVariant {
  final int id;
  final String name;
  final double sellingPrice;
  final int deliveryDay;
  final int editNum;
  final List<Map<String, dynamic>> features;

  SellerProductVariant({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.deliveryDay,
    required this.editNum,
    required this.features,
  });

  factory SellerProductVariant.fromJson(Map<String, dynamic> json) {
    return SellerProductVariant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sellingPrice: double.tryParse(json['sellingPrice']?.toString() ?? '0') ?? 0.0,
      deliveryDay: json['deliveryDay'] ?? 0,
      editNum: json['editNum'] ?? 0,
      features: (json['feature'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
    );
  }
}

class SellerInfo {
  final int id;
  final String nickName;
  final String? trueName;
  final String? avatar;
  final String? remarks;
  final bool? memberAttention;
  final int fansCount;

  SellerInfo({
    required this.id,
    required this.nickName,
    this.trueName,
    this.avatar,
    this.remarks,
    this.memberAttention,
    this.fansCount = 0,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'] ?? 0,
      nickName: json['nickName'] ?? '',
      trueName: json['trueName'],
      avatar: json['avatar'],
      remarks: json['remarks'],
      memberAttention: json['memberAttention'] ?? false,
      fansCount: json['fansCount'] ?? 0,
    );
  }
} 