import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Universitas {
  String nama;
  String univ;
  Universitas({required this.nama, required this.univ});
}

class Unive {
  List<Universitas> ListPop = <Universitas>[];

  Unive(Map<String, dynamic> json) {
    // isi listPop disini
    var data = json["data"];
    for (var val in data) {
      var nama = val["name"].toString(); // ubah menjadi string
      var univ = val["domains"].toString(); // ubah menjadi string
      ListPop.add(Universitas(nama: nama, univ: univ));
    }
  }

  // map dari json ke atribut
  factory Unive.fromJson(Map<String, dynamic> json) {
    return Unive(json);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

//class state
class MyAppState extends State<MyApp> {
  late Future<Unive> futureUnive;

  //https://datausa.io/api/data?drilldowns=Nation&measures=Population
  String url = "http://universities.hipolabs.com/search?country=Indonesia";

  //fetch data
  Future<Unive> fetchData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      return Unive.fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futureUnive = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'coba http',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('coba http'),
          ),
          body: Center(
            child: FutureBuilder<Unive>(
              future: futureUnive,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    //gunakan listview builder
                    child: ListView.builder(
                      itemCount: snapshot
                          .data!.ListPop.length, //asumsikan data ada isi
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(snapshot.data!.ListPop[index].nama
                                      .toString()),
                                  Text(snapshot.data!.ListPop[index].univ
                                      .toString()),
                                ]));
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ),
        ));
  }
}
