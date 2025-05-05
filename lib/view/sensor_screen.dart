import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/theme/app_colors.dart';
import 'package:smart_farm/widget/bottom_bar.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animationController;

  // MQTT Client
  late MqttServerClient client;
  final String broker = '103.6.234.189'; // IP của Mosquitto server
  final int port = 1883;
  final String clientIdentifier =
      'smart_farm_flutter_${DateTime.now().millisecondsSinceEpoch}';
  final String username = 'admin'; // Username
  final String password = 'admin'; // Password

  bool isConnected = false;
  bool isConnecting = false;
  String connectionStatus = 'Chưa kết nối';

  StreamSubscription? mqttSubscription;

  // Thêm biến để lưu trữ các message nhận được theo topic
  Map<String, List<String>> topicMessages = {};
  final int maxStoredMessages =
      10; // Số lượng tối đa tin nhắn lưu trữ cho mỗi topic

  // Danh sách các khu vườn (dữ liệu cứng ban đầu)
  List<Map<String, dynamic>> gardens = [
    {
      'id': 'garden_a',
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
      'lastUpdated': null,
    },
    {
      'id': 'garden_b',
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
      'lastUpdated': null,
    },
    {
      'id': 'garden_c',
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
      'lastUpdated': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    // Khởi tạo kết nối MQTT
    _initMQTT();

    // Kiểm tra kết nối định kỳ
    Timer.periodic(Duration(seconds: 30), (timer) {
      _checkConnection();
    });
  }

  void _checkConnection() {
    if (client.connectionStatus?.state != MqttConnectionState.connected &&
        !isConnecting) {
      _reconnect();
    }
  }

  void _initMQTT() async {
    if (isConnecting) return;

    setState(() {
      isConnecting = true;
      connectionStatus = 'Đang kết nối...';
    });

    try {
      client = MqttServerClient(broker, clientIdentifier);
      client.port = port;
      client.logging(on: true);
      client.keepAlivePeriod = 60;
      client.autoReconnect = true;
      client.resubscribeOnAutoReconnect = true;

      // Cấu hình kết nối
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientIdentifier)
          .withWillTopic('smart_farm/disconnect')
          .withWillMessage('Flutter client disconnected')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      // Thêm username và password
      connMessage.authenticateAs(username, password);

      client.connectionMessage = connMessage;

      // Xử lý callbacks
      client.onConnected = _onConnected;
      client.onDisconnected = _onDisconnected;
      client.onSubscribed = _onSubscribed;
      client.pongCallback = _pongCallback;

      // Kết nối tới server
      await client.connect();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi kết nối MQTT: $e');
      }
      _cleanUpOnError();
      _showConnectionError();
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  void _cleanUpOnError() {
    setState(() {
      isConnected = false;
      connectionStatus = 'Lỗi kết nối';
    });

    try {
      client.disconnect();
    } catch (e) {
      // Bỏ qua lỗi khi disconnect
    }
  }

  void _reconnect() async {
    if (isConnecting) return;

    setState(() {
      isConnecting = true;
      connectionStatus = 'Đang kết nối lại...';
      isConnected = false;
    });

    try {
      // Hủy subscription cũ
      mqttSubscription?.cancel();

      // Đảm bảo client ngắt kết nối sạch sẽ
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        client.disconnect();
      }

      // Tạo mới client
      _initMQTT();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi reconnect: $e');
      }
      _cleanUpOnError();
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  void _onConnected() {
    if (kDebugMode) {
      print('Đã kết nối tới MQTT broker');
    }
    setState(() {
      isConnected = true;
      connectionStatus = 'Đã kết nối';
    });

    // Subscribe tới các topic
    _subscribeToTopics();

    // Bắt đầu lắng nghe messages
    mqttSubscription = client.updates?.listen(_onMessage);
  }

  void _onDisconnected() {
    if (kDebugMode) {
      print('Ngắt kết nối MQTT');
    }
    setState(() {
      isConnected = false;
      connectionStatus = 'Mất kết nối';
    });
  }

  void _onSubscribed(String topic) {
    if (kDebugMode) {
      print('Đã subscribe topic: $topic');
    }
  }

  void _pongCallback() {
    if (kDebugMode) {
      print('Ping response từ broker');
    }
  }

  void _subscribeToTopics() {
    // Subscribe tới topic của từng vườn
    for (var garden in gardens) {
      String topic = 'smart_farm/${garden['id']}/sensor_data';
      client.subscribe(topic, MqttQos.atLeastOnce);
    }

    // Subscribe tới topic thời tiết chung
    client.subscribe('smart_farm/weather', MqttQos.atLeastOnce);

    // Subscribe tới topic alerts
    client.subscribe('smart_farm/alerts', MqttQos.atLeastOnce);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final String topic = event[0].topic;

    // Lưu message vào danh sách theo topic
    setState(() {
      if (!topicMessages.containsKey(topic)) {
        topicMessages[topic] = [];
      }

      // Thêm thông tin thời gian vào message
      final now = DateTime.now();
      final timeStr = DateFormat('HH:mm:ss').format(now);
      final logMessage = "[$timeStr] $message";

      // Thêm vào đầu danh sách (hiển thị mới nhất trước)
      topicMessages[topic]!.insert(0, logMessage);

      // Giới hạn số lượng message lưu trữ
      if (topicMessages[topic]!.length > maxStoredMessages) {
        topicMessages[topic]!.removeLast();
      }
    });

    if (kDebugMode) {
      print('Nhận message từ topic $topic: $message');
    }

    try {
      final data = json.decode(message);

      if (topic.contains('/sensor_data')) {
        // Xử lý dữ liệu cảm biến từng vườn
        _updateGardenData(topic, data);
      } else if (topic == 'smart_farm/weather') {
        // Xử lý dữ liệu thời tiết chung
        _updateWeatherData(data);
      } else if (topic == 'smart_farm/alerts') {
        // Xử lý thông báo cảnh báo
        _showAlert(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi parse message: $e');
      }
    }
  }

  void _updateGardenData(String topic, Map<String, dynamic> data) {
    String gardenId = '';

    // Trích xuất ID vườn từ topic
    for (var garden in gardens) {
      if (topic.contains(garden['id'])) {
        gardenId = garden['id'];
        break;
      }
    }

    if (gardenId.isNotEmpty) {
      setState(() {
        // Tìm và cập nhật dữ liệu cho vườn tương ứng
        for (var i = 0; i < gardens.length; i++) {
          if (gardens[i]['id'] == gardenId) {
            // Cập nhật dữ liệu sensor
            if (data.containsKey('temperature'))
              gardens[i]['temperature'] = data['temperature'];
            if (data.containsKey('humidity'))
              gardens[i]['humidity'] = data['humidity'];
            if (data.containsKey('wind')) gardens[i]['wind'] = data['wind'];
            if (data.containsKey('light')) gardens[i]['light'] = data['light'];
            if (data.containsKey('soilMoisture'))
              gardens[i]['soilMoisture'] = data['soilMoisture'];

            // Cập nhật lịch sử
            if (data.containsKey('temperature')) {
              List<dynamic> tempHistory = List.from(gardens[i]['historyTemp']);
              tempHistory.removeAt(0);
              tempHistory.add(data['temperature']);
              gardens[i]['historyTemp'] = tempHistory;
            }

            if (data.containsKey('humidity')) {
              List<dynamic> humidityHistory =
                  List.from(gardens[i]['historyHumidity']);
              humidityHistory.removeAt(0);
              humidityHistory.add(data['humidity']);
              gardens[i]['historyHumidity'] = humidityHistory;
            }

            // Cập nhật thời gian cập nhật cuối
            gardens[i]['lastUpdated'] = DateTime.now();
            break;
          }
        }
      });
    }
  }

  void _updateWeatherData(Map<String, dynamic> data) {
    setState(() {
      // Cập nhật thông tin thời tiết cho từng vườn nếu có
      for (var i = 0; i < gardens.length; i++) {
        String gardenId = gardens[i]['id'];
        if (data.containsKey(gardenId) &&
            data[gardenId] is Map &&
            data[gardenId].containsKey('weather')) {
          gardens[i]['weather'] = data[gardenId]['weather'];

          // Cập nhật hình ảnh thời tiết tương ứng (có thể mở rộng thêm)
          _updateWeatherImage(i);
        }
      }
    });
  }

  void _updateWeatherImage(int gardenIndex) {
    // Thay đổi hình ảnh thời tiết dựa vào điều kiện thời tiết
    // Hiện tại chưa có nhiều icon thời tiết, dùng mặc định
  }

  void _showAlert(Map<String, dynamic> data) {
    // Hiển thị cảnh báo từ server
    if (data.containsKey('message') && data.containsKey('level')) {
      String message = data['message'];
      String level = data['level'].toString().toLowerCase();

      Color backgroundColor;
      switch (level) {
        case 'warning':
          backgroundColor = AppColors.statusWarning;
          break;
        case 'danger':
          backgroundColor = AppColors.statusDanger;
          break;
        default:
          backgroundColor = AppColors.primaryBlue;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Đóng',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _showConnectionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối tới server MQTT'),
          backgroundColor: AppColors.statusDanger,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () {
              _initMQTT();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();

    // Hủy subscription MQTT
    mqttSubscription?.cancel();

    // Đảm bảo ngắt kết nối MQTT
    try {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        client.disconnect();
      }
    } catch (e) {
      // Bỏ qua lỗi khi disconnect
    }

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
              height: size.height - 70 * pix,
              decoration: BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Garden selector tabs
                    _buildGardenTabs(pix),

                    // Main weather page view
                    Container(
                      height: 560 * pix,
                      width: size.width,
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
                            key: ValueKey('garden_$index'),
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

                    // Connection indicator
                    _buildConnectionStatus(pix),
                    SizedBox(height: 96 * pix),
                  ],
                ),
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

  Widget _buildConnectionStatus(double pix) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * pix, vertical: 8 * pix),
      padding: EdgeInsets.symmetric(horizontal: 12 * pix, vertical: 8 * pix),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.statusGood.withOpacity(0.2)
            : AppColors.statusDanger.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20 * pix),
      ),
      child: Row(
        children: [
          Container(
            width: 8 * pix,
            height: 8 * pix,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isConnected ? AppColors.statusGood : AppColors.statusDanger,
            ),
          ),
          SizedBox(width: 8 * pix),
          Text(
            connectionStatus,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12 * pix,
              fontWeight: FontWeight.w500,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          if (!isConnected && !isConnecting) ...[
            SizedBox(width: 8 * pix),
            GestureDetector(
              onTap: _initMQTT,
              child: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 16 * pix,
              ),
            ),
          ],
          Spacer(),
          // Thêm nút debug
          GestureDetector(
            onTap: () => _showDebugDialog(context),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10 * pix, vertical: 4 * pix),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16 * pix),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bug_report,
                    color: Colors.white,
                    size: 16 * pix,
                  ),
                  SizedBox(width: 4 * pix),
                  Text(
                    'Debug',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12 * pix,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'BeVietnamPro',
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

  // 4. Hàm hiển thị dialog debug
  void _showDebugDialog(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * pix),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(16 * pix),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MQTT Debug',
                      style: TextStyle(
                        fontSize: 20 * pix,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16 * pix),
                Expanded(
                  child: topicMessages.isEmpty
                      ? Center(
                          child: Text('Chưa có dữ liệu nhận được từ MQTT.'))
                      : DefaultTabController(
                          length: topicMessages.keys.length,
                          child: Column(
                            children: [
                              TabBar(
                                isScrollable: true,
                                labelColor: AppColors.primaryGreen,
                                unselectedLabelColor: Colors.grey,
                                tabs: topicMessages.keys.map((topic) {
                                  // Hiển thị tên topic ngắn gọn
                                  String displayTopic = topic.split('/').last;
                                  return Tab(
                                    text: displayTopic,
                                  );
                                }).toList(),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: topicMessages.keys.map((topic) {
                                    return _buildTopicMessagesList(topic, pix);
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                SizedBox(height: 16 * pix),
                // Thêm nút gửi message MQTT test
                ElevatedButton(
                  onPressed: () => _publishTestMessage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: Text(
                    'Gửi message test',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. Hàm hiển thị danh sách message cho một topic
  Widget _buildTopicMessagesList(String topic, double pix) {
    if (topicMessages[topic]?.isEmpty ?? true) {
      return Center(
        child: Text(
          'Chưa có dữ liệu',
          style: TextStyle(
            fontSize: 16 * pix,
            fontFamily: 'BeVietnamPro',
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: topicMessages[topic]!.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final message = topicMessages[topic]![index];
        return Container(
          padding: EdgeInsets.all(8 * pix),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Topic: $topic',
                style: TextStyle(
                  fontSize: 12 * pix,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              SizedBox(height: 4 * pix),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8 * pix),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14 * pix,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. Hàm gửi message test
  void _publishTestMessage() {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      try {
        // Tạo message test với timestamp
        final now = DateTime.now();
        final timeStr = DateFormat('HH:mm:ss').format(now);

        // Test data cho từng garden
        for (var garden in gardens) {
          final gardenId = garden['id'];
          final testData = {
            'temperature':
                (20 + math.Random().nextDouble() * 15).toStringAsFixed(1),
            'humidity':
                (40 + math.Random().nextDouble() * 50).toStringAsFixed(1),
            'wind': (5 + math.Random().nextInt(15)),
            'light': (200 + math.Random().nextInt(600)),
            'soilMoisture': (30 + math.Random().nextInt(50)),
            'timestamp': timeStr,
          };

          final topic = 'smart_farm/$gardenId/sensor_data';
          final payload = json.encode(testData);
          final builder = MqttClientPayloadBuilder();
          builder.addString(payload);

          client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
              retain: false);

          print('Đã gửi message test tới topic $topic: $payload');
        }

        // Test data cho weather
        final weatherStates = [
          'Nắng',
          'Mưa nhẹ',
          'Nhiều mây',
          'Nắng gián đoạn'
        ];
        final weatherData = {};

        for (var garden in gardens) {
          weatherData[garden['id']] = {
            'weather':
                weatherStates[math.Random().nextInt(weatherStates.length)],
            'timestamp': timeStr,
          };
        }

        final weatherTopic = 'smart_farm/weather';
        final weatherPayload = json.encode(weatherData);
        final weatherBuilder = MqttClientPayloadBuilder();
        weatherBuilder.addString(weatherPayload);

        client.publishMessage(
            weatherTopic, MqttQos.atLeastOnce, weatherBuilder.payload!,
            retain: false);

        print('Đã gửi message test tới topic $weatherTopic: $weatherPayload');

        // Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi message test thành công'),
            backgroundColor: AppColors.statusGood,
          ),
        );
      } catch (e) {
        print('Lỗi khi gửi message test: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi message test: $e'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chưa kết nối tới MQTT broker'),
          backgroundColor: AppColors.statusDanger,
        ),
      );
    }
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
                  color: isSelected ? AppColors.primaryGreen : Colors.white,
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
                  ? AppColors.primaryGreen
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

    final now = DateTime.now();
    final dateFormat = DateFormat('d MMMM, yyyy');
    final formattedDate = dateFormat.format(now);

    // Format thời gian cập nhật cuối
    String lastUpdatedText = "";
    if (garden['lastUpdated'] != null) {
      final lastUpdated = garden['lastUpdated'] as DateTime;
      lastUpdatedText =
          "Cập nhật lúc: ${DateFormat('HH:mm:ss').format(lastUpdated)}";
    }

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
            padding: EdgeInsets.all(10 * pix),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24 * pix),
              color: Colors.white.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date and last updated
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12 * pix,
                        color: Colors.white,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                    if (garden['lastUpdated'] != null)
                      Text(
                        lastUpdatedText,
                        style: TextStyle(
                          fontSize: 12 * pix,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'BeVietnamPro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
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
                        fontSize: 50 * pix,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'BeVietnamPro',
                        height: 0.9,
                      ),
                    ),
                    Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 20 * pix,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * pix),

                // Weather condition
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * pix,
                    vertical: 5 * pix,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20 * pix),
                  ),
                  child: Text(
                    garden['weather'],
                    style: TextStyle(
                      fontSize: 14 * pix,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ),

                Divider(
                  color: Colors.white.withOpacity(0.3),
                  height: 20 * pix,
                  thickness: 1.5,
                ),

                // Weather metrics in grid
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.air,
                            value: '${garden['wind']} km/h',
                            label: 'Gió',
                            pix: pix,
                            iconColor: AppColors.lightBlue,
                          ),
                        ),
                        SizedBox(width: 12 * pix),
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.opacity,
                            value: '${garden['humidity']}%',
                            label: 'Độ ẩm',
                            pix: pix,
                            iconColor: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * pix),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.wb_sunny,
                            value: '${garden['light']} lux',
                            label: 'Ánh sáng',
                            pix: pix,
                            iconColor: AppColors.accentYellow,
                          ),
                        ),
                        SizedBox(width: 12 * pix),
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.grass,
                            value: '${garden['soilMoisture']}%',
                            label: 'Độ ẩm đất',
                            pix: pix,
                            iconColor: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
      padding: EdgeInsets.all(10 * pix),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16 * pix),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10 * pix),
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
          SizedBox(height: 12 * pix),
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
}
