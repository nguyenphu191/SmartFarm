import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'package:intl/intl.dart';

class DetailPlantScreen extends StatefulWidget {
  final String plantid;
  const DetailPlantScreen({super.key, required this.plantid});

  @override
  _DetailPlantScreenState createState() => _DetailPlantScreenState();
}

class _DetailPlantScreenState extends State<DetailPlantScreen> {
  DateTime selectedDate = DateTime.now();
  late Map<String, dynamic> plant;
  TextEditingController plantNameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController yieldController =
      TextEditingController(); // Thêm controller cho sản lượng
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Các loại công việc chăm sóc
  final List<String> careTaskTypes = [
    'Bón phân',
    'Tưới nước',
    'Phun thuốc',
    'Tỉa cành',
    'Thu hoạch',
    'Xử lý sâu bệnh'
  ];

  // Trạng thái cây
  String plantStatus = 'Đang tốt';
  final List<String> statusOptions = [
    'Đang tốt',
    'Cần chú ý',
    'Có vấn đề',
    'Đã thu hoạch'
  ];

  List<Map<String, dynamic>> carePlan = [
    {'date': DateTime.now(), 'task': 'Bón phân', 'completed': false},
    {
      'date': DateTime.now().add(Duration(days: 7)),
      'task': 'Tưới nước',
      'completed': false
    },
    {
      'date': DateTime.now().add(Duration(days: 14)),
      'task': 'Phun thuốc',
      'completed': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.plantid.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(Duration(milliseconds: 800), () {
        if (widget.plantid == "1") {
          plant = {
            "id": widget.plantid,
            "name": "Su hào",
            "image": AppImages.suhao,
            "status": "Đang tốt",
            "address": "Vườn 1",
            "note": "Loại cây dễ trồng, thích hợp khí hậu mát mẻ.",
            "plantDate": DateTime(2024, 1, 15),
            "harvestDate": null,
            "yield": null,
          };
        } else if (widget.plantid == "2") {
          plant = {
            "id": widget.plantid,
            "name": "Khoai tây",
            "image": AppImages.khoaitay,
            "status": "Cần chú ý",
            "address": "Vườn 2",
            "note": "Cần tưới nước đều đặn, tránh ánh nắng trực tiếp.",
            "plantDate": DateTime(2024, 1, 10),
            "harvestDate": null,
            "yield": null,
          };
        } else if (widget.plantid == "3") {
          plant = {
            "id": widget.plantid,
            "name": "Súp lơ",
            "image": AppImages.supno,
            "status": "Đang tốt",
            "address": "Vườn 3",
            "note": "Cần nhiều nước và ánh sáng đầy đủ.",
            "plantDate": DateTime(2024, 2, 1),
            "harvestDate": null,
            "yield": null,
          };
        } else if (widget.plantid == "h1") {
          // Dữ liệu cây đã thu hoạch
          plant = {
            "id": widget.plantid,
            "name": "Su hào",
            "image": AppImages.suhao,
            "status": "Đã thu hoạch",
            "address": "Vườn 1",
            "note": "Loại cây dễ trồng, thích hợp khí hậu mát mẻ.",
            "plantDate": DateTime(2024, 1, 15),
            "harvestDate": DateTime(2024, 3, 20),
            "yield": "12 kg",
          };
        } else {
          plant = {
            "id": widget.plantid,
            "name": "Cây trồng ${widget.plantid}",
            "image": AppImages.suhao,
            "status": "Đang tốt",
            "address": "Vườn ${widget.plantid}",
            "note": "",
            "plantDate": DateTime.now(),
            "harvestDate": null,
            "yield": null,
          };
        }

        plantNameController.text = plant["name"];
        noteController.text = plant["note"] ?? "";
        plantStatus = plant["status"] ?? "Đang tốt";
        selectedDate = plant["plantDate"] ?? DateTime.now();
        yieldController.text = plant["yield"] ?? "";

        setState(() {
          _isLoading = false;
        });
      });
    } else {
      plant = {
        "id": "",
        "name": "",
        "image": null,
        "status": "Đang tốt",
        "address": "",
        "note": "",
        "plantDate": DateTime.now(),
        "harvestDate": null,
        "yield": null,
      };
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: ${e.toString()}'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Lỗi khi chọn ảnh: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chụp ảnh: ${e.toString()}'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Lỗi khi chụp ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    String screenTitle =
        widget.plantid.isEmpty ? 'Thêm cây mới' : 'Chi tiết cây trồng';

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(title: screenTitle, isBack: true),
          ),
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
          Positioned(
            top: 120 * pix,
            left: 16 * pix,
            right: 16 * pix,
            bottom: 0,
            child: _isLoading
                ? _buildLoadingIndicator()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPlantInfoSection(context),
                        SizedBox(height: 20 * pix),
                        plantStatus != 'Đã thu hoạch'
                            ? _buildCarePlanSection(context)
                            : SizedBox(),
                        SizedBox(height: 20 * pix),
                        widget.plantid.isNotEmpty &&
                                plantStatus != 'Đã thu hoạch'
                            ? _buildDiseasePredictionSection(context)
                            : SizedBox(),
                        SizedBox(height: 36 * pix),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlantInfoSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Container(
      width: size.width,
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
          _buildPlantHeader(pix),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
          _buildStatusSection(pix),
          _buildPlantingDateSection(pix),
          if (plantStatus == 'Đã thu hoạch')
            _buildHarvestInfoSection(pix), // Thêm thông tin thu hoạch
          _buildNotesSection(pix),
          _buildActionButtons(pix),
          SizedBox(height: 16 * pix),
        ],
      ),
    );
  }

  Widget _buildPlantHeader(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: plantStatus != 'Đã thu hoạch'
                ? () => _showImageOptions()
                : null,
            child: Container(
              width: 100 * pix,
              height: 100 * pix,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * pix),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _buildPlantImage(pix, 100),
            ),
          ),
          SizedBox(width: 16 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.plantid.isEmpty
                    ? TextField(
                        controller: plantNameController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên cây',
                          hintStyle: TextStyle(
                            fontSize: 18 * pix,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8 * pix),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12 * pix,
                            vertical: 8 * pix,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            plant["name"] = value;
                          });
                        },
                        style: TextStyle(
                          fontSize: 18 * pix,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff165598),
                          fontFamily: 'BeVietnamPro',
                        ),
                      )
                    : Text(
                        plant['name'] ?? 'Chưa đặt tên',
                        style: TextStyle(
                          fontSize: 22 * pix,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff165598),
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                SizedBox(height: 8 * pix),
                if (widget.plantid.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16 * pix,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4 * pix),
                      Text(
                        plant['address'] ?? 'Chưa có địa chỉ',
                        style: TextStyle(
                          fontSize: 14 * pix,
                          color: Colors.grey[600],
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8 * pix),
                if (widget.plantid.isNotEmpty && plantStatus != 'Đã thu hoạch')
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit, size: 16 * pix),
                    label: Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * pix),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * pix,
                        vertical: 6 * pix,
                      ),
                    ),
                    onPressed: () {
                      _showEditPlantInfoDialog();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final pix = MediaQuery.of(context).size.width / 375;
        return Container(
          padding: EdgeInsets.all(20 * pix),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20 * pix)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn ảnh',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              SizedBox(height: 20 * pix),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Chụp ảnh',
                    pix: pix,
                    onTap: () {
                      Navigator.pop(context);
                      _takePicture();
                    },
                  ),
                  _buildImageOptionButton(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    pix: pix,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ],
              ),
              SizedBox(height: 20 * pix),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOptionButton({
    required IconData icon,
    required String label,
    required double pix,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * pix),
      child: Container(
        width: 100 * pix,
        padding: EdgeInsets.all(16 * pix),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12 * pix),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36 * pix,
              color: Colors.green,
            ),
            SizedBox(height: 8 * pix),
            Text(
              label,
              style: TextStyle(
                fontSize: 14 * pix,
                fontWeight: FontWeight.w500,
                fontFamily: 'BeVietnamPro',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlantInfoDialog() {
    final pix = MediaQuery.of(context).size.width / 375;
    final TextEditingController nameController =
        TextEditingController(text: plant['name']);
    final TextEditingController addressController =
        TextEditingController(text: plant['address']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Chỉnh sửa thông tin',
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên cây',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16 * pix),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  plant['name'] = nameController.text;
                  plant['address'] = addressController.text;
                  plantNameController.text = nameController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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

  Widget _buildStatusSection(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái:',
            style: TextStyle(
              fontSize: 16 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 8 * pix),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * pix),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8 * pix),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: plantStatus,
                isExpanded: true,
                items: statusOptions.map((String value) {
                  Color statusColor;
                  if (value == 'Đang tốt') {
                    statusColor = Colors.green;
                  } else if (value == 'Cần chú ý') {
                    statusColor = Colors.orange;
                  } else if (value == 'Có vấn đề') {
                    statusColor = Colors.red;
                  } else {
                    statusColor = Colors.blue; // Màu cho Đã thu hoạch
                  }

                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Container(
                          width: 12 * pix,
                          height: 12 * pix,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8 * pix),
                        Text(
                          value,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: plantStatus != 'Đã thu hoạch'
                    ? (newValue) {
                        if (newValue != null) {
                          if (newValue == 'Đã thu hoạch') {
                            _showHarvestDialog();
                          } else {
                            setState(() {
                              plantStatus = newValue;
                              plant['status'] = newValue;
                            });
                          }
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHarvestDialog() {
    final pix = MediaQuery.of(context).size.width / 375;
    DateTime? harvestDate = DateTime.now();
    TextEditingController yieldController = TextEditingController();
    String quality = 'Tốt'; // Giá trị mặc định cho chất lượng
    final List<String> qualityOptions = [
      'Tệ',
      'Ổn',
      'Tốt',
      'Rất tốt'
    ]; // Các mức chất lượng

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Xác nhận thu hoạch',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Ngày thu hoạch'),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(harvestDate!)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: harvestDate!,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.green,
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          harvestDate = picked;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: yieldController,
                    decoration: InputDecoration(
                      labelText: 'Sản lượng (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16 * pix), // Khoảng cách giữa các mục
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chất lượng:',
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                      SizedBox(height: 8 * pix),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * pix),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8 * pix),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: quality,
                            isExpanded: true,
                            items: qualityOptions.map((String value) {
                              Color qualityColor;
                              switch (value) {
                                case 'Tệ':
                                  qualityColor = Colors.red;
                                  break;
                                case 'Ổn':
                                  qualityColor = Colors.orange;
                                  break;
                                case 'Tốt':
                                  qualityColor = Colors.green;
                                  break;
                                case 'Rất tốt':
                                  qualityColor = Colors.blue;
                                  break;
                                default:
                                  qualityColor = Colors.grey;
                              }
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12 * pix,
                                      height: 12 * pix,
                                      decoration: BoxDecoration(
                                        color: qualityColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8 * pix),
                                    Text(
                                      value,
                                      style: TextStyle(
                                        color: qualityColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  quality = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (yieldController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng nhập sản lượng'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      plantStatus = 'Đã thu hoạch';
                      plant['status'] = 'Đã thu hoạch';
                      plant['harvestDate'] = harvestDate;
                      plant['yield'] = '${yieldController.text} kg';
                      plant['quality'] = quality; // Lưu chất lượng
                      this.yieldController.text = '${yieldController.text} kg';
                    });
                    Navigator.pop(context);
                    _savePlantingPlan(); // Tự động lưu khi xác nhận thu hoạch
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Xác nhận',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlantingDateSection(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ngày trồng:',
            style: TextStyle(
              fontSize: 16 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 8 * pix),
          InkWell(
            onTap: plantStatus != 'Đã thu hoạch'
                ? () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                        plant['plantDate'] = picked;
                      });
                    }
                  }
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * pix,
                vertical: 12 * pix,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8 * pix),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontFamily: 'BeVietnamPro',
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 20 * pix,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestInfoSection(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin thu hoạch:',
            style: TextStyle(
              fontSize: 16 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 8 * pix),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày thu hoạch:',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey[600],
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                    SizedBox(height: 4 * pix),
                    Text(
                      plant['harvestDate'] != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(plant['harvestDate'])
                          : 'Chưa có dữ liệu',
                      style: TextStyle(
                        fontSize: 16 * pix,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sản lượng:',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey[600],
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                    SizedBox(height: 4 * pix),
                    Text(
                      plant['yield'] ?? 'Chưa có dữ liệu',
                      style: TextStyle(
                        fontSize: 16 * pix,
                        fontFamily: 'BeVietnamPro',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ghi chú:',
            style: TextStyle(
              fontSize: 16 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          SizedBox(height: 8 * pix),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú về cây trồng...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * pix),
              ),
              contentPadding: EdgeInsets.all(16 * pix),
            ),
            maxLines: 3,
            onChanged: (value) {
              plant['note'] = value;
            },
            enabled: plantStatus != 'Đã thu hoạch',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: plantStatus != 'Đã thu hoạch'
                  ? () {
                      _savePlantingPlan();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12 * pix),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
              ),
              child: Text(
                'Xác nhận',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16 * pix),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12 * pix),
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
              ),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarePlanSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Container(
      width: size.width,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kế hoạch chăm sóc',
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: 28 * pix,
                  ),
                  onPressed: () {
                    _addNewCareTask();
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
          carePlan.isEmpty
              ? _buildEmptyCarePlan(pix)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: carePlan.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final task = carePlan[index];
                    return _buildCareTaskItem(task, index, pix);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyCarePlan(double pix) {
    return Container(
      padding: EdgeInsets.all(32 * pix),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_note,
              size: 48 * pix,
              color: Colors.grey,
            ),
            SizedBox(height: 16 * pix),
            Text(
              'Chưa có kế hoạch chăm sóc',
              style: TextStyle(
                fontSize: 16 * pix,
                color: Colors.grey[600],
                fontFamily: 'BeVietnamPro',
              ),
            ),
            SizedBox(height: 16 * pix),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Thêm công việc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * pix,
                  vertical: 8 * pix,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
              ),
              onPressed: () {
                _addNewCareTask();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareTaskItem(Map<String, dynamic> task, int index, double pix) {
    return Dismissible(
      key: Key('care-task-${index}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20 * pix),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 26 * pix,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Xóa công việc"),
              content: Text("Bạn có chắc chắn muốn xóa công việc này?"),
              actions: [
                TextButton(
                  child: Text("Hủy"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    "Xóa",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        setState(() {
          carePlan.removeAt(index);
        });
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * pix,
          vertical: 8 * pix,
        ),
        leading: Container(
          width: 40 * pix,
          height: 40 * pix,
          decoration: BoxDecoration(
            color: _getTaskColor(task['task']).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTaskIcon(task['task']),
            color: _getTaskColor(task['task']),
            size: 20 * pix,
          ),
        ),
        title: Text(
          task['task'],
          style: TextStyle(
            fontSize: 16 * pix,
            fontWeight: FontWeight.w500,
            fontFamily: 'BeVietnamPro',
            decoration: task['completed'] == true
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(task['date'])}',
          style: TextStyle(
            fontSize: 14 * pix,
            color: Colors.grey[600],
            fontFamily: 'BeVietnamPro',
            decoration: task['completed'] == true
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.edit,
            size: 20 * pix,
            color: Colors.blue,
          ),
          onPressed: () {
            _editCareTask(index);
          },
        ),
      ),
    );
  }

  Color _getTaskColor(String taskType) {
    switch (taskType) {
      case 'Bón phân':
        return Colors.brown;
      case 'Tưới nước':
        return Colors.blue;
      case 'Phun thuốc':
        return Colors.purple;
      case 'Tỉa cành':
        return Colors.green;
      case 'Thu hoạch':
        return Colors.orange;
      case 'Xử lý sâu bệnh':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'Bón phân':
        return Icons.eco;
      case 'Tưới nước':
        return Icons.water_drop;
      case 'Phun thuốc':
        return Icons.sanitizer;
      case 'Tỉa cành':
        return Icons.content_cut;
      case 'Thu hoạch':
        return Icons.shopping_basket;
      case 'Xử lý sâu bệnh':
        return Icons.bug_report;
      default:
        return Icons.event_note;
    }
  }

  Widget _buildDiseasePredictionSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Container(
      width: size.width,
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
        children: [
          Padding(
            padding: EdgeInsets.all(16 * pix),
            child: Text(
              "Dự đoán bệnh cây",
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 18 * pix,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.2)),
          GestureDetector(
            onTap: () => _showDiseaseScanOptions(),
            child: Container(
              margin: EdgeInsets.all(16 * pix),
              height: 180 * pix,
              width: 180 * pix,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16 * pix),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48 * pix,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 16 * pix),
                  Text(
                    'Chụp ảnh để phân tích',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      color: Colors.grey[700],
                      fontFamily: 'BeVietnamPro',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16 * pix),
            child: ElevatedButton.icon(
              icon: Icon(Icons.healing),
              label: Text('Dự đoán bệnh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * pix,
                  vertical: 12 * pix,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
              ),
              onPressed: () {
                _showDiseaseScanOptions();
              },
            ),
          ),
          SizedBox(height: 16 * pix),
        ],
      ),
    );
  }

  void _showDiseaseScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final pix = MediaQuery.of(context).size.width / 375;
        return Container(
          padding: EdgeInsets.all(20 * pix),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Phân tích bệnh cây',
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              SizedBox(height: 20 * pix),
              Text(
                'Chụp ảnh lá cây bị bệnh để phân tích',
                style: TextStyle(
                  fontSize: 14 * pix,
                  color: Colors.grey[600],
                  fontFamily: 'BeVietnamPro',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20 * pix),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Chụp ảnh',
                    pix: pix,
                    onTap: () {
                      Navigator.pop(context);
                      _showDiseaseAnalysisResult();
                    },
                  ),
                  _buildImageOptionButton(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    pix: pix,
                    onTap: () {
                      Navigator.pop(context);
                      _showDiseaseAnalysisResult();
                    },
                  ),
                ],
              ),
              SizedBox(height: 20 * pix),
            ],
          ),
        );
      },
    );
  }

  void _showDiseaseAnalysisResult() {
    showDialog(
      context: context,
      builder: (context) {
        final pix = MediaQuery.of(context).size.width / 375;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * pix),
          ),
          title: Text(
            'Kết quả phân tích',
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200 * pix,
                height: 150 * pix,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
                child: Icon(
                  Icons.image,
                  size: 48 * pix,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16 * pix),
              Text(
                'Phát hiện bệnh héo xanh vi khuẩn',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * pix),
              Text(
                'Mức độ nhiễm: Trung bình\nKhuyến nghị: Phun thuốc kháng khuẩn và tăng cường thoát nước',
                style: TextStyle(
                  fontSize: 14 * pix,
                  fontFamily: 'BeVietnamPro',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Đóng',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addDiseaseTask();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Thêm vào kế hoạch',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addDiseaseTask() {
    setState(() {
      carePlan.add({
        'date': DateTime.now().add(Duration(days: 1)),
        'task': 'Xử lý sâu bệnh',
        'completed': false,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm việc xử lý bệnh vào kế hoạch'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildPlantImage(double pix, double size) {
    try {
      if (widget.plantid.isNotEmpty && plant['image'] is String) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12 * pix),
          child: Image.asset(
            plant['image']!,
            width: size * pix,
            height: size * pix,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderImage(pix, size);
            },
          ),
        );
      } else if (_selectedImage != null) {
        return FutureBuilder(
          future: _selectedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12 * pix),
                child: Image.memory(
                  snapshot.data!,
                  width: size * pix,
                  height: size * pix,
                  fit: BoxFit.cover,
                ),
              );
            }
            return _buildPlaceholderImage(pix, size);
          },
        );
      }
      return _buildPlaceholderImage(pix, size);
    } catch (e) {
      debugPrint('Lỗi hiển thị ảnh: $e');
      return _buildPlaceholderImage(pix, size);
    }
  }

  Widget _buildPlaceholderImage(double pix, double sz) {
    return Container(
      width: sz * pix,
      height: sz * pix,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12 * pix),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 32 * pix,
            color: Colors.grey[500],
          ),
          SizedBox(height: 8 * pix),
          Text(
            'Thêm ảnh',
            style: TextStyle(
              fontSize: 14 * pix,
              color: Colors.grey[500],
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ],
      ),
    );
  }

  void _savePlantingPlan() {
    if (widget.plantid.isEmpty) {
      if (plantNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng nhập tên cây'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng chọn ảnh cho cây'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, {
        'plant': {
          'id': widget.plantid.isEmpty
              ? 'new_${DateTime.now().millisecondsSinceEpoch}'
              : widget.plantid,
          'name': plant["name"],
          'image': _selectedImage?.path ?? plant["image"],
          'status': plantStatus,
          'note': noteController.text,
          'plantDate': selectedDate,
          'harvestDate': plant["harvestDate"],
          'yield': plant["yield"],
        },
        'plantingDate': selectedDate,
        'carePlan': carePlan,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.plantid.isEmpty
              ? 'Đã thêm cây mới'
              : 'Đã cập nhật thông tin cây'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _addNewCareTask() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final task = await showDialog<String>(
        context: context,
        builder: (context) {
          String selectedTask = careTaskTypes[0];
          return AlertDialog(
            title: Text('Thêm công việc'),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ngày: ${DateFormat('dd/MM/yyyy').format(pickedDate)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTask,
                    decoration: InputDecoration(
                      labelText: 'Công việc',
                      border: OutlineInputBorder(),
                    ),
                    items: careTaskTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              _getTaskIcon(value),
                              color: _getTaskColor(value),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      selectedTask = newValue!;
                    },
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
                  Navigator.pop(context, selectedTask);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  'Thêm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (task != null) {
        setState(() {
          carePlan.add({
            'date': pickedDate,
            'task': task,
            'completed': false,
          });
          carePlan.sort((a, b) => a['date'].compareTo(b['date']));
        });
      }
    }
  }

  void _editCareTask(int index) async {
    final originalTask = carePlan[index];
    DateTime newDate = originalTask['date'];
    String newTask = originalTask['task'];
    bool isCompleted = originalTask['completed'] ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Chỉnh sửa công việc'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Ngày'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(newDate)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: newDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.green,
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          newDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: newTask,
                    decoration: InputDecoration(
                      labelText: 'Công việc',
                      border: OutlineInputBorder(),
                    ),
                    items: careTaskTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              _getTaskIcon(value),
                              color: _getTaskColor(value),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          newTask = value;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isCompleted,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            isCompleted = value ?? false;
                          });
                        },
                      ),
                      Text('Đã hoàn thành'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      carePlan[index]['date'] = newDate;
                      carePlan[index]['task'] = newTask;
                      carePlan[index]['completed'] = isCompleted;
                      carePlan.sort((a, b) => a['date'].compareTo(b['date']));
                    });
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật công việc'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
