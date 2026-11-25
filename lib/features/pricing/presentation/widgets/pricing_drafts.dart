import 'package:flutter/material.dart';

typedef PricingDraftKey = ({String itemId, String subItemId, String field});

class PricingDrafts extends ChangeNotifier {
  final _changes =
      <PricingDraftKey, ({Object value, Future<void> Function()? save})>{};
  bool _saving = false;

  bool get isSaving => _saving;
  bool get hasChanges => _changes.isNotEmpty;

  T? value<T>(PricingDraftKey key) {
    final value = _changes[key]?.value;
    return value is T ? value : null;
  }

  Iterable<T> valuesFor<T>(String itemId, String subItemId) => _changes.entries
      .where(
        (entry) =>
            entry.key.itemId == itemId && entry.key.subItemId == subItemId,
      )
      .map((entry) => entry.value.value)
      .whereType<T>();

  void stage(PricingDraftKey key, Object value, Future<void> Function()? save) {
    _changes[key] = (value: value, save: save);
    notifyListeners();
  }

  void remove(PricingDraftKey key) {
    if (_changes.remove(key) != null) notifyListeners();
  }

  void removeFor(String itemId, [String? subItemId]) {
    _changes.removeWhere(
      (key, _) =>
          key.itemId == itemId &&
          (subItemId == null || key.subItemId == subItemId),
    );
    notifyListeners();
  }

  Future<String?> save(Future<void> Function() refresh) async {
    if (_saving || !hasChanges) return null;
    if (_changes.values.any((change) => change.save == null)) {
      return 'راجع بيانات العناصر ونسبة الربح قبل الحفظ.';
    }

    _saving = true;
    notifyListeners();
    var savedAny = false;
    String? error;
    try {
      for (final entry in _changes.entries.toList()) {
        try {
          await entry.value.save!();
          _changes.remove(entry.key);
          savedAny = true;
        } catch (_) {
          error = 'تعذّر حفظ بعض التعديلات. يمكنك إعادة المحاولة.';
        }
      }
      if (savedAny) await refresh();
      return error;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
