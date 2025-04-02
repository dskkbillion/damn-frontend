import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import the generated file
import 'injection_container.config.dart'; 

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'init', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async => init(getIt);

// Later, you will register your modules/services like this:
// @module
// abstract class RegisterModule {
//   @lazySingleton
//   MyService get myService => MyServiceImpl();
// } 