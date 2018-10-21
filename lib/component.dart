class Component {
  String widget;
  List<Component> children;

  Component({this.widget, this.children});

  @override
  String toString() {
    return 'Component{Widget: $widget, children: $children}';
  }


}

