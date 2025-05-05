import 'package:flutter/material.dart';
import 'package:smart_farm/theme/app_colors.dart';

import 'package:smart_farm/view/login_screen.dart';
import 'package:smart_farm/widget/top_bar.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopBar(title: 'Đăng ký', isBack: true),
            Center(
              child: Column(
                children: [
                  Container(
                    width: size.width,
                    height: 90 * pix,
                    padding: EdgeInsets.only(top: 10 * pix),
                    child: Text(
                      'Bắt đầu chăm sóc khu vườn của bạn!',
                      style: TextStyle(
                          fontSize: 22 * pix,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
              margin: EdgeInsets.only(bottom: 5 * pix),
              child: Text(
                'Họ và tên',
                style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              padding: EdgeInsets.only(left: 16 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: TextField(
                  decoration: InputDecoration(
                labelText: 'Nhập tên của bạn',
                labelStyle: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey),
                border: InputBorder.none,
              )),
            ),
            SizedBox(
              height: 16 * pix,
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
              margin: EdgeInsets.only(bottom: 5 * pix),
              child: Text(
                'Email',
                style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              padding: EdgeInsets.only(left: 16 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: TextField(
                  decoration: InputDecoration(
                labelText: 'Nhập email của bạn',
                labelStyle: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey),
                border: InputBorder.none,
              )),
            ),
            SizedBox(
              height: 16 * pix,
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 20 * pix),
              margin: EdgeInsets.only(bottom: 5 * pix),
              child: Text(
                'Mật khẩu',
                style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              margin: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              padding: EdgeInsets.only(left: 16 * pix),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: TextField(
                  decoration: InputDecoration(
                labelText: 'Nhập mật khẩu của bạn',
                labelStyle: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                    color: Colors.grey),
                border: InputBorder.none,
              )),
            ),
            SizedBox(
              height: 69 * pix,
            ),
            Padding(
              padding: EdgeInsets.all(16 * pix),
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Loginscreen()));
                },
                child: Container(
                  width: size.width,
                  height: 56 * pix,
                  padding: EdgeInsets.only(
                      left: 16 * pix, right: 16 * pix, top: 12 * pix),
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
                  child: Text('Đăng ký ',
                      style: TextStyle(
                          fontSize: 20 * pix,
                          fontFamily: 'BeVietnamPro',
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            SizedBox(
              height: 10 * pix,
            ),
            Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              child: Text('Or',
                  style: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.black),
                  textAlign: TextAlign.center),
            ),
            Container(
              width: size.width,
              height: 56 * pix,
              padding: EdgeInsets.only(
                  left: 66 * pix, right: 16 * pix, top: 12 * pix),
              child: Row(
                children: [
                  Text('Bạn đã có tài khoản?',
                      style: TextStyle(
                          fontSize: 14 * pix,
                          fontFamily: 'BeVietnamPro',
                          color: Colors.black),
                      textAlign: TextAlign.center),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Loginscreen()));
                    },
                    child: Text(' Đăng nhập',
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontFamily: 'BeVietnamPro',
                          color: AppColors.primaryGreen,
                        ),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
