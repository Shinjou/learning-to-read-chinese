enum RegisterQuestionLabel {
  initial(0, ""),
  pet(1, "你最喜歡的寵物名稱"),
  name(2, "你外婆的名字"),
  color(3, "你最愛的顏色"),
  fruit(4, "你最愛的水果"),
  people(5, "你的家中有幾個人"),
  telephone(6, "家中電話號碼")
  ;

  const RegisterQuestionLabel(this.value, this.question);
  final int value;
  final String question;
}

List<String> registerQuestions = RegisterQuestionLabel.values.map((e) => e.question).toList();