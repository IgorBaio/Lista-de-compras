import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lista_compras/models/ToShop.dart';
import 'package:lista_compras/screens/ToShop_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToShopList extends StatefulWidget {
  @override
  _ToShopListState createState() => _ToShopListState();
}

class _ToShopListState extends State<ToShopList> {
  List<ToShop> list = [];
  final _doneStyle = TextStyle(
    color: Colors.green,
    decoration: TextDecoration.lineThrough,

  );
  final _toShopStyle = TextStyle(
    color: Colors.white,

  );

  @override
  void initState() {
    super.initState();
    _reloadList();
  }

  _reloadList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var data = preferences.getString("list");
    if(data != null){
      var objs = jsonDecode(data) as List;
      setState(() {
        list = objs.map((obj) => ToShop.fromJson(obj)).toList();
      });
    }
  }

  _removeItem(int index){
    setState(() {
      list.removeAt(index);
    });
    SharedPreferences
      .getInstance()
      .then(
            (preferences) => preferences
                              .setString("list", jsonEncode(list))
          );
  }

  _doneItem(int index){
    setState(() {
      list[index].status = "C";
      var itemDone = list[index];
      list.removeAt(index);
      list.add(itemDone);
    });
    SharedPreferences
        .getInstance()
        .then(
            (preferences) => preferences
            .setString("list", jsonEncode(list)));
  }

  _toShopItem(int index){
    List<ToShop> listAux = [];
    setState(() {
      list[index].status = "O";
      listAux.add(list[index]);
      list.removeAt(index);
      listAux.addAll(list);
      list = [];
      list.addAll(listAux);
    });
    SharedPreferences
        .getInstance()
        .then(
            (preferences) => preferences
            .setString("list", jsonEncode(list)));
  }

  _reAddAll(BuildContext context){
    List<ToShop> listAux = [];
    var index = 0;
    for(index; index<list.length;index++){
      if(list[index].status=="C"){
        _toShopItem(index);

      }
    }

  }

  _removeAll(BuildContext context, String conteudo){
    showDialog(
        context: context,
        builder: (context){
      return AlertDialog(
        title: Text("Confirmação"),
        content: Text(conteudo),
        actions: <Widget>[
          FlatButton(
            child: Text("Não"),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text("Sim"),
            onPressed: (){
              Navigator.pop(context);
              setState(() {
                list.clear();
              });
              SharedPreferences
                  .getInstance()
                  .then(
                      (preferences) => preferences
                      .setString("list", jsonEncode(list))
              );
              Navigator.pop(context);
            },
          )
        ],
      );
      }
    );

  }
  
  _showAlertDialog(BuildContext context, String conteudo, Function confirmfunction, int index){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Confirmação"),
            content: Text(conteudo),
            actions: <Widget>[
              FlatButton(
                child: Text("Não"),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  confirmfunction(index);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Lista de compras"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black12,
      body: ListView.separated(
          separatorBuilder: (context,index) => Divider(),
          itemCount: list.length,
          itemBuilder: (context,index) {
            return Card(
              color: Colors.white12,
              child: ListTile(
                title: Text('${list[index].title}',
                    style: list[index].status == "C" ? _doneStyle : _toShopStyle),
                subtitle: Text('Quantidade: ${list[index].quantity}',
                    style: list[index].status == "C" ? _doneStyle : _toShopStyle),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ToShopItem(toShop: list[index],index:index)
                    )).then((value) => _reloadList()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Visibility(
                      visible: list[index].status == "O",
                      child:
                      IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.white54,),
                        onPressed: () => _doneItem(index),
                      ),
                    ),
                    Visibility(
                      visible: list[index].status == "C",
                      child:
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.white54,),
                        onPressed: () =>_toShopItem(index),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear,
                        color: Colors.white54,),
                      onPressed: () => _showAlertDialog(
                          context,
                          "Tem certeza que deseja excluir ?",
                          _removeItem,
                          index
                      ),
                    ),

                  ],
                ),
              ),
            );

          },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: ()=>Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ToShopItem(
              toShop: null,
              index: -1,
            )
          )
        ).then((value) => _reloadList()),
      ),
        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black12, //This will change the drawer background to blue.
          //other styles
          ),
          child: Drawer(
            child: ListView(
              padding: const EdgeInsets.all(8.0),

              children: <Widget>[

                new Container(
              child: Text("Mais Opções",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
                  color:Colors.deepPurple,
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 25.0),),
                new Container(
                  child: ListTile(

                    title: Text("Readicionar Tudo",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap:() {
                      _reAddAll(context);
                      Navigator.pop(context);
                    },
                ),
                color: Colors.black12,
                margin: EdgeInsets.only(top: 25.0),
                ),
                new Container(child: ListTile(
                  title: Text("Remover Tudo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {
                    _removeAll(context,
                      "Tem certeza que deseja excluir tudo?",
                      );
                  },
                ),
              )

              ],

            ),// Populate the Drawer in the next step.
        ),
        ),

    );
  }
}
