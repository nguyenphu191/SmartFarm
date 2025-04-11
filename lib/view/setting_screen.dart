import 'package:flutter/material.dart';
import 'package:smart_farm/widget/bottom_bar.dart';
import 'package:smart_farm/widget/top_bar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String selectedLanguage = 'Tiếng Việt'; // Ngôn ngữ mặc định
  bool weatherNotification = true; // Thông báo thời tiết
  bool careNotification = true; // Thông báo kế hoạch chăm sóc
  bool isDarkMode = false; // Chế độ tối

  final List<String> languageOptions = ['Tiếng Việt', 'Tiếng Anh'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Stack(
        children: [
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              title: "Cài đặt",
              isBack: true,
            ),
          ),

          // Gradient background
          Positioned(
            top: 100 * pix,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: size.width,
              height: size.height - 100 * pix,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff47BFDF), Color(0xff4A91FF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),

          // Main content
          Positioned(
            top: 120 * pix,
            left: 16 * pix,
            right: 16 * pix,
            bottom: 16 * pix,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Ngôn ngữ',
                    child: _buildLanguageSelector(pix),
                    pix: pix,
                  ),
                  SizedBox(height: 20 * pix),
                  _buildSection(
                    title: 'Thông báo',
                    child: _buildNotificationSettings(pix),
                    pix: pix,
                  ),
                  SizedBox(height: 20 * pix),
                  _buildSection(
                    title: 'Giao diện',
                    child: _buildThemeToggle(pix),
                    pix: pix,
                  ),
                  SizedBox(height: 20 * pix),
                  _buildSection(
                    title: 'Dữ liệu',
                    child: _buildDataOptions(pix),
                    pix: pix,
                  ),
                  SizedBox(height: 20 * pix),
                  _buildSection(
                    title: 'Thông tin ứng dụng',
                    child: _buildAppInfo(pix),
                    pix: pix,
                  ),
                  SizedBox(height: 80 * pix),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Bottombar(type: 5),
          )
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required double pix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * pix),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16 * pix),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18 * pix,
                fontWeight: FontWeight.bold,
                fontFamily: 'BeVietnamPro',
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
          child,
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ngôn ngữ ứng dụng',
            style: TextStyle(
              fontSize: 16 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * pix),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8 * pix),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                items: languageOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14 * pix,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                      // TODO: Thêm logic thay đổi ngôn ngữ (ví dụ: cập nhật Locale)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thay đổi sang $newValue'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông báo thời tiết',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              Switch(
                value: weatherNotification,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    weatherNotification = value;
                    // TODO: Thêm logic bật/tắt thông báo thời tiết
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Đã bật thông báo thời tiết'
                              : 'Đã tắt thông báo thời tiết',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 12 * pix),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông báo chăm sóc',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              Switch(
                value: careNotification,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    careNotification = value;
                    // TODO: Thêm logic bật/tắt thông báo chăm sóc
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Đã bật thông báo chăm sóc'
                              : 'Đã tắt thông báo chăm sóc',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chế độ tối',
            style: TextStyle(
              fontSize: 16 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          Switch(
            value: isDarkMode,
            activeColor: Colors.green,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
                // TODO: Thêm logic chuyển đổi theme sáng/tối
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Đã bật chế độ tối' : 'Đã tắt chế độ tối',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataOptions(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showClearDataDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(
                horizontal: 24 * pix,
                vertical: 12 * pix,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8 * pix),
              ),
            ),
            child: Text(
              'Xóa dữ liệu cục bộ',
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
                fontFamily: 'BeVietnamPro',
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            'Xóa tất cả dữ liệu cây trồng và cài đặt đã lưu.',
            style: TextStyle(
              fontSize: 12 * pix,
              color: Colors.grey[600],
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Xác nhận xóa dữ liệu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa tất cả dữ liệu cục bộ? Hành động này không thể hoàn tác.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Thêm logic xóa dữ liệu (ví dụ: SharedPreferences, local database)
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa dữ liệu cục bộ'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Xóa',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppInfo(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ứng dụng: Smart Farm',
            style: TextStyle(
              fontSize: 16 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            'Phiên bản: 1.0.0',
            style: TextStyle(
              fontSize: 14 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            'Nhà phát triển: xAI',
            style: TextStyle(
              fontSize: 14 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 12 * pix),
          ElevatedButton(
            onPressed: () {
              // TODO: Điều hướng đến trang hỗ trợ hoặc liên hệ
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Liên hệ hỗ trợ: support@x.ai'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                horizontal: 24 * pix,
                vertical: 12 * pix,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8 * pix),
              ),
            ),
            child: Text(
              'Liên hệ hỗ trợ',
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
                fontFamily: 'BeVietnamPro',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
