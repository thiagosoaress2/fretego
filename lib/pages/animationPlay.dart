import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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



  String sample = 'airplane';

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;


    return sample == 'menu'
        ? _MenuSample(animationController)
        : sample == 'airplane'
          ? _AirPlaneSample(animationController)
          : Container();

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


