// import 'package:flutter/material.dart';
// import 'package:smart_farm/res/imagesSF/AppImages.dart';
// import 'package:smart_farm/view/detail_plant.dart';
// import 'package:smart_farm/widget/bottom_bar.dart';
// import 'package:smart_farm/widget/top_bar.dart';
// import 'package:smart_farm/theme/app_colors.dart';

// class PlantSelectionScreen extends StatefulWidget {
//   @override
//   _PlantSelectionScreenState createState() => _PlantSelectionScreenState();
// }

// class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
//   List<Map<String, String>> plants = [
//     {
//       "id": "1",
//       "name": "Su hào",
//       "image": AppImages.suhao,
//     },
//     {
//       "id": "2",
//       "name": "Khoai tây",
//       "image": AppImages.khoaitay,
//     },
//     {
//       "id": "3",
//       "name": "Súp lơ",
//       "image": AppImages.supno,
//     },
//     {
//       "id": "4",
//       "name": "Su hào",
//       "image": AppImages.suhao,
//     },
//     {
//       "id": "5",
//       "name": "Khoai tây",
//       "image": AppImages.khoaitay,
//     },
//     {
//       "id": "6",
//       "name": "Súp lơ",
//       "image": AppImages.supno,
//     },
//   ];

//   TextEditingController searchController = TextEditingController();

//   List<Map<String, String>> get filteredPlants {
//     if (searchController.text.isEmpty) {
//       return plants;
//     }

//     return plants
//         .where((plant) => plant['name']!
//             .toLowerCase()
//             .contains(searchController.text.toLowerCase()))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final pix = size.width / 375;

//     return Scaffold(
//       backgroundColor: AppColors.backgroundWhite,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: TopBar(title: 'Chọn cây trồng', isBack: false),
//           ),
//           Positioned(
//             top: 100 * pix,
//             left: 0,
//             right: 0,
//             bottom: 66 * pix,
//             child: Container(
//               width: size.width,
//               height: size.height - 166 * pix,
//               decoration: BoxDecoration(
//                 gradient: AppColors.backgroundGradient,
//               ),
//               child: Column(
//                 children: [
//                   // Search Bar
//                   Padding(
//                     padding: EdgeInsets.all(16 * pix),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16 * pix),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: TextField(
//                         controller: searchController,
//                         style: TextStyle(
//                           color: AppColors.textDark,
//                           fontSize: 16 * pix,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Tìm kiếm cây trồng',
//                           hintStyle: TextStyle(color: AppColors.textGrey),
//                           prefixIcon: Icon(
//                             Icons.search,
//                             color: AppColors.textGrey,
//                           ),
//                           suffixIcon: searchController.text.isNotEmpty
//                               ? IconButton(
//                                   icon: Icon(
//                                     Icons.clear,
//                                     color: AppColors.textGrey,
//                                   ),
//                                   onPressed: () {
//                                     searchController.clear();
//                                     setState(() {});
//                                   },
//                                 )
//                               : null,
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 16 * pix,
//                             vertical: 14 * pix,
//                           ),
//                         ),
//                         onChanged: (value) {
//                           setState(() {});
//                         },
//                       ),
//                     ),
//                   ),

//                   // Section Header
//                   Container(
//                     height: 30 * pix,
//                     width: size.width,
//                     padding: EdgeInsets.symmetric(horizontal: 16 * pix),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.eco,
//                           color: Colors.white,
//                           size: 20 * pix,
//                         ),
//                         SizedBox(width: 8 * pix),
//                         Text(
//                           'Danh sách cây đã trồng',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18 * pix,
//                             color: Colors.white,
//                             fontFamily: 'BeVietnamPro',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 16 * pix),

//                   // Plants List
//                   Expanded(
//                     child: filteredPlants.isEmpty
//                         ? _buildEmptyState(pix)
//                         : ListView.builder(
//                             padding: EdgeInsets.symmetric(horizontal: 16 * pix),
//                             itemCount: filteredPlants.length,
//                             itemBuilder: (context, index) {
//                               final plant = filteredPlants[index];
//                               return _buildPlantCard(
//                                 name: plant['name']!,
//                                 image: plant['image']!,
//                                 pix: pix,
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => DetailPlantScreen(
//                                         plantid: plant['id']!,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Add New Plant Button
//           Positioned(
//             bottom: 80 * pix,
//             left: 0,
//             right: 0,
//             child: Container(
//               width: size.width,
//               height: 50 * pix,
//               padding: EdgeInsets.symmetric(horizontal: 16 * pix),
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => DetailPlantScreen(plantid: ''),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.accentOrange,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16 * pix),
//                   ),
//                   elevation: 4,
//                   shadowColor: AppColors.accentOrange.withOpacity(0.4),
//                 ),
//                 icon: Icon(
//                   Icons.add_circle_outline,
//                   color: Colors.white,
//                   size: 24 * pix,
//                 ),
//                 label: Text(
//                   'Thêm cây mới',
//                   style: TextStyle(
//                     fontSize: 18 * pix,
//                     color: Colors.white,
//                     fontFamily: 'BeVietnamPro',
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Bottombar(type: 3),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(double pix) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 70 * pix,
//             color: Colors.white.withOpacity(0.7),
//           ),
//           SizedBox(height: 16 * pix),
//           Text(
//             'Không tìm thấy cây trồng nào',
//             style: TextStyle(
//               fontSize: 18 * pix,
//               color: Colors.white,
//               fontFamily: 'BeVietnamPro',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlantCard({
//     required String name,
//     required String image,
//     required double pix,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16 * pix),
//       child: Container(
//         margin: EdgeInsets.only(bottom: 16 * pix),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16 * pix),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               offset: Offset(0, 4),
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(16 * pix),
//           child: Row(
//             children: [
//               Container(
//                 height: 60 * pix,
//                 width: 60 * pix,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12 * pix),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       offset: Offset(0, 2),
//                       blurRadius: 6,
//                     ),
//                   ],
//                 ),
//                 clipBehavior: Clip.hardEdge,
//                 child: Image.asset(
//                   image,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               SizedBox(width: 16 * pix),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyle(
//                         fontSize: 18 * pix,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'BeVietnamPro',
//                         color: AppColors.textDark,
//                       ),
//                     ),
//                     SizedBox(height: 4 * pix),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 10 * pix,
//                         vertical: 4 * pix,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryGreen.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12 * pix),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 8 * pix,
//                             height: 8 * pix,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColors.primaryGreen,
//                             ),
//                           ),
//                           SizedBox(width: 6 * pix),
//                           Text(
//                             'Đang phát triển',
//                             style: TextStyle(
//                               fontSize: 12 * pix,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: 'BeVietnamPro',
//                               color: AppColors.primaryGreen,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 size: 18 * pix,
//                 color: AppColors.textGrey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
