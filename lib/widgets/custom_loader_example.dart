import 'package:flutter/material.dart';
import 'package:taskhub/widgets/custom_loader.dart';
import 'package:taskhub/theme/const_value.dart';

/// Example usage of the CustomLoader
class LoaderExampleScreen extends StatelessWidget {
  const LoaderExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loader Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          
 
            
            const SizedBox(height: 20),
            
            // Animated loader example
            PrimaryButton(
              label: 'Show Animated Loader',
              onPressed: () {
                CustomLoaderWithAnimation.show(context);
                
                // Auto-hide after 3 seconds for demo purposes
                Future.delayed(const Duration(seconds: 3), () {
                  CustomLoaderWithAnimation.hide(context);
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Animated loader with cancel button
            PrimaryButton(
              label: 'Show Animated Loader with Cancel',
              onPressed: () {
                CustomLoaderWithAnimation.show(
                  context,
                  text: 'Processing payment...',
                  showCancelButton: true,
                  onCancel: () {
                    // Handle cancel action
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment cancelled')),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 