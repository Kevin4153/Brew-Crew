import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values
  String? _currentName;
  String? _currentSugars;
  dynamic _currentStrength = 100;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data!;

            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Update your brew settings.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    initialValue: userData.name,
                    decoration: textInputDeocartion,
                    validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) => setState(() => _currentName = val),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),

                  //dropdown
                  DropdownButtonFormField<String>(
                    decoration: textInputDeocartion,
                    value: _currentSugars == "" ? userData.sugars : sugars[0],
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(value: sugar, child: Text('$sugar sugars'));
                    }).toList(),
                    onChanged: (String? val) => setState(() => _currentSugars = val!),
                  ),

                  //slider
                  Slider(
                    activeColor: Colors.brown[_currentStrength ?? userData.strength],
                    inactiveColor: Colors.brown[_currentStrength ?? userData.strength],
                    min: 100,
                    max: 900,
                    divisions: 8,
                    onChanged: (val) => setState(() => _currentStrength = val.round()),
                    value: (_currentStrength ?? userData.strength).toDouble(),
                  ),

                  ElevatedButton(
                      style: raisedButtonStyle,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await DatabaseService(uid: user.uid).updateUserData(
                              _currentSugars ?? userData.sugars,
                              _currentName ?? userData.name,
                              _currentStrength ?? userData.strength);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
