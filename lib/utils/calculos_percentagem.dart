
class CalculosPercentagem {

  static const int taxaMulta = 15;

  static const int taxaServico = 10;

  double CalculePorcentagemDesteValor(int porcentagem, double valor){

    final _porcentagem = porcentagem/100;
    return _porcentagem*valor;
  }


}