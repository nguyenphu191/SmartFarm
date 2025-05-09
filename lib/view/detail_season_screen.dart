import 'package:flutter/material.dart';
import 'package:smart_farm/models/season_model.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'package:intl/intl.dart';

class DetailSeasonScreen extends StatefulWidget {
  final SeasonModel season;

  const DetailSeasonScreen({Key? key, required this.season}) : super(key: key);

  @override
  State<DetailSeasonScreen> createState() => _DetailSeasonScreenState();
}

class _DetailSeasonScreenState extends State<DetailSeasonScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
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
                    _buildStatsOverview(pix),
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

  Widget _buildStatsOverview(double pix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan',
          style: TextStyle(
            fontSize: 18 * pix,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16 * pix),
      ],
    );
  }
}
