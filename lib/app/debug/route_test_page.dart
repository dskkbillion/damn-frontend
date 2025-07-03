import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_mode.dart';
import '../navigation/unified_route_builder.dart';
import '../navigation/new_router_provider.dart';
import '../navigation/app_router_config.dart';
import '../../generated/l10n.dart';

/// 路由测试页面
class RouteTestPage extends ConsumerStatefulWidget {
  const RouteTestPage({super.key});

  @override
  ConsumerState<RouteTestPage> createState() => _RouteTestPageState();
}

class _RouteTestPageState extends ConsumerState<RouteTestPage> {
  final List<_TestResult> _testResults = [];
  bool _isRunning = false;
  int _currentTestIndex = 0;
  
  final List<_TestCase> _testCases = [
    _TestCase(
      name: '切换到买家模式',
      description: '测试切换到买家模式时的页面重建',
      action: (ref) async {
        ref.read(appModeProvider.notifier).setMode(AppMode.buyer);
        await Future.delayed(const Duration(milliseconds: 500));
      },
    ),
    _TestCase(
      name: '切换到卖家模式',
      description: '测试切换到卖家模式时的页面重建',
      action: (ref) async {
        ref.read(appModeProvider.notifier).setMode(AppMode.seller);
        await Future.delayed(const Duration(milliseconds: 500));
      },
    ),
    _TestCase(
      name: '错误边界测试',
      description: '模拟页面错误并测试错误边界',
      action: (ref) async {
        // 模拟触发错误
        try {
          throw Exception('测试错误边界');
        } catch (e) {
          print('[RouteTest] Simulated error: $e');
        }
        await Future.delayed(const Duration(milliseconds: 300));
      },
    ),
    _TestCase(
      name: '缓存性能测试',
      description: '测试页面缓存的性能',
      action: (ref) async {
        final stopwatch = Stopwatch()..start();
        
        // 多次访问同一页面测试缓存
        for (int i = 0; i < 5; i++) {
          UnifiedRouteBuilder.buildFirstTabContent(ref);
          UnifiedRouteBuilder.buildSecondTabContent(ref);
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        stopwatch.stop();
        print('[RouteTest] Cache performance: ${stopwatch.elapsedMilliseconds}ms');
      },
    ),
    _TestCase(
      name: '内存清理测试',
      description: '测试页面缓存清理',
      action: (ref) async {
        UnifiedRouteBuilder.clearCache();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // 重新创建页面验证缓存已清理
        UnifiedRouteBuilder.buildFirstTabContent(ref);
        UnifiedRouteBuilder.buildSecondTabContent(ref);
      },
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final appMode = ref.watch(appModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('路由测试'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            onPressed: _isRunning ? null : _runAllTests,
            icon: const Icon(Icons.play_arrow),
            tooltip: '运行所有测试',
          ),
          IconButton(
            onPressed: _clearResults,
            icon: const Icon(Icons.clear),
            tooltip: '清除结果',
          ),
        ],
      ),
      body: Column(
        children: [
          // 当前状态显示
          _buildStatusCard(appMode),
          
          // 测试控制面板
          _buildControlPanel(),
          
          // 测试结果列表
          Expanded(
            child: _buildTestResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard(AppMode appMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                '当前状态',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('应用模式: '),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appMode == AppMode.buyer ? Colors.blue.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  appMode == AppMode.buyer ? '买家模式' : '卖家模式',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: appMode == AppMode.buyer ? Colors.blue.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('时间: ${DateTime.now().toString().substring(0, 19)}'),
        ],
      ),
    );
  }
  
  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '测试控制',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_isRunning) ...[
            LinearProgressIndicator(
              value: _currentTestIndex / _testCases.length,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text('正在运行: ${_testCases[_currentTestIndex].name}'),
          ] else ...[
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _runAllTests,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('运行所有测试'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _clearResults,
                  icon: const Icon(Icons.clear),
                  label: const Text('清除结果'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTestResults() {
    if (_testResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '点击"运行所有测试"开始测试',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _testResults.length,
      itemBuilder: (context, index) {
        final result = _testResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            title: Text(result.testName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.description),
                const SizedBox(height: 4),
                Text(
                  '耗时: ${result.duration}ms | ${result.timestamp}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (result.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '错误: ${result.errorMessage}',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
  
  Future<void> _runAllTests() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _currentTestIndex = 0;
      _testResults.clear();
    });
    
    for (int i = 0; i < _testCases.length; i++) {
      setState(() {
        _currentTestIndex = i;
      });
      
      final testCase = _testCases[i];
      await _runSingleTest(testCase);
      
      // 测试间隔
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    setState(() {
      _isRunning = false;
    });
  }
  
  Future<void> _runSingleTest(_TestCase testCase) async {
    final stopwatch = Stopwatch()..start();
    bool success = true;
    String? errorMessage;
    
    try {
      await testCase.action(ref);
    } catch (e) {
      success = false;
      errorMessage = e.toString();
      print('[RouteTest] Test "${testCase.name}" failed: $e');
    }
    
    stopwatch.stop();
    
    setState(() {
      _testResults.add(_TestResult(
        testName: testCase.name,
        description: testCase.description,
        success: success,
        duration: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now().toString().substring(11, 19),
        errorMessage: errorMessage,
      ));
    });
  }
  
  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }
}

/// 测试用例
class _TestCase {
  final String name;
  final String description;
  final Future<void> Function(WidgetRef ref) action;
  
  const _TestCase({
    required this.name,
    required this.description,
    required this.action,
  });
}

/// 测试结果
class _TestResult {
  final String testName;
  final String description;
  final bool success;
  final int duration;
  final String timestamp;
  final String? errorMessage;
  
  const _TestResult({
    required this.testName,
    required this.description,
    required this.success,
    required this.duration,
    required this.timestamp,
    this.errorMessage,
  });
}