import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/arabic_numerals_to_chinese.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:ltrc/widgets/setting/setting_divider.dart';

class SettingView extends ConsumerStatefulWidget {
  const SettingView({super.key});

  @override
  SettingViewState createState() => SettingViewState();
}

class SettingViewState extends ConsumerState<SettingView> {
  late TextEditingController nameController;
  late String account;
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();

  @override 
  void initState() {
    super.initState();
    nameController = TextEditingController();
    account = "";
  }

  @override
  void dispose(){
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    final List<DropdownMenuEntry<int>> gradeEntries = [];
    final List<DropdownMenuEntry<int>> publisherEntries = [];

    final userName = ref.watch(userNameProvider);
    int selectedGrade = ref.watch(gradeProvider);
    int selectedPublisher = ref.watch(publisherCodeProvider);
    double _currentSliderValue = 0.5;
    
    nameController.text = userName;
    gradeController.text = numeralToChinese[selectedGrade]!;
    publisherController.text = publisherCodeTable[selectedPublisher]!;
    
    for (var key in [1, 2, 3, 4, 5, 6]) {
      gradeEntries.add(
        DropdownMenuEntry<int>(
          value: key, 
          label: numeralToChinese[key]!, 
        )
      );
    }
    
    for (var key in publisherCodeTable.keys) {
      publisherEntries.add(
        DropdownMenuEntry<int>(
          value: key, 
          label: publisherCodeTable[key]!, 
        )
      );
    }

    setState(() {
      account = ref.watch(accountProvider);
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: '#1E1E1E'.toColor(),
      body: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Container(
              height: deviceHeight * 0.3673,
              width: deviceWidth,
              decoration: BoxDecoration(
                color: '#013E6D'.toColor(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
              )
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 10),
                alignment: AlignmentDirectional.topEnd,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: '#F5F5DC'.toColor(),
                    size: 40,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4.5))],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              )
            ),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.138, deviceHeight * 0.064, 0, 0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.settings,
                    color: '#F5F5DC'.toColor(),
                    size: 36
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                    child: const Text(
                      '設定',
                      style: TextStyle(
                        fontSize: 36,
                      )
                    )
                  )
                ]
              )
            ),
            Positioned(
              top: deviceHeight * 0.156,
              left: deviceWidth * 0.058,
              child: Container(
                height: deviceHeight * 0.8,
                width: deviceWidth * 0.882,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: '#F5F5DC'.toColor(),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: deviceWidth * 0.85,
                      margin: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.0513, deviceHeight * 0.032, 0, deviceHeight * 0.024),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_circle,
                            color: '#1C1B1F'.toColor(),
                            size: 40
                          ),
                          Container( width: 12 ),
                          Flexible(
                            child: Text(
                              userName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: (userName.length)<5 ? 20 : (userName.length)<12 ? 16 : 14,
                              )
                            ),
                          ),
                          Container( width: 12 ),
                          InkWell(
                            onTap: (){
                              showDialog(
                                context: context, 
                                builder: (context) => AlertDialog(
                                  backgroundColor: "#F5F5DC".toColor(),
                                  title: const Text("編輯名稱"),
                                  content: TextField(
                                    style: TextStyle( color: '#1C1B1F'.toColor(),),
                                    decoration: const InputDecoration(
                                      hintText: "請輸入你的名稱"
                                    ),
                                    controller: nameController,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        ref.read(userNameProvider.notifier).state = nameController.text;
                                        User userToUpdate = await UserProvider.getUser(inputAccount: account);
                                        userToUpdate.username = nameController.text;
                                        await UserProvider.updateUser(user: userToUpdate);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        '確認', 
                                        style: TextStyle(
                                          color: "#1C1B1F".toColor(),
                                        ),  
                                      )
                                    )
                                  ],
                                )
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.mode,
                                  color: "#999999".toColor(),
                                ),
                                Text(
                                  "編輯",
                                  style: TextStyle(
                                    color: "#999999".toColor(),
                                  ),
                                )
                              ],
                            )
                          ),
                          Container( width: 12,)
                        ]
                      ),
                    ),
                    const SettingDivider(),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: deviceHeight * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children : [
                          const Text(
                            '年級',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black
                            )
                          ),
                          DropdownMenu<int>(
                            controller: gradeController,
                            width: 120,
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            dropdownMenuEntries: gradeEntries,
                            initialSelection: selectedGrade,
                            onSelected: (int? grade) async {
                              User userToUpdate = await UserProvider.getUser(inputAccount: account);
                              userToUpdate.grade = grade!;
                              await UserProvider.updateUser(user: userToUpdate);
                              ref.read(gradeProvider.notifier).state = grade;
                            },
                          ),
                        ]
                      ),
                    ),
                    const SettingDivider(),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: deviceHeight * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children : [
                          const Text(
                            '課本版本',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black
                            )
                          ),
                          DropdownMenu<int>(
                            controller: publisherController,
                            width: 120,
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            dropdownMenuEntries: publisherEntries,
                            initialSelection: selectedPublisher,
                            onSelected: (int? publisher) async {
                              User userToUpdate = await UserProvider.getUser(inputAccount: account);
                              userToUpdate.publisher = publisherCodeTable[publisher]!;
                              await UserProvider.updateUser(user: userToUpdate);
                              ref.read(publisherCodeProvider.notifier).state = publisher!;
                            },
                          ),
                        ]
                      ),
                    ),
                    const SettingDivider(),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: deviceHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          const Text(
                            '撥放速度',
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 24,
                            )
                          ),
                          Slider(
                            value: _currentSliderValue, 
                            onChanged: (double value) {  },
                          )
                        ]
                      )
                    ),
                    const SettingDivider(),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: deviceHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          const Text(
                            '資源出處',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                            )
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pushNamed('/acknowledge'),
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: Colors.black,
                            iconSize: 22
                          )
                        ]
                      )
                    ),
                    SizedBox(
                      height: deviceHeight * 0.09,
                      width: deviceWidth * 0.882,
                    ),
                    Expanded(
                      child:TextButton(
                        onPressed: (){
                          Navigator.of(context).pushNamed('/login');
                          ref.read(accountProvider.notifier).state = "";
                          ref.read(userNameProvider.notifier).state = "";
                          ref.read(gradeProvider.notifier).state = 1;
                          ref.read(publisherCodeProvider.notifier).state = 0;
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromHeight(30),
                        ),
                        child: const Text(
                          '登出',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          )
                        ),
                      )
                    )
                  ]
                )
              )
            ),
          ]
        ),
      ),
    );
  }
}

