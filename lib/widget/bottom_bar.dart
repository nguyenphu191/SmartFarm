import 'package:flutter/material.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/view/history_screen.dart';
import 'package:smart_farm/view/home_screen.dart';
import 'package:smart_farm/view/sensor_screen.dart';
import 'package:smart_farm/view/setting_screen.dart';
import 'package:smart_farm/view/warning_screen.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key, required this.type});
  final int type;

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Container(
      height: 66 * pix, // Tăng chiều cao để chứa thêm nhãn
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền trắng
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            image: AppImages.iconhome,
            label: 'Trang chủ', // Thêm nhãn
            enabled: widget.type == 1,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SensorScreen()),
              );
            },
            image: AppImages.iconthom,
            label: 'Khí hậu', // Thêm nhãn
            enabled: widget.type == 2,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            image: AppImages.iconeye,
            label: 'Lịch sử', // Thêm nhãn
            enabled: widget.type == 3,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WarningScreen()),
              );
            },
            image: AppImages.iconnoti,
            label: 'Cảnh báo ', // Thêm nhãn
            enabled: widget.type == 4,
          ),
          _buildActionButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
            image: AppImages.iconsetting,
            label: 'Cài đặt', // Thêm nhãn
            enabled: widget.type == 5,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String image,
    required String label,
    required bool enabled,
  }) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40 * pix,
            width: 40 * pix,
            decoration: BoxDecoration(
              color: enabled
                  ? const Color.fromARGB(255, 28, 214, 66).withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 24 * pix,
                height: 24 * pix,
                color: enabled
                    ? const Color.fromARGB(255, 10, 146, 0)
                    : Colors.grey, // Thay đổi màu icon khi active
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * pix,
              color: enabled
                  ? const Color.fromARGB(255, 10, 146, 0)
                  : Colors.grey, // Thay đổi màu nhãn khi active
              fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
