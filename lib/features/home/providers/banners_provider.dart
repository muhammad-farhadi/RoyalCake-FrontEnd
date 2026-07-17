import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart'; // آدرس کلاینت دیو خودت
import '../data/models/banner_model.dart'; // آدرسی که مدل را در آن ساختی

final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/banners');

  final List data = response.data;
  return data.map((e) => BannerModel.fromJson(e)).toList();
});
