import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class TaskerIdentityVerificationScreen extends StatefulWidget {
  const TaskerIdentityVerificationScreen({super.key});

  @override
  State<TaskerIdentityVerificationScreen> createState() => _TaskerIdentityVerificationScreenState();
}

class _TaskerIdentityVerificationScreenState extends State<TaskerIdentityVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ninController = TextEditingController();
  String _gender = 'male';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final auth = context.read<AuthProvider>();

    // Pull basic identity fields from provider user data when available
    final user = (auth.userData != null) ? auth.userData!['user'] as Map<String, dynamic>? : null;
    final firstName = (user?['firstName'] as String?)?.trim().isNotEmpty == true
      ? (user!['firstName'] as String).trim()
      : auth.firstNameController.text.trim();
    final lastName = (user?['lastName'] as String?)?.trim().isNotEmpty == true
      ? (user!['lastName'] as String).trim()
      : auth.lastNameController.text.trim();
    // Expecting YYYY-MM-DD per backend
    final dob = (user?['dateOfBirth'] as String?)?.trim().isNotEmpty == true
      ? (user!['dateOfBirth'] as String).trim()
      : auth.dobController.text.trim();
    final phone = (user?['phoneNumber'] as String?)?.trim().isNotEmpty == true
      ? (user!['phoneNumber'] as String).trim()
      : auth.phoneController.text.trim();
    final email = (user?['emailAddress'] as String?)?.trim().isNotEmpty == true
      ? (user!['emailAddress'] as String).trim()
      : auth.emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || dob.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('First name, last name, and date of birth are required')),
    );
    return;
    }

      final success = await auth.verifyTaskerIdentity(
        nin: _ninController.text.trim(),
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dob,
        gender: _gender,
        phoneNumber: phone.isNotEmpty ? phone : null,
        email: email.isNotEmpty ? email : null,
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identity verification successful')),
        );
        Navigator.pop(context, true);
      } else {
        final msg = context.read<AuthProvider>().errorMessage ?? 'Verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Verify Identity'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24 + MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.verified_user_outlined, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'To complete your identity verification, please provide a valid Means of Identification. Currently supported: NIN only.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Means of Identification',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const _SingleOptionChip(label: 'NIN (National Identification Number)'),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enter NIN', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _ninController,
                            keyboardType: TextInputType.number,
                            maxLength: 11,
                            decoration: InputDecoration(
                              hintText: '11-digit NIN',
                              counterText: '',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'NIN is required';
                              if (!RegExp(r'^\d{11}$').hasMatch(v)) {
                                return 'Enter a valid 11-digit NIN';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'male', label: Text('Male')),
                              ButtonSegment(value: 'female', label: Text('Female')),
                            ],
                            selected: {_gender},
                            onSelectionChanged: (s) {
                              setState(() => _gender = s.first);
                            },
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Note: We will verify your NIN with our verification provider. Ensure it matches your legal identity.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit for verification'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleOptionChip extends StatelessWidget {
  final String label;
  const _SingleOptionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fiber_manual_record, size: 10, color: Colors.green),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const Text('(Only option available)', style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
