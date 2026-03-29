/// Pre-defined fixture data for integration tests.
///
/// All responses mirror the shape returned by the real backend API.
class MockData {
  MockData._();

  // ==================== Auth ====================
  static const Map<String, dynamic> loginResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'token': 'mock_token_abc123',
      'refreshToken': 'mock_refresh_token_xyz',
      'user': {
        'id': 'user_001',
        'nickname': 'TestUser',
        'phone': '13800138000',
        'avatar': '',
        'role': 'buyer',
      },
    },
  };

  static const Map<String, dynamic> userProfile = {
    'code': 200,
    'message': 'success',
    'data': {
      'id': 'user_001',
      'nickname': 'TestUser',
      'phone': '13800138000',
      'avatar': '',
      'role': 'buyer',
      'balance': 1000.0,
    },
  };

  // ==================== Products / Services ====================
  static const Map<String, dynamic> productListResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'list': [
        {
          'id': 'prod_001',
          'title': 'Logo Design Service',
          'description': 'Professional logo design',
          'price': 99.0,
          'currency': 'USD',
          'coverImage': '',
          'sellerId': 'seller_001',
          'sellerName': 'DesignPro',
          'status': 'active',
          'category': 'design',
        },
        {
          'id': 'prod_002',
          'title': 'Translation Service',
          'description': 'EN-CN professional translation',
          'price': 50.0,
          'currency': 'USD',
          'coverImage': '',
          'sellerId': 'seller_002',
          'sellerName': 'LangExpert',
          'status': 'active',
          'category': 'translation',
        },
        {
          'id': 'prod_003',
          'title': 'Code Review',
          'description': 'Senior engineer code review',
          'price': 150.0,
          'currency': 'USD',
          'coverImage': '',
          'sellerId': 'seller_003',
          'sellerName': 'CodeMaster',
          'status': 'active',
          'category': 'tech',
        },
      ],
      'total': 3,
      'page': 1,
      'pageSize': 20,
    },
  };

  static const Map<String, dynamic> productDetailResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'id': 'prod_001',
      'title': 'Logo Design Service',
      'description': 'Professional logo design with 3 revisions',
      'price': 99.0,
      'currency': 'USD',
      'coverImage': '',
      'images': <String>[],
      'sellerId': 'seller_001',
      'sellerName': 'DesignPro',
      'sellerAvatar': '',
      'status': 'active',
      'category': 'design',
      'deliveryTime': '3 days',
      'rating': 4.8,
      'reviewCount': 25,
    },
  };

  // ==================== Orders ====================
  static const Map<String, dynamic> buyerOrderListResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'list': [
        {
          'id': 'order_001',
          'productId': 'prod_001',
          'productTitle': 'Logo Design Service',
          'status': 'completed',
          'price': 99.0,
          'currency': 'USD',
          'sellerId': 'seller_001',
          'sellerName': 'DesignPro',
          'createdAt': '2026-03-20T10:00:00Z',
        },
        {
          'id': 'order_002',
          'productId': 'prod_002',
          'productTitle': 'Translation Service',
          'status': 'in_progress',
          'price': 50.0,
          'currency': 'USD',
          'sellerId': 'seller_002',
          'sellerName': 'LangExpert',
          'createdAt': '2026-03-25T14:30:00Z',
        },
      ],
      'total': 2,
      'page': 1,
      'pageSize': 20,
    },
  };

  static const Map<String, dynamic> sellerOrderListResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'list': [
        {
          'id': 'order_003',
          'productId': 'prod_001',
          'productTitle': 'Logo Design Service',
          'status': 'pending',
          'price': 99.0,
          'currency': 'USD',
          'buyerId': 'user_002',
          'buyerName': 'Client A',
          'createdAt': '2026-03-28T09:00:00Z',
        },
      ],
      'total': 1,
      'page': 1,
      'pageSize': 20,
    },
  };

  // ==================== Chat ====================
  static const Map<String, dynamic> chatRoomListResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'list': [
        {
          'id': 'room_001',
          'name': 'DesignPro',
          'lastMessage': 'Your logo is ready!',
          'lastMessageTime': '2026-03-28T18:00:00Z',
          'unreadCount': 1,
          'avatar': '',
          'type': 'private',
        },
        {
          'id': 'room_002',
          'name': 'LangExpert',
          'lastMessage': 'Translation in progress...',
          'lastMessageTime': '2026-03-27T12:00:00Z',
          'unreadCount': 0,
          'avatar': '',
          'type': 'private',
        },
      ],
      'total': 2,
    },
  };

  static const Map<String, dynamic> chatMessagesResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'list': [
        {
          'id': 'msg_001',
          'roomId': 'room_001',
          'senderId': 'seller_001',
          'content': 'Your logo is ready!',
          'type': 'text',
          'createdAt': '2026-03-28T18:00:00Z',
        },
        {
          'id': 'msg_002',
          'roomId': 'room_001',
          'senderId': 'user_001',
          'content': 'Great, let me check!',
          'type': 'text',
          'createdAt': '2026-03-28T17:55:00Z',
        },
      ],
      'total': 2,
    },
  };

  // ==================== Generic ====================
  static const Map<String, dynamic> emptyListResponse = {
    'code': 200,
    'message': 'success',
    'data': {
      'list': <dynamic>[],
      'total': 0,
      'page': 1,
      'pageSize': 20,
    },
  };

  static const Map<String, dynamic> successResponse = {
    'code': 200,
    'message': 'success',
    'data': null,
  };

  static const Map<String, dynamic> errorResponse = {
    'code': 500,
    'message': 'Internal server error',
    'data': null,
  };
}
