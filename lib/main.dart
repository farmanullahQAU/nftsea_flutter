import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nft_sea/home/view.dart';
import 'package:nft_sea/home_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeView(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("NFT sea"),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (controller.imageFile != null)
              Container(
                height: 50,
                width: Get.width,
                child: Text(controller.imageFile!.path),
              ),
            FloatingActionButton(
              onPressed: () {
                controller.uploadToPinata();
              },
              tooltip: 'iamge',
              child: const Icon(Icons.upload),
            ),
            FloatingActionButton(
              onPressed: () {
                controller.getImage();
              },
              tooltip: 'iamge',
              child: const Icon(Icons.image),
            ),
          ],
        ),
        body: Column(
          children: [
            ...controller.nfts
                .map((e) => Column(
                      children: [
                        FutureBuilder(
                            future: controller.getMetadataFromIPFS(e.uri),
                            builder: ((context, snapshot) => Column(
                                  children: [
                                    Image.network(
                                      "https://ipfs.io/ipfs/${snapshot.data?["imageCID"] ?? ""}",
                                      width: context.width * 0.3,
                                      height: context.width * 0.2,
                                    ),
                                    Text(snapshot.data?["name"] ?? ""),
                                    Text(controller
                                        .convertWeiToEther(
                                            snapshot.data!["price"])
                                        .toString())
                                  ],
                                )))
                      ],
                    ))
                .toList(),
          ],
        ),
      );
    });
  }
}
