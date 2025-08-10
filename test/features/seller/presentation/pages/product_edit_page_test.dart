import 'package:flutter_test/flutter_test.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/product_edit_models.dart';

void main() {
  group('ProductMaterials Data Conversion Tests', () {
    test('Should convert QA items to PROBLEM type ProductMaterials', () {
      // Arrange
      final qaItems = [
        QAPair(question: '产品保修期多久？', answer: '提供一年免费保修'),
        QAPair(question: '支持哪些支付方式？', answer: '支持支付宝、微信支付'),
      ];
      
      // Act
      final materials = <ProductMaterial>[];
      int materialId = 1;
      for (final qa in qaItems) {
        materials.add(ProductMaterial(
          id: materialId++,
          question: qa.question,
          answer: qa.answer,
          type: 'PROBLEM',
        ));
      }
      
      // Assert
      expect(materials.length, 2);
      expect(materials[0].type, 'PROBLEM');
      expect(materials[0].question, '产品保修期多久？');
      expect(materials[0].answer, '提供一年免费保修');
      expect(materials[1].type, 'PROBLEM');
      expect(materials[1].question, '支持哪些支付方式？');
      expect(materials[1].answer, '支持支付宝、微信支付');
    });
    
    test('Should convert BuyerInfoItems to TEXT/ATTACHMENT type ProductMaterials', () {
      // Arrange
      final buyerInfoItems = [
        BuyerInfoItem(
          type: BuyerInfoType.text,
          label: '产品规格要求',
          description: '请详细说明您需要的产品规格',
          isRequired: true,
        ),
        BuyerInfoItem(
          type: BuyerInfoType.image,
          label: '参考图片',
          description: '请上传产品参考图片',
          isRequired: false,
        ),
        BuyerInfoItem(
          type: BuyerInfoType.file,
          label: '设计文件',
          description: '请上传设计源文件',
          isRequired: true,
        ),
      ];
      
      // Act
      final materials = <ProductMaterial>[];
      int buyerInfoMaterialId = 1000;
      for (final item in buyerInfoItems) {
        String materialType = 'TEXT';
        if (item.type == BuyerInfoType.file || item.type == BuyerInfoType.image) {
          materialType = 'ATTACHMENT';
        }
        
        materials.add(ProductMaterial(
          id: buyerInfoMaterialId++,
          question: item.label,
          answer: item.description,
          type: materialType,
        ));
      }
      
      // Assert
      expect(materials.length, 3);
      
      // First item should be TEXT type
      expect(materials[0].type, 'TEXT');
      expect(materials[0].question, '产品规格要求');
      expect(materials[0].answer, '请详细说明您需要的产品规格');
      
      // Second item should be ATTACHMENT type (image)
      expect(materials[1].type, 'ATTACHMENT');
      expect(materials[1].question, '参考图片');
      expect(materials[1].answer, '请上传产品参考图片');
      
      // Third item should be ATTACHMENT type (file)
      expect(materials[2].type, 'ATTACHMENT');
      expect(materials[2].question, '设计文件');
      expect(materials[2].answer, '请上传设计源文件');
    });
    
    test('Should combine QA and BuyerInfo items into single ProductMaterials list', () {
      // Arrange
      final qaItems = [
        QAPair(question: '交货时间？', answer: '7个工作日'),
      ];
      
      final buyerInfoItems = [
        BuyerInfoItem(
          type: BuyerInfoType.text,
          label: '详细需求',
          description: '请描述您的详细需求',
          isRequired: true,
        ),
        BuyerInfoItem(
          type: BuyerInfoType.image,
          label: '样品图片',
          description: '请上传样品图片',
          isRequired: false,
        ),
      ];
      
      // Act
      final materials = <ProductMaterial>[];
      
      // Convert QA items
      int materialId = 1;
      for (final qa in qaItems) {
        materials.add(ProductMaterial(
          id: materialId++,
          question: qa.question,
          answer: qa.answer,
          type: 'PROBLEM',
        ));
      }
      
      // Convert BuyerInfo items
      int buyerInfoMaterialId = 1000;
      for (final item in buyerInfoItems) {
        String materialType = 'TEXT';
        if (item.type == BuyerInfoType.file || item.type == BuyerInfoType.image) {
          materialType = 'ATTACHMENT';
        }
        
        materials.add(ProductMaterial(
          id: buyerInfoMaterialId++,
          question: item.label,
          answer: item.description,
          type: materialType,
        ));
      }
      
      // Assert
      expect(materials.length, 3);
      
      // QA item
      expect(materials[0].type, 'PROBLEM');
      expect(materials[0].id, 1);
      
      // BuyerInfo items
      expect(materials[1].type, 'TEXT');
      expect(materials[1].id, 1000);
      
      expect(materials[2].type, 'ATTACHMENT');
      expect(materials[2].id, 1001);
    });
    
    test('Should handle empty lists correctly', () {
      // Arrange
      final qaItems = <QAPair>[];
      final buyerInfoItems = <BuyerInfoItem>[];
      
      // Act
      final materials = <ProductMaterial>[];
      
      int materialId = 1;
      for (final qa in qaItems) {
        materials.add(ProductMaterial(
          id: materialId++,
          question: qa.question,
          answer: qa.answer,
          type: 'PROBLEM',
        ));
      }
      
      int buyerInfoMaterialId = 1000;
      for (final item in buyerInfoItems) {
        String materialType = 'TEXT';
        if (item.type == BuyerInfoType.file || item.type == BuyerInfoType.image) {
          materialType = 'ATTACHMENT';
        }
        
        materials.add(ProductMaterial(
          id: buyerInfoMaterialId++,
          question: item.label,
          answer: item.description,
          type: materialType,
        ));
      }
      
      // Assert
      expect(materials.isEmpty, true);
    });
  });
}