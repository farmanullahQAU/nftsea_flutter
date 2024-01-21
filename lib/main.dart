import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nft_sea/bindings/binding.dart';
import 'package:nft_sea/home/view.dart';
import 'package:nft_sea/routes/app_pages.dart';
import 'package:nft_sea/services/walletconnect.dart';
import 'package:nft_sea/style/theme.dart';

// 1

Future<void> initServices() async {
  await Get.put(() => WalletServices());
  print('Wallet initialized...');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const NFTSea());
}

class NFTSea extends StatelessWidget {
  const NFTSea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NFT Sea',
      theme: AppTheme().lightTheme,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme().darkTheme,
      initialBinding: AppBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
