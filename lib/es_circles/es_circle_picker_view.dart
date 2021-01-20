import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_select_circle.dart';
import 'package:provider/provider.dart';

class CirclePickerView extends StatefulWidget {
  static const routeName = "/circlePickerView";

  @override
  _CirclePickerViewState createState() => _CirclePickerViewState();
}

class _CirclePickerViewState extends State<CirclePickerView> {
  EsSelectCircleBloc _esSelectCircleBloc;

  @override
  void initState() {
    _esSelectCircleBloc =
        Provider.of<EsSelectCircleBloc>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
