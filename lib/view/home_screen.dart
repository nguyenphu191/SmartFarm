import 'package:flutter/material.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/view/detail_plant.dart';
import 'package:smart_farm/widget/bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> allPlants = [
    {
      "id": "1",
      "name": "Su hào",
      "image": AppImages.suhao,
      "address": "Vườn 1",
      "status": "Đang tốt",
    },
    {
      "id": "2",
      "name": "Khoai tây",
      "image": AppImages.khoaitay,
      "address": "Vườn 2",
      "status": "Đang tốt",
    },
    {
      "id": "3",
      "name": "Súp lơ",
      "image": AppImages.supno,
      "address": "Vườn 3",
      "status": "Đang tốt",
    },
    {
      "id": "4",
      "name": "Su hào",
      "image": AppImages.suhao,
      "address": "Vườn 4",
      "status": "Đang tốt",
    },
    {
      "id": "5",
      "name": "Khoai tây",
      "image": AppImages.khoaitay,
      "address": "Vườn 5",
      "status": "Đang tốt",
    },
    {
      "id": "6",
      "name": "Súp lơ",
      "image": AppImages.supno,
      "address": "Vườn 6",
      "status": "Đang tốt",
    },
  ];

  // Filtered plants based on search
  List<Map<String, String>> get filteredPlants {
    if (searchController.text.isEmpty) {
      return allPlants;
    }

    return allPlants
        .where((plant) =>
            plant['name']!
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            plant['address']!
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
        gradient: LinearGradient(
          colors: [Color(0xff47BFDF), Color(0xff4A91FF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(children: [
        Positioned(
          top: 180 * pix,
          left: 16 * pix,
          right: 16 * pix,
          bottom: 50 * pix,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 40 * pix,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                filteredPlants.isEmpty
                    ? Center(
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
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredPlants.length,
                        itemBuilder: (context, index) {
                          final plant = filteredPlants[index];
                          return _buildCard(
                            name: plant['name']!,
                            address: 'Địa chỉ: ${plant['address']}',
                            status: 'Trạng thái: ${plant['status']}',
                            image: plant['image']!,
                            pix: pix,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPlantScreen(
                                    plantid: plant['id']!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                SizedBox(
                  height: 40 * pix,
                ),
              ],
            ),
          ),
        ),
        _buildHeader(size, pix),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Bottombar(type: 1),
        ),
      ]),
    ));
  }

  Widget _buildHeader(Size size, double pix) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 200 * pix,
        width: size.width,
        margin: EdgeInsets.only(bottom: 16 * pix),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 28, 214, 66),
              Color.fromARGB(255, 10, 146, 0)
            ],
            stops: [0.2, 0.8],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30 * pix),
            bottomRight: Radius.circular(30 * pix),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 10),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Abstract background patterns
            Positioned(
              top: -20 * pix,
              right: -20 * pix,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  height: 150 * pix,
                  width: 150 * pix,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60 * pix,
              left: -30 * pix,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  height: 180 * pix,
                  width: 180 * pix,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * pix),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10 * pix),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleIconButton(
                            icon: Icons.menu,
                            pix: pix,
                            onTap: () {
                              _showOptionsDialog(context, pix);
                            },
                          ),
                          _buildCircleIconButton(
                            icon: Icons.notifications_outlined,
                            pix: pix,
                            onTap: () {
                              _showNotificationsSnackBar(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * pix),
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
                                offset: const Offset(0, 5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Hero(
                            tag: 'profile-image',
                            child: ClipOval(
                              child: Image.asset(
                                AppImages.caitim,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20 * pix),
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
                                'Duong Quoc Hoang',
                                style: TextStyle(
                                  fontSize: 22 * pix,
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
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20 * pix),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      color: Colors.white,
                                      size: 16 * pix,
                                    ),
                                    SizedBox(width: 4 * pix),
                                    Text(
                                      'Chúc bạn học tốt!',
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
            ),
          ],
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
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Tuỳ chọn",
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          content: Container(
            height: 200 * pix,
            width: 300 * pix,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogOption(
                  context: context,
                  icon: Icons.add,
                  title: 'Thêm cây mới',
                  pix: pix,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPlantScreen(plantid: ''),
                      ),
                    );
                  },
                ),
                _buildDialogOption(
                  context: context,
                  icon: Icons.help,
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
                    _showLogoutConfirmation(context, pix);
                  },
                ),
              ],
            ),
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
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8 * pix),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8 * pix),
        ),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16 * pix,
          fontWeight: FontWeight.w500,
          fontFamily: 'BeVietnamPro',
        ),
      ),
      onTap: onTap,
    );
  }

  void _showHelpBottomSheet(BuildContext context, double pix) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * pix)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20 * pix),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trợ giúp',
                style: TextStyle(
                  fontSize: 20 * pix,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BeVietnamPro',
                ),
              ),
              SizedBox(height: 16 * pix),
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
              SizedBox(height: 16 * pix),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12 * pix),
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
      padding: EdgeInsets.only(bottom: 16 * pix),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10 * pix),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10 * pix),
            ),
            child: Icon(icon, color: Colors.green),
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
                  ),
                ),
                SizedBox(height: 4 * pix),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14 * pix,
                    color: Colors.black.withOpacity(0.6),
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

  void _showLogoutConfirmation(BuildContext context, double pix) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Xác nhận đăng xuất',
            style: TextStyle(
              fontSize: 18 * pix,
              fontWeight: FontWeight.bold,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(
              fontSize: 16 * pix,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement logout logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã đăng xuất'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * pix),
                ),
              ),
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 16 * pix,
                  fontFamily: 'BeVietnamPro',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Không có thông báo mới'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildCircleIconButton({
    required IconData icon,
    required double pix,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20 * pix),
      child: Container(
        height: 40 * pix,
        width: 40 * pix,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22 * pix,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String name,
    required String address,
    required String status,
    required String image,
    required double pix,
    required VoidCallback onTap,
  }) {
    // Determine status color
    Color statusColor = Colors.green;
    if (status.contains('Đang tốt')) {
      statusColor = Colors.green;
    } else if (status.contains('Cần chú ý')) {
      statusColor = Colors.orange;
    } else if (status.contains('Có vấn đề')) {
      statusColor = Colors.red;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 126 * pix,
        width: 333 * pix,
        padding: EdgeInsets.all(16 * pix),
        margin: EdgeInsets.only(bottom: 16 * pix),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'plant-image-${image}',
              child: Container(
                height: 94 * pix,
                width: 94 * pix,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12 * pix),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16 * pix),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 18 * pix,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BeVietnamPro',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16 * pix,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * pix),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14 * pix,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'BeVietnamPro',
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 8 * pix),
                  Row(
                    children: [
                      Container(
                        width: 10 * pix,
                        height: 10 * pix,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(width: 4 * pix),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 14 * pix,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'BeVietnamPro',
                          color: statusColor,
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
    );
  }
}
