import 'package:flutter_shopping_list/controllers/auth_controller.dart';
import 'package:flutter_shopping_list/custom_exception.dart';
import 'package:flutter_shopping_list/models/item_model.dart';
import 'package:flutter_shopping_list/repositories/item_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final itemListControllerProvider =
    StateNotifierProvider<ItemListController, AsyncValue<List<Item>>>(
  (ref) {
    final user = ref.watch(authControllerProvider);
    return ItemListController(ref.read, user?.uid);
  },
);

class ItemListController extends StateNotifier<AsyncValue<List<Item>>> {
  final Reader _read;
  final String? _userId;

  ItemListController(this._read, this._userId) : super(AsyncValue.loading());

  Future<void> retrieveItems({bool isRefreshing = false}) async {
    if (isRefreshing) state = AsyncValue.loading();
    try {
      final items =
          await _read(itemRepositoryProvider).retrieveItems(userId: _userId!);
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } on CustomException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
