// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on _AppStore, Store {
  final _$isDarkModeAtom = Atom(name: '_AppStore.isDarkMode');

  @override
  bool get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  final _$isLoadingAtom = Atom(name: '_AppStore.isLoading');

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  final _$collegeMakerImageListAtom =
      Atom(name: '_AppStore.collegeMakerImageList');

  @override
  ObservableList<File> get collegeMakerImageList {
    _$collegeMakerImageListAtom.reportRead();
    return super.collegeMakerImageList;
  }

  @override
  set collegeMakerImageList(ObservableList<File> value) {
    _$collegeMakerImageListAtom.reportWrite(value, super.collegeMakerImageList,
        () {
      super.collegeMakerImageList = value;
    });
  }

  final _$setDarkModeAsyncAction = AsyncAction('_AppStore.setDarkMode');

  @override
  Future<void> setDarkMode(bool aIsDarkMode) {
    return _$setDarkModeAsyncAction.run(() => super.setDarkMode(aIsDarkMode));
  }

  final _$_AppStoreActionController = ActionController(name: '_AppStore');

  @override
  void addCollegeImages(File image) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.addCollegeImages');
    try {
      return super.addCollegeImages(image);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearCollegeImageList() {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.clearCollegeImageList');
    try {
      return super.clearCollegeImageList();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLoading');
    try {
      return super.setLoading(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isDarkMode: ${isDarkMode},
isLoading: ${isLoading},
collegeMakerImageList: ${collegeMakerImageList}
    ''';
  }
}
