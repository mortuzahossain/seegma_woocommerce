import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seegma_woocommerce/api/api_service.dart';
import 'package:seegma_woocommerce/utils/loading_dialog.dart';
import 'package:seegma_woocommerce/utils/snackbar.dart';
import 'package:seegma_woocommerce/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountUpdatePage extends StatefulWidget {
  const AccountUpdatePage({super.key});

  @override
  State<AccountUpdatePage> createState() => _AccountUpdatePageState();
}

class _AccountUpdatePageState extends State<AccountUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController nickname = TextEditingController();
  final TextEditingController mobile = TextEditingController();

  String gender = "male";
  String? avatarBase64;
  File? avatarFile;
  String? avatarNetworkUrl;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      firstName.text = prefs.getString('first_name') ?? '';
      lastName.text = prefs.getString('last_name') ?? '';
      nickname.text = prefs.getString('nickname') ?? '';
      mobile.text = prefs.getString('mobile') ?? '';
      gender = (prefs.getString('gender')?.isNotEmpty ?? false) ? prefs.getString('gender')! : 'male';

      final profileUrl = prefs.getString('profile_image');
      if (profileUrl != null && profileUrl.isNotEmpty) {
        avatarFile = null; // no local file yet
        avatarBase64 = null; // will remain null until user picks new image
        avatarNetworkUrl = profileUrl; // new variable to store URL
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();

      setState(() {
        avatarFile = File(picked.path);
        avatarBase64 = 'data:image/$ext;base64,${base64Encode(bytes)}';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "first_name": firstName.text,
      "last_name": lastName.text,
      "nickname": nickname.text,
      "gender": gender,
      "mobile_number": mobile.text,
      if (avatarBase64 != null) "avatar_base64": avatarBase64,
    };

    LoadingDialog.show(context);

    try {
      final response = await ApiService.post('/hh/v1/update-profile', body: body);

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // Save other fields
        await prefs.setString('first_name', body['first_name'] ?? '');
        await prefs.setString('last_name', body['last_name'] ?? '');
        await prefs.setString('nickname', body['nickname'] ?? '');
        await prefs.setString('mobile', body['mobile_number'] ?? '');
        await prefs.setString('gender', body['gender'] ?? '');

        // Save avatar URL if available
        final avatarUrl = response['avatar_url'] ?? '';
        if (avatarUrl.isNotEmpty) {
          await prefs.setString('profile_image', avatarUrl);
        }
      }

      LoadingDialog.hide(context);
      showAwesomeSnackbar(
        context: context,
        type: ContentType.success,
        title: 'Success!',
        message: response['message'] ?? 'Successful ... ',
      );
    } catch (e) {
      LoadingDialog.hide(context);

      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Something went wrong.';
      showAwesomeSnackbar(context: context, type: ContentType.failure, title: 'Failed!', message: message);
    }
  }

  Widget avatarWidget() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(2), // border width
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 3),
            ),
            child: ClipOval(
              child: SizedBox(
                width: 100,
                height: 100,
                child: avatarFile != null
                    ? Image.file(avatarFile!, fit: BoxFit.cover)
                    : (avatarNetworkUrl != null
                          ? CachedNetworkImage(
                              imageUrl: avatarNetworkUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(FontAwesomeIcons.personHalfDress, size: 50, color: Colors.white70),
                            )
                          : const Icon(FontAwesomeIcons.personHalfDress, size: 50, color: AppColors.primaryBlueDark)),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _pickImage,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(FontAwesomeIcons.camera, color: AppColors.primaryBlue, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Account")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                avatarWidget(),
                const SizedBox(height: 20),
                TextFormField(
                  controller: firstName,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(FontAwesomeIcons.user),
                  ),
                  validator: (v) => v!.isEmpty ? "Enter first name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastName,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(FontAwesomeIcons.user),
                  ),
                  validator: (v) => v!.isEmpty ? "Enter last name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nickname,
                  decoration: const InputDecoration(
                    labelText: "Nickname",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(FontAwesomeIcons.userTag),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: "male", child: Text("Male")),
                    DropdownMenuItem(value: "female", child: Text("Female")),
                    DropdownMenuItem(value: "other", child: Text("Other")),
                  ],
                  onChanged: (v) {
                    setState(() => gender = v!);
                  },
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(FontAwesomeIcons.venusMars),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: mobile,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(FontAwesomeIcons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _updateProfile, child: const Text("Update Profile")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
