class ItemClass {

  String name;
  double weight;
  bool singlePerson;
  int volume;
  String image;

  ItemClass({this.name, this.weight, this.singlePerson, this.volume, this.image});

  /*
  factory ItemClass.fromJson(Map<String, dynamic> json) {
    return new ItemClass(
      name: json['name'] as String,
      weight: json['weight'] as double,
      singlePerson: json['singlePerson'] as bool,
      volume: json['singlePerson'] as int,
      image: json['image'] as String
    );
  }

   */


  //fazendo editor online json
  //https://jsoneditoronline.org/#left=local.qipoxu
  //arquivo salvo em downloads itens.json
  //video guia
  //https://www.youtube.com/watch?v=iiADhChRriM

  //fonte   https://www.developerlibs.com/2018/11/flutter-how-to-parse-local-json-file-in.html

//https://stackoverflow.com/questions/49278185/loading-local-json-into-listview-builder

}