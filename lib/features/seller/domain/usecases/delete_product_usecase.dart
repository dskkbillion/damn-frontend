import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// 删除商品参数
class DeleteProductParams extends Equatable {
  /// 商品ID列表
  final List<int> productIds;
  
  /// 商品信息（用于判断是否需要先下架）
  final List<SellerManagedProduct>? products;

  /// 构造函数
  const DeleteProductParams({
    required this.productIds,
    this.products,
  });

  @override
  List<Object?> get props => [productIds, products];
}

/// 删除商品UseCase
@injectable
class DeleteProductUseCase implements UseCase<bool, DeleteProductParams> {
  final ISellerRepository _sellerRepository;

  /// 构造函数
  DeleteProductUseCase(this._sellerRepository);

  @override
  Future<Either<Failure, bool>> call(DeleteProductParams params) async {
    try {
      // 如果没有提供商品信息，直接尝试删除（向后兼容）
      if (params.products == null || params.products!.isEmpty) {
        AppLogger.d('DeleteProductUseCase: 没有商品信息，直接删除');
        return await _sellerRepository.deleteProduct(params.productIds);
      }

      // 遍历每个商品，根据状态进行不同操作
      for (int i = 0; i < params.productIds.length; i++) {
        final productId = params.productIds[i];
        final product = params.products!.length > i ? params.products![i] : null;
        
        AppLogger.d('=== 删除商品 $productId ===');
        AppLogger.d('商品名称: ${product?.name}');
        AppLogger.d('商品状态: ${product?.status}');
        AppLogger.d('状态值: ${product?.status.value}');
        
        // 判断是否为草稿商品（需要先下架再删除）
        if (product != null && _isDraftProduct(product)) {
          AppLogger.d('检测到草稿商品，执行两步删除流程');
          
          // 步骤1：先下架草稿商品
          AppLogger.d('步骤1：下架草稿商品');
          final offlineResult = await _sellerRepository.updateProductStatus(
            productId, 
            'disabled'  // 使用小写，匹配后端枚举值
          );
          
          if (offlineResult.isLeft()) {
            AppLogger.d('下架失败，终止删除流程');
            return offlineResult.map((r) => false);
          }
          
          AppLogger.d('下架成功，继续删除流程');
        }
        
        // 步骤2：删除商品（带重试机制）
        AppLogger.d('步骤2：删除商品');
        
        // 重试删除，因为后端状态同步可能有延迟
        Either<Failure, bool>? finalDeleteResult;
        
        for (int attempt = 1; attempt <= 3; attempt++) {
          AppLogger.d('删除尝试 $attempt/3');
          
          if (attempt > 1) {
            // 第2、3次尝试前等待更长时间
            final waitTime = Duration(seconds: attempt);
            AppLogger.d('等待 ${waitTime.inSeconds} 秒后重试...');
            await Future.delayed(waitTime);
          }
          
          final deleteResult = await _sellerRepository.deleteProduct([productId]);
          finalDeleteResult = deleteResult;
          
          if (deleteResult.isRight()) {
            AppLogger.d('删除成功 (第 $attempt 次尝试)');
            break;
          } else {
            AppLogger.d('删除失败 (第 $attempt 次尝试): ${deleteResult.fold((l) => l.message, (r) => "")}');
            
            if (attempt == 3) {
              // 最后一次尝试失败，返回错误
              AppLogger.d('所有删除尝试都失败，放弃删除');
              return deleteResult;
            }
          }
        }
        
        // 检查最终结果
        if (finalDeleteResult != null && finalDeleteResult.isLeft()) {
          AppLogger.d('最终删除失败');
          return finalDeleteResult;
        }
        
        AppLogger.d('删除成功');
      }
      
      AppLogger.d('所有商品删除完成');
      return const Right(true);
      
    } catch (e) {
      AppLogger.d('删除商品异常: $e');
      return Left(ServerFailure(message: '删除商品失败: $e'));
    }
  }
  
  /// 判断是否为草稿商品（需要先下架的商品）
  bool _isDraftProduct(SellerManagedProduct product) {
    // 草稿商品的特征：显示为草稿状态
    // 草稿商品在后端通常是 state="normal" + productType="draft"
    // 但前端会将其映射为 ProductStatus.draft
    return product.status == ProductStatus.draft;
  }
} 