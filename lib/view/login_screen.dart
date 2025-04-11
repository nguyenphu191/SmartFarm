import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/view/home_screen.dart';
import 'package:smart_farm/view/register_screen.dart';
import 'package:smart_farm/widget/top_bar.dart';

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
        body: SingleChildScrollView(
      child: Column(
        children: [
          TopBar(
            title: 'Đăng nhập',
          ),
          Center(
            child: Container(
              width: size.width - 32 * pix,
              height: 230 * pix,
              padding: EdgeInsets.all(10 * pix),
              child: Image.asset(AppImages.anhthuc2),
            ),
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
            margin: EdgeInsets.symmetric(horizontal: 16 * pix),
            padding: EdgeInsets.only(left: 16 * pix),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16 * pix),
            ),
            child: TextField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                labelStyle: TextStyle(
                  fontSize: 14 * pix,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5 * pix,
          ),
          InkWell(
            onTap: () {},
            child: Container(
              width: size.width,
              height: 20 * pix,
              padding: EdgeInsets.only(left: 16 * pix, right: 16 * pix),
              child: Text('Quên mật khẩu?',
                  style: TextStyle(
                      fontSize: 14 * pix,
                      fontFamily: 'BeVietnamPro',
                      fontWeight: FontWeight.w500,
                      color: Colors.red[400]),
                  textAlign: TextAlign.right),
            ),
          ),
          SizedBox(
            height: 69 * pix,
          ),
          Padding(
            padding: EdgeInsets.all(16 * pix),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: Container(
                width: size.width,
                height: 56 * pix,
                padding: EdgeInsets.only(
                    left: 16 * pix, right: 16 * pix, top: 12 * pix),
                decoration: BoxDecoration(
                  color: Color(0xff5B7BFE),
                  borderRadius: BorderRadius.circular(16 * pix),
                ),
                child: Text('Đăng nhập',
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
            padding:
                EdgeInsets.only(left: 66 * pix, right: 16 * pix, top: 12 * pix),
            child: Row(
              children: [
                Text('Bạn chưa có tài khoản?',
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
                            builder: (context) => Signupscreen()));
                  },
                  child: Text(' Đăng ký',
                      style: TextStyle(
                          fontSize: 14 * pix,
                          fontFamily: 'BeVietnamPro',
                          color: Color(0xff5B7BFE)),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
