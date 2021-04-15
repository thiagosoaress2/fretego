class GlobalsStrings {

  static String appName = 'FretesGo';

  //variaveis de situação
  static String sitAguardando = 'aguardando';  //<<fazer nada
  static String sitTruckerFinished = 'trucker_finished';  //<<desabilitar os controles e exibir mensagem
  static String sitTruckerQuitAfterPayment = 'trucker_quited_after_payment';  //<<desabilitar os controles e exibir mensagem mas permitir trocar motorista
  static String sitUserInformTruckerDidntMakeMove = 'user_informs_trucker_didnt_make_move';  //<<desabilitar os controles e exibir a mensagem
  static String sitUserInformTruckerDidntFinishedMove = 'user_informs_trucker_didnt_finished_move'; //<<desabilitar os controles e exibir a mensagem
  static String sitAccepted = 'accepted'; //<<exibir tudo
  static String sitPago = 'pago';  //<<exibir tudo
  static String sitQuit = 'quit';  //<<exibir tudo
  static String sitDeny = 'deny';
  static String sitUserInformTruckerDidntFinishedButItsGoingBack = 'user_informs_trucker_didnt_finished_move_goingback'; //<<esse n tem correspondencia no app do user
  static String sitUserFinished = 'user_finished';
  static String sitNoTrucker = 'sem motorista';
  static String sitTruckerIsGoingToMove = 'motorista a caminho'; //ainda precisa implementar. Vai perguntar ao user se ele ta indo quando faltar 2 horas pra mudanças...e ele vai dar ok
  static String sitNewServiceNoTrucker = 'agendamentos_sem_motorista'; //quando o user cria uma mudança sem motorista
  static String sitAguardandoEspecifico = 'aguardando_especifico'; //quando o user cria uma mudança usando o código do motorista específico

  static String sitReschedule = 'reagendou';


  //textos do botão
  static String buttonTxtLogin = 'Login';
  static String buttonTxtComecarMudanca = 'Começar mudança';
  static String buttonTxtVerMudanca = 'Ver minha mudança'; //descontinuado mas permance no codigo
  static String buttonTxtPagar = 'Pagar'; //descontinuado mas permanece no codigo



  //motivos de cancelamento
  static String motivoTruckerAbandon = 'trucker_desistiu';
  static String motivoUserCancel = 'user_desistiu';


  //popups codigo
  static String popupCodeTruckerDeny='truckerDeny';
  static String popupCodeTruckerFinished='trucker_finished';
  static String popupCodeTruckerquitedAfterPayment='trucker_quited_after_payment';
  static String popupCodeSolvingProblems='solving_problems';
  static String popupCodeAccepptedLittleNegative='accepted_little_negative';
  static String popupCodeAccepptedMuchNegative='accepted_much_negative';
  static String popupCodeAcceptedAlmostTime='accepted_almost_time';
  static String popupCodeAcceptedTimeToMove='accepted_timeToMove';
  static String popupCodepagoLittleNegative='pago_little_negative';
  static String popupCodepagoMuchNegative='pago_much_negative';
  static String popupCodepagoAlmostTime='pago_almost_time';
  static String popupCodepagoTimeToMove='pago_timeToMove';
  static String popupCodeSystemCanceled='sistem_canceled';
  static String popupCodeSystemCanceledExpired='sistem_canceled_expired';
  static String popupCodeSystemTruckerNotAnsweredButIsClose='sistem_trucker_notAnswered_but_is_near';



}