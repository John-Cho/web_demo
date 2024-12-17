class Order {
  final String name;
  final String number;
  bool isCopied;

  Order({required this.name, required this.number, this.isCopied = false});
  get message{
    return 
'''안녕하세요 $name 대표님 :-)\n\n
주문해주신 상품이 당일 출고 되었습니다.\n\n
로젠택배 : $number
\n\n상품 구매 해주셔서 감사합니다!''';
  }
}