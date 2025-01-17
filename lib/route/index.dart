import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:englister/amplifyconfiguration.dart';
import 'package:englister/api/rest/UserApi.dart';
import 'package:englister/components/drawer/MyDrawer.dart';
import 'package:englister/components/navigation/MyBottomNavigationBar.dart';
import 'package:englister/components/signin/LoginButton.dart';
import 'package:englister/models/auth/AuthService.dart';
import 'package:englister/models/localstorage/LocalStorageHelper.dart';
import 'package:englister/models/riverpod/PhraseRiverpod.dart';

import 'package:englister/models/riverpod/UserRiverpod.dart';
import 'package:englister/models/subscriptions/listenToPurchaseUpdated.dart';
import 'package:englister/pages/diary.dart';
import 'package:englister/pages/home.dart';
import 'package:englister/pages/phrase.dart';
import 'package:englister/pages/record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/riverpod/StudyRiverpod.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  ConsumerState<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> {
  //TODO: ここで管理したくない・・
  int _selectedIndex = 0;
  late StreamSubscription<dynamic> _subscription;

  Future<void> _configureAmplify() async {
    if (!Amplify.isConfigured) {
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugin(AmplifyAuthCognito());

      // call Amplify.configure to use the initialized categories in your app
      //TODO: 手動でSignInRedirectURIをenglister://に修正してる。まじ！？
      // WARN: pushしたらWebサービスのログイン障害に繋がる危険な状態
      await Amplify.configure(amplifyconfig);
    }

    //ここでログイン状況を確認したい
    var userNotifier = ref.read(userProvider.notifier);

    try {
      userNotifier.set(await AuthService.getCurrentUserAttribute());
    } catch (e) {
      print(e);
    }

    await LocalStorageHelper.initializeUserId();
    await UserApi.signin();
  }

  @override
  void initState() {
    super.initState();
    _subscribePurchaseUpdate();
    _configureAmplify();
  }

  void _subscribePurchaseUpdate() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // The store cannot be reached or accessed. Update the UI accordingly.
      return;
    }
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
      debugPrint("payment error: $error");
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    RecordPage(),
    PhrasePage(),
    DiaryPage(),
  ];

  FloatingActionButtonLocation? getFloatingActionButtonLocation(
      int selectedIndex, List phrases) {
    //フレーズ画面
    if (_selectedIndex == 2 && phrases.isNotEmpty) {
      return FloatingActionButtonLocation.centerDocked;
    }
    //日記画面
    if (_selectedIndex == 3) {
      return FloatingActionButtonLocation.endFloat;
    }
    return null;
  }

  Widget? getFloatingActionButton(int selectedIndex, List phrases) {
    //フレーズ画面
    if (_selectedIndex == 2 && phrases.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/phrase/study');
          },
          label: const Text('フラッシュカードで覚える'),
          icon: const Icon(Icons.school),
        ),
      );
    }
    //日記を書く画面
    if (_selectedIndex == 3) {
      return FloatingActionButton(
        onPressed: () {
          //初期化
          var studyState = ref.watch(studyProvider);
          var studyNotifier = ref.watch(studyProvider.notifier);
          studyNotifier.set(studyState.copyWith(
              english: "", japanese: "", translation: "", needRetry: false));

          Navigator.pushNamed(context, '/diary/write');
        },
        child: const Icon(Icons.mode_edit),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var phrases = ref.watch(phrasesProvider);

    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        // titleTextStyle:
        //     const TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
        actions: const [
          Padding(padding: EdgeInsets.all(10), child: LoginButton())
        ],
      ),
      drawer: MyDrawer(),
      bottomNavigationBar: MyBottomNavigationBar(_selectedIndex, _onItemTapped),
      body: _widgetOptions.elementAt(_selectedIndex),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation:
          getFloatingActionButtonLocation(_selectedIndex, phrases),
      floatingActionButton: getFloatingActionButton(_selectedIndex, phrases),
    );
    return scaffold;
  }
}
