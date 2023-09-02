class WordStatus {
  WordStatus({
    required this.id,
    required this.userAccount,
    required this.word,
    required this.learned,
    required this.liked,
  });
  
  final int id;
  final String userAccount;
  final String word;
  final bool learned;
  final bool liked;

  Map<String, dynamic> toMap() {
    return {
      'userAccount': userAccount,
      'word': word,
      'learned': learned,
      'liked': liked,
    };
  }

  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'userAccount': userAccount,
      'word': word,
      'learned': learned,
      'liked': liked,
    };
  }

  @override
  String toString() {
    return "WordStatus{id : $id, userAccount : $userAccount, word : $word, learned : $learned, liked: $liked}";
  }
} 