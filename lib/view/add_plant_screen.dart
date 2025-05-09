import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/provider/location_provider.dart';
import 'package:smart_farm/provider/season_provider.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'package:intl/intl.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  DateTime selectedDate = DateTime.now();
  TextEditingController plantNameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String _stauts = 'Đang tốt';
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isSeasonExpanded = false;
  bool _isLocationExpanded = false;
  String? _selectedSeasonId;
  String? _selectedLocationId;
  String systemImg = "";

  // Các loại công việc chăm sóc
  final List<String> careTaskTypes = [
    'Bón phân',
    'Tưới nước',
    'Phun thuốc',
    'Tỉa cành',
    'Thu hoạch',
    'Xử lý sâu bệnh'
  ];

  final List<String> statusOptions = ['Đang tốt', 'Cần chú ý', 'Có vấn đề'];

  List<Map<String, dynamic>> carePlan = [];

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

  void _showDefaultImageSelector() {
    final pix = MediaQuery.of(context).size.width / 375;

    // Danh sách các ảnh mặc định
    final List<Map<String, dynamic>> defaultImages = [
      {"image": AppImages.suhao, "name": "Su hào"},
      {"image": AppImages.khoaitay, "name": "Khoai tây"},
      {"image": AppImages.supno, "name": "Súp lơ"},
      {"image": AppImages.caitim, "name": "Cải tím"},
      {"image": AppImages.duachuot, "name": "Dưa chuột"},
      {"image": AppImages.salach, "name": "Sa lách"},
      {"image": AppImages.toi, "name": "Tỏi"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(20 * pix),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn ảnh mặc định',
                    style: TextStyle(
                      fontSize: 18 * pix,
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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10 * pix,
                    mainAxisSpacing: 10 * pix,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: defaultImages.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          plantNameController.text =
                              defaultImages[index]['name'];
                          systemImg = defaultImages[index]['image'];
                        });
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12 * pix),
                                child: Image.asset(
                                  defaultImages[index]['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4 * pix),
                          Text(
                            defaultImages[index]['name'],
                            style: TextStyle(
                              fontSize: 12 * pix,
                              fontFamily: 'BeVietnamPro',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
                  _buildImageOptionButton(
                    icon: Icons.eco,
                    label: 'Mẫu có sẵn',
                    pix: pix,
                    onTap: () {
                      Navigator.pop(context);
                      _showDefaultImageSelector();
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seasonProvider =
          Provider.of<SeasonProvider>(context, listen: false);
      seasonProvider.fetchSeasons();
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      locationProvider.reset();
    });
  }

  Future<void> fetchLocations(String seasonId) async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.fetchLocations(seasonId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(title: 'Thêm cây mới', isBack: true),
          ),
          Positioned(
            top: 70 * pix,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: size.width,
              height: size.height - 100 * pix,
              decoration: BoxDecoration(
                color: const Color(0xff47BFDF).withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            top: 80 * pix,
            left: 16 * pix,
            right: 16 * pix,
            bottom: 0,
            child: _isLoading
                ? _buildLoadingIndicator()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPlantInfoSection(context),
                        SizedBox(height: 16 * pix),
                        _buildCarePlanSection(context),
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
            'Đang xử lý...',
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
          _buildSeasonsSection(pix),
          _buildAddressSection(pix),
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
            onTap: () => _showImageOptions(),
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
                TextField(
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
                  style: TextStyle(
                    fontSize: 18 * pix,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff165598),
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                SizedBox(height: 8 * pix),
                Text(
                  'Vui lòng điền thông tin cơ bản',
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: Colors.grey[600],
                    fontFamily: 'BeVietnamPro',
                    fontStyle: FontStyle.italic,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantImage(double pix, double size) {
    try {
      if (_selectedImage != null) {
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
      } else if (systemImg.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12 * pix),
          child: Image.asset(
            systemImg,
            width: size * pix,
            height: size * pix,
            fit: BoxFit.cover,
          ),
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
                value: _stauts,
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
                    statusColor = Colors.blue;
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
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _stauts = newValue;
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
            onTap: () async {
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
                });
              }
            },
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

  Widget _buildSeasonsSection(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isSeasonExpanded = !_isSeasonExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mùa vụ:',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                Icon(
                  _isSeasonExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 24 * pix,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * pix),
          Consumer<SeasonProvider>(
            builder: (context, seasonProvider, child) {
              if (seasonProvider.loading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (seasonProvider.seasons.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có mùa vụ nào',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              } else if (_isSeasonExpanded) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: seasonProvider.seasons.length,
                  itemBuilder: (context, index) {
                    final season = seasonProvider.seasons[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSeasonId = season.id;
                        });
                        fetchLocations(season.id);
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * pix),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16 * pix),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      season.name,
                                      style: TextStyle(
                                        fontSize: 16 * pix,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8 * pix),
                                    Text(
                                      'Start: ${DateFormat('dd/MM/yyyy').format(season.startDate!)}',
                                      style: TextStyle(
                                        fontSize: 14 * pix,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5 * pix),
                                    Text(
                                      'End: ${DateFormat('dd/MM/yyyy').format(season.endDate!)}',
                                      style: TextStyle(
                                        fontSize: 14 * pix,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: season.id,
                                groupValue: _selectedSeasonId,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSeasonId = value;
                                  });
                                  fetchLocations(value!);
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(double pix) {
    return Padding(
      padding: EdgeInsets.all(16 * pix),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isLocationExpanded = !_isLocationExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Địa điểm trồng:',
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                Icon(
                  _isLocationExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 24 * pix,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * pix),
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              if (locationProvider.loading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (locationProvider.locations.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có vị trí nào',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              } else if (_isLocationExpanded) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: locationProvider.locations.length,
                  itemBuilder: (context, index) {
                    final location = locationProvider.locations[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * pix),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16 * pix),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.name,
                                    style: TextStyle(
                                      fontSize: 16 * pix,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8 * pix),
                                  Text(
                                    'D/c: ${location.description}',
                                    style: TextStyle(
                                      fontSize: 14 * pix,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5 * pix),
                                  Text(
                                    'D/t: ${location.area}',
                                    style: TextStyle(
                                      fontSize: 14 * pix,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: location.id,
                              groupValue: _selectedLocationId,
                              onChanged: (value) {
                                setState(() {
                                  _selectedLocationId = value;
                                });
                              },
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12 * pix),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
              ),
              child: Text(
                'Thêm cây',
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
                  child: Text("HủyCola"),
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
          ),
        ),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(task['date'])}',
          style: TextStyle(
            fontSize: 14 * pix,
            color: Colors.grey[600],
            fontFamily: 'BeVietnamPro',
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
}
