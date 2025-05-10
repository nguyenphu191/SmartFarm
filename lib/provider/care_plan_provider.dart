import 'package:flutter/widgets.dart';
import 'package:smart_farm/models/care_plan_model.dart';
import 'package:smart_farm/utils/base_url.dart';

class CarePlanProvider with ChangeNotifier {
  String baseUrl = BaseUrl.baseUrl;
  bool _loading = false;
  bool get loading => _loading;
  List<CarePlanModel> _carePlanList = [];
  List<CarePlanModel> get carePlanList => _carePlanList;
}
