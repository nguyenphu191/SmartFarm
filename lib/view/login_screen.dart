import 'package:flutter/material.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/view/home_screen.dart';
import 'package:smart_farm/view/register_screen.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'package:smart_farm/theme/app_colors.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              title: 'Đăng nhập',
              isBack: false,
            ), 
          ),
          Positioned(
            top: 70 * pix,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                   
                  Center(
                    child: Container(
                      width: size.width - 32 * pix,
                      height: 220 * pix,
                      padding: EdgeInsets.all(10 * pix),
                      child: Image.asset(AppImages.anhthuc2),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8 * pix),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Nhập email của bạn',
                            hintStyle: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: AppColors.textGrey,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * pix),
                              borderSide: BorderSide(color: AppColors.borderGrey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * pix),
                              borderSide: BorderSide(color: AppColors.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * pix),
                              borderSide:
                                  BorderSide(color: AppColors.primaryGreen, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16 * pix,
                              vertical: 16 * pix,
                            ),
                          ),
                        ),
                        SizedBox(height: 20 * pix),
                        Text(
                          'Mật khẩu',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8 * pix),
                        TextField(
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Nhập mật khẩu',
                            hintStyle: TextStyle(
                              fontSize: 14 * pix,
                              fontFamily: 'BeVietnamPro',
                              color: AppColors.textGrey,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * pix),
                              borderSide: BorderSide(color: AppColors.borderGrey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * pix),
                              borderSide: BorderSide(color: AppColors.borderGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12 * pix),
                              borderSide:
                                  BorderSide(color: AppColors.primaryGreen, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16 * pix,
                              vertical: 16 * pix,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textGrey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * pix),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontSize: 14 * pix,
                                fontFamily: 'BeVietnamPro',
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40 * pix),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          },
                          child: Container(
                            width: size.width,
                            height: 56 * pix,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12 * pix),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 18 * pix,
                                  fontFamily: 'BeVietnamPro',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24 * pix),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.borderGrey,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                              child: Text(
                                'Hoặc',
                                style: TextStyle(
                                  fontSize: 14 * pix,
                                  fontFamily: 'BeVietnamPro',
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.borderGrey,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24 * pix),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bạn chưa có tài khoản?',
                                style: TextStyle(
                                  fontSize: 14 * pix,
                                  fontFamily: 'BeVietnamPro',
                                  color: AppColors.textDark,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Signupscreen()),
                                  );
                                },
                                child: Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    fontSize: 14 * pix,
                                    fontFamily: 'BeVietnamPro',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40 * pix),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
