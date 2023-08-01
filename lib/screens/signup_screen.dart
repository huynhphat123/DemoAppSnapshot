import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lvtn_mangxahoi/resources/auth_method.dart';
import 'package:lvtn_mangxahoi/screens/choice_title.dart';
import 'package:lvtn_mangxahoi/screens/login_screen.dart';
import 'package:lvtn_mangxahoi/utils/sharedpreference.dart';
import 'package:lvtn_mangxahoi/utils/utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreensState();
}

class _SignupScreensState extends State<SignupScreen> {
  final Color kAccentColor = Colors.teal;
  bool _obscureText = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }
  void iniitShared() async {
    await sharedPreferences.initPreference();
  }
  @override
  void initState() {
    super.initState();
    iniitShared();
  }


  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }
bool isEmailValid(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    return emailRegex.hasMatch(email);
  }
bool isPasswordValid(String password) {
    // Kiểm tra độ dài password và định dạng bằng biểu thức chính quy
    final passwordRegex = RegExp(r'^.{6,}$');
    return passwordRegex.hasMatch(password);
  }
  void signUpUser() async {
    if (_image == null) {
      showSnackBar(context, "Vui lòng chọn ảnh đại diện");
      return;
    }
    if (_emailController.text.isEmpty) {
      showSnackBar(context, "Bạn chưa nhập email!");
      return;
    }
    if (!isEmailValid(_emailController.text)) {
      showSnackBar(context, "Email không hợp lệ");
      return;
    }
    if (!isPasswordValid(_passwordController.text)) {
      showSnackBar(context, "Mật khẩu phải có ít nhất 6 ký tự ");
      return;
    }
    setState(() {
      isLoading = true;
    });
    String res = await AuthMethod().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!);
    setState(() {
      isLoading = false;
    });
    if (res != 'success') {
      showSnackBar(context, res);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChoiceTitle(),
        ),
      );
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: const Color.fromARGB(255, 196, 250, 253),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // const SizedBox(height: 32.0),
                    Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_image!))
                            : const CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage(
                                    "https://tse2.mm.bing.net/th?id=OIP.RtLnpr_QmrKy0jS5EVs8CQHaHa&pid=Api&P=0"),
                              ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    _buildTextField(
                      textEditingController: _usernameController,
                      hintText: 'Họ tên',
                      icon: Icons.person,
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(height: 13.0),
                    _buildTextField(
                      textEditingController: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 13.0),
                    _buildTextField(
                      textEditingController: _passwordController,
                      hintText: 'Mật khẩu',
                      icon: Icons.lock,
                      obscureText: _obscureText,
                      isPassword: true,
                      textInputType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 13.0),
                    _buildTextField(
                      textEditingController: _bioController,
                      hintText: 'Tiểu sử',
                      icon: Icons.description,
                      maxLines: 2,
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(height: 32.0),
                    InkWell(
                      onTap: signUpUser,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          // color: Color.fromARGB(255, 91, 165, 226),
                          color: Color.fromARGB(255, 15, 145, 211),
                        ),
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                ),
                              )
                            : const Text(
                                'ĐĂNG KÝ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: const Text(
                        "Bạn đã có tài khoản? ",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    GestureDetector(
                      onTap: navigateToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: const Text(
                          "Đăng nhập tại đây",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController textEditingController,
    required String hintText,
    required IconData icon,
    required TextInputType textInputType,
    bool obscureText = false,
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: textEditingController,
      keyboardType: textInputType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  // đảo ngược trạng thái của obscureText khi nhấn vào biểu tượng con mắt
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        enabledBorder: OutlineInputBorder(
          // borderSide: BorderSide(color: Theme.of(context).accentColor),
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            // color: Theme.of(context).accentColor,
            color: Colors.blueAccent,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}
