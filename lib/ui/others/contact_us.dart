import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/snackbar.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Dispose controllers
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Submit function
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "your-name": _nameController.text.trim(),
        "your-email": _emailController.text.trim(),
        "your-subject": _subjectController.text.trim(),
        "your-message": _messageController.text.trim(),
      };

      LoadingDialog.show(context);

      try {
        final response = await ApiService.post('/hh/v1/contact-us', body: data);

        LoadingDialog.hide(context);
        showAwesomeSnackbar(
          context: context,
          type: ContentType.success,
          title: 'Success!',
          message: response['message'] ?? 'Successful ... ',
        );

        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      } catch (e) {
        LoadingDialog.hide(context);

        final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Something went wrong.';
        showAwesomeSnackbar(context: context, type: ContentType.failure, title: 'Failed!', message: message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Your Name", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Your Email", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your email";
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: "Subject", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Enter subject" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: "Message", border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? "Enter message" : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
