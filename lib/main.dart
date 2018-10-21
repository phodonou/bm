import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'component.dart';

void main() => runApp(new MyApp());
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  Firestore _f = Firestore.instance;

  @override
  Widget build(BuildContext context) {

    return new MaterialApp(

      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Great App'),
        ),
        body: StreamBuilder(
          stream: _f.collection('app').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Text('DOES NOT EXIST');
            }
            else{
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    itemBuilder: (BuildContext context, int index){
                      switch(snapshot.data.documents[index]['comp']){
                        case 'TextField':
                          return TextField();
                        case 'Button':
                          return RaisedButton(
                            onPressed: (){},
                            color: Colors.green,
                            child: Text("Button"),
                          );
                        case 'Text':
                          return Text("");
                        case 'FloatingActionButton':
                          return FloatingActionButton(onPressed: (){}, backgroundColor: Colors.blue,);
                        case 'CheckBox':
                          return Checkbox(value: true, onChanged: (_){},);
                        case 'Switch':
                          return Switch(value: true, onChanged: (_){},);
                        case 'Container':
                          return Container();
                        case 'Card':
                          return Card();
                        case 'Image':
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
                            height: 150.0,
                            color: Colors.green,
                            child: Center(
                              child: Text('Your Image Here'),
                              ),
                          );
                        default:
                          return Text("Cannot Render Widget");
                      }
                    }
                );
            }
//            return FutureBuilder(
//                future: getDocs(snapshot),
//                builder: (BuildContext context, AsyncSnapshot<List<Component>> pchildren){
//                  if(!pchildren.hasData){
//                    return Center(child: CircularProgressIndicator(),);
//                  }else{
//                      Component app = Component(
//                        widget: "Container",
//                        children: pchildren.data
//                      );
//                      debugPrint(app.toString());
//                      var ui = draw(app, renderWidget(app.widget));
//                      return ui;
//                  }
//                },
//            );
          },
        ),
      ),
    );
  }

  Widget renderWidget(String comp){

      switch(comp){
          case 'TextField':
           return TextField();
          case 'Button':
            return RaisedButton(
              onPressed: (){},
              color: Colors.green,
              child: Text("Button"),
            );
          case 'Text':
            return Text("");
          case 'FloatingActionButton':
            return FloatingActionButton(onPressed: (){}, backgroundColor: Colors.blue,);
          case 'CheckBox':
            return Checkbox(value: true, onChanged: (_){},);
          case 'Switch':
            return Switch(value: true, onChanged: (_){},);
          case 'Container':
            return Container();
          default:
            return Text("Cannot Render Widget");
      }
  }

   Future<List<Component>> getDocs(AsyncSnapshot<QuerySnapshot> snapshot) async {
    List<Component> children = [];
    for(DocumentSnapshot doc in snapshot.data.documents){
      if(doc.documentID != "update_code"){
        children.add( await makeComp(doc.reference));
      }
    }
    return children;
  }

    Future<Component> makeComp(DocumentReference docF) async {
      QuerySnapshot querySnapshot = await docF.collection('children').getDocuments();
      if(querySnapshot.documents.length != 0){ //have children
        List<Component> children = [];
        for(DocumentSnapshot d in querySnapshot.documents){
          children.add(
            await makeComp(d.reference)
          );
        }
      }
      else{
        DocumentSnapshot currDoc = await docF.get();
        return Component(widget: currDoc.data['comp'], children: []);
      }
    // docF.collection('children').getDocuments().then((QuerySnapshot querySnapshot){
      //     docF.get().then((DocumentSnapshot currDoc){
      //         if(querySnapshot.documents.length == 0){ //have no children
      //           return Component(widget: currDoc.data['comp'], children: []);
      //         }else{
      //             List<Component> children = [];
      //             for(DocumentSnapshot d in querySnapshot.documents){
      //               children.add(makeComp(d.reference));
      //           }
      //         }
      //     });
      // });
  }

  Widget draw(Component rootLevel, Container container){
      if(rootLevel == null){
        return container;
      }
      for(int i =0; i < 0; i++){
        Component child = rootLevel.children[i];

        String toRender = child.widget;
//        if(rootLevel.children.length > 0){
//          if(rootLevel.children[0] == null){
//            toRender =  "ERROR";
//          }
//        }else{
//          toRender = child.widget;
//        }

        //check relative layout with next child and draw based on that
        Container curCont = Container(
          child: Column(
            children: <Widget>[
              container,
              renderWidget(toRender)
            ],
          ),
        );
        //call on it's children
        for(Component subC in child.children){
          draw(subC, curCont);
        }
      }
      //return renderWidget(rootLevel.children.length > 0 ? rootLevel.children[0] == null ? "Button" : rootLevel.widget: Text(''));
  }
}