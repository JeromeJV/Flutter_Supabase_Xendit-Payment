import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'screens/demo_store_screen.dart';
import 'screens/product_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initializationError;
  if (AppConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
    } on Exception catch (error) {
      initializationError = error.toString();
    }
  }

  runApp(StudentShopApp(initializationError: initializationError));
}

class StudentShopApp extends StatelessWidget {
  const StudentShopApp({super.key, this.initializationError});

  final String? initializationError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: initializationError != null
          ? SupabaseSetupScreen(errorMessage: initializationError)
          : AppConfig.isConfigured
          ? const ProductListScreen()
          : const DemoStoreScreen(),
    );
  }
}

class SupabaseSetupScreen extends StatelessWidget {
  const SupabaseSetupScreen({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Shop setup')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage == null
                          ? 'Connect your Supabase project'
                          : 'Could not initialize Supabase',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage ??
                          'Set your Supabase Project URL and anon (public) key '
                              'using the dart-define options below, then run '
                              'the app again.',
                    ),
                    const SizedBox(height: 16),
                    const SelectableText(
                      'flutter run '
                      '--dart-define=SUPABASE_URL=https://your-project.supabase.co '
                      '--dart-define=SUPABASE_ANON_KEY=your-anon-key',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Use the anon/public key only. Never put a service-role '
                      'key in the app.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
