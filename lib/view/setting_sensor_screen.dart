import 'package:flutter/material.dart';
import 'package:smart_farm/widget/bottom_bar.dart';
import 'package:smart_farm/widget/top_bar.dart';

class SettingSensorScreen extends StatefulWidget {
  @override
  _SettingSensorScreenState createState() => _SettingSensorScreenState();
}

class _SettingSensorScreenState extends State<SettingSensorScreen> {
  // Tần suất lấy dữ liệu (phút)
  String _selectedFrequency = '15'; // Giá trị mặc định
  final List<String> _frequencyOptions = ['5', '10', '15', '30', '60'];

  // Ngưỡng cảnh báo (hard-coded, có thể tích hợp với server sau)
  double _tempHigh = 35.0;
  double _tempLow = 15.0;
  double _humidityLow = 30.0;
  double _lightHigh = 800.0;
  double _co2High = 1000.0;

  // Controller cho form kết nối thiết bị
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _deviceIpController = TextEditingController();

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _deviceIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Stack(
        children: [
          // TopBar
          const Positioned(
            child: TopBar(
              title: "Cài đặt cảm biến",
              isBack: true,
            ),
            top: 0,
            left: 0,
            right: 0,
          ),
          // Main content
          Positioned(
            top: 70 * pix,
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16 * pix),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tần suất lấy dữ liệu
                      _buildSectionTitle('Tần suất lấy dữ liệu', pix),
                      _buildFrequencySelector(pix),
                      SizedBox(height: 24 * pix),

                      // Ngưỡng cảnh báo
                      _buildSectionTitle('Ngưỡng cảnh báo', pix),
                      _buildThresholdSliders(pix),
                      SizedBox(height: 24 * pix),

                      // Kết nối thiết bị mới
                      _buildSectionTitle('Kết nối thiết bị mới', pix),
                      _buildDeviceConnectionForm(pix),
                      SizedBox(height: 24 * pix),

                      // Nút lưu cài đặt
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _saveSettings();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32 * pix,
                              vertical: 12 * pix,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * pix),
                            ),
                          ),
                          child: Text(
                            'Lưu cài đặt',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * pix,
                              fontFamily: 'BeVietnamPro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 80 * pix), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ),
          ),
          // BottomBar
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double pix) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20 * pix,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'BeVietnamPro',
      ),
    );
  }

  Widget _buildFrequencySelector(double pix) {
    return Container(
      margin: EdgeInsets.only(top: 8 * pix),
      padding: EdgeInsets.symmetric(horizontal: 16 * pix),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12 * pix),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFrequency,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: Colors.white.withOpacity(0.9),
          items: _frequencyOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                'Mỗi $value phút',
                style: TextStyle(
                  fontSize: 16 * pix,
                  color: Colors.black,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFrequency = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildThresholdSliders(double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16 * pix),
      ),
      child: Column(
        children: [
          _buildSlider(
            label: 'Nhiệt độ cao',
            value: _tempHigh,
            min: 20.0,
            max: 45.0,
            unit: '°C',
            pix: pix,
            onChanged: (value) {
              setState(() {
                _tempHigh = value;
              });
            },
          ),
          _buildSlider(
            label: 'Nhiệt độ thấp',
            value: _tempLow,
            min: 5.0,
            max: 25.0,
            unit: '°C',
            pix: pix,
            onChanged: (value) {
              setState(() {
                _tempLow = value;
              });
            },
          ),
          _buildSlider(
            label: 'Độ ẩm thấp',
            value: _humidityLow,
            min: 10.0,
            max: 50.0,
            unit: '%',
            pix: pix,
            onChanged: (value) {
              setState(() {
                _humidityLow = value;
              });
            },
          ),
          _buildSlider(
            label: 'Ánh sáng cao',
            value: _lightHigh,
            min: 500.0,
            max: 1500.0,
            unit: 'lux',
            pix: pix,
            onChanged: (value) {
              setState(() {
                _lightHigh = value;
              });
            },
          ),
          _buildSlider(
            label: 'CO2 cao',
            value: _co2High,
            min: 400.0,
            max: 2000.0,
            unit: 'ppm',
            pix: pix,
            onChanged: (value) {
              setState(() {
                _co2High = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required double pix,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16 * pix,
                color: Colors.white,
                fontFamily: 'BeVietnamPro',
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'BeVietnamPro',
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          label: '${value.toStringAsFixed(1)}$unit',
          activeColor: Colors.blue,
          inactiveColor: Colors.white.withOpacity(0.5),
          onChanged: onChanged,
        ),
        SizedBox(height: 8 * pix),
      ],
    );
  }

  Widget _buildDeviceConnectionForm(double pix) {
    return Container(
      padding: EdgeInsets.all(16 * pix),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16 * pix),
      ),
      child: Column(
        children: [
          TextField(
            controller: _deviceIdController,
            style: TextStyle(color: Colors.white, fontFamily: 'BeVietnamPro'),
            decoration: InputDecoration(
              labelText: 'ID thiết bị',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'BeVietnamPro',
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8 * pix),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(8 * pix),
              ),
            ),
          ),
          SizedBox(height: 16 * pix),
          TextField(
            controller: _deviceNameController,
            style: TextStyle(color: Colors.white, fontFamily: 'BeVietnamPro'),
            decoration: InputDecoration(
              labelText: 'Tên thiết bị',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'BeVietnamPro',
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8 * pix),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(8 * pix),
              ),
            ),
          ),
          SizedBox(height: 16 * pix),
          TextField(
            controller: _deviceIpController,
            style: TextStyle(color: Colors.white, fontFamily: 'BeVietnamPro'),
            decoration: InputDecoration(
              labelText: 'Địa chỉ IP',
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'BeVietnamPro',
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8 * pix),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(8 * pix),
              ),
            ),
          ),
          SizedBox(height: 16 * pix),
          ElevatedButton(
            onPressed: () {
              _connectNewDevice();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(
                horizontal: 24 * pix,
                vertical: 12 * pix,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * pix),
              ),
            ),
            child: Text(
              'Kết nối thiết bị',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16 * pix,
                fontFamily: 'BeVietnamPro',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Lưu cài đặt (hiện tại in ra console, sau này có thể gửi lên server)
    print('Tần suất lấy dữ liệu: $_selectedFrequency phút');
    print('Ngưỡng cảnh báo:');
    print('Nhiệt độ cao: $_tempHigh°C');
    print('Nhiệt độ thấp: $_tempLow°C');
    print('Độ ẩm thấp: $_humidityLow%');
    print('Ánh sáng cao: $_lightHigh lux');
    print('CO2 cao: $_co2High ppm');

    // Hiển thị thông báo lưu thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu cài đặt thành công'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _connectNewDevice() {
    final deviceId = _deviceIdController.text;
    final deviceName = _deviceNameController.text;
    final deviceIp = _deviceIpController.text;

    if (deviceId.isEmpty || deviceName.isEmpty || deviceIp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin thiết bị'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Giả lập kết nối thiết bị (in ra console, sau này có thể gửi lên server)
    print('Kết nối thiết bị mới:');
    print('ID: $deviceId');
    print('Tên: $deviceName');
    print('IP: $deviceIp');

    // Xóa form sau khi kết nối
    _deviceIdController.clear();
    _deviceNameController.clear();
    _deviceIpController.clear();

    // Hiển thị thông báo kết nối thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã kết nối thiết bị "$deviceName" thành công'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
