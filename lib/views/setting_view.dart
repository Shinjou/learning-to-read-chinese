import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/arabic_numerals_to_chinese.dart';
import 'package:ltrc/contants/semester_code.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

class SettingView extends ConsumerStatefulWidget {
  const SettingView({super.key});

  @override
  SettingViewState createState() => SettingViewState();
}

class SettingViewState extends ConsumerState<SettingView> {
  late TextEditingController nameController;
  late String account;
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  var currentSliderValue = 0.5;

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
    double fontSize =
        getFontSize(context, 16); // 16 is the base font size for 360dp width

    const Color colorBlack = Color.fromRGBO(0, 0, 0, 1);

    final List<DropdownMenuEntry<int>> gradeEntries = [];
    final List<DropdownMenuEntry<int>> semesterEntries = [];
    final List<DropdownMenuEntry<int>> publisherEntries = [];

    final userName = ref.watch(userNameProvider);
    int selectedGrade = ref.watch(gradeProvider);
    int selectedSemester = ref.watch(semesterCodeProvider);
    int selectedPublisher = ref.watch(publisherCodeProvider);

    nameController.text = userName;
    gradeController.text = numeralToChinese[selectedGrade]!;
    semesterController.text = semesterCodeTable[selectedSemester]!;
    publisherController.text = publisherCodeTable[selectedPublisher]!;

    currentSliderValue = ref.watch(soundSpeedProvider);

    for (var key in [1, 2, 3, 4, 5, 6]) {
      gradeEntries.add(
        DropdownMenuEntry<int>(
        value: key,
        label: numeralToChinese[key]!,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontSize: fontSize * 0.6,
              color: '#1C1B1F'.toColor(),
            ),
          ),
        ),
      ));
    }

    for (var key in semesterCodeTable.keys) {
      semesterEntries.add(DropdownMenuEntry<int>(
        value: key,
        label: semesterCodeTable[key]!,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontSize: fontSize * 0.6,
              color: '#1C1B1F'.toColor(),
            ),
          ),
        ),
      ));
    }

    for (var key in publisherCodeTable.keys) {
      publisherEntries.add(
        DropdownMenuEntry<int>(
        value: key,
        label: publisherCodeTable[key]!,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontSize: fontSize * 0.6,
              color: '#1C1B1F'.toColor(),
            ),
          ),
        ),
      ));
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
                  ))),
          SafeArea(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 10),
                  alignment: AlignmentDirectional.topEnd,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: '#F5F5DC'.toColor(),
                    size: fontSize * 1.5,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4.5))],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ))),
          Container(
              padding: EdgeInsetsDirectional.fromSTEB(fontSize * 10, fontSize * 2.0, 0, 0),
                  // deviceWidth * 0.138, deviceHeight * 0.064, 0, 0),
              child: Row(children: <Widget>[
                Icon(
                  Icons.settings,
                  color: '#F5F5DC'.toColor(),
                  size: fontSize * 1.3,
                ),
                Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                    child: Text('設定',
                        style: TextStyle(
                          fontSize: fontSize * 1.3,
                        )))
              ])),
          Positioned(
              top: fontSize * 3.5, // deviceHeight * 0.156,
              left: fontSize * 1.0, // deviceWidth * 0.058,
              child: Container(
                  height: deviceHeight * 0.82,
                  width: deviceWidth * 0.92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: '#F5F5DC'.toColor(),
                  ),
                  child: Column(children: [
                    Container(
                      height: fontSize * 1.8,
                      width: deviceWidth * 0.85,
                      margin: EdgeInsetsDirectional.fromSTEB(
                          deviceWidth * 0.0513,
                          deviceHeight * 0.032,
                          0,
                          deviceHeight * 0.024),
                      child: Row(children: [
                        Icon(
                          Icons.account_circle,
                          color: '#1C1B1F'.toColor(),
                          size: fontSize * 2.0,
                        ),
                        Container(
                          width: fontSize * 0.3,
                        ),
                        Flexible(
                          child: Text(userName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: (userName.length) < 5
                                    ? fontSize
                                    : (userName.length) < 12
                                        ? fontSize
                                        : fontSize * 0.8,
                              )),
                        ),
                        Container(width: fontSize * 0.5),
                        InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        backgroundColor: "#F5F5DC".toColor(),
                                        title: Text("編輯名稱",
                                            style: TextStyle(
                                              fontSize: fontSize * 1.0,
                                            )),
                                        content: TextField(
                                          style: TextStyle(
                                            color: '#1C1B1F'.toColor(),
                                            fontSize: fontSize * 0.8,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "請輸入你的名稱",
                                            hintStyle: TextStyle(
                                              fontSize: fontSize *
                                                  0.8, // Set your desired font size for the hint text here
                                            ),
                                          ),
                                          controller: nameController,
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                ref
                                                        .read(userNameProvider
                                                            .notifier)
                                                        .state =
                                                    nameController.text;
                                                User userToUpdate =
                                                    await UserProvider.getUser(
                                                        inputAccount: account);
                                                userToUpdate.username =
                                                    nameController.text;
                                                await UserProvider.updateUser(
                                                    user: userToUpdate);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                '確認',
                                                style: TextStyle(
                                                  color: "#1C1B1F".toColor(),
                                                  fontSize: fontSize * 0.8,
                                                ),
                                              ))
                                        ],
                                      ));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.mode,
                                  color: "#999999".toColor(),
                                  size: fontSize * 1.0,
                                ),
                                Text(
                                  "編輯",
                                  style: TextStyle(
                                    color: "#999999".toColor(),
                                    fontSize: fontSize * 1.0,
                                  ),
                                )
                              ],
                            )),
                        Container(
                          width: fontSize * 0.2,
                        )
                      ]),
                    ),
                    // const SettingDivider(),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12, vertical: deviceHeight * 0.01),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('年級',
                                style: TextStyle(
                                    fontSize: fontSize * 1.2,
                                    color: Colors.black)),
                            DropdownMenu<int>(
                              controller: gradeController,
                              width: 6.0 * fontSize,
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: fontSize,
                              ),
                              dropdownMenuEntries: gradeEntries,
                              initialSelection: selectedGrade,
                              onSelected: (int? grade) async {
                                User userToUpdate = await UserProvider.getUser(
                                    inputAccount: account);
                                userToUpdate.grade = grade!;
                                await UserProvider.updateUser(
                                    user: userToUpdate);
                                ref.read(gradeProvider.notifier).state = grade;
                                ref
                                        .read(totalWordCountProvider.notifier)
                                        .state =
                                    await UnitProvider.getTotalWordCount(
                                        inputPublisher: publisherCodeTable[
                                            selectedPublisher]!,
                                        inputGrade: grade,
                                        // inputSemester: "上"
                                        inputSemester: semesterCodeTable[
                                            selectedSemester]!);
                                ref
                                        .read(learnedWordCountProvider.notifier)
                                        .state =
                                    await UnitProvider.getLearnedWordCount(
                                        inputAccount: account,
                                        inputPublisher: publisherCodeTable[
                                            selectedPublisher]!,
                                        inputGrade: grade,
                                        // inputSemester: "上"
                                        inputSemester: semesterCodeTable[
                                            selectedSemester]!);
                              },
                            ),
                          ]),
                    ),
                    // const SettingDivider(),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12, vertical: deviceHeight * 0.01),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('學期',
                                style: TextStyle(
                                    fontSize: fontSize * 1.2,
                                    color: Colors.black)),
                            DropdownMenu<int>(
                              controller: semesterController,
                              width: 7.1 * fontSize,
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: fontSize,
                              ),
                              dropdownMenuEntries: semesterEntries,
                              initialSelection: selectedSemester,
                              onSelected: (int? semester) async {
                                User userToUpdate = await UserProvider.getUser(
                                    inputAccount: account);
                                userToUpdate.semester =
                                    semesterCodeTable[semester]!;
                                await UserProvider.updateUser(
                                    user: userToUpdate);
                                ref.read(semesterCodeProvider.notifier).state =
                                    semester!;
                                ref
                                        .read(totalWordCountProvider.notifier)
                                        .state =
                                    await UnitProvider.getTotalWordCount(
                                        inputPublisher: publisherCodeTable[
                                            selectedPublisher]!,
                                        inputGrade: selectedGrade,
                                        // inputSemester: "上"
                                        inputSemester:
                                            semesterCodeTable[semester]!);
                                ref
                                        .read(learnedWordCountProvider.notifier)
                                        .state =
                                    await UnitProvider.getLearnedWordCount(
                                        inputAccount: account,
                                        inputPublisher: publisherCodeTable[
                                            selectedPublisher]!,
                                        inputGrade: selectedGrade,
                                        // inputSemester: "上"
                                        inputSemester:
                                            semesterCodeTable[semester]!);
                              },
                            ),
                          ]),
                    ),
                    // const SettingDivider(),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12, vertical: deviceHeight * 0.01),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('課本出版社',
                                style: TextStyle(
                                    fontSize: fontSize * 1.2,
                                    color: Colors.black)),
                            DropdownMenu<int>(
                              controller: publisherController,
                              width: 7.1 * fontSize,
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: fontSize,
                              ),
                              dropdownMenuEntries: publisherEntries,
                              initialSelection: selectedPublisher,
                              onSelected: (int? publisher) async {
                                User userToUpdate = await UserProvider.getUser(
                                    inputAccount: account);
                                userToUpdate.publisher =
                                    publisherCodeTable[publisher]!;
                                await UserProvider.updateUser(
                                    user: userToUpdate);
                                ref.read(publisherCodeProvider.notifier).state =
                                    publisher!;
                                ref
                                        .read(totalWordCountProvider.notifier)
                                        .state =
                                    await UnitProvider.getTotalWordCount(
                                        inputPublisher:
                                            publisherCodeTable[publisher]!,
                                        inputGrade: selectedGrade,
                                        // inputSemester: "上"
                                        inputSemester: semesterCodeTable[
                                            selectedSemester]!);
                                ref
                                        .read(learnedWordCountProvider.notifier)
                                        .state =
                                    await UnitProvider.getLearnedWordCount(
                                        inputAccount: account,
                                        inputPublisher:
                                            publisherCodeTable[publisher]!,
                                        inputGrade: selectedGrade,
                                        // inputSemester: "上"
                                        inputSemester: semesterCodeTable[
                                            selectedSemester]!);
                              },
                            ),
                          ]),
                    ),
                    // const SettingDivider(),
                    Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 12, vertical: deviceHeight * 0.01),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text('撥放速度',
                                  style: TextStyle(
                                    color: colorBlack,
                                    fontSize: fontSize * 1.2,
                                  )),
                              SizedBox(
                                  width: 8.2 * fontSize,
                                  child: Slider(
                                    value: currentSliderValue,
                                    max: 1.0,
                                    divisions: 10,
                                    onChanged: (double value) {
                                      setState(() {
                                        currentSliderValue = value;
                                      });
                                      ref
                                          .read(soundSpeedProvider.notifier)
                                          .state = value;
                                    },
                                  ))
                            ])),
                    // const SettingDivider(),
                    Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 12, vertical: deviceHeight * 0.01),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text('授權與致謝',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fontSize * 1.2,
                                  )),
                              IconButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/acknowledge'),
                                icon: const Icon(Icons.arrow_forward_ios),
                                color: Colors.black,
                                iconSize: fontSize * 1.2,
                              )
                            ])),
                    SizedBox(
                      height: fontSize * 1.0,
                      // width: deviceWidth * 0.882,
                    ),
                    Expanded(
                        child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                        ref.read(accountProvider.notifier).state = "";
                        ref.read(userNameProvider.notifier).state = "";
                        ref.read(gradeProvider.notifier).state = 1;
                        ref.read(semesterCodeProvider.notifier).state = 0;
                        ref.read(publisherCodeProvider.notifier).state = 0;
                      },
                      style: TextButton.styleFrom(
                        fixedSize: Size.fromHeight(fontSize * 1.5),
                      ),
                      child: Text('登出',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: fontSize * 1.2,
                          )),
                    ))
                  ]))),
        ]),
      ),
    );
  }
}
