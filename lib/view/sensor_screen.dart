import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/view/setting_sensor_screen.dart';
import 'package:smart_farm/widget/bottom_bar.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animationController;
  // IO.Socket? socket;

  // Danh sách các khu vườn (dữ liệu cứng)
  List<Map<String, dynamic>> gardens = [
    {
      'name': 'Vườn A',
      'weather': 'Nắng',
      'image': AppImages.mua,
      'temperature': 34,
      'wind': 10,
      'humidity': 54,
      'light': 500,
      'soilMoisture': 42,
      'historyTemp': [28, 30, 32, 34, 33, 31, 29],
      'historyHumidity': [60, 58, 55, 54, 53, 56, 58],
    },
    {
      'name': 'Vườn B',
      'weather': 'Mưa nhẹ',
      'image': AppImages.mua,
      'temperature': 28,
      'wind': 15,
      'humidity': 78,
      'light': 320,
      'soilMoisture': 68,
      'historyTemp': [26, 27, 28, 28, 29, 28, 27],
      'historyHumidity': [72, 75, 78, 80, 79, 78, 78],
    },
    {
      'name': 'Vườn C',
      'weather': 'Nhiều mây',
      'image': AppImages.mua,
      'temperature': 31,
      'wind': 8,
      'humidity': 62,
      'light': 420,
      'soilMoisture': 55,
      'historyTemp': [29, 30, 31, 32, 31, 30, 31],
      'historyHumidity': [65, 63, 62, 60, 61, 62, 62],
    },
  ];

  // Thêm dữ liệu cho biểu đồ
  final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    // // Khởi tạo kết nối Socket.IO (đã comment vì chưa có server)
    // _initSocket();
  }

  // void _initSocket() {
  //   try {
  //     // Thay bằng URL server thực tế, ví dụ: 'http://192.168.1.100:3000'
  //     const serverUrl = 'http://localhost:3000'; // Thay bằng URL thực tế
  //     socket = IO.io(serverUrl, <String, dynamic>{
  //       'transports': ['websocket'],
  //       'autoConnect': false,
  //     });

  //     socket!.connect();

  //     socket!.onConnect((_) {
  //       print('Kết nối thành công với server Socket.IO');
  //     });

  //     // Lắng nghe dữ liệu cảm biến mới
  //     socket!.on('sensorData', (data) {
  //       setState(() {
  //         final gardenIndex = gardens.indexWhere((g) => g['name'] == data['gardenName']);
  //         if (gardenIndex != -1) {
  //           gardens[gardenIndex] = {
  //             ...gardens[gardenIndex],
  //             'temperature': data['temperature'] ?? gardens[gardenIndex]['temperature'],
  //             'wind': data['wind'] ?? gardens[gardenIndex]['wind'],
  //             'humidity': data['humidity'] ?? gardens[gardenIndex]['humidity'],
  //             'light': data['light'] ?? gardens[gardenIndex]['light'],
  //             'soilMoisture': data['soilMoisture'] ?? gardens[gardenIndex]['soilMoisture'],
  //             'weather': data['weather'] ?? gardens[gardenIndex]['weather'],
  //             'historyTemp': [
  //               ...gardens[gardenIndex]['historyTemp'].sublist(1),
  //               data['temperature'] ?? gardens[gardenIndex]['temperature']
  //             ],
  //             'historyHumidity': [
  //               ...gardens[gardenIndex]['historyHumidity'].sublist(1),
  //               data['humidity'] ?? gardens[gardenIndex]['humidity']
  //             ],
  //           };
  //         }
  //       });
  //     });

  //     socket!.onDisconnect((_) {
  //       print('Ngắt kết nối với server Socket.IO');
  //     });

  //     socket!.onError((error) {
  //       print('Lỗi Socket.IO: $error');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Lỗi kết nối server cảm biến'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     });
  //   } catch (e) {
  //     print('Không thể khởi tạo Socket.IO: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Không thể kết nối đến server cảm biến'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    // socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            child: TopBar(
              title: "Thông tin cảm biến",
              isBack: false,
            ),
            top: 0,
            left: 0,
            right: 0,
          ),
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
              child: Column(
                children: [
                  // Garden selector tabs
                  _buildGardenTabs(pix),

                  // Main weather page view
                  Expanded(
                    child: PageView.builder(
                      itemCount: gardens.length,
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final isCurrentPage = index == _currentPage;
                        return AnimatedContainer(
                          key: ValueKey(
                              'garden_$index'), // Đảm bảo mỗi thẻ có key riêng
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOutQuint,
                          margin: EdgeInsets.only(
                            top: isCurrentPage ? 0 : 20 * pix,
                            bottom: isCurrentPage ? 0 : 20 * pix,
                            left: 5 * pix,
                            right: 5 * pix,
                          ),
                          child: _buildWeatherCard(
                            context: context,
                            garden: gardens[index],
                          ),
                        );
                      },
                    ),
                  ),

                  // Page indicator
                  _buildPageIndicator(pix),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Bottombar(type: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenTabs(double pix) {
    return Container(
      height: 30 * pix,
      margin: EdgeInsets.only(top: 10 * pix),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gardens.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentPage;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8 * pix),
              padding: EdgeInsets.symmetric(horizontal: 16 * pix),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30 * pix),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        )
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                gardens[index]['name'],
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14 * pix,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(double pix) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16 * pix),
      height: 10 * pix,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          gardens.length,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 4 * pix),
            width: index == _currentPage ? 24 * pix : 10 * pix,
            decoration: BoxDecoration(
              color: index == _currentPage
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(5 * pix),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
      {required BuildContext context, required Map<String, dynamic> garden}) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    // Lấy ngày hiện tại
    final now = DateTime.now();
    final dateFormat = DateFormat('d MMMM, yyyy');
    final formattedDate = dateFormat.format(now);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Weather icon animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * math.pi * 0.05,
                child: child,
              );
            },
            child: Image.asset(
              garden['image'],
              width: 120 * pix,
              height: 120 * pix,
              fit: BoxFit.contain,
            ),
          ),

          // Main weather card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16 * pix),
            padding: EdgeInsets.all(8 * pix),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24 * pix),
              color: Colors.white.withOpacity(0.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12 * pix,
                    color: Colors.white,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),

                SizedBox(height: 10 * pix),

                // Temperature display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${garden['temperature']}',
                      style: TextStyle(
                        fontSize: 60 * pix,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'BeVietnamPro',
                        height: 0.9,
                      ),
                    ),
                    Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 26 * pix,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * pix),

                // Weather condition
                Text(
                  ' ${garden['weather']}',
                  style: TextStyle(
                    fontSize: 18 * pix,
                    color: Colors.white,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),

                Divider(
                  color: Colors.white.withOpacity(0.5),
                  thickness: 1.5 * pix,
                  height: 18 * pix,
                ),

                // Weather metrics in grid
                Container(
                  padding: EdgeInsets.all(12 * pix),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.air,
                              value: '${garden['wind']} km/h',
                              label: 'Gió',
                              pix: pix,
                              iconColor: Colors.cyan,
                            ),
                          ),
                          SizedBox(width: 8 * pix),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.opacity,
                              value: '${garden['humidity']}%',
                              label: 'Độ ẩm',
                              pix: pix,
                              iconColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * pix),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.wb_sunny,
                              value: '${garden['light']} lux',
                              label: 'Ánh sáng',
                              pix: pix,
                              iconColor: Colors.amber,
                            ),
                          ),
                          SizedBox(width: 8 * pix),
                          Expanded(
                            child: _buildMetricCard(
                              icon: Icons.grass,
                              value: '${garden['soilMoisture']}%',
                              label: 'Độ ẩm đất',
                              pix: pix,
                              iconColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // // Actions buttons
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     _buildActionButton(
                //       icon: Icons.history,
                //       label: 'Lịch sử',
                //       pix: pix,
                //       onTap: () {
                //         _showHistoryBottomSheet(context, garden);
                //       },
                //     ),
                //     _buildActionButton(
                //       icon: Icons.notifications,
                //       label: 'Cảnh báo',
                //       pix: pix,
                //       onTap: () {
                //         _showAlertDialog(context, garden);
                //       },
                //     ),
                //     _buildActionButton(
                //       icon: Icons.settings,
                //       label: 'Cài đặt',
                //       pix: pix,
                //       onTap: () {
                //         _showSettingsDialog(context);
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ),

          SizedBox(height: 56 * pix),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required double pix,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * pix),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 65, 65, 65).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12 * pix),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8 * pix),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24 * pix,
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 4 * pix),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required double pix,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * pix),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * pix,
          vertical: 8 * pix,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12 * pix),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24 * pix,
            ),
            SizedBox(height: 4 * pix),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * pix,
                fontFamily: 'BeVietnamPro',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryBottomSheet(
      BuildContext context, Map<String, dynamic> garden) {
    final pix = MediaQuery.of(context).size.width / 375;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24 * pix),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40 * pix,
                height: 5 * pix,
                margin: EdgeInsets.symmetric(vertical: 12 * pix),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5 * pix),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16 * pix),
                child: Text(
                  'Lịch sử dữ liệu: ${garden['name']}',
                  style: TextStyle(
                    fontSize: 20 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: 30, // 30 days of history
                  itemBuilder: (context, index) {
                    final date = DateTime.now().subtract(Duration(days: index));
                    final dateStr = DateFormat('dd/MM/yyyy').format(date);

                    // Random history data (in real app this would come from database)
                    final temp = 25 + math.Random().nextInt(10);
                    final humidity = 50 + math.Random().nextInt(30);
                    final light = 300 + math.Random().nextInt(300);
                    final soil = 40 + math.Random().nextInt(40);

                    return ListTile(
                      title: Text(
                        dateStr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                      subtitle: Text(
                        'Nhiệt độ: $temp°C | Độ ẩm: $humidity% | Ánh sáng: $light lux',
                        style: TextStyle(fontFamily: 'BeVietnamPro'),
                      ),
                      trailing: Container(
                        width: 40 * pix,
                        height: 40 * pix,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove_red_eye,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: () {
                        // Show detailed view for this day
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Xem chi tiết ngày $dateStr'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context, Map<String, dynamic> garden) {
    final pix = MediaQuery.of(context).size.width / 375;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Cài đặt cảnh báo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
              fontSize: 20 * pix,
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAlertSlider(
                  label: 'Nhiệt độ cao',
                  value: 35.0,
                  min: 20.0,
                  max: 45.0,
                  unit: '°C',
                  pix: pix,
                ),
                _buildAlertSlider(
                  label: 'Nhiệt độ thấp',
                  value: 15.0,
                  min: 5.0,
                  max: 25.0,
                  unit: '°C',
                  pix: pix,
                ),
                _buildAlertSlider(
                  label: 'Độ ẩm thấp',
                  value: 30.0,
                  min: 10.0,
                  max: 50.0,
                  unit: '%',
                  pix: pix,
                ),
                _buildAlertSlider(
                  label: 'Ánh sáng cao',
                  value: 800.0,
                  min: 500.0,
                  max: 1500.0,
                  unit: 'lux',
                  pix: pix,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã lưu cài đặt cảnh báo'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required double pix,
  }) {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 16 * pix,
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
            onChanged: (newValue) {
              setState(() {
                // Trong ứng dụng thực, bạn sẽ cập nhật giá trị trạng thái
              });
            },
          ),
          SizedBox(height: 8 * pix),
        ],
      );
    });
  }

  void _showSettingsDialog(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Cài đặt cảm biến',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
              fontSize: 20 * pix,
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      Icon(Icons.schedule, color: Colors.blue, size: 24 * pix),
                  title: Text(
                    'Tần suất cập nhật',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 16 * pix,
                    ),
                  ),
                  subtitle: Text(
                    'Mỗi 15 phút',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 14 * pix,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16 * pix),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.device_hub,
                      color: Colors.blue, size: 24 * pix),
                  title: Text(
                    'Trạng thái thiết bị',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 16 * pix,
                    ),
                  ),
                  subtitle: Text(
                    'Đang hoạt động',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'BeVietnamPro',
                      fontSize: 14 * pix,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16 * pix),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.battery_full,
                      color: Colors.blue, size: 24 * pix),
                  title: Text(
                    'Pin',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 16 * pix,
                    ),
                  ),
                  subtitle: Text(
                    '85%',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 14 * pix,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16 * pix),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.wifi, color: Colors.blue),
                  title: Text(
                    'Kết nối',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 16 * pix,
                    ),
                  ),
                  subtitle: Text(
                    'WiFi',
                    style: TextStyle(
                      fontFamily: 'BeVietnamPro',
                      fontSize: 14 * pix,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16 * pix),
                  onTap: () {},
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Đóng',
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 16 * pix,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showCalibrationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Hiệu chỉnh',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'BeVietnamPro',
                    fontSize: 16 * pix),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCalibrationDialog(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hiệu chỉnh cảm biến',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
              fontSize: 20 * pix,
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn có chắc chắn muốn hiệu chỉnh lại các cảm biến không?',
                  style: TextStyle(
                    fontFamily: 'BeVietnamPro',
                    fontSize: 16 * pix,
                  ),
                ),
                SizedBox(height: 16 * pix),
                Text(
                  'Quá trình này sẽ mất khoảng 5 phút và các cảm biến sẽ tạm thời không hoạt động trong thời gian hiệu chỉnh.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontFamily: 'BeVietnamPro',
                    fontSize: 14 * pix,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showCalibrationProgress(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Hiệu chỉnh',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'BeVietnamPro',
                    fontSize: 16 * pix),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCalibrationProgress(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double progress = 0.0;

            // Simulate calibration progress
            Future.delayed(Duration(milliseconds: 100), () {
              var timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
                setState(() {
                  progress += 0.01;
                  if (progress >= 1.0) {
                    timer.cancel();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hiệu chỉnh cảm biến thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              });
            });

            return AlertDialog(
              title: Text(
                'Đang hiệu chỉnh...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  fontSize: 20 * pix,
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16 * pix),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BeVietnamPro',
                        fontSize: 20 * pix,
                      ),
                    ),
                    SizedBox(height: 8 * pix),
                    Text(
                      'Vui lòng không tắt ứng dụng trong quá trình hiệu chỉnh',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12 * pix,
                        fontFamily: 'BeVietnamPro',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
