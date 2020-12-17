class ItemClass {

  String name;
  double weight;
  bool singlePerson;
  double volume;
  String image;

  //ItemClass(this.name, this.weight, this.singlePerson, this.volume, this.image);
  ItemClass(this.name, this.weight, this.singlePerson, this.volume);

  ItemClass.empty();

  double calculateVolume(double altura, double largura, double profundidade){

    return altura*largura*profundidade;

  }

}