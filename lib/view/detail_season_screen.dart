import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/models/season_model.dart';
import 'package:smart_farm/provider/location_provider.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'package:intl/intl.dart';

class DetailSeasonScreen extends StatefulWidget {
  final SeasonModel season;

  const DetailSeasonScreen({Key? key, required this.season}) : super(key: key);

  @override
  State<DetailSeasonScreen> createState() => _DetailSeasonScreenState();
}

class _DetailSeasonScreenState extends State<DetailSeasonScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _areaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false)
          .fetchLocations(widget.season.id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> addLocation(
      String seasonId, String name, String description, int area) async {
    if (name.isEmpty || description.isEmpty || area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final success = await locationProvider.addLocation(
      seasonId,
      name,
      description,
      area,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm vị trí thành công')),
      );

      Navigator.of(context).pop();
      _nameController.clear();
      _addressController.clear();
      _areaController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm vị trí thất bại')),
      );
    }
  }

  Future<void> deleteLocation(String locationId) async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final success =
        await locationProvider.deleteLocation(widget.season.id, locationId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa vị trí thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa vị trí thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        backgroundColor: const Color(0xff47BFDF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: const Color(0xff47BFDF).withOpacity(0.5),
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              title: 'Chi tiết mùa vụ',
              isBack: true,
            ),
          ),

          // Main content
          Positioned(
            top: 80 * pix,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * pix),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSeasonHeader(pix),
                    SizedBox(height: 16 * pix),
                    _buildDateRangeInfo(pix),
                    SizedBox(height: 24 * pix),
                    _buildLocationsView(pix),
                    SizedBox(height: 24 * pix),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonHeader(double pix) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * pix),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * pix),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.season.name,
                    style: TextStyle(
                      fontSize: 20 * pix,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * pix,
                    vertical: 5 * pix,
                  ),
                  decoration: BoxDecoration(
                    color: widget.season.isActive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15 * pix),
                  ),
                  child: Text(
                    widget.season.isActive ? 'Đang hoạt động' : 'Đã kết thúc',
                    style: TextStyle(
                      fontSize: 12 * pix,
                      fontWeight: FontWeight.bold,
                      color: widget.season.isActive
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16 * pix),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ mùa vụ',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * pix),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeInfo(double pix) {
    return Card(
      elevation: 3,
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
                    'Ngày bắt đầu',
                    style: TextStyle(
                      fontSize: 14 * pix,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4 * pix),
                  Text(
                    widget.season.startDate != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(widget.season.startDate!)
                        : 'Chưa xác định',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40 * pix,
              width: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16 * pix),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày kết thúc',
                      style: TextStyle(
                        fontSize: 14 * pix,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4 * pix),
                    Text(
                      widget.season.endDate != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(widget.season.endDate!)
                          : 'Chưa xác định',
                      style: TextStyle(
                        fontSize: 16 * pix,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsView(double pix) {
    return Column(
      children: [
        Text(
          'Danh sách vị trí',
          style: TextStyle(
            fontSize: 18 * pix,
            fontWeight: FontWeight.bold,
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
            } else {
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
                          SizedBox(width: 16 * pix),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Xóa vị trí'),
                                      content: Text(
                                          'Bạn có chắc chắn muốn xóa vị trí này không?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteLocation(location.id);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Xóa'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                size: 25 * pix,
                                color: Colors.red,
                              )),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _showAddLocationDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final pix = size.width / 375;
        return AlertDialog(
          title: Text('Thêm vị trí mới'),
          content: Container(
            width: size.width * 0.8,
            height: size.height * 0.4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: 'Nhập tên vị trí'),
                  ),
                  SizedBox(height: 16 * pix),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(hintText: 'Nhập địa chỉ'),
                  ),
                  SizedBox(height: 16 * pix),
                  TextField(
                    controller: _areaController,
                    decoration:
                        InputDecoration(hintText: 'Nhập diện tích (m2)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                addLocation(
                    widget.season.id,
                    _nameController.text,
                    _addressController.text,
                    int.tryParse(_areaController.text) ?? 0);
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }
}
