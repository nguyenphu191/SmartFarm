import 'package:flutter/material.dart';
import 'package:smart_farm/res/imagesSF/AppImages.dart';
import 'package:smart_farm/view/detail_plant.dart';
import 'package:smart_farm/widget/bottom_bar.dart';
import 'package:smart_farm/widget/top_bar.dart';

class PlantSelectionScreen extends StatefulWidget {
  @override
  _PlantSelectionScreenState createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  List<Map<String, String>> plants = [
    {
      "id": "1",
      "name": "Su hào",
      "image": AppImages.suhao,
    },
    {
      "id": "2",
      "name": "Khoai tây",
      "image": AppImages.khoaitay,
    },
    {
      "id": "3",
      "name": "Súp lơ",
      "image": AppImages.supno,
    },
    {
      "id": "4",
      "name": "Su hào",
      "image": AppImages.suhao,
    },
    {
      "id": "5",
      "name": "Khoai tây",
      "image": AppImages.khoaitay,
    },
    {
      "id": "6",
      "name": "Súp lơ",
      "image": AppImages.supno,
    },
  ];
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(title: 'Chọn cây trồng', isBack: false),
          ),
          Positioned(
            top: 100 * pix,
            left: 0,
            right: 0,
            bottom: 66 * pix,
            child: SingleChildScrollView(
              child: Container(
                width: size.width,
                height: size.height - 166 * pix,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff47BFDF), Color(0xff4A91FF)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm cây trồng',
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      height: 20 * pix,
                      width: size.width,
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Danh sách cây đã trồng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * pix,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * pix),
                        child: ListView.builder(
                          itemCount: plants.length,
                          itemBuilder: (context, index) {
                            final plant = plants[index];
                            return _buildCard(
                              name: plant['name']!,
                              image: plant['image']!,
                              pix: pix,
                              onTap: () {
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPlantScreen(
                                        plantid: plant['id']!,
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 120 * pix),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80 * pix,
            left: 0,
            right: 0,
            child: Container(
              width: size.width,
              height: 50 * pix,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF5A31F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Thêm cây mới',
                  style: TextStyle(
                      fontSize: 18 * pix,
                      color: Colors.white,
                      fontFamily: 'BeVietnamPro'),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Bottombar(type: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      {required String name,
      required String image,
      required double pix,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 88 * pix,
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
            Image.asset(
              image,
              height: 60 * pix,
              width: 60 * pix,
            ),
            SizedBox(width: 20 * pix),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 18 * pix,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'BeVietnamPro',
                  color: Color(0xff165598),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
