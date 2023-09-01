enum RegisterQuestionLabel {
  initial(0, ""),
  pet(1, "你最喜歡的寵物名稱"),
  city(2, "你的出生城市"),
  color(3, "你最愛的顏色"),
  fruit(4, "你最愛的水果"),
  people(5, "你的家中有幾個人")
  ;

  const RegisterQuestionLabel(this.label, this.question);
  final int label;
  final String question;
}