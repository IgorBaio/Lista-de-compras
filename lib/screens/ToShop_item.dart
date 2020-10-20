import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lista_compras/models/ToShop.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToShopItem extends StatefulWidget {
  final ToShop toShop;
  final int index;
  const ToShopItem({Key key,@required this.toShop,@required this.index}) : super(key: key);

  @override
  _ToShopItemState createState() => _ToShopItemState(toShop, index);
}

class _ToShopItemState extends State<ToShopItem> {
  ToShop _toShop;
  int _index;
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();

  final key = GlobalKey<ScaffoldState>();
  
  _ToShopItemState(ToShop toShop, int index){
    this._toShop = toShop;
    this._index = index;
    if(toShop != null){
      _titleController.text = _toShop.title;
    }
  }
  
  _saveItem() async {
    if(_titleController.text.isEmpty){
      key.currentState.showSnackBar(SnackBar(
          content: Text("Campos obrigatórios")
        )
      );
    }else{
      if(_quantityController.text.isEmpty)
        _quantityController.text = "1";
      SharedPreferences preferences = await SharedPreferences.getInstance();
      
      List<ToShop> list = [];
      var data = preferences.getString("list");
      if(data != null){
        var objs = jsonDecode(data) as List;
        list = objs.map((obj) => ToShop.fromJson(obj)).toList();
      }
      
      _toShop = ToShop.fromTitle(_titleController.text,_quantityController.text);
      List<ToShop> listAux = [];
      if(_index != -1){
        list[_index] = _toShop;
      }else{
        listAux = list;
        list = [];
        list.add(_toShop);
        list.addAll(listAux);
      }

      preferences.setString('list', jsonEncode(list));
      Navigator.pop(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Item a comprar"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFCAE1FF),
                hintText: "Nome do produto",
                hintStyle: TextStyle(color: Color(0xFF000000)),
                border: OutlineInputBorder(),

              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _quantityController,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFCAE1FF),
                hintText: "Quantidade: 1",
                hintStyle: TextStyle(color: Color(0xFF000000)),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              minWidth: double.infinity,
              child: RaisedButton(
                child: Text(
                  "Adicionar",
                  style: TextStyle(fontSize: 22),
                ),
                textColor: Colors.white,
                color: Color(0xFF8A2BE2),
                onPressed: (){
                  _saveItem();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              minWidth: double.infinity,
              child: RaisedButton(
                child: Text(
                  "Limpar",
                  style: TextStyle(fontSize: 22),
                ),
                textColor: Colors.white,
                color: Color(0xFF6A5ACD),
                onPressed: (){
                  _titleController.text = '';
                  _quantityController.text='';
                },
              ),
            ),
          ),
        ],
      )
    );
  }
}
