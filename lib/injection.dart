import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import the generated config file
import 'injection.config.dart'; 

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default = true, using false for stand-alone function
)
Future<void> configureDependencies() async => $initGetIt(getIt); 