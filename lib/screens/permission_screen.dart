import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import 'home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final SmsService _smsService = SmsService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingPermission();
  }

  Future<void> _checkExistingPermission() async {
    final hasPermission = await _smsService.hasPermission();
    if (hasPermission && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);

    final granted = await _smsService.requestPermission();

    setState(() => _isLoading = false);

    if (granted) {
      _navigateToHome();
    } else {
      _showDeniedDialog();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'Permission Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bankbox needs SMS permission to read and filter your bank messages. '
          'Without this permission, the app cannot function.\n\n'
          'Please grant SMS access to continue.',
          style: TextStyle(color: Color(0xFFA1A1A1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFA1A1A1)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermission();
            },
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bankbox',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Read, filter, and export your bank SMS messages to Excel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA1A1A1),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _requestPermission,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('Allow SMS Access'),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Your data stays on your device.\nWe never upload or share your messages.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
