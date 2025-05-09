import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/provider/season_provider.dart';
import 'package:smart_farm/view/detail_season_screen.dart';
import 'package:smart_farm/widget/top_bar.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class SeasonsScreen extends StatefulWidget {
  const SeasonsScreen({super.key});

  @override
  State<SeasonsScreen> createState() => _SeasonsScreenState();
}

class _SeasonsScreenState extends State<SeasonsScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String? dateErrorText;

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        // Reset date error text
        dateErrorText = null;

        // If endDate exists and is before the new startDate, reset endDate
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu trước')),
      );
      return;
    }

    DateTime initialDate;
    if (endDate != null) {
      initialDate = endDate!;
    } else {
      DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
      initialDate = startDate!.add(const Duration(days: 30)).isAfter(tomorrow)
          ? startDate!.add(const Duration(days: 30))
          : tomorrow;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate!, // Cannot select a date before startDate
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;

        validateDateSelection();
      });
    }
  }

  void validateDateSelection() {
    if (startDate != null && endDate != null) {
      if (startDate!.isAfter(endDate!)) {
        dateErrorText = 'Ngày bắt đầu không thể sau ngày kết thúc';
        return;
      }

      if (endDate!.isBefore(DateTime.now())) {
        dateErrorText = 'Ngày kết thúc phải lớn hơn ngày hiện tại';
        return;
      }

      // If all validations pass
      dateErrorText = null;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _addSeason() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên mùa vụ')),
      );
      return;
    }

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn đầy đủ ngày bắt đầu và kết thúc')),
      );
      return;
    }

    if (startDate!.isAfter(endDate!)) {
      setState(() {
        dateErrorText = 'Ngày bắt đầu không thể sau ngày kết thúc';
      });
      return;
    }

    if (endDate!.isBefore(DateTime.now())) {
      setState(() {
        dateErrorText = 'Ngày kết thúc phải lớn hơn ngày hiện tại';
      });
      return;
    }
    final seasonProvider = Provider.of<SeasonProvider>(context, listen: false);
    bool success = await seasonProvider.addSeason(
        nameController.text, startDate!, endDate!);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm mùa vụ thành công')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm mùa vụ thất bại')),
      );
    }
  }

  Future<void> _deleteSeason(String id) async {
    final seasonProvider = Provider.of<SeasonProvider>(context, listen: false);
    bool success = await seasonProvider.deleteSeason(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa mùa vụ thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa mùa vụ thất bại')),
      );
    }
  }

  void _showAddSeasonDialog() {
    nameController.clear();
    startDate = null;
    endDate = null;
    dateErrorText = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        final pix = size.width / 375;
        return Consumer<SeasonProvider>(
            builder: (context, seasonProvider, child) {
          if (seasonProvider.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm mùa vụ mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Tên mùa vụ'),
                    ),
                    SizedBox(height: 16 * pix),
                    ListTile(
                      title: Text(
                        startDate == null
                            ? 'Chọn ngày bắt đầu'
                            : 'Ngày bắt đầu: ${formatDate(startDate!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                            // If endDate exists and is before the new startDate, reset endDate
                            if (endDate != null && endDate!.isBefore(picked)) {
                              endDate = null;
                            }
                            dateErrorText = null;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(
                        endDate == null
                            ? 'Chọn ngày kết thúc'
                            : 'Ngày kết thúc: ${formatDate(endDate!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Vui lòng chọn ngày bắt đầu trước')),
                          );
                          return;
                        }

                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ??
                              startDate!.add(const Duration(days: 30)),
                          firstDate:
                              startDate!, // Cannot select a date before startDate
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setState(() {
                            endDate = picked;

                            if (picked.isBefore(DateTime.now())) {
                              dateErrorText =
                                  'Ngày kết thúc phải lớn hơn ngày hiện tại';
                            } else {
                              dateErrorText = null;
                            }
                          });
                        }
                      },
                    ),
                    if (dateErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dateErrorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 16 * pix),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                SizedBox(width: 8 * pix),
                ElevatedButton(
                  onPressed: () {
                    _addSeason();
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          });
        });
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSeasonDialog,
        backgroundColor: const Color(0xff47BFDF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0 * pix,
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
          Positioned(top: 0, left: 0, right: 0, child: TopBar(title: 'Mùa vụ')),
          Consumer<SeasonProvider>(
            builder: (context, seasonProvider, child) {
              if (seasonProvider.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (seasonProvider.seasons.isEmpty) {
                return const Center(
                  child: Text('Chưa có mùa vụ nào'),
                );
              }
              final seasons = seasonProvider.seasons;
              return Positioned(
                top: 80 * pix,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(left: 20 * pix, right: 20 * pix),
                  child: Column(
                    children: [
                      Container(
                        height: 50 * pix,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10 * pix),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 20 * pix, right: 20 * pix),
                                child: TextField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Tìm kiếm',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.search, size: 24 * pix),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: seasons.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'Chưa có mùa vụ nào',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Nhấn nút + để thêm mùa vụ mới',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: seasons.length,
                                itemBuilder: (context, index) {
                                  final season = seasons[index];
                                  if (searchController.text.isNotEmpty &&
                                      !season.name.toLowerCase().contains(
                                          searchController.text
                                              .toLowerCase())) {
                                    return Container();
                                  }
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailSeasonScreen(
                                              season: season,
                                            ),
                                          ));
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(bottom: 10 * pix),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(12),
                                        title: Text(
                                          season.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 8),
                                            Text(
                                              'Bắt đầu: ${season.startDate != null ? formatDate(season.startDate!) : 'Chưa xác định'}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Kết thúc: ${season.endDate != null ? formatDate(season.endDate!) : 'Chưa xác định'}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: season.isActive
                                                    ? Colors.green
                                                        .withOpacity(0.2)
                                                    : Colors.red
                                                        .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                season.isActive
                                                    ? 'Đang hoạt động'
                                                    : 'Đã kết thúc',
                                                style: TextStyle(
                                                  color: season.isActive
                                                      ? Colors.green[800]
                                                      : Colors.red[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteSeason(season.id),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
