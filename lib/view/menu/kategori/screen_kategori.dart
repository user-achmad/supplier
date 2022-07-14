import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supplier/helper/ui/app_dialog.dart';
import 'package:supplier/helper/ui/app_hex_color.dart';
import 'package:supplier/helper/utility/app_shared_prefs.dart';
import 'package:supplier/model/kategoi_model.dart';

String token = "";

class KategoriPage extends StatelessWidget {
  const KategoriPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => _ProviderGetKategori(),
      )
    ], child: const _KategoriContent());
  }
}

class _KategoriContent extends StatefulWidget {
  const _KategoriContent({Key? key}) : super(key: key);

  @override
  State<_KategoriContent> createState() => _KategoriContentState();
}

class _KategoriContentState extends State<_KategoriContent> {
  final _formKey = GlobalKey<FormState>();
  final _namaKategoriController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppSharedPrefs.getToken().then((value) => token = value);
      if (token.isNotEmpty) {
        await context.read<_ProviderGetKategori>().setData(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Kategori",
            textScaleFactor: 1,
            style: GoogleFonts.mochiyPopOne(fontSize: 20, color: Colors.white)),
      ),
      body: Consumer<_ProviderGetKategori>(
        builder: (context, value, child) {
          var rows = value.result;
          if (rows.isNotEmpty) {
            return ListView.builder(
                itemCount: rows.length,
                itemBuilder: (_, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey,
                    ),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Slidable(
                      closeOnScroll: true,
                      key: const ValueKey(0),
                      startActionPane: ActionPane(
                        // A motion is a widget used to control how the pane animates.
                        motion: const BehindMotion(),

                        // A pane can dismiss the Slidable.
                        dismissible: DismissiblePane(onDismissed: () {}),

                        // All actions are defined in the children parameter.
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            spacing: 1,
                            onPressed: (_) {
                              _deleteApi(context, {"idkat": rows[index].idkat});
                            },
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                          SlidableAction(
                            onPressed: (_) async {
                              await _actionButtonEdit(context, rows[index]);
                              context
                                  .read<_ProviderGetKategori>()
                                  .setData(context);
                            },
                            backgroundColor: const Color(0xFF21B7CA),
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          _box(rows[index].nmkat),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _actionButtonAdd(context);
            context.read<_ProviderGetKategori>().setData(context);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
    );
  }

  Widget _box(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey,
      ),
      height: 100,
      width: 200,
      child: Center(
          child: Text(title,
              textScaleFactor: 1,
              style:
                  GoogleFonts.mochiyPopOne(fontSize: 15, color: Colors.white))),
    );
  }

  Future<void> _actionButtonAdd(BuildContext closecontext) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext addcontext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          "FORM TAMBAH KATEGORI",
          textScaleFactor: 1,
        ),
        content: Form(
          key: _formKey,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              textInputAction: TextInputAction.go,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _namaKategoriController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nama Kategori",
              ),
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Mohon mengisi nama kategori";
                }
                if (value.length < 2) {
                  return "Masukkan nama kategori dengan benar";
                }
                return null;
              },
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey.shade100,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
                textScaleFactor: 1,
              )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppHexColor("#B3C3F2"),
              ),
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _addApi(context, {"nmkat": _namaKategoriController.text});
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.black),
                textScaleFactor: 1,
              )),
        ],
      ),
    );
  }

  Future<void> _actionButtonEdit(BuildContext closecontext, Result rows) async {
    _namaKategoriController.text = rows.nmkat;
    await showDialog<String>(
      context: context,
      builder: (BuildContext addcontext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          "FORM EDIT KATEGORI",
          textScaleFactor: 1,
        ),
        content: Form(
          key: _formKey,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              textInputAction: TextInputAction.go,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _namaKategoriController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nama Kategori",
              ),
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Mohon mengisi nama kategori";
                }
                if (value.length < 2) {
                  return "Masukkan nama kategori dengan benar";
                }
                return null;
              },
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey.shade100,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
                textScaleFactor: 1,
              )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppHexColor("#B3C3F2"),
              ),
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _editApi(context, {
                  "idkat": rows.idkat,
                  "nmkat": _namaKategoriController.text
                });
              },
              child: const Text(
                'Edit',
                style: TextStyle(color: Colors.black),
                textScaleFactor: 1,
              )),
        ],
      ),
    );
  }
}

Future<void> _addApi(BuildContext context, dynamic params) async {
  print(params);
  int act = 2;
  AppDialogs.showProgressDialog(
      context: context, title: "Prosess", message: "Proses tambah kategori");
  Response response = await Dio().post(
      "https://tugaskuy009.000webhostapp.com/tugas/kat.php?act=$act",
      data: params,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": token
      }));
  AppDialogs.hideProgressDialog();
  if (response.data['result'] != null) {
    await AppDialogs.resultDialog(
        context: context,
        title: "Berhasil",
        message: "Kategori berhasil ditambahkan");
    Navigator.pop(context);
  }
}

Future<void> _editApi(BuildContext context, dynamic params) async {
  print(params);
  int act = 3;
  AppDialogs.showProgressDialog(
      context: context, title: "Prosess", message: "Proses edit kategori");
  Response response = await Dio().post(
      "https://tugaskuy009.000webhostapp.com/tugas/kat.php?act=$act",
      data: params,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": token
      }));
  AppDialogs.hideProgressDialog();
  if (response.data['result'] != null) {
    await AppDialogs.resultDialog(
        context: context,
        title: "Berhasil",
        message: "Kategori berhasil diedit");
    Navigator.pop(context);
  }
}

Future<void> _deleteApi(BuildContext context, dynamic params) async {
  int act = 4;
  AppDialogs.showProgressDialog(
      context: context, title: "Prosess", message: "Proses hapus kategori");
  Response response = await Dio().post(
      "https://tugaskuy009.000webhostapp.com/tugas/kat.php?act=$act",
      data: params,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "token": token
      }));
  AppDialogs.hideProgressDialog();
  if (response.data['result'] != null) {
    await AppDialogs.resultDialog(
        context: context,
        title: "Berhasil",
        message: "Kategori berhasil dihapus");
    context.read<_ProviderGetKategori>().setData(context);
  }
}

class _ProviderGetKategori with ChangeNotifier {
  List<Result> result = [];
  int act = 1;
  bool isBusy = false;

  Future<void> setData(BuildContext context, {bool append = false}) async {
    if (isBusy) return;

    if (!append) {
      result.clear();
      notifyListeners();
    }

    isBusy = true;
    notifyListeners();
    Response response = await Dio().get(
        "https://tugaskuy009.000webhostapp.com/tugas/kat.php?act=$act",
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "token": token
        }));
    if (response.data != null) {
      ModelKategori model = ModelKategori.fromJson(response.data);
      result.addAll(model.result);
    }
    isBusy = false;
    notifyListeners();
  }
}
