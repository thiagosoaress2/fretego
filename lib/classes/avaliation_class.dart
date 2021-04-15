class AvaliationClass {

  //variaveis comuns no app freteiro e no app user
  String avaliationTargetName;
  String avaliationTargetId;
  double avaliationTargetRate;
  int avaliations;
  double newRate=0;

  //variaveis especificas
  String enderecoOrigem;
  String enderecoDestino;
  String distancia;
  String nomeMotorista;
  String motoristaId;
  String data;
  String hora;
  String motoristaImage;


  AvaliationClass(this.avaliationTargetName, this.avaliationTargetId, this.avaliationTargetRate, this.avaliations);

  AvaliationClass.Empty();

  double calculateAvaliation(double value, int avaliations, double _userRate){

    double _totalRate = _userRate+value;
    int _totalAvaliations = avaliations+1;
    return _totalRate/_totalAvaliations;
  }


}