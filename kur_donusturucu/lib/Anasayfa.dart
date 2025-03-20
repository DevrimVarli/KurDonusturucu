import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  final String _apiKey ="22f59c0468203f67ae8a520cd7592d6d";
  final String _baseUrl="http://api.exchangeratesapi.io/v1/latest?access_key=";
  var _controller=TextEditingController();
  Map<String,double> _oranlar={
  };
  var _secilenKur="USD";
  double _sonuc=0;


  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek();
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Kur Dönüştürücü",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body:_oranlar.isNotEmpty ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: (String yeniDeger){
                      _hesapla();
                    },
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                DropdownButton<String>(
                    value:_secilenKur ,
                    items: _oranlar.keys.map((String kur) {
                      return DropdownMenuItem<String>(
                          value: kur,
                          child: Text(kur),);

                    }).toList(),
                    onChanged: (String? yenideger ){
                          if(yenideger != null){
                              _secilenKur=yenideger;
                              _hesapla();

                          }
                    }),
              ],
            ),
             SizedBox(height: 16,),
            Text("${_sonuc.toStringAsFixed(2)} tl",style: TextStyle(fontSize: 28),),
            Padding(
              padding:  EdgeInsets.only(top:8.0),
              child: Container(
                height: 3,
                color: Colors.black,
              ),
            ),
            Expanded(child: ListView.builder(
                itemCount: _oranlar.keys.length,
                itemBuilder: (context,indeks){
                  return SizedBox(
                    height: 50,
                    child: Card(
                      color: Colors.black45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(_oranlar.keys.toList()[indeks],style: TextStyle(fontSize: 16,color: Colors.white),),
                          Text(_oranlar.values.toList()[indeks].toStringAsFixed(2),style: TextStyle(fontSize: 16,color: Colors.white),),
                        ],
                      ),
                    ),
                  );
                }

            ),
            ),
          ],
        ),
      ):Center(child: CircularProgressIndicator()),


    );
  }
  void _verileriInternettenCek() async{
    Future.delayed(Duration(seconds:3 ));
    var uri= Uri.parse(_baseUrl+_apiKey);
    var cevap=await http.get(uri);
    Map<String,dynamic> parseCevap=json.decode(cevap.body);
    Map<String,dynamic> rates=parseCevap["rates"];
    double? baseTlKuru=rates["TRY"];
    if(baseTlKuru!=null){
      for(String ulkeKuru in rates.keys){
        double? baseKuru=double.tryParse(rates[ulkeKuru].toString());
        if(baseKuru!=null){
          double? tlKuru=baseTlKuru/baseKuru;
          _oranlar[ulkeKuru]=tlKuru;
        }
      }
    }
    setState(() {

    });
  }
  void _hesapla(){
    double? deger=double.tryParse(_controller.text);
    double? oran =_oranlar[_secilenKur];
    if(deger !=null && oran!=null){
      setState(() {
        _sonuc=oran*deger;
      });
    }
  }

}
/*
{
    "success": true,
    "timestamp": 1519296206,
    "base": "EUR",
    "date": "2021-03-17",
    "rates": {
        "AUD": 1.566015,
        "CAD": 1.560132,
        "CHF": 1.154727,
        "CNY": 7.827874,
        "GBP": 0.882047,
        "JPY": 132.360679,
        "USD": 1.23396,
    [...]
    }
}
 */