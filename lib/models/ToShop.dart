class ToShop{
  String title;
  String status;
  String quantity;

  ToShop();

  ToShop.fromTitle(String title,String quantity){
    this.title = title;
    this.quantity = quantity;
    this.status = "O";
  }

  ToShop.fromJson(Map<String,dynamic> json) :
      title = json["title"],
      quantity = json["quantity"],
      status = json["status"];

  Map toJson() => {
    "title": title,
    "quantity": quantity,
    "status": status
  };


}