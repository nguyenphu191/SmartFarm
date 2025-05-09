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
  final String broker = '103.6.234.189'; // IP của Mosquitto server local
  final int port = 1883;
  final String clientIdentifier =
      'smart_farm_flutter_${DateTime.now().millisecondsSinceEpoch}';
  final String username = 'admin'; // Username
  final String password = 'admin'; // Password
  final String mainTopic = 'sensor/data'; // Topic chính để subscribe

  bool isConnected = false;
  bool isConnecting = false;
  String connectionStatus = 'Chưa kết nối';

  StreamSubscription? mqttSubscription;

  // Thêm biến để lưu trữ các message nhận được theo topic
  Map<String, List<String>> topicMessages = {};
  final int maxStoredMessages = 20; // Số lượng tin nhắn lưu trữ

  // Thêm biến để lưu trữ lịch sử dữ liệu chi tiết
  Map<String, List<Map<String, dynamic>>> sensorDataHistory = {};
  final int maxHistoryEntries = 50; // Số lượng mục lưu trữ tối đa

  // Danh sách các khu vườn (chỉ giữ cấu trúc, dữ liệu sẽ được cập nhật từ MQTT)
  List<Map<String, dynamic>> gardens = [
    {
      'id': 'garden_a',
      'name': 'Vườn A',
      'weather': 'Đang cập nhật...',
      'image': AppImages.mua,
      'temperature': 0,
      'humidity': 0,
      'light': 0,
      'soilMoisture': 0,
      'lastUpdated': null,
    },
    {
      'id': 'garden_b',
      'name': 'Vườn B',
      'weather': 'Đang cập nhật...',
      'image': AppImages.mua,
      'temperature': 0,
      'humidity': 0,
      'light': 0,
      'soilMoisture': 0,
      'lastUpdated': null,
    },
    {
      'id': 'garden_c',
      'name': 'Vườn C',
      'weather': 'Đang cập nhật...',
      'image': AppImages.mua,
      'temperature': 0,
      'humidity': 0,
      'light': 0,
      'soilMoisture': 0,
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

    // Subscribe tới topic
    _subscribeToTopic();

    // Bắt đầu lắng nghe messages
    mqttSubscription = client.updates?.listen(_onMessage);

    // Hiển thị thông báo kết nối thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã kết nối tới MQTT broker tại $broker:$port'),
        backgroundColor: AppColors.statusGood,
        duration: Duration(seconds: 2),
      ),
    );
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

  void _subscribeToTopic() {
    // Subscribe tới topic chính
    client.subscribe(mainTopic, MqttQos.atLeastOnce);

    if (kDebugMode) {
      print('Đã đăng ký nhận dữ liệu từ topic: $mainTopic');
    }

    // Hiển thị thông báo đã đăng ký nhận dữ liệu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã đăng ký nhận dữ liệu từ topic: $mainTopic'),
        backgroundColor: AppColors.statusGood,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    try {
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

      // Xử lý dữ liệu từ topic chính
      if (topic == mainTopic) {
        try {
          final data = json.decode(message);
          // Cập nhật dữ liệu cho tất cả các vườn
          _updateAllGardens(data);
        } catch (e) {
          if (kDebugMode) {
            print('Lỗi parse message từ topic $topic: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi xử lý message MQTT: $e');
      }
    }
  }

  // Cập nhật dữ liệu cho tất cả các vườn từ một nguồn dữ liệu
  void _updateAllGardens(Map<String, dynamic> data) {
    final now = DateTime.now();

    // Kiểm tra các trường dữ liệu cần thiết
    if (!data.containsKey('nhietdo') ||
        !data.containsKey('doam') ||
        !data.containsKey('anhsang')) {
      if (kDebugMode) {
        print('Dữ liệu không hợp lệ: $data');
      }
      return;
    }

    // Debug log - in dữ liệu nhận được để kiểm tra
    if (kDebugMode) {
      print('Đang cập nhật dữ liệu vườn với dữ liệu MQTT: $data');
    }

    setState(() {
      for (var i = 0; i < gardens.length; i++) {
        // Lấy trực tiếp giá trị từ dữ liệu MQTT, không qua xử lý
        final temperature = (data['nhietdo'] as num).toDouble();
        final humidity = (data['doam'] as num).toDouble();
        final light = (data['anhsang'] as num).toDouble();

        // Lấy độ ẩm đất nếu có, nếu không dùng giá trị mặc định
        final soilMoisture = data.containsKey('doamdat')
            ? (data['doamdat'] as num).toDouble()
            : 50.0;

        // Dự đoán thời tiết dựa trên các giá trị nhận được
        final weatherCondition = duDoanThoiTiet(
          nhietDo: temperature,
          doAm: humidity,
          anhSang: light,
        );

        // Cập nhật trực tiếp dữ liệu cho vườn
        gardens[i]['temperature'] = temperature.round();
        gardens[i]['humidity'] = humidity.round();
        gardens[i]['light'] = light.round();
        gardens[i]['soilMoisture'] = soilMoisture.round();
        gardens[i]['weather'] = weatherCondition;
        gardens[i]['lastUpdated'] = now; // Cập nhật thời gian

        // // Log để kiểm tra
        // if (kDebugMode && i == 0) {
        //   print('Vườn ${gardens[i]['name']} sau khi cập nhật: '
        //       'nhiệt độ=${gardens[i]['temperature']}, '
        //       'độ ẩm=${gardens[i]['humidity']}, '
        //       'ánh sáng=${gardens[i]['light']}, '
        //       'độ ẩm đất=${gardens[i]['soilMoisture']}');
        // }

        // Cập nhật lịch sử (nếu cần)
        // Bạn có thể giữ lại hoặc bỏ phần này nếu không quan tâm đến lịch sử
        final historyKey = '${gardens[i]['id']}/sensor_data';

        if (!sensorDataHistory.containsKey(historyKey)) {
          sensorDataHistory[historyKey] = [];
        }

        // Lưu trữ dữ liệu hiện tại vào lịch sử
        Map<String, dynamic> entryWithTimestamp = {
          'temperature': temperature.round(),
          'humidity': humidity.round(),
          'light': light.round(),
          'soilMoisture': soilMoisture.round(),
          'timestamp': now.millisecondsSinceEpoch,
        };

        sensorDataHistory[historyKey]!.add(entryWithTimestamp);

        if (sensorDataHistory[historyKey]!.length > maxHistoryEntries) {
          sensorDataHistory[historyKey]!.removeAt(0);
        }
      }
    });
  }

  void _showConnectionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối tới MQTT broker tại $broker:$port'),
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

  String duDoanThoiTiet({
    required double nhietDo,
    required double doAm,
    required double anhSang,
  }) {
    if (doAm > 80 && anhSang < 100) {
      return "Mưa";
    } else if (anhSang > 600 && nhietDo > 30 && doAm < 60) {
      return "Nắng";
    } else if (anhSang >= 200 && anhSang <= 600 && doAm >= 60) {
      return "Nhiều mây";
    } else {
      return "Nhiều mây";
    }
  }

  String image(String type) {
    switch (type) {
      case 'Mưa':
        return AppImages.mua;
      case 'Nắng':
        return AppImages.sun;
      case 'Nhiều mây':
        return AppImages.may;
      default:
        return AppImages.sun;
    }
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
                      height: 520 * pix,
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
                            child: _buildWeatherCardWithHistoryButton(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                connectionStatus,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * pix,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              Text(
                'Broker: $broker:$port ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10 * pix,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              Text(
                'Topic: $mainTopic',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10 * pix,
                  fontFamily: 'BeVietnamPro',
                ),
              )
            ],
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
          // Cải tiến nút debug
          _buildDebugButton(pix),
        ],
      ),
    );
  }

  // Nút debug cải tiến
  Widget _buildDebugButton(double pix) {
    return GestureDetector(
      onTap: () => _showEnhancedDebugDialog(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * pix, vertical: 4 * pix),
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
              'MQTT',
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
    );
  }

  // Dialog debug nâng cao
  void _showEnhancedDebugDialog(BuildContext context) {
    final pix = MediaQuery.of(context).size.width / 375;
    String searchFilter = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
                        'MQTT',
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

                  // Thêm trường tìm kiếm
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8 * pix),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm thông tin...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8 * pix),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchFilter = value;
                        });
                      },
                    ),
                  ),

                  // Thông tin kết nối
                  Container(
                    padding: EdgeInsets.all(8 * pix),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? AppColors.statusGood.withOpacity(0.1)
                          : AppColors.statusDanger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8 * pix),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8 * pix,
                          height: 8 * pix,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected
                                ? AppColors.statusGood
                                : AppColors.statusDanger,
                          ),
                        ),
                        SizedBox(width: 8 * pix),
                        Text(
                          'Broker: $broker:$port ',
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8 * pix),

                  // Content area
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
                                    String displayTopic = topic.split('/').last;
                                    return Tab(
                                      text: displayTopic,
                                    );
                                  }).toList(),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: topicMessages.keys.map((topic) {
                                      // Lọc message theo searchFilter
                                      List<String> filteredMessages =
                                          searchFilter.isEmpty
                                              ? topicMessages[topic]!
                                              : topicMessages[topic]!
                                                  .where((msg) => msg
                                                      .toLowerCase()
                                                      .contains(searchFilter
                                                          .toLowerCase()))
                                                  .toList();

                                      return _buildTopicMessagesList(
                                          topic, pix, filteredMessages);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  SizedBox(height: 16 * pix),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              topicMessages.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textGrey,
                          ),
                          child: Text(
                            'Xóa logs',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * pix),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _reconnect();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                          ),
                          child: Text(
                            'Kết nối lại',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // Hiển thị danh sách message
  Widget _buildTopicMessagesList(
      String topic, double pix, List<String> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu phù hợp',
          style: TextStyle(
            fontSize: 16 * pix,
            fontFamily: 'BeVietnamPro',
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final message = messages[index];
        return Container(
          padding: EdgeInsets.all(8 * pix),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  // Add timestamp extraction
                  Text(
                    _extractTimestamp(message),
                    style: TextStyle(
                      fontSize: 10 * pix,
                      color: AppColors.textGrey,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                ],
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
                  _extractMessageContent(message),
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

  // Hàm trích xuất timestamp từ message
  String _extractTimestamp(String message) {
    // Định dạng thông thường là: [HH:mm:ss] message
    RegExp regex = RegExp(r'\[(.*?)\]');
    var match = regex.firstMatch(message);
    return match != null ? match.group(1) ?? '' : '';
  }

  // Hàm trích xuất nội dung message (bỏ timestamp)
  String _extractMessageContent(String message) {
    // Bỏ phần [HH:mm:ss] ở đầu message
    return message.replaceFirst(RegExp(r'\[.*?\]\s*'), '');
  }

  Widget _buildWeatherCardWithHistoryButton(
      {required BuildContext context, required Map<String, dynamic> garden}) {
    return _buildWeatherCard(context: context, garden: garden);
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
              image(garden['weather']),
              width: 100 * pix,
              height: 100 * pix,
              fit: BoxFit.contain,
            ),
          ),

          // Main weather card with MQTT data
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

                // Weather condition from MQTT data
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

                SizedBox(height: 10 * pix),

                Divider(
                  color: Colors.white.withOpacity(0.3),
                  height: 10 * pix,
                  thickness: 1.5,
                ),

                // Weather metrics in grid
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.thermostat,
                            value: '${garden['temperature']} °C',
                            label: 'Nhiệt độ',
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
              size: 20 * pix,
            ),
          ),
          SizedBox(height: 8 * pix),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 4 * pix),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ],
      ),
    );
  }
}
