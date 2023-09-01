class User {
  User({
    required this.account,
    required this.password,
    this.username = "使用者"
  });
  
  final String account;
  final String password;
  final String username;


  Map<String, dynamic> toMap() {
    return {
      'account': account,
      'password': password,
      'username': username,
    };
  }

  @override
  String toString() {
    return "User{account : $account, password : $password, username : $username}";
  }
} 