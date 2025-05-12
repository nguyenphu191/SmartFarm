import 'package:flutter/material.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/view/detail_plant.dart';
import 'package:smart_farm/widget/bottom_bar.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;  

  // Danh sách cây trồng đã thu hoạch
  List<Map<String, dynamic>> harvestedPlants = [
    {
      "id": "h1",
      "name": "Su hào",
      "image": AppImages.suhao,
      "address": "Vườn 1",
      "status": "Đã thu hoạch",
      "plantDate": DateTime(2024, 1, 15),
      "harvestDate": DateTime(2024, 3, 20),
      "yield": "12 kg",
      "quality": "Tốt",
    },
    {
      "id": "h2",
      "name": "Khoai tây",
      "image": AppImages.khoaitay,
      "address": "Vườn 2",
      "status": "Đã thu hoạch",
      "plantDate": DateTime(2024, 1, 10),
      "harvestDate": DateTime(2024, 4, 5),
      "yield": "30 kg",
      "quality": "Rất tốt",
    },
    {
      "id": "h3",
      "name": "Súp lơ",
      "image": AppImages.supno,
      "address": "Vườn 3",
      "status": "Đã thu hoạch",
      "plantDate": DateTime(2024, 2, 1),
      "harvestDate": DateTime(2024, 4, 10),
      "yield": "8 kg",
      "quality": "Trung bình",
    },
  ];

  // Danh sách lịch sử vụ mùa
  List<Map<String, dynamic>> seasonHistory = [
    {
      "id": "s1",
      "season": "Xuân 2024",
      "totalPlants": 15,
      "totalYield": "120 kg",
      "startDate": DateTime(2024, 1, 1),
      "endDate": DateTime(2024, 4, 30),
      "status": "Đang diễn ra",
    },
    {
      "id": "s2",
      "season": "Đông 2023",
      "totalPlants": 12,
      "totalYield": "95 kg",
      "startDate": DateTime(2023, 10, 1),
      "endDate": DateTime(2023, 12, 31),
      "status": "Hoàn thành",
    },
    {
      "id": "s3",
      "season": "Thu 2023",
      "totalPlants": 10,
      "totalYield": "78 kg",
      "startDate": DateTime(2023, 7, 1),
      "endDate": DateTime(2023, 9, 30),
      "status": "Hoàn thành",
    },
  ];
  late AnimationController _controller;
  late Animation<double> _animation;
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _controller.forward();

    // Initialize data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    // Mô phỏng tải dữ liệu từ server
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Stack(
        children: [
          // Top Bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              title: "Lịch sử vụ mùa",
              isBack: false,
            ),
          ),

          // Main content
          Positioned(
            top: 60 * pix,
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
                  // Search Bar
                  Padding(
                    padding: EdgeInsets.all(16 * pix),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm cây trồng',
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30 * pix),
                        ),
                        fillColor: Colors.white.withOpacity(0.2),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(30 * pix),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30 * pix),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _buildHarvestedTab(),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_animation),
                child: Bottombar(type: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestedTab() {
    final pix = MediaQuery.of(context).size.width / 375;

    // Filter plants based on search
    final filteredPlants = searchController.text.isEmpty
        ? harvestedPlants
        : harvestedPlants
            .where((plant) =>
                plant['name']
                    .toString()
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                plant['address']
                    .toString()
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
            .toList();

    if (filteredPlants.isEmpty) {
      return _buildEmptyState(
        icon: Icons.eco,
        message: 'Không tìm thấy cây trồng',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16 * pix, 0, 16 * pix, 60 * pix),
      itemCount: filteredPlants.length,
      itemBuilder: (context, index) {
        final plant = filteredPlants[index];
        return _buildHarvestedCard(plant: plant, pix: pix);
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    final pix = MediaQuery.of(context).size.width / 375;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80 * pix,
            color: Colors.white.withOpacity(0.7),
          ),
          SizedBox(height: 16 * pix),
          Text(
            message,
            style: TextStyle(
              fontSize: 18 * pix,
              color: Colors.white,
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestedCard(
      {required Map<String, dynamic> plant, required double pix}) {
    final plantDate = DateFormat('dd/MM/yyyy').format(plant['plantDate']);
    final harvestDate = DateFormat('dd/MM/yyyy').format(plant['harvestDate']);

    return Card(
      margin: EdgeInsets.only(bottom: 16 * pix),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * pix),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPlantScreen(
                  seasonId: "", locationId: "", plantid: plant['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16 * pix),
        child: Container(
          padding: EdgeInsets.all(16 * pix),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant image
              ClipRRect(
                borderRadius: BorderRadius.circular(12 * pix),
                child: Image.asset(
                  plant['image'],
                  width: 60 * pix,
                  height: 60 * pix,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10 * pix),

              // Plant details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plant name and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plant['name'],
                          style: TextStyle(
                            fontSize: 18 * pix,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * pix,
                            vertical: 4 * pix,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12 * pix),
                          ),
                          child: Text(
                            plant['status'],
                            style: TextStyle(
                              fontSize: 12 * pix,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * pix),

                    // Plant location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16 * pix,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4 * pix),
                        Text(
                          plant['address'],
                          style: TextStyle(
                            fontSize: 14 * pix,
                            color: Colors.grey[600],
                            fontFamily: 'BeVietnamPro',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * pix),

                    // Plant dates
                    Row(
                      children: [
                        _buildDateInfo(
                          label: 'Ngày trồng',
                          date: plantDate,
                          icon: Icons.calendar_today,
                          pix: pix,
                        ),
                        SizedBox(width: 16 * pix),
                        _buildDateInfo(
                          label: 'Ngày thu hoạch',
                          date: harvestDate,
                          icon: Icons.event_available,
                          pix: pix,
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * pix),

                    // Yield and quality
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            label: 'Sản lượng',
                            value: plant['yield'],
                            icon: Icons.inventory,
                            pix: pix,
                          ),
                        ),
                        SizedBox(width: 8 * pix),
                        Expanded(
                          child: _buildInfoChip(
                            label: 'Chất lượng',
                            value: plant['quality'],
                            icon: Icons.star,
                            pix: pix,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo({
    required String label,
    required String date,
    required IconData icon,
    required double pix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * pix,
            color: Colors.grey[600],
            fontFamily: 'BeVietnamPro',
          ),
        ),
        SizedBox(height: 4 * pix),
        Row(
          children: [
            Icon(
              icon,
              size: 12 * pix,
              color: Colors.grey[600],
            ),
            SizedBox(width: 4 * pix),
            Text(
              date,
              style: TextStyle(
                fontSize: 14 * pix,
                fontWeight: FontWeight.w500,
                fontFamily: 'BeVietnamPro',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required IconData icon,
    required double pix,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * pix,
        vertical: 6 * pix,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8 * pix),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16 * pix,
            color: Colors.blue,
          ),
          SizedBox(width: 4 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10 * pix,
                    color: Colors.grey[600],
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
