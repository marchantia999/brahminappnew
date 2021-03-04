import 'package:bot_toast/bot_toast.dart';
import 'package:brahminapp/app/home_page/drawer_tiles/puja_offering/catagories.dart';
import 'package:brahminapp/common_widgets/platform_exception_alert_dialog.dart';
import 'package:brahminapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

List<Category> trendingPujaList = [];
List<String> trendingPujaNameList = [];

class AddAndEditPuja extends StatefulWidget {
  final String uid;
  final DocumentSnapshot docSnap;

  const AddAndEditPuja({Key key, @required this.uid, @required this.docSnap})
      : super(key: key);

  @override
  _AddAndEditPujaState createState() => _AddAndEditPujaState();
}

class _AddAndEditPujaState extends State<AddAndEditPuja> {
  final _formKey = GlobalKey<FormState>();
  String puja = "Select puja";
  bool other = false;
  String _name;
  double _rate;
  String _benefits;
  String samagri;
  String _additionalDisctription;
  String _time;
  String hr;
  Map keymap = {};
  Map samMap = {};
  dynamic keyword;

  int index = 0;

  //String _serviceId=widget.database
  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    try {
      final String serviceId = DateTime.now().toIso8601String();
      FireStoreDatabase(uid: widget.uid)
          .setPujaOffering(data: {
            'puja': _name,
            'price': _rate,
            'Benefit': _benefits,
            'swastik': 0,
            'PanditD': _additionalDisctription,
            'Pujan Samagri': samagri,
            'time': _time,
            'keyword': keyword == null ? '#' + _name + '/' : keyword,
            'subscriber': 0,
            'profit': 0.1,
            'serviceId': serviceId,
          }, pid: serviceId)
          .whenComplete(() => FireStoreDatabase(uid: widget.uid).updateKeyword(
                keyword == null ? '#' + _name + '/' : keyword,
              ))
          .whenComplete(() {
            BotToast.showText(text: "$_name adeed in your service list");
          });
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  Future<void> _submit1() async {
    try {
      FireStoreDatabase(uid: widget.uid).updatePujaOffering(data: {
        'puja': _name,
        'price': _rate,
        'Benefit': _benefits,
        'PanditD': _additionalDisctription,
        'time': _time,
      }, pid: widget.docSnap.id);
      BotToast.showText(text: "$_name is updated");
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Operation failed',
        exception: e,
      ).show(context);
    }
  }

  @override
  void initState() {
    samagri = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.docSnap != null) {
      _name = widget.docSnap.data()['puja'];
      _rate = widget.docSnap.data()['price'];
      _benefits = widget.docSnap.data()['Benefit'];
      samagri = widget.docSnap.data()['Pujan Samagri'];
      _additionalDisctription = widget.docSnap.data()['PanditD'];
      _time = widget.docSnap.data()['time'];
      print(
          '########################################+++++++++++$_name $_additionalDisctription $samagri');
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        elevation: 2.0,
        title: Text(widget.docSnap != null ? 'Edit puja' : 'Add Puja'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () {
              if (widget.docSnap == null) {
                if (_validateAndSaveForm() && keyword != null) {
                  _submit();
                  Navigator.of(context).pop();
                }
                if (keyword == null) {
                  BotToast.showText(text: "Please select puja type");
                }
              } else {
                if (_validateAndSaveForm()) {
                  Navigator.of(context).pop();
                  _submit1();
                }
              }
            },
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return StreamBuilder<QuerySnapshot>(
        stream: FireStoreDatabase(uid: widget.uid).getTrendingList,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          trendingPujaNameList.clear();
          keymap.clear();

          snapshot.data.docs.forEach((element) {
            keymap.addAll({element.data()['name']: element.id});
            samMap.addAll({element.data()['name']: element.data()['Samagri']});
          });
          print(keymap);
          keymap.forEach((key, value) {
            trendingPujaNameList.add(key);
          });
          //trendingPujaNameList.add('Others');
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildFormChildren(),
            ),
          );
        });
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'Puja name'),
        initialValue: _name,
        validator: (value) => value.isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Rate', prefixText: '₹'),
        initialValue: _rate != null ? '$_rate' : '',
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        validator: (value) => value.isNotEmpty ? null : 'Rate can\'t be empty',
        onSaved: (value) => _rate = double.tryParse(value) ?? 0,
      ),
      TextFormField(
        initialValue: _time,
        decoration: InputDecoration(labelText: 'Duration in min'),
        validator: (value) =>
            value.isNotEmpty ? null : 'Duration can\'t be empty',
        onSaved: (value) => _time = value, // = int.tryParse(value) ?? 0,
      ),
      other
          ? TextFormField(
              decoration: InputDecoration(labelText: 'Pujan samagri'),
              initialValue: samagri,
              validator: (value) =>
                  value.isNotEmpty ? null : 'Pujan samagri can\'t be empty',
              onSaved: (value) => samagri = value,
            )
          : SizedBox(),
      TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration(labelText: 'Benefits from this puja'),
        initialValue: _benefits,
        onSaved: (value) => _benefits = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Additional Description'),
        initialValue: _additionalDisctription,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        onSaved: (value) => _additionalDisctription = value,
      ),
      SizedBox(
        height: 20,
      ),
      widget.docSnap != null
          ? SizedBox()
          : Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.black54,
                      width: 0.5,
                      style: BorderStyle.solid)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Choose Category",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(width: 25),
                  SearchableDropdown.single(
                    hint: Text("Puja type"),
                    isExpanded: true,
                    displayClearIcon: false,
                    items:
                        trendingPujaNameList.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    onChanged: (String value) {
                      setState(() {
                        puja = value;
                        if (value == "Others") {
                          setState(() {
                            other = true;
                          });
                        } else {
                          setState(() {
                            samagri = samMap[value];
                            keyword = keymap[value];
                            other = false;
                          });
                        }
                      });
                    },
                  ),
                  Text(
                    '*Select this field very carefully as this field will decide pujan samagri*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
      SizedBox(
        height: 10,
      ),
      widget.docSnap != null
          ? SizedBox()
          : Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                      color: Colors.black54,
                      width: 0.5,
                      style: BorderStyle.solid)),
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text("Samagri"),
                  keyword == null
                      ? SizedBox()
                      : TextFormField(
                          key: Key(samagri.toString()),
                          initialValue: samagri,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          onSaved: (value) => samagri = value,
                        ),
                ],
              ),
            ),
      SizedBox(
        height: 50,
      ),
    ];
  }
}
