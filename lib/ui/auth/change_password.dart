import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/snackbar.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    LoadingDialog.show(context);

    try {
      final response = await ApiService.post(
        '/hh/v1/change-password',
        body: {
          "current_password": _currentPasswordController.text,
          "new_password": _newPasswordController.text,
          "confirm_password": _newPasswordController.text,
        },
      );

      LoadingDialog.hide(context);
      showAwesomeSnackbar(
        context: context,
        type: ContentType.success,
        title: 'Success!',
        message: response['message'] ?? 'Successful ... ',
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      LoadingDialog.hide(context);

      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Something went wrong.';
      showAwesomeSnackbar(context: context, type: ContentType.failure, title: 'Failed!', message: message);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
                obscure: _obscureCurrent,
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _changePassword, child: const Text('Update Password')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        // border: const OutlineInputBorder(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: onToggle),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (value.length < 6) return 'Minimum 6 characters';
            return null;
          },
    );
  }
}
