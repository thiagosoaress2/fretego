import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretego/utils/colors.dart';
import 'package:fretego/widgets/widgets_constructor.dart';

class AnimationPlayPage extends StatefulWidget {
  @override
  _AnimationPlayPageState createState() => _AnimationPlayPageState();
}

//https://www.youtube.com/watch?v=FCyoHclCqc8
///19:40

class _AnimationPlayPageState extends State<AnimationPlayPage>
  with SingleTickerProviderStateMixin {

  AnimationController animationController;

  double heightPercent;
  double widthPercent;


  @override
  void initState() {
      super.initState();
      animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 250),
      );
  }



  String sample = 'itenspage';

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(),
      body: sample == 'menu'
          ? _MenuSample(animationController)
          : sample == 'airplane'
          ? _AirPlaneSample(animationController)
          : sample == 'itenspage'
          ? _itensPageAnim()
          : Container(),
    );

  }


    bool canScroll=false; //vai liberar o scroll so na hora da animacao
    double offset=0.0;
    ScrollController _TopAnimcrollController;
    int step=0;

  Widget _itensPageAnim(){

    _TopAnimcrollController = ScrollController();

    //para animação da tela
    _TopAnimcrollController.addListener(() {
      setState(() {
        offset = _TopAnimcrollController.hasClients ? _TopAnimcrollController.offset : 0.1;

      });
      print(offset);
    });

    return Container(
      width: widthPercent,
      height: heightPercent,
      color: Colors.white,
      child: Stack(
        children: [

          Positioned(
            top: heightPercent*0.12,
              left: 0.1,
              right: 0.1,
              child: Container(
                width: widthPercent,
                height: heightPercent*0.08,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              )
          ),

          //lista
          Positioned(
            top: heightPercent*0.10,
            left: widthPercent*0.05,
            right: 10.0,
            child: Container(
              height: heightPercent*0.10,
              width: widthPercent,
              child: ListView(
                controller: _TopAnimcrollController,
                physics: canScroll == false ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,

                children: [


                  SizedBox(width: widthPercent*0.02,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.assignment, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Itens', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.home, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Endereços', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.airport_shuttle, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Veículo', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),


                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.people_alt_sharp, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Pessoal', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.schedule_outlined, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Agendar', Colors.grey, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: widthPercent*0.09,),
                  Column(
                    children: [
                      Container(
                        child: Icon(Icons.check, color: Colors.white,),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,// You can use like this way or like the below line
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2.0, //                   <--- border width here
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: widthPercent*0.10,
                        height: heightPercent*0.07,
                      ),
                      WidgetsConstructor().makeText('Pronto!', CustomColors.yellow, 8.0, 1.0, 0.0, 'center'),
                    ],
                  ),

                  SizedBox(width: 10000.0,),


                ],
              ),
            ),

          ),

          //caixa 1
          step>=1 ? Positioned(
              top: heightPercent*0.04,
              left: widthPercent*0.047,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 2
          step>=2 ? Positioned(
              top: heightPercent*0.04,
              left: widthPercent*0.072,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 3
          step>=3 ? Positioned(
              top: heightPercent*0.04,
              left: widthPercent*0.097,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 4
          step>=4 ? Positioned(
              top: heightPercent*0.025,
              left: widthPercent*0.052,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caixa 5
          step>=5 ? Positioned(
              top: heightPercent*0.025,
              left: widthPercent*0.082,
              child: Container(
                width: widthPercent*0.025,
                height: heightPercent*0.015,
                color: CustomColors.brown,)
          ) : Container(),

          //caminhonete
          Positioned(
              top: heightPercent*0.03,
              left: widthPercent*0.04,
              child: Container(
                width: widthPercent*0.15,
                height: heightPercent*0.055,
                child: Image.asset('images/itensselect/anim/anim_caminhonete.png', fit: BoxFit.fill,),
              )),

          //roda traseira
          Positioned(
            top: heightPercent*0.07,
              left: widthPercent*0.047,
              child: Container(
                width: widthPercent*0.045,
                height: heightPercent*0.025,
                child: Image.asset('images/itensselect/anim/anim_roda.png', fit: BoxFit.fill,),
              )
          ),

          //roda dianteira
          Positioned(
              top: heightPercent*0.07,
              left: widthPercent*0.14,
              child: Container(
                width: widthPercent*0.045,
                height: heightPercent*0.025,
                child: Image.asset('images/itensselect/anim/anim_roda.png', fit: BoxFit.fill,),
              )
          ),


          Positioned(
              top: 380.0,
              left: 10.0,
              right: 10.0,
              child:
              RaisedButton(
                  child: Text('Para frente'),
                  color: Colors.blue, onPressed: (){
                _scroll();
              })
          ),
          Positioned(
              top: 480.0,
              left: 10.0,
              right: 10.0,
              child:
              RaisedButton(
                  child: Text('Para tras'),
                  color: Colors.blue, onPressed: (){
                _scrollBack();
              })
          ),
        ],
      ),
    );


  }

  void _scroll(){
    double offsetAcrescim=widthPercent*0.19;

      canScroll=true;
      offset=offset+offsetAcrescim;
      _TopAnimcrollController.animateTo(offset, duration: Duration(milliseconds: 200), curve:Curves.easeInOut);
      canScroll=false;
      setState(() {
        step=step+1;
      });
  }

  void _scrollBack(){
    double offsetAcrescim=widthPercent*0.19;

    canScroll=true;
    offset<0.1 ? 0.0 : offset=offset-offsetAcrescim;
    _TopAnimcrollController.animateTo(offset, duration: Duration(milliseconds: 200), curve:Curves.easeInOut);
    canScroll=false;

    if(step!=0){
      setState(() {
        step=step-1;
      });
    }

  }

  Widget _AirPlaneSample(AnimationController animationController){

    int page=1;
    String pergunta= "Pergunta "+page.toString();

    Widget arrowIcons(){

      return Positioned(
          left: 8,
          bottom: 0,
          child: Column(
            children: [
              Icon(
                  Icons.arrow_upward, size: 25.0,
                  color : Colors.white
              ),
              Icon(
                  Icons.arrow_downward, size: 25.0,
                  color : Colors.white
              ),
            ],
          )
      );
    }

    Widget Plane(){

      return Positioned(
        left: 40,
        top: 32,
        child: RotatedBox(
          quarterTurns: 2,
          child: Icon(
            Icons.airplanemode_active,
            size: 64,
            color: Colors.white,
          ),
        ),

      );
    }

    Widget Line(){

      return Positioned(
        left: 40.0 + 32,
        top: 40,
        bottom: 0,
        width: 1,
        child: Container(color: Colors.white.withOpacity(0.5),),

      );
    }

    Widget answers(){

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                color: Colors.white,
                width: 35.0,
                height: 35.0,
              ),
              SizedBox(width: 15.0,),
              GestureDetector(
                onTap: () async {
                  //nextpage
                },
                child: Text('Pergunta clicável'),
              ),
              GestureDetector(
                  onTap: (){
                    //nextpage
                  },
                  child: Text('Pergunta clicável'),
              ),
              GestureDetector(
                  onTap: (){
                    //nextpage
                  },
                  child: Text('Pergunta clicável'),
              ),

            ],
          )
        ],
      );
    }

    Widget pageWid(String stepNumber, String stepQuestion){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.0,),
          Text(stepNumber),
          Text(stepQuestion),
          Spacer(),
          answers(),
          SizedBox(height: 64.0,),

        ],
      );
    }


    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: SafeArea(
          child: Stack(
            children: [
              arrowIcons(),
              Plane(),
              Line(),
              GestureDetector(
                onTap: (){
                  page++;
                  pergunta='Pergunta '+page.toString();

                },
                child: pageWid(page.toString(), pergunta),
              ),


            ],
          ),
        ),
      ),
    );




  }




  Widget _MenuSample(AnimationController animationController){

    var myDrawer = Container(color: Colors.blue, width: widthPercent, height: heightPercent,);
    var myChild = Container(color: Colors.white, width: widthPercent, height: heightPercent,);

    bool _canBeDragged=false;
    double minDragStartEdge=60.0;
    double maxDragStartEdge;

    final double maxSlide=225.0;

    maxDragStartEdge=maxSlide-16;

    void _toggle() => animationController.isDismissed
        ? animationController.forward()
        : animationController.reverse();


    void _onDragStart(DragStartDetails details){
      bool isDragOpenFromLeft = animationController.isDismissed && details.globalPosition.dx < minDragStartEdge;
      bool isDragcloseFromRight = animationController.isCompleted && details.globalPosition.dx > maxDragStartEdge;

      _canBeDragged = isDragOpenFromLeft || isDragcloseFromRight;
    }

    void _onDragUpdate(DragUpdateDetails details){
      if(_canBeDragged){
        double delta = details.primaryDelta / maxSlide;
        animationController.value += delta;
      }
    }

    void _onDragEnd(DragEndDetails details){
      if(animationController.isDismissed || animationController.isCompleted){
        return;
      }
      if(details.velocity.pixelsPerSecond.dx.abs() >= 365.0){
        double visualVelocity = details.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;

        animationController.fling(velocity: visualVelocity);
      } else if(animationController.value < 0.5){
        //close();
        _toggle();
      } else {
        //open();
        _toggle();
      }


    }

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,

      onTap: _toggle,
      child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {

            double slide = maxSlide * animationController.value;
            double scale = 1 - (animationController.value*0.3);
            return Stack(
              children: [
                myDrawer,
                Transform(transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale),
                  alignment: Alignment.centerLeft,
                  child: myChild,
                ),
              ],
            );

          }
      ),

    );



  }

  }


class ItemFader extends StatefulWidget {
  final Widget child;

  const ItemFader({Key key, @required this.child}) : super(key: key);

  @override
  _ItemFaderState createState() => _ItemFaderState();
}

class _ItemFaderState extends State<ItemFader> with SingleTickerProviderStateMixin {

  //1 means its bellow and -1 means its above
  int position = 1;
  AnimationController _animationController;
  Animation _animation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
        animation: _animation,
        child: widget.child,
        builder: (context, child){
          return Transform.translate(
            offset: Offset(0, 64 * position * (1 - _animation.value)),
            child: Opacity(
              opacity: _animation.value,
              child: child,
            ),
          );
        },
    );
  }

  void show(){
    setState(() => position = 1);
    _animationController.forward();
  }

  void hide(){
    setState(() => position = -1);
    _animationController.reverse();
  }
}


