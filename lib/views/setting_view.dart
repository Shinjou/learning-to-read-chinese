// setting_view.dart is a stateful widget that displays the settings page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/arabic_numerals_to_chinese.dart';
import 'package:ltrc/contants/semester_code.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
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



  late double fontSize;
  late double deviceHeight;
  late double deviceWidth;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    account = "";
  }

  @override
  void dispose() {
    nameController.dispose();
    gradeController.dispose();
    semesterController.dispose();
    publisherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.read(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    deviceHeight = screenInfo.screenHeight;
    deviceWidth = screenInfo.screenWidth;
    debugPrint('setting_view: H: $deviceHeight, W: $deviceWidth, F: $fontSize');

    final List<DropdownMenuEntry<int>> gradeEntries = [];
    final List<DropdownMenuEntry<int>> semesterEntries = [];
    final List<DropdownMenuEntry<int>> publisherEntries = [];

    account = ref.watch(accountProvider);
    int selectedGrade = ref.watch(gradeProvider);
    int selectedSemester = ref.watch(semesterCodeProvider);
    int selectedPublisher = ref.watch(publisherCodeProvider);

    gradeController.text = numeralToChinese[selectedGrade]!;
    semesterController.text = semesterCodeTable[selectedSemester]!;
    publisherController.text = publisherCodeTable[selectedPublisher]!;

    currentSliderValue = ref.watch(soundSpeedProvider);

    // Populate dropdown entries
    _populateDropdownEntries(gradeEntries, semesterEntries, publisherEntries);

    return SafeArea( // Wrap the content inside a SafeArea
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: veryDarkGray,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _buildBackgroundContainer(),
              Positioned(
                top: fontSize * 1.0,
                left: fontSize * 1.0,
                child: _buildContentContainer(
                  gradeEntries,
                  semesterEntries,
                  publisherEntries,
                  selectedGrade,
                  selectedSemester,
                  selectedPublisher,
                ),
              ),
              // Close button with tap detection
              Positioned(
                top: fontSize,  // Ensure the close button is below the notch
                right: fontSize,
                child: GestureDetector(
                  onTap: () {
                    debugPrint('Close button tapped');
                    _handleCloseButton();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),  // Red border for visibility
                    ),
                    child: const Icon(Icons.close, color: Colors.black, size: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _populateDropdownEntries(
      List<DropdownMenuEntry<int>> gradeEntries,
      List<DropdownMenuEntry<int>> semesterEntries,
      List<DropdownMenuEntry<int>> publisherEntries,
    ) {
      for (var key in [1, 2, 3, 4, 5, 6]) {
        gradeEntries.add(DropdownMenuEntry<int>(
          value: key,
          label: numeralToChinese[key]!,
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(fontSize: fontSize * 0.6, color: veryDarkGrayishBlue),
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
              TextStyle(fontSize: fontSize * 0.6, color: veryDarkGrayishBlue),
            ),
          ),
        ));
      }

      for (var key in publisherCodeTable.keys) {
        publisherEntries.add(DropdownMenuEntry<int>(
          value: key,
          label: publisherCodeTable[key]!,
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(fontSize: fontSize * 0.6, color: veryDarkGrayishBlue),
            ),
          ),
        ));
      }
    }

  Widget _buildBackgroundContainer() {
    return Container(
      height: deviceHeight,
      width: deviceWidth,
      decoration: const BoxDecoration(
        color: deepBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
    );
  }

  Widget _buildContentContainer(
    List<DropdownMenuEntry<int>> gradeEntries,
    List<DropdownMenuEntry<int>> semesterEntries,
    List<DropdownMenuEntry<int>> publisherEntries,
    int selectedGrade,
    int selectedSemester,
    int selectedPublisher,
  ) {
    return Container(
      height: deviceHeight * 0.95,
      width: deviceWidth * 0.92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: beige,
      ),
      child: Column(
        children: [
          _buildTopBar(),
          _buildAccountSection(),
          _buildDropdownSection('年級', gradeController, gradeEntries, selectedGrade, _handleGradeChange),
          _buildDropdownSection('學期', semesterController, semesterEntries, selectedSemester, _handleSemesterChange),
          _buildDropdownSection('課本出版社', publisherController, publisherEntries, selectedPublisher, _handlePublisherChange),
          _buildSlider(),
          _buildAcknowledgmentSection(),
          _buildSwVersion(),          
          SizedBox(height: fontSize * 0.2),
          _buildAccountActions(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: fontSize * 0.5, horizontal: fontSize * 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(children: <Widget>[
            Icon(Icons.settings, color: Colors.black, size: fontSize * 1.2),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(fontSize, 0, 0, 0),
              child: Text('設定', style: TextStyle(fontSize: fontSize * 1.2, color: Colors.black)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: fontSize * 0.5, vertical: deviceHeight * 0.01),
      child: Container(
        height: fontSize * 1.8,
        width: deviceWidth * 0.85,
        margin: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.0513, deviceHeight * 0.032, 0, deviceHeight * 0.024),
        child: Row(
          children: [
            Icon(Icons.account_circle, color: veryDarkGrayishBlue, size: fontSize * 2.0),
            SizedBox(width: fontSize * 0.3),
            Flexible(
              child: Text(
                account,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: (account.length) < 5 ? fontSize : (account.length) < 12 ? fontSize : fontSize * 0.8,
                ),
              ),
            ),
            SizedBox(width: fontSize * 0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection(
    String label,
    TextEditingController controller,
    List<DropdownMenuEntry<int>> entries,
    int selectedValue,
    Function(int?) onChanged,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: fontSize * 0.5, vertical: deviceHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize * 1.0, color: Colors.black)),
          DropdownMenu<int>(
            controller: controller,
            width: label == '年級' ? 6.0 * fontSize : label == '學期' ? 7.1 * fontSize : 8.2 * fontSize,
            textStyle: TextStyle(color: Colors.black, fontSize: fontSize),
            dropdownMenuEntries: entries,
            initialSelection: selectedValue,
            onSelected: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: fontSize * 0.5, vertical: deviceHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text('撥放速度', style: TextStyle(color: Colors.black, fontSize: fontSize * 1.0)),
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
                ref.read(soundSpeedProvider.notifier).state = value;
                debugPrint('Slider changed to value: $currentSliderValue');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgmentSection() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: fontSize * 0.5, vertical: deviceHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text('授權與致謝', style: TextStyle(color: Colors.black, fontSize: fontSize * 1.0)),
          IconButton(
            onPressed: () {
              if (context.mounted) {
                navigateWithProvider(context, '/acknowledge', ref);
              }
            },
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.black,
            iconSize: fontSize * 1.2,
          ),
        ],
      ),
    );
  }

  Widget _buildSwVersion() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: fontSize * 0.5, vertical: deviceHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text('版本資訊', style: TextStyle(color: Colors.black, fontSize: fontSize * 1.0)),
          IconButton(
            onPressed: () {
              if (context.mounted) {
                navigateWithProvider(context, '/swversion', ref);
              }
            },
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.black,
            iconSize: fontSize * 1.2,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.5), // Reduce the padding around the buttons
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (account != 'tester' && account != 'testerbpmf')
            Flexible(
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: fontSize * 0.5), // Reduce the vertical padding
                  backgroundColor: Colors.grey.shade200, // Add a background color for visibility
                ),
                child: Text(
                  '刪除帳號',
                  style: TextStyle(color: Colors.black, fontSize: fontSize * 0.9), // Adjust font size
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
            ),
          SizedBox(width: fontSize * 0.5), // Add some spacing between buttons

          Flexible(
            child: TextButton(
              onPressed: _handleLogout,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: fontSize * 0.5),
                backgroundColor: Colors.grey.shade200,
              ),
              child: Text(
                '登出',
                style: TextStyle(color: Colors.black, fontSize: fontSize * 0.9),
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ),
          SizedBox(width: fontSize * 0.5), // Add some spacing between buttons

          Flexible(
            child: TextButton(
              onPressed: _handleCloseButton,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: fontSize * 0.5),
                backgroundColor: Colors.grey.shade200,
              ),
              child: Text(
                '儲存',
                style: TextStyle(color: Colors.black, fontSize: fontSize * 0.9),
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _handleCloseButton() {
    debugPrint('_handleCloseButton called');
    
    // Capture the current route before attempting to pop
    debugPrint('Current route before pop: ${ModalRoute.of(context)?.settings.name}');
    
    if (context.mounted) {
      if (Navigator.of(context).canPop()) {
        debugPrint('Navigator can pop. Popping from the stack.');
        
        Navigator.of(context).pop();  // Attempt to pop the page
      } else {
        debugPrint('Navigator cannot pop. Navigating to main page.');
        
        navigateWithProvider(context, '/mainPage', ref);  // Fallback navigation
      }
    }   
    // Log the route after pop without delay
    debugPrint('Current route after pop: ${ModalRoute.of(context)?.settings.name}');
  }

  void _handleGradeChange(int? grade) async {
    if (grade == null) return;
    try {
      User userToUpdate = await UserProvider().getUser(inputAccount: account);
      userToUpdate.grade = grade;
      await UserProvider().updateUser(user: userToUpdate);
      if (!context.mounted) return;
      ref.read(gradeProvider.notifier).state = grade;
      _updateWordCounts(grade: grade);
    } catch (e) {
      debugPrint('Error updating grade: $e');
    }
  }

  void _handleSemesterChange(int? semester) async {
    if (semester == null) return;
    try {
      User userToUpdate = await UserProvider().getUser(inputAccount: account);
      userToUpdate.semester = semesterCodeTable[semester]!;
      await UserProvider().updateUser(user: userToUpdate);
      if (!context.mounted) return;
      ref.read(semesterCodeProvider.notifier).state = semester;
      _updateWordCounts(semester: semester);
    } catch (e) {
      debugPrint('Error updating semester: $e');
    }
  }

  void _handlePublisherChange(int? publisher) async {
    if (publisher == null) return;
    try {
      User userToUpdate = await UserProvider().getUser(inputAccount: account);
      userToUpdate.publisher = publisherCodeTable[publisher]!;
      await UserProvider().updateUser(user: userToUpdate);
      if (!context.mounted) return;
      ref.read(publisherCodeProvider.notifier).state = publisher;
      _updateWordCounts(publisher: publisher);
    } catch (e) {
      debugPrint('Error updating publisher: $e');
    }
  }

  void _updateWordCounts({int? grade, int? semester, int? publisher}) async {
    try {
      int selectedGrade = grade ?? ref.read(gradeProvider);
      int selectedSemester = semester ?? ref.read(semesterCodeProvider);
      int selectedPublisher = publisher ?? ref.read(publisherCodeProvider);

      ref.read(totalWordCountProvider.notifier).state = await UnitProvider().getTotalWordCount(
        inputPublisher: publisherCodeTable[selectedPublisher]!,
        inputGrade: selectedGrade,
        inputSemester: semesterCodeTable[selectedSemester]!,
      );

      ref.read(learnedWordCountProvider.notifier).state = await UnitProvider().getLearnedWordCount(
        inputAccount: account,
        inputPublisher: publisherCodeTable[selectedPublisher]!,
        inputGrade: selectedGrade,
        inputSemester: semesterCodeTable[selectedSemester]!,
      );
    } catch (e) {
      debugPrint('Error updating word counts: $e');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("刪除帳號"),
          content: Text(
            "您確定要刪除您的帳號 $account 嗎？",
            style: TextStyle(color: Colors.black, fontSize: fontSize * 1.0),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消', style: TextStyle(color: Colors.black, fontSize: fontSize * 1.0)),
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              child: Text('確定', style: TextStyle(color: Colors.black, fontSize: fontSize * 1.0)),
              onPressed: () async {
                try {
                  await UserProvider().deleteUser(inputAccount: account);
                  if (!context.mounted) return;
                  navigateWithProvider(context, '/login', ref);
                  debugPrint('Deleted account $account');
                } catch (e) {
                  debugPrint('Error deleting account: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    ref.read(accountProvider.notifier).state = "";
    ref.read(userNameProvider.notifier).state = "";
    ref.read(gradeProvider.notifier).state = 1;
    ref.read(semesterCodeProvider.notifier).state = 0;
    ref.read(publisherCodeProvider.notifier).state = 0;
    if (context.mounted) {
      navigateWithProvider(context, '/login', ref);
    }
  }

}

