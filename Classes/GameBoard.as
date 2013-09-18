package 
{
	
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	public class GameBoard extends MovieClip 
	{
		//01234, 0 = food, 1 = wood, 2 = clay, 3 = stone, 4 = gold
		//public static var stage:Stage;
		static var hunt:Area;
		static var wood:Area;
		static var clay:Area;
		static var stone:Area;
		static var gold:Area;
		static var farm:Area;
		static var hut:Area;
		static var tools:Area;
		static var stack1:Area;
		static var stack2:Area;
		static var stack3:Area;
		static var stack4:Area;
		static var card1:Area;
		static var card2:Area;
		static var card3:Area;
		static var card4:Area;
		static var areas:Array;
		public var buttons:Array;

		public function GameBoard(){
			okayButton.visible = false;
		hunt = new Area("hunt", 0, 40);
		wood = new Area("wood",1, 7);
		clay = new Area("clay",2, 7);
		stone = new Area("stone",3, 7);
		gold = new Area("gold",4, 7);
		farm = new Area("farm",5, 1);
		hut = new Area("hut",0, 2);
		tools = new Area("tools",0, 1);
		stack1 = new Area("building stack 1",0, 1);
		stack2 = new Area("building stack 2",0, 1);
		stack3 = new Area("building stack 3",0, 1);
		stack4 = new Area("building stack 4",0, 1);
		card1 = new Area("1 resource card", 0, 1);
		card2 = new Area("2 resource card",0, 1);
		card3 = new Area("3 resource card",0, 1);
		card4 = new Area("4 resource card",0, 1);
		if(Game.getPlayerCount() == 3){
				areas = new Array(15);
			} else if(Game.getPlayerCount() == 4){
				areas = new Array(16);
			} else{
				areas = new Array(14);
			}
			areas[0] = hunt;
			areas[1] = wood;
			areas[2] = clay;
			areas[3] = stone;
			areas[4] = gold;
			areas[5] = farm;
			areas[6] = hut;
			areas[7] = tools;
			areas[8] = card1;
			areas[9] = card2;
			areas[10] = card3;
			areas[11] = card4;
			areas[12] = stack1;
			areas[13] = stack2;
			if(Game.getPlayerCount() >= 3){
				areas[14] = stack3;
			}
			if(Game.getPlayerCount() >= 4){
				areas[15] = stack4;
			}
			
			doneButton.visible=false;
			//trace(Game.getPlayerCount());
			buttons = new Array(huntButton, woodButton, brickButton, stoneButton, goldButton, foodButton, hutButton, toolsButton, Game.c1, Game.c2, Game.c3, Game.c4, Game.b1, Game.b2, Game.b3, Game.b4);
			
		}
		public function newRound():void{
			getClick();
			getDone();
		}
		public function getClick():void 
		{
			foodButton.addEventListener( MouseEvent.CLICK, onClickFood );
			toolsButton.addEventListener( MouseEvent.CLICK, onClickTools );
			huntButton.addEventListener( MouseEvent.CLICK, onClickHunt );
			woodButton.addEventListener( MouseEvent.CLICK, onClickWood );
			brickButton.addEventListener( MouseEvent.CLICK, onClickBrick );
			stoneButton.addEventListener( MouseEvent.CLICK, onClickStone );
			goldButton.addEventListener( MouseEvent.CLICK, onClickGold );
			toolsButton.addEventListener( MouseEvent.CLICK, onClickTools );
			hutButton.addEventListener( MouseEvent.CLICK, onClickHut );

		}
		public function getDone():void 
		{
		trace("new round???");
			doneButton.addEventListener( MouseEvent.CLICK, onClickDone );
			undoButton.addEventListener(MouseEvent.CLICK, unDo);
		}
		public function canBeDone():void 
		{
			doneButton.visible=true;
			undoButton.visible=true;
		}
		public function canOkay():void 
		{
			setChildIndex(okayButton,stage.numChildren - 1);
			okayButton.visible=true;
			okayButton.addEventListener( MouseEvent.CLICK, onClickOkay );
		}
		public function cannotDone():void 
		{
			doneButton.visible=false;
			undoButton.visible=false;
		}
		public function notOkay():void 
		{
			okayButton.visible=false;
		}
		public function cannotClickBut(area:Number, left:Number):void 
		{
			for(var i:int = 0; i < buttons.length; i++){
				if(i!=area || areas[i].emptySpots() == 0 || left==0) {
					buttons[i].visible=false;
				} else {
					buttons[i].visible=true;
				}
			}
		}
		public function cannotClick():void 
		{
			for(var i:int = 0; i < buttons.length; i++){
				buttons[i].visible=false;
			}
		}
		public function canClickAll():void 
		{
			for(var i:int = 0; i < buttons.length; i++){
				buttons[i].visible=true;
			}
		}
		public function onClickOkay( event:MouseEvent ):void
		{
			dispatchEvent( new NavigationEvent( NavigationEvent.OKAY) );
		}
		public function onClickHut( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.HUT , 6 ) );
		}
		public function canClick():void 
		{
			for(var i:int = 0; i < buttons.length; i++){
				if(areas[i].emptySpots() > 0) buttons[i].visible=true;
			}
		}
		public function canNewClick(number:Number):void 
		{
			for(var i:int = 0; i < buttons.length; i++){

				if(areas[i].emptySpots() > 0 && !areas[i].hasAlready(number)) {
					buttons[i].visible=true;
				} else {
					buttons[i].visible=false;
				}
				
			}
		}
		public function canActiveClick(number:Number):void 
		{
			for(var i:int = 0; i < buttons.length; i++){
				if(areas[i].hasAlready(number)) {
					buttons[i].visible=true;
				} else {buttons[i].visible=false;}
			}
		}
		public function onClickFood( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.FARM , 5 ) );
		}
		public function onClickHunt( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.HUNT , 0 ) );
			//trace(Game.getFunctionName());
		}
		public function onClickWood( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.WOOD , 1 ) );
		}
		public function onClickBrick( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.BRICK , 2 ) );
		}
		public function onClickStone( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.STONE , 3 ) );
		}
		public function onClickGold( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.GOLD , 4 ) );
		}
		public function onClickC1( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.C1 , 8 ) );
		}
		public function onClickC2( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.C2 , 9 ) );
		}
		public function onClickC3( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.C3 , 10 ) );
		}
		public function onClickC4( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.C4 , 11 ) );
		}
		public function onClickB1( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.B1 , 12 ) );
		}
		public function onClickB2( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.B2 , 13 ) );
		}
		public function onClickB3( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.B3 , 14 ) );
		}
		public function onClickB4( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.B4 , 15 ) );
		}
		public function onClickTools( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new ClickEvent( ClickEvent.TOOLS , 7 ) );
		}
		public function onClickDone( event:MouseEvent ):void
		{
			trace("clicked?");
			dispatchEvent( new NavigationEvent( NavigationEvent.DONE ));
		}
		public function unDo( event:MouseEvent ):void
		{
			//trace("clicked?");
			dispatchEvent( new NavigationEvent( NavigationEvent.OOPS ));
		}
	}
	

	

}