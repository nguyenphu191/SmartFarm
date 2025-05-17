import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/models/plant_model.dart';
import 'package:smart_farm/provider/auth_provider.dart';
import 'package:smart_farm/provider/plant_provider.dart';
import 'package:smart_farm/utils/base_url.dart';
import 'package:smart_farm/view/add_plant_screen.dart';
import 'package:smart_farm/view/detail_plant.dart';
import 'package:smart_farm/view/seasons_screen.dart';
import 'package:smart_farm/widget/bottom_bar.dart';
import 'package:smart_farm/theme/app_colors.dart';
import 'package:smart_farm/widget/network_img.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  final _baseUrl = BaseUrl.baseUrl;
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
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
    _controller.forward();

    // khởi tạo data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantProvider = Provider.of<PlantProvider>(context, listen: false);
      plantProvider.fetchPlants(false);
      allPlants = plantProvider.plants;
    });
  }

  List<PlantModel> allPlants = [];

  // lọc cây trồng
  List<PlantModel> get filteredPlants {
    if (searchController.text.isEmpty) {
      return allPlants;
    }

    return allPlants
        .where((plant) =>
            plant.name!
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            plant.address!
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            Consumer<PlantProvider>(builder: (context, plantProvider, child) {
              if (plantProvider.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (plantProvider.plants.isEmpty) {
                return _buildEmptyState(pix);
              }

              return Positioned(
                top: 180 * pix,
                left: 16 * pix,
                right: 16 * pix,
                bottom: 50 * pix,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 40 * pix),
                      // Search Bar
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16 * pix),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16 * pix,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm cây trồng',
                            hintStyle: const TextStyle(color: AppColors.textGrey),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textGrey,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppColors.textGrey,
                                    ),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16 * pix,
                              vertical: 14 * pix,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(height: 24 * pix),
                      // Plants List

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: plantProvider.plants.length,
                        itemBuilder: (context, index) {
                          final plant = plantProvider.plants[index];
                          return _buildPlantCard(
                            plant: plant,
                            pix: pix,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPlantScreen(
                                    seasonId: plant.seasonId!,
                                    locationId: plant.locationId!,
                                    plantid: plant.id!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 40 * pix),
                    ],
                  ),
                ),
              );
            }),

            _buildHeader(size, pix),
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
                  child: const Bottombar(type: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, double pix) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 200 * pix,
        width: size.width,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30 * pix),
            bottomRight: Radius.circular(30 * pix),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 8),
              blurRadius: 15,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -20 * pix,
              right: -20 * pix,
              child: Container(
                height: 150 * pix,
                width: 150 * pix,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -60 * pix,
              left: -30 * pix,
              child: Container(
                height: 180 * pix,
                width: 180 * pix,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Consumer<AuthProvider>(builder: (context, authProvider, child) {
              if (authProvider.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final user = authProvider.user;
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * pix),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10 * pix),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleIconButton(
                            icon: Icons.menu_rounded,
                            pix: pix,
                            onTap: () => _showOptionsDialog(context, pix),
                          ),
                          _buildCircleIconButton(
                            icon: Icons.notifications_outlined,
                            pix: pix,
                            onTap: () => _showNotificationsSnackBar(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 16 * pix),
                      Row(
                        children: [
                          Container(
                              height: 80 * pix,
                              width: 80 * pix,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3 * pix,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: NetworkImageWidget(
                                  url: "${_baseUrl}${user?.avatar}" ?? "",
                                  width: 80 * pix,
                                  height: 80 * pix,
                                ),
                              )),
                          SizedBox(width: 16 * pix),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào,',
                                  style: TextStyle(
                                    fontSize: 16 * pix,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'BeVietnamPro',
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                SizedBox(height: 4 * pix),
                                Text(
                                  user?.username ?? 'Người dùng',
                                  style: TextStyle(
                                    fontSize: 24 * pix,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'BeVietnamPro',
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8 * pix),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12 * pix,
                                    vertical: 6 * pix,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(20 * pix),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.eco,
                                        color: Colors.white,
                                        size: 16 * pix,
                                      ),
                                      SizedBox(width: 6 * pix),
                                      Text(
                                        'Chúc vụ mùa bội thu!',
                                        style: TextStyle(
                                          fontSize: 14 * pix,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'BeVietnamPro',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // trạng thái khi không tìm thấy cây trồng
  Widget _buildEmptyState(double pix) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 50 * pix),
          Icon(
            Icons.search_off,
            size: 70 * pix,
            color: Colors.white.withOpacity(0.7),
          ),
          SizedBox(height: 16 * pix),
          Text(
            'Không tìm thấy cây trồng nào',
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

  // card cây trồng
  Widget _buildPlantCard({
    required PlantModel plant,
    required double pix,
    required VoidCallback onTap,
  }) {
    Color statusColor = AppColors.statusGood;
    if (plant.status!.contains('Cần chú ý')) {
      statusColor = AppColors.statusWarning;
    } else if (plant.status!.contains('Có vấn đề')) {
      statusColor = AppColors.statusDanger;
    }
    String img = plant.image!;
    bool sys = false;
    if (img[1] == 'd') {
      img = img.substring(17);
      sys = true;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: 16 * pix),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * pix),
          child: Row(
            children: [
              sys
                  ? Container(
                      height: 80 * pix,
                      width: 80 * pix,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 * pix),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        img,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipOval(
                      child: NetworkImageWidget(
                        url: "${_baseUrl}${img}",
                        width: 80 * pix,
                        height: 80 * pix,
                      ),
                    ),
              SizedBox(width: 16 * pix),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18 * pix,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BeVietnamPro',
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 6 * pix),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16 * pix,
                          color: AppColors.textGrey,
                        ),
                        SizedBox(width: 4 * pix),
                        Text(
                          plant.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14 * pix,
                            fontFamily: 'BeVietnamPro',
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * pix),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * pix,
                        vertical: 4 * pix,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12 * pix),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8 * pix,
                            height: 8 * pix,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          SizedBox(width: 6 * pix),
                          Text(
                            plant.status!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13 * pix,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'BeVietnamPro',
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18 * pix,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // icon của menu
  Widget _buildCircleIconButton({
    required IconData icon,
    required double pix,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20 * pix),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20 * pix),
        child: Container(
          height: 40 * pix,
          width: 40 * pix,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24 * pix,
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, double pix) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Tuỳ chọn",
            style: TextStyle(
              fontSize: 20 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
              color: AppColors.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogOption(
                context: context,
                icon: Icons.add_circle_outline,
                title: 'Thêm mùa vụ mới',
                pix: pix,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeasonsScreen(),
                    ),
                  );
                },
              ),
              _buildDialogOption(
                context: context,
                icon: Icons.add_circle_outline,
                title: 'Thêm cây mới',
                pix: pix,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPlantScreen(),
                    ),
                  );
                },
              ),
              _buildDialogOption(
                context: context,
                icon: Icons.help_outline,
                title: 'Trợ giúp',
                pix: pix,
                onTap: () {
                  Navigator.pop(context);
                  _showHelpBottomSheet(context, pix);
                },
              ),
              _buildDialogOption(
                context: context,
                icon: Icons.logout,
                title: 'Đăng xuất',
                pix: pix,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  authProvider.logout();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã đăng xuất'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required double pix,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * pix),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * pix,
          vertical: 12 * pix,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * pix),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12 * pix),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 24 * pix,
              ),
            ),
            SizedBox(width: 16 * pix),
            Text(
              title,
              style: TextStyle(
                fontSize: 16 * pix,
                fontWeight: FontWeight.w500,
                fontFamily: 'BeVietnamPro',
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context, double pix) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * pix)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24 * pix),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trợ giúp',
                style: TextStyle(
                  fontSize: 24 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 20 * pix),
              _buildHelpItem(
                icon: Icons.search,
                title: 'Tìm kiếm cây trồng',
                description: 'Nhập tên hoặc địa chỉ vườn để tìm kiếm cây trồng',
                pix: pix,
              ),
              _buildHelpItem(
                icon: Icons.add_circle,
                title: 'Thêm cây trồng mới',
                description: 'Nhấn vào biểu tượng menu và chọn "Thêm cây mới"',
                pix: pix,
              ),
              _buildHelpItem(
                icon: Icons.touch_app,
                title: 'Xem chi tiết cây trồng',
                description: 'Nhấn vào một cây trồng bất kỳ để xem chi tiết',
                pix: pix,
              ),
              SizedBox(height: 20 * pix),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: 14 * pix),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * pix),
                    ),
                  ),
                  child: Text(
                    'Đã hiểu',
                    style: TextStyle(
                      fontSize: 16 * pix,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
    required double pix,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20 * pix),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10 * pix),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12 * pix),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 24 * pix,
            ),
          ),
          SizedBox(width: 16 * pix),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4 * pix),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: AppColors.textGrey,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Không có thông báo mới'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
