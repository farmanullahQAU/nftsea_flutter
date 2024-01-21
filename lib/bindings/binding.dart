import 'package:get/get.dart';
import 'package:nft_sea/home/controller.dart';
import 'package:nft_sea/services/walletconnect.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletServices>(() => WalletServices());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
