class User {
  User({
    required this.account,
    required this.password,
    this.username = "使用者",
    required this.safetyQuestionId1,
    required this.safetyAnswer1,
    required this.safetyQuestionId2,
    required this.safetyAnswer2,
    required this.grade,
    required this.publisher,
  });
  
  final String account;
  String password;
  String username;
  final int safetyQuestionId1;
  final String safetyAnswer1;
  final int safetyQuestionId2;
  final String safetyAnswer2;
  int grade;
  String publisher;

  Map<String, dynamic> toMap() {
    return {
      'account': account,
      'password': password,
      'username': username,
      'safetyQuestionId1': safetyQuestionId1,
      'safetyAnswer1': safetyAnswer1,
      'safetyQuestionId2': safetyQuestionId2,
      'safetyAnswer2': safetyAnswer2,
      'grade': grade,
      'publisher': publisher
    };
  }

  @override
  String toString() {
    return "User{account: $account, password: $password, username: $username, safetyQuestionId1: $safetyQuestionId1, safetyAnswer1: $safetyAnswer1, safetyQuestionId2: $safetyQuestionId2, safetyAnswer2: $safetyAnswer2, grade: $grade, publisher: $publisher}";
  }
} 