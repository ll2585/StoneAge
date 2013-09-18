package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	public class Player extends MovieClip{
		
		protected var human:Boolean;
		
		var myName:String;
		var startIcon:MovieClip;
		var next:Player;
		var people:int;
		var resource:Array;
		var tools:Array;
		var cards:Array;
		var buildings:Array;
		var points:int;
		var lotteryIndex:Array;
		var foodtrack:int;
		var color:String;
		var number:int;
		var toolsUsed:Array;
		private var toolsTempUsed:Array;
		var numcards:int;
		var chose:Boolean= false;
		var board:PlayerBoard;
		var timer:Timer;
		private var listening:Boolean = false;
		private var payment:Array;
		private var tempArea:Number;
		private var tempRoll:Number;
		private var numChildrenBefore:Number;
		private var toolImageArray:Array;
		private var diceImageArray:Array;
		
		public function Player(pName:String, pNumber:Number){
			human = false;
			board = new PlayerBoard(pName, pNumber);
		this.number = pNumber;
		this.myName = pName;
		numcards = 0;
		resource = new Array(12, 0, 0, 0, 0);
		payment = new Array(0, 0, 0, 0, 0);
		tools = new Array(3);
		tools[0] = 0;
		tools[1] = 0;
		tools[2] = 0;
		cards = new Array();
		/*for(var i:int=0; i < cards.length; i++){
		cards[i] = Card.NIL;
		}
		*/
		buildings = new Array();
		if(number !=1){
		people = 5;
		} else people = 2;
		toolsUsed = new Array(3);
		toolsUsed[1] = false;
		toolsUsed[0] = false;
		toolsUsed[2] = false;
		toolsTempUsed = new Array(3);
		toolsTempUsed[1] = false;
		toolsTempUsed[0] = false;
		toolsTempUsed[2] = false;
		}
		public function takeAction():void {
			timer=new Timer(100,GameBoard.areas.length);
			//tools first
			trace("taking actions, new timer ");
			
			timer.addEventListener(TimerEvent.TIMER,add);
			timer.reset();
			timer.start();
		}
		public function add(event:TimerEvent):void {
			var a:int=timer.currentCount-1;
			/*var nextThumb:Thumbnail = new Thumbnail();
			nextThumb.displayImage = thumbArray[a];
			nextThumb.displayTxt = txtArray[a];
			nextThumb.x = 0;
			nextThumb.y = (a*nextThumb.height)+a*10;
			thumbs.addChild(nextThumb);*/
			trace("the timer is at " + a);
			var notLottery:Boolean = true;
			var toRoll:Boolean = false;
			for(var i:int= 4; i >= 0; i--){
				if(GameBoard.areas[i].hasAlready(number)){
					toRoll = true;
					break;
				} else {
					toRoll = false;
				}
			}
			if(GameBoard.areas[7].hasAlready(number)){
				getTools(1);
				trace(getName() + " got tools");
				dispatchEvent( new ClickEvent( ClickEvent.TOOLS , 7 ) );
			} else {
				if(toRoll){
					for(var i:int= 4; i >= 0; i--){
						if(GameBoard.areas[i].hasAlready(number)){
							trace(getName() + " rolls in " + GameBoard.areas[i].toString());
							airoll(GameBoard.areas[i].getNumber(number), i);
							harvest();
							GameBoard.areas[i].reset(number);
							break;
						}
					}
				} else{
					for(var i:int= 0; i < GameBoard.areas.length; i++){
						trace(getName() + " checking area " + GameBoard.areas[i]);
						if(GameBoard.areas[i].hasAlready(number)){
							if(i == 5){
								getFood();
								trace(getName() + " got food");
								dispatchEvent( new ClickEvent( ClickEvent.FARM , 5 ) );
								GameBoard.areas[i].reset(number);
								break;
							} else if(i==6){
								getKids();
								trace(getName() + " got kids");
								dispatchEvent( new ClickEvent( ClickEvent.HUT , 6 ) );
								GameBoard.areas[i].reset(number);
								break;
							} else if(i>=8 && i < 12){
								var tempCard:Card = Game.cardInfo[Game.boardCards[i-8]];
								trace("buying civ card " + tempCard +  " at location " + i);
								if(willBuyCard(tempCard)){
									if(tempCard.isLottery()){
										trace("it is a lottery!!!");
										timer.stop();
										addEventListener (NavigationEvent.LOTTERYRESUME, lotteryResume);
										notLottery = false;
									}
									dispatchEvent( new ClickEvent( ClickEvent.BUY , i ) );
									withdraw(i);
								} else{
									withdraw(i);
								}
								GameBoard.areas[i].reset(number);
								break;
							} else if(i>=12){//buildings
								var tempCard:Card = Game.buildingInfo[Game.stack[i-12][0]];
								trace("The card is " + tempCard);
								trace("The card type is " + tempCard.getMyType());
								if(tempCard.getMyType()==1 && canBuyType1(tempCard)){
									trace("ai bought a " + tempCard + " at " + i);
									payment = tempCard.cost;
									dispatchEvent (new ClickEvent(ClickEvent.BUY, i));
									withdraw(i);
								} else if(tempCard.getMyType()==3 && willBuyType3()){
									trace("ai bought a type 3 card " + tempCard + " at " + i);
									dispatchEvent (new ClickEvent(ClickEvent.BUY, i));
									withdraw(i);
								} else if(tempCard.getMyType()==2 && willBuyType2(tempCard)){
									trace("ai bought a type 2 card " + tempCard + " at " + i);
									dispatchEvent (new ClickEvent(ClickEvent.BUY, i));
									withdraw(i);
								} else {
									withdraw(i);
								}
								GameBoard.areas[i].reset(number);
								break;
								
							} else {
								GameBoard.areas[i].reset(number);
								withdraw(i);
								break;
							}
						}
					}
				}
			}
			trace("my people placed are " + peoplePlaced());
			if(peoplePlaced()==0&&notLottery){
				trace("stopping timer");
				timer.removeEventListener(TimerEvent.TIMER,add);
				dispatchEvent (new NavigationEvent (NavigationEvent.TURNOVER));
				timer.stop();
			}

		}
		
		public function lotteryResume(e:NavigationEvent){
			timer.start();
		}

					/*					if(i>7&& i < 12){//card1..4, 8 costs 1
						trace(getName() + " tries to buy card " + Game.cardlist[i-8]);
						trace(getName() + " needs " + (i-7) + " resources ");
						var totalres:int= 0;
						for(var j:int= 1; j < resource.length; j++){
							totalres += resource[j];
						}
						if(totalres >= (i-7)){
							buy(Game.cardlist[i-8], i-7);
						}
					}
					if(i>=12){//buildings
						if(canBuy(Card(Game.stack[i-12].top()))){
							buyBuilding(Card(Game.stack[i-12].pop()));
						}
					}
					Board.areas[i].reset(number);
				}
			}
			resetTools();
					
				}
		}
		}
*/
		public function withdraw(area:Number):void {
			switch(area){
				case 8:			
					dispatchEvent( new ClickEvent( ClickEvent.C1 , 8 ) );
					break;
				case 9:
					dispatchEvent( new ClickEvent( ClickEvent.C2 , 9 ) );
					break;
				case 10:
					dispatchEvent( new ClickEvent( ClickEvent.C3 , 10 ) );
					break;
				case 11:
					dispatchEvent( new ClickEvent( ClickEvent.C4 , 11 ) );
					break;
				case 12:			
					dispatchEvent( new ClickEvent( ClickEvent.B1 , 12 ) );
					break;
				case 13:
					dispatchEvent( new ClickEvent( ClickEvent.B2 , 13 ) );
					break;
				case 14:
					dispatchEvent( new ClickEvent( ClickEvent.B3 , 14 ) );
					break;
				default:
					dispatchEvent( new ClickEvent( ClickEvent.B4 , 15 ) );
			}


		}
		public function takeActionAt(area:Number):void {
			if (area==5){//farm
				getFood();
			}
			if(area==6){//hut
				getKids();
			}
			if(area==7){//hut
				getTools(1);
			}
			if(area < 5){
				rollDice(GameBoard.areas[area].getNumber(number), area);
			}
/*			//tools first
			for(var i:int= 0; i < Board.areas.length; i++){
				if(Board.areas[i].hasAlready(number)){
					if(i>7&& i < 12){//card1..4, 8 costs 1
						trace(getName() + " tries to buy card " + Game.cardlist[i-8]);
						trace(getName() + " needs " + (i-7) + " resources ");
						var totalres:int= 0;
						for(var j:int= 1; j < resource.length; j++){
							totalres += resource[j];
						}
						if(totalres >= (i-7)){
							buy(Game.cardlist[i-8], i-7);
						}
					}
					if(i>=12){//buildings
						trace(getName() + " tries to buy a building");
						if(canBuy(Card(Game.stack[i-12].top()))){
							trace(getName() +" will buy");
							buyBuilding(Card(Game.stack[i-12].pop()));
						}
					}
					GameBoard.areas[i].reset(number);
				}
			}
			//resetTools();
			*/
		}
		private function airoll(number2:int, area:int):void{
			trace("my params are " + String(number2) + " and " + String(area));
			switch(area){
				case 0: dispatchEvent( new ClickEvent( ClickEvent.HUNT , 0 ) );
					trace("dispatched new hunt");
					break;
				case 1:dispatchEvent( new ClickEvent( ClickEvent.WOOD , 1 ) );
					trace("dispatched new wood");
					break;
				case 2:dispatchEvent( new ClickEvent( ClickEvent.BRICK , 2 ) );
					trace("dispatched new brick");
					break;
				case 3:dispatchEvent( new ClickEvent( ClickEvent.STONE , 3 ) );
					trace("dispatched new stone");
					break
				default: dispatchEvent( new ClickEvent( ClickEvent.GOLD , 4 ) );
					trace("dispatched new gold");
			}
			roll(number2, area);
		}
		private function rollDice(number2:int, area:int):void{//takes area, number of dice and just displays dice roll
			numChildrenBefore = board.numChildren;
			var resourcecost:int= area+2;
			var diceArray:Array = new Array(number2);
			diceImageArray = new Array(number2);
			var roll:Array = new Array(number2);
			var total:Number = 0;
			for (var i:int=0; i<diceArray.length; i++) {
				roll[i] = Math.floor(Math.random()*6)+1;
				total += roll[i];
				diceArray[i] = Game.getDiceFace(roll[i]);
				diceArray[i].x = -730+38*i;
				diceArray[i].y = 520.05-(number-1)*board.height;
				diceArray[i];
				diceImageArray[i] = diceArray[i];
				board.addChild(diceArray[i]);
			}
			//lotteryIndex[i] = playScreen.getChildIndex(iconArray[i]);
			//trace("did it add? " + lotteryIndex[i]);
			//iconArray[i].addEventListener( MouseEvent.CLICK, clickedArray );
			tempArea = area;
			tempRoll = total;
			displayRoll();
		}
		private function displayRoll():void{
			while(board.numChildren != numChildrenBefore+diceImageArray.length){
				board.removeChildAt(board.numChildren-1);
			}
			var resourcecost:int= tempArea+2;
			var textResult:TextField = new TextField();
			var myFormat:TextFormat = new TextFormat();
			myFormat.font = "Verdana";
			myFormat.size = 25;
			textResult.defaultTextFormat =myFormat;
			textResult.selectable = false;
			textResult.width = 1000;
			toolImageArray = new Array(3);
			for(var i:Number=0; i < tools.length; i++){
				if(tools[i]>0 && !toolsTempUsed[i] && !toolsUsed[i]){
					var tempTool:MovieClip = new MovieClip();
					tempTool.addChild(DocumentClass.clone(Game.icons[tools[i]+12]));
					tempTool.x = -728+35*i;
					tempTool.y = 580.05-(number-1)*board.height;
					tempTool.buttonMode = true;
					board.addChild(tempTool);
					tempTool.addEventListener( MouseEvent.CLICK, toolSelected );
					toolImageArray[i] = tempTool;
				} else if(tools[i]>0 && toolsTempUsed[i] && !toolsUsed[i]){
					var tempTool:MovieClip = new MovieClip();
					tempTool.addChild(DocumentClass.clone(Game.icons[tools[i]+18]));
					tempTool.x = -728+35*i;
					tempTool.y = 580.05-(number-1)*board.height;
					tempTool.buttonMode = true;
					board.addChild(tempTool);
					tempTool.addEventListener( MouseEvent.CLICK, toolunSelected );
					toolImageArray[i] = tempTool;
				}else if(tools[i]>0 && toolsUsed[i]){
					var tempTool:MovieClip = new MovieClip();
					tempTool.addChild(DocumentClass.clone(Game.icons[tools[i]+18]));
					tempTool.x = -728+35*i;
					tempTool.y = 580.05-(number-1)*board.height;
					board.addChild(tempTool);
					toolImageArray[i] = tempTool;
				}
			}
			trace(textResult.text);
			textResult.text = " = " + String(tempRoll) + " / " + String(resourcecost) + " = " + String(Math.floor(tempRoll/resourcecost));
			textResult.width = textResult.textWidth+50;
			trace(diceImageArray);
			textResult.height = textResult.textHeight;
			textResult.x = -730+38*diceImageArray.length;
			textResult.y = 520.05-(number-1)*board.height;
			board.addChild(textResult);
			var icon:Bitmap = DocumentClass.clone(Game.icons[tempArea]);
			icon.x = textResult.x + textResult.textWidth + 5;
			icon.y = textResult.y;
			board.addChild(icon);
		}
		private function roll(number2:int, area:int):void{
			var resourcecost:int= area+2;
			numChildrenBefore = board.numChildren;
			//trace(numChildrenBefore);
			var diceArray:Array = new Array(number2);
			var roll:Array = new Array(number2);
			var total:Number = 0;
			var textResult:TextField = new TextField();
			var myFormat:TextFormat = new TextFormat();
			myFormat.font = "Verdana";
			myFormat.size = 25;

			for (var i:int=0; i<diceArray.length; i++) {
				roll[i] = Math.floor(Math.random()*6)+1;
				total += roll[i];
				diceArray[i] = Game.getDiceFace(roll[i]);
				diceArray[i].x = -730+38*i;
				diceArray[i].y = 520.05-(number-1)*board.height;
				board.addChild(diceArray[i]);
			}
			textResult.defaultTextFormat =myFormat;
			textResult.selectable = false;
			textResult.width = 1000;
			toolImageArray = new Array(3);
			for(i=0; i < tools.length; i++){
				if(tools[i]>0){
					var tempTool:MovieClip = new MovieClip();
					tempTool.addChild(DocumentClass.clone(Game.icons[tools[i]+12]));
					tempTool.x = -728+35*i;
					tempTool.y = 580.05-(number-1)*board.height;
					tempTool.buttonMode = true;
					trace(tempTool.x);
					board.addChild(tempTool);
					tempTool.addEventListener( MouseEvent.CLICK, toolSelected );
					toolImageArray[i] = tempTool;
				}
			}
			//lotteryIndex[i] = playScreen.getChildIndex(iconArray[i]);
			//trace("did it add? " + lotteryIndex[i]);
			//iconArray[i].addEventListener( MouseEvent.CLICK, clickedArray );
			
			textResult.text = " = " + String(total) + " / " + String(resourcecost) + " = " + String(Math.floor(total/resourcecost));
			textResult.width = textResult.textWidth+50;
			textResult.height = textResult.textHeight;
			textResult.x = -730+38*diceArray.length;
			textResult.y = 520.05-(number-1)*board.height;
			board.addChild(textResult);
			var icon:Bitmap = DocumentClass.clone(Game.icons[area]);
			icon.x = textResult.x + textResult.textWidth + 5;
			icon.y = textResult.y;
			board.addChild(icon);
			tempArea = area;
			tempRoll = total;
			
			//roll1234
			
			
			//var finalresult:int= usetools(result, resource);
			//this.resource[resource] += finalresult / resourcecost;
		}
		private function toolSelected(e:MouseEvent):void{
			var toolChose:Number = mouseX;
			toolChose = Math.floor(toolChose/38)+1;
			trace("tool chosen " + toolChose);
			toolsTempUsed[toolChose-1] = true;
			tempRoll += tools[toolChose-1];
			displayRoll();
		}
		private function toolunSelected(e:MouseEvent):void{
			var toolChose:Number = mouseX;
			toolChose = Math.floor(toolChose/38)+1;
			trace("tool chosen " + toolChose);
			toolsTempUsed[toolChose-1] = false;
			tempRoll -= tools[toolChose-1];
			displayRoll();
		}

		public function addCard(c:Card):void{
			trace("adding card " + c);
			if(c.isCiv()){
				cards.push(c);
				board.setCards(cards);
				getBenefit(c);
			} else{
				buildings.push(c);
				board.setBuildings(buildings);
			}
		}
		public function getPayment():Array{
			return payment;
		}
		public function pay(a:Array):void{
			for(var i:int; i < resource.length; i++){
				resource[i] -=a[i];
			}
		}
		public function scorePoints(a:Array):void{
			var toScore:int= 0;
			for(var i:int= 0; i < a.length; i++){
				toScore += (i+2)*(a[i]);
			}
			points += toScore;
		}
		public function getPoints(n:Number):void{
			trace("getting " + n);
			points+= n;
			updateCount();
		}
		public function buyBuilding(c:Card):void{
			points+= c.points(c.getCost());
			updateCount();
		}
		public function canBuyType1(c:Card):Boolean{
			trace("my resources are " + resource);
			trace("the card cost is " + c.getCost());
			for(var i = 0; i < resource.length; i++){
				if( resource[i] - c.getCost()[i] < 0) {
					trace("don't have enough of " + i);
					return false;
				}
			}
			return true;
		}
		public function willBuyType3():Boolean{
			var tempPayment = new Array(0,0,0,0,0);
			var willBuy:Boolean = false;
			var totalRes:Number = 0;
			for(var i = resource.length-1; i >=0; i--){
				var tempAmt:Number = resource[i];
				while(tempAmt!=0&&totalRes != 7){
					tempPayment[i]++;
					tempAmt--;
					totalRes++;
				}
				if(totalRes==7){
					willBuy = true;
					break;
				}
			}
			if(willBuy){
			trace(getName() + " will buy this 7cost card with " + tempPayment);
				payment = tempPayment;
				return true;
			}else{
			return false;
			}
		}
		public function willBuyCard(c:Card):Boolean{
			var cost:Number = c.getTotal(); //the cost
			var tempPayment = new Array(0,0,0,0,0);
			var willBuy:Boolean = false;
			var totalRes:Number = 0;
			for(var i = 0; i < resource.length; i--){
				var tempAmt:Number = resource[i];
				while(tempAmt!=0&&totalRes != cost){
					tempPayment[i]++;
					tempAmt--;
					totalRes++;
				}
				if(totalRes==cost){
					willBuy = true;
					break;
				}
			}
			if(willBuy){
			trace(getName() + " will buy this civ card with " + tempPayment);
				payment = tempPayment;
				return true;
			}else{
			return false;
			}
		}
		public function willBuyType2(c:Card):Boolean{
			var totalCost:Number = c.getTotal();
			var unique:Number = c.getUniqueAmt();
			var tempPayment = new Array(0,0,0,0,0);
			var willBuy:Boolean = false;
			var totalRes:Number = 0;
			var totalUnique:Number = 0;

			for(var i = resource.length-1; i >=0; i--){
				var tempAmt:Number = resource[i];
				if(resource[i]!=0) totalUnique++;
				while(tempAmt!=0&&totalRes != totalCost&&totalUnique<=unique&&(totalCost-totalRes>unique-totalUnique)){
					tempPayment[i]++;
					tempAmt--;
					totalRes++;
				}
				if(totalRes==totalCost){
					willBuy = true;
					break;
				}
			}
			if(willBuy){
			trace(getName() + " will buy this type 2 card " + c.toString() + " with " + tempPayment);
				payment = tempPayment;
				return true;
			}else{
			return false;
			}
		}
		public function getDice(n:Number):void{
			chose = true;
			trace("you chosde dice " + n);
			var dice:Number = n;
			if(Game.lotteryRoll[n-1] < 5){
				resource[Game.lotteryRoll[n-1]]++;
			} else if(Game.lotteryRoll[n-1] == 5){
				getTools(1);
			} else if(Game.lotteryRoll[n-1] == 6){
				getFood();
			}
			updateCount();
			Game.lotteryRoll[n-1] = 0;

		}
		public function waitForLottery():void{
			trace("waiting");
			addEventListener( ClickEvent.LOTTERY, blah );
		}
		public function iChose(diceChose:Number):void{
			trace(getName() + " chose!");
			dispatchEvent( new ClickEvent(ClickEvent.LOTTERY, diceChose));
			removeEventListener( ClickEvent.LOTTERY, blah );
		}
		private function blah (e:ClickEvent):void{
			trace("blah");
			//getDice(e.area);
			dispatchEvent( new ClickEvent(ClickEvent.CHOSE, e.area ));//removes the icons
			getDice(e.area);//gets my stuff
			trace("I am " + getName() + " and the next to choose is " + next.getName());
			next.chooseLottery();//next person chooses
		}
		
		public function chooseLottery():void{
			var allres:Number = 0;
			for(var i:int= 0; i < Game.lotteryRoll.length; i++){
				if(Game.lotteryRoll[i] > 0){
					allres = 999;
					break;
				}
				else{
					allres = -99;
				}
			}
			trace("time for " + getName() + " to choose lots, what is allres and chose and human? " + allres + " " + chose + " " + human);
			if(allres!=0){
				if(!chose&&!human){
					trace("time to choose?");
					for(var i:int= 0; i < Game.lotteryRoll.length; i++){
						if(Game.lotteryRoll[i]==6&&foodtrack!=10){
							trace(getName() + " chooses the 6 and goes up on food");
							getFood();
							Game.lotteryRoll[i]=0;
							chose=true;
							dispatchEvent( new ClickEvent(ClickEvent.CHOSE, i+1));
							getDice(i+1);//gets my stuff
							next.chooseLottery();//next person chooses
							break;
						}
					}
				}
				if(!chose&&!human){
					for(var i:int= 0; i < Game.lotteryRoll.length; i++){
						if(Game.lotteryRoll[i]==5&&tools[2]!=4){
							trace(getName() + " chooses the 5 and gets a tool");
							getTools(1);
							Game.lotteryRoll[i]=0;
							chose=true;
							dispatchEvent( new ClickEvent(ClickEvent.CHOSE, i+1));
							getDice(i+1);//gets my stuff
							next.chooseLottery();//next person chooses
							break;
						}
					}
				}
				if(!chose&&!human){
					
					for(var i:int= 0; i < Game.lotteryRoll.length; i++){
						if(Game.lotteryRoll[i]==4){
							trace(getName() + " chooses the 4 and gets a gold");
							resource[4]++;
							Game.lotteryRoll[i]=0;
							chose=true;
							dispatchEvent( new ClickEvent(ClickEvent.CHOSE, i+1));
							getDice(i+1);//gets my stuff
							next.chooseLottery();//next person chooses
							break;
						}
					}
				}
				if(!chose&&!human){
					for(var i:int= 0; i < Game.lotteryRoll.length; i++){
						if(Game.lotteryRoll[i]==3){
							trace(getName() + " chooses the 3 and gets a stone");
							resource[3]++;
							Game.lotteryRoll[i]=0;
							chose=true;
							dispatchEvent( new ClickEvent(ClickEvent.CHOSE, i+1));
							getDice(i+1);//gets my stuff
							next.chooseLottery();//next person chooses
							break;
						}
					}
				}
				if(!chose&&!human){
					for(var i:int= 0; i < Game.lotteryRoll.length; i++){
						if(Game.lotteryRoll[i]==2){
							trace(getName() + " chooses the 2 and gets a clay");
							resource[2]++;
							Game.lotteryRoll[i]=0;
							chose=true;
							dispatchEvent( new ClickEvent(ClickEvent.CHOSE, i+1));
							getDice(i+1);//gets my stuff
							next.chooseLottery();//next person chooses
							break;
						}
					}
				}
				if(!chose&&!human){
					for(var i:int= 0; i < Game.lotteryRoll.length; i++){
						if(Game.lotteryRoll[i]==1){
							trace(getName() + " chooses the 1 and gets a wood");
							resource[1]++;
							Game.lotteryRoll[i]=0;
							chose=true;
							dispatchEvent( new ClickEvent(ClickEvent.CHOSE, i+1));
							getDice(i+1);//gets my stuff
							next.chooseLottery();//next person chooses
							break;
						}
					}
				}
			} else{
				trace("all chose and you are a human, so we done");
				dispatchEvent(new NavigationEvent(NavigationEvent.ALLCHOSE));
			}
		}
		protected function getBenefit(card:Card):void {
			if(card.isResource()) {
				trace(getName() + " gets " + card.resourceAmount() + " " +Card.getResource(card.resourceType()));
				resource[card.resourceType()] += card.resourceAmount();
			}
			if(card.addBonus()){
				if(card.bonusType()==0) {					
					foodtrack+=card.bonusAmount();
					trace(getName() + " advances on food to " + foodtrack);
				}
				if(card.bonusType()==1) {
					trace(getName() + " gets a free tool");
					getTools(card.bonusAmount());
				}
			}
			if(card.isRoll()){
				if(isHuman()){
				trace(getName() + " gets to roll " + card.RollAmount() + " dice for " + Card.getResource(card.RollType()));
				roll(card.RollAmount(), card.RollType());
				}
				else{
				trace(getName() + " gets to roll " + card.RollAmount() + " dice for " + Card.getResource(card.RollType()));
					roll(card.RollAmount(), card.RollType());
					trace("the temp roll is " + tempRoll);
					harvest();
				}
			}
/*			if(card.isLottery()){
				trace(getName() + " has a lottery roll!");
				
			}*/
		}

		public function unchoose():void{
			chose = false;
		}
		public function harvest():void{
			while(board.numChildren != numChildrenBefore){
				board.removeChildAt(board.numChildren-1);
			}
			for(var i:Number = 0; i < toolsTempUsed.length; i++){
				if(toolsTempUsed[i]) {
					toolsUsed[i] = true;
					toolsTempUsed[i] = false;
				}
			}
			resource[tempArea] += Math.floor(tempRoll/(tempArea+2));
			
		}
		
		function getName():String{
			return myName;
		}
		public function isHuman():Boolean{
			return human;
		}
		
		function getNumber():Number{
			return number;
		}
		
		function getBoard():PlayerBoard{
			return board;
		}
		
		public function setNext(player:Player):void{
		next = player;
		}
		
		public function setStart():void{
			startIcon = Game.icons[5];
			startIcon.x = 195;
			startIcon.y = 48;
			board.addChild(startIcon);
		}
		public function loseStart():void{
			board.removeChild(startIcon);
		}
		public function feed():void{
			resource[0] = resource[0] + foodtrack - people;
			if(resource[0] < 0){
				resource[0] = 0;
				trace("Starving, points were " + points);
				starve();
			}
		}
		public function giveResource(number:Number, amt:Number):void{
			resource[number] += amt;
			board.updateCounts();
		}
		public function loseResource(number:Number, amt:Number):void{
			resource[number] -= amt;
			board.updateCounts();
		}
		private function starve():void{
			points -= 10;
			trace("points are now " + points);
		}
		public function getResource(i:Number):Number{
			return resource[i];
		}
		public function getNext():Player{
			return this.next;
		}
		public function workersLeft():int{
			return people - peoplePlaced();
		}
		public function peoplePlaced():int{

			var result:int= 0;
			for(var i:int= 0; i < GameBoard.areas.length; i++){
				result += GameBoard.areas[i].getNumber(number);
			}
			return result;
		}
		public function place():Array {
			var toPlace:Array;
			var number:Number= new Number(); 
			var area:int;
			/*if(GameBoard.areas[5].emptySpots()>0){
				GameBoard.areas[5].place(this.number, 1);
			}else if(GameBoard.areas[7].emptySpots()>0){
				GameBoard.areas[7].place(this.number, 1);
			}else if(canBuyBuildingi()!=-1&&Board.areas[canBuyBuildingi()+12].emptySpots()>0){
				Board.areas[canBuyBuildingi()+12].place(this.number, 1);
				trace(getName() + " will place " + 1+ " to build " + Game.stack[canBuyBuildingi()].top());
			}else if(canBuyCardi()!=-1&&Board.areas[canBuyCardi()+8].emptySpots()>0){
				Board.areas[canBuyCardi()+8].place(this.number, 1);
				trace(getName() + " will place " + 1+ " to get the " + Game.cardlist[canBuyCardi()]);
			}else{*/
				do{
					area = Math.floor(Math.random()*GameBoard.areas.length);
				} while(GameBoard.areas[area].emptySpots()==0||
					GameBoard.areas[area].hasAlready(this.number)||
					(area==6&& workersLeft()<2)||
					(area==6&& people==10)||
					(area==7&& tools[2]==4)||
					(area==5&& foodtrack==10));
				var toplace:int;
				
				do{
					toplace = Math.floor(Math.random()*workersLeft())+1;
				} while(toplace > GameBoard.areas[area].emptySpots()&&area!=6);
				if(area==6) toplace=2;
				trace(getName() + " will place " + toplace + " in the " + GameBoard.areas[area] + ", and there are " + GameBoard.areas[area].emptySpots() + " spots left");
				toPlace = new Array(area, this.number, toplace);
				return toPlace;
			//}
		}
		
		public function getFood():void{
			foodtrack++;
			updateCount();
		}
		
		public function goListen():void{
			listening = true;
		}
		public function readyToListen():Boolean{
			return listening;
		}
		public function noListen():void{
			listening = false;
		}
		public function getTools(i:int):void{
			var times:int= i;
			var totaltools:int=0;
			while(times>0){
				if(tools[2]==tools[0]) {
					tools[0]++;
				}
				else if(tools[0]>tools[1]) { tools[1]++; }
				else if(tools[0]==tools[1]) {tools[2]++;}
				for(var j:int=0;j<tools.length;j++)
					totaltools+=tools[j];
				times--;
			}						
		}
		public function getKids():void{
			people++;
		}
		public function updateCount():void{
			board.setResources(resource);
			board.setIncome(foodtrack);
			board.setPeople(people, workersLeft());
			board.setTools(tools);
			board.setCards(cards);
			board.setBuildings(buildings);
			board.setPoints(points);
			board.updateCounts();
		}
		public function resetTools():void{
			trace("Resetting tools");
			toolsUsed[1] = false;
			toolsUsed[0] = false;
			toolsUsed[2] = false;
		}
		/*
		
		private function canBuyCardi():int{
		for(var i:int= 0; i < Game.cardlist.length; i++){
		if(canBuy(Card(Game.cardlist[i]))) return i;
		}
		return -1;
		}
		
		private function canBuyBuildingi():int{
		for(var i:int= 0; i < Game.stack.length; i++){
		if(canBuy(Card(Game.stack[i].top()))) return i;
		}
		return -1;
		}
		
		public function takeAction():voidthrows IOException {
		//tools first
		if(Board.areas[7].hasAlready(number)){
		getTools(1);
		}
		for(var i:int= 4; i >= 0; i--){
		if(Board.areas[i].hasAlready(number)){
		trace(getName() + " is rolling in " +Board.areas[i]);
		roll(Board.areas[i].getNumber(number), i);
		}
		}
		for(var i:int= 0; i < Board.areas.length; i++){
		if(Board.areas[i].hasAlready(number)){
		if(i < 5){
		//trace(getName() + " is rolling in " +Board.areas[i]);
		//roll(Board.areas[i].getNumber(number), i);
		}
		if(i == 5){//farm
		getFood();
		}
		if(i==6){//hut
		getKids();
		}
		if(i==7){//tools
		//done above;
		}
		if(i>7&& i < 12){//card1..4, 8 costs 1
		trace(getName() + " tries to buy card " + Game.cardlist[i-8]);
		trace(getName() + " needs " + (i-7) + " resources ");
		var totalres:int= 0;
		for(var j:int= 1; j < resource.length; j++){
		totalres += resource[j];
		}
		if(totalres >= (i-7)){
		buy(Game.cardlist[i-8], i-7);
		}
		}
		if(i>=12){//buildings
		trace(getName() + " tries to buy a building");
		if(canBuy(Card(Game.stack[i-12].top()))){
		trace(getName() +" will buy");
		buyBuilding(Card(Game.stack[i-12].pop()));
		}
		}
		Board.areas[i].reset(number);
		}
		}
		resetTools();
		}
		
		
		protected function resetTools():void{
		toolsUsed[1] = false;
		toolsUsed[0] = false;
		toolsUsed[2] = false;
		}
		
		private function buyBuilding(card:Card):void{
		var i:int= card.type();
		var payment:Array= new int[5];
		for(var m:int=0; m < payment.length; m++){
		payment[m]=0;
		}
		switch(i){
		case 1:{
		for(var j:int= 0; j < resource.length; j++){
		if(card.getCost()[j] >= resource[j]){
		resource[j]-=card.getCost()[j];
		payment[j] +=card.getCost()[j];
		}
		}
		points += card.points(payment);
		break;
		}
		case 2:{
		var done:Boolean= false;
		var needtotal:int= card.getAttribute(0);
		var needunique:int= card.getAttribute(1);
		var mytotal:int= 0;
		//1 unique
		switch(needunique){
		case 1: {
		mytotal = 0;
		for(var m:int=resource.length-1; m >0; m--){
		if(resource[m]>=needtotal&&resource[m]>0&&!done){
		resource[m] --;
		payment[m] ++;
		mytotal = 4;
		while(mytotal<needtotal){
		if(resource[m]>0){
		resource[m] --;
		payment[m] ++;
		mytotal++;
		}
		}
		done = true;
		}
		}
		break;
		}
		case 2:{
		mytotal = 0;
		for(var m:int=resource.length-1; m >0; m--){
		for(var n:int=resource.length-1; n >0; n--){
		if(n!=m && n<m){
		if(resource[m]+resource[n]>=needtotal&&resource[m]>0&&resource[n]>0&&!done){
		resource[m] --;
		resource[n] --;
		payment[m] ++;
		payment[n] ++;
		mytotal = 4;
		while(mytotal<needtotal){
		if(resource[m]>0){
		resource[m] --;
		payment[m] ++;
		mytotal++;
		} else if(resource[n]>0){
		resource[n] --;
		payment[n] ++;
		mytotal++;
		}
		}
		done = true;
		}
		}
		}
		}
		break;
		}
		case 3:{
		mytotal = 0;
		for(var m:int=resource.length-1; m >0; m--){
		for(var n:int=resource.length-1; n >0; n--){
		for(var o:int=resource.length-1; o >0; o--){
		if(n!=m && n<m && n!=o && o<n && o!=m && o<m){
		if(resource[m]+resource[n]+resource[o]>=needtotal&&resource[m]>0&&resource[n]>0&&resource[o]>0&&!done){
		resource[m] --;
		resource[n] --;
		resource[o] --;
		payment[m] ++;
		payment[n] ++;
		payment[o] ++;
		mytotal = 4;
		while(mytotal<needtotal){
		if(resource[m]>0){
		resource[m] --;
		payment[m] ++;
		mytotal++;
		} else if(resource[n]>0){
		resource[n] --;
		payment[n] ++;
		mytotal++;
		} else if(resource[o]>0){
		resource[o] --;
		payment[o] ++;
		mytotal++;
		}
		}
		done = true;
		}
		}
		}
		}
		}
		break;
		}
		default:{
		mytotal = 0;
		for(var m:int=resource.length-1; m >0; m--){
		for(var n:int=resource.length-1; n >0; n--){
		for(var o:int=resource.length-1; o >0; o--){
		for(var p:int=resource.length-1; p >0; p--){
		if(n!=m && n<m && n!=o && o<n && o!=m && o<m && p!=m && p<m && p!=n && p<n && p!=o && p<o){
		if(resource[m]+resource[n]+resource[o]+resource[p]>=needtotal&&resource[m]>0&&resource[n]>0&&resource[o]>0&&resource[p]>0&&!done){
		resource[m] --;
		resource[n] --;
		resource[o] --;
		resource[p] --;
		payment[m] ++;
		payment[n] ++;
		payment[o] ++;
		payment[p] ++;
		mytotal = 4;
		while(mytotal<needtotal){
		if(resource[m]>0){
		resource[m] --;
		payment[m] ++;
		mytotal++;
		} else if(resource[n]>0){
		resource[n] --;
		payment[n] ++;
		mytotal++;
		} else if(resource[o]>0){
		resource[o] --;
		payment[o] ++;
		mytotal++;
		} else if(resource[p]>0){
		resource[p] --;
		payment[p] ++;
		mytotal++;
		}
		}
		done = true;
		}
		}
		}
		}
		}
		}
		break;
		}
		}
		}
		//2 unique
		default:{
		var topay:int= 7;
		var mytotal:int= 0;
		for(var m:int=resource.length-1; m >0; m--){
		if(resource[m]>=topay && mytotal<8){
		mytotal+=topay;
		payment[m]=topay;
		resource[m]-=topay;
		}
		else if (mytotal<8){
		payment[m]=resource[m];
		resource[m]-=payment[m];
		mytotal += payment[m];
		topay -= payment[m];
		}
		}
		break;
		}
		}
		buildings.push(card);
		points += card.points(payment);
		trace(getName() + " now has " + points + " points.");
		}
		
		private function canBuy(card:Card):Boolean{
		var i:int= card.type();
		switch(i){
		case 1:{
		for(var j:int= 1; j < resource.length; j++){
		if(card.getCost()[j] > resource[j]) return false;
		}
		return true;
		}
		case 2:{
		var needtotal:int= card.getAttribute(0);
		var needunique:int= card.getAttribute(1);
		var payment:Array= new int[5];
		for(var m:int=0; m < payment.length; m++){
		payment[m]=0;
		}
		//1 unique
		switch(needunique){
		case 1: {
		for(var m:int=resource.length-1; m >0; m--){
		if (resource[m] >= needtotal) return true;
		}
		return false;
		}
		case 2:{
		for(var m:int=resource.length-1; m >0; m--){
		for(var n:int=resource.length-1; n >0; n--){
		if(n!=m && n<m){
		if(resource[m]+resource[n]>=needtotal&&resource[m]>0&&resource[n]>0){
		return true;
		}
		}
		}
		}
		return false;
		}
		case 3:{
		for(var m:int=resource.length-1; m >0; m--){
		for(var n:int=resource.length-1; n >0; n--){
		for(var o:int=resource.length-1; o >0; o--){
		if(n!=m && n<m && n!=o && o<n && o!=m && o<m){
		if(resource[m]+resource[n]+resource[o]>=needtotal&&resource[m]>0&&resource[n]>0&&resource[o]>0){
		return true;
		}
		}
		}
		}
		}
		return false;
		}
		default:{
		for(var m:int=resource.length-1; m >0; m--){
		for(var n:int=resource.length-1; n >0; n--){
		for(var o:int=resource.length-1; o >0; o--){
		for(var p:int=resource.length-1; p >0; p--){
		if(n!=m && n<m && n!=o && o<n && o!=m && o<m && p!=m && p<m && p!=n && p<n && p!=o && p<o){
		if(resource[m]+resource[n]+resource[o]+resource[p]>=needtotal&&resource[p]>0&&resource[m]>0&&resource[n]>0&&resource[o]>0){
		return true;
		}
		}
		}
		}
		}
		}
		return false;
		}
		}
		}
		//2 unique
		default:{
		var mytotal:int= 0;
		for(var m:int=resource.length-1; m > 0; m--){
		mytotal+=resource[m];
		}
		return mytotal >= 1;
		}
		}
		}
		
		protected function buy(card:Card, total:int):voidthrows IOException {
		trace(getName() + " must pay " + total + " total");
		var topay:int= 0;
		var payment:Array= new int[5];
		for(var i:int=1; i < payment.length; i++){
		payment[i]=0;
		}
		var buy:Boolean= false;
		trace(getName() + " has " + convertToResource(resource) + ".");
		
		for(var i:int=1; i < resource.length; i++){
		if(!buy){
		if(resource[i] + topay >= total){
		payment[i] = total-topay;
		buy = true;
		} else {
		payment[i] = resource[i];
		topay += resource[i];
		}
		}
		}
		if(buy){
		trace(getName() + " pays " + convertToResource(payment) + ".");
		for(var i:int=1; i < resource.length; i++){
		resource[i] -= payment[i];
		}
		cards[numcards] = card;
		getBenefit(card);
		numcards++;
		Game.cardlist[total-1] = Card.NIL;
		}
		}
		
		protected function convertToResource(payment:Array):String{
		var result:String= "";
		for(var i:int= 1; i < payment.length; i++){
		if(payment[i]>0)
		result += payment[i] + " " + Card.getResource(i) + ", ";
		}
		if(result.length()>0) result = result.substring(0, result.length()-2);
		return result;
		}
		
		protected function getBenefit(card:Card):voidthrows IOException {
		if(card.isResource()) {
		trace(getName() + " gets " + card.resourceAmount() + " " +Card.getResource(card.resourceType()));
		resource[card.resourceType()] += card.resourceAmount();
		}
		if(card.addBonus()){
		if(card.bonusType()==0) {
		
		foodtrack+=card.bonusAmount();
		trace(getName() + " advances on food to " + foodtrack);
		}
		if(card.bonusType()==1) {
		trace(getName() + " gets a free tool");
		getTools(card.bonusAmount());
		}
		}
		if(card.isRoll()){
		trace(getName() + " gets to roll " + card.RollAmount() + " dice for " + Card.getResource(card.RollType()));
		roll(card.RollType(), card.RollAmount());
		}
		if(card.isLottery()){
		trace(getName() + " has a lottery roll!");
		rollLottery();
		}
		}
		
		private function rollLottery():voidthrows IOException {
		var number:Random= new Random(); 
		var number2:int= Game.players.length;
		var results:Array= new int[number2];
		var toprint:String= "";
		toprint += getName() + " rolls a ";
		for (var i:int=0; i<number2; i++) {
		var dice:int= number.nextInt(6)+1;
		results[i] = dice;
		toprint += dice + ",";
		}
		trace(toprint);
		for(var i:int= 0; i < Game.players.length; i++){
		Game.players[i].unchoose();
		}
		chooseLottery(results);
		}
		
		private function unchoose():void{
		chose = false;
		}
		
		protected function chooseLottery(results:Array):voidthrows IOException {
		var allres:int= 0;
		var tosend:Array= new int[results.length];
		for(var i:int= 0; i < results.length; i++){
		allres += results[i];
		tosend[i] = results[i];
		}
		if(allres!=0){
		if(!chose){
		for(var i:int= 0; i < results.length; i++){
		if(results[i]==6&&foodtrack!=10){
		trace(getName() + " chooses the 6 and goes up on food");
		foodtrack++;
		tosend[i]=0;
		chose=true;
		next.chooseLottery(tosend);
		break;
		}
		}
		}
		if(!chose){
		
		for(var i:int= 0; i < results.length; i++){
		if(results[i]==5&&tools[2]!=4){
		trace(getName() + " chooses the 5 and gets a tool");
		getTools(1);
		tosend[i]=0;
		chose=true;
		next.chooseLottery(tosend);
		break;
		}
		}
		}
		if(!chose){
		
		for(var i:int= 0; i < results.length; i++){
		if(results[i]==4){
		trace(getName() + " chooses the 4 and gets a gold");
		resource[4]++;
		tosend[i]=0;
		chose=true;
		next.chooseLottery(tosend);
		break;
		}
		}
		}
		if(!chose){
		for(var i:int= 0; i < results.length; i++){
		if(results[i]==3){
		trace(getName() + " chooses the 3 and gets a stone");
		resource[3]++;
		tosend[i]=0;
		chose=true;
		next.chooseLottery(tosend);
		break;
		}
		}
		}
		if(!chose){
		for(var i:int= 0; i < results.length; i++){
		if(results[i]==2){
		trace(getName() + " chooses the 2 and gets a clay");
		resource[2]++;
		tosend[i]=0;
		chose=true;
		next.chooseLottery(tosend);
		break;
		}
		}
		}
		if(!chose){
		for(var i:int= 0; i < results.length; i++){
		if(results[i]==1){
		trace(getName() + " chooses the 1 and gets a wood");
		resource[1]++;
		tosend[i]=0;
		chose=true;
		next.chooseLottery(tosend);
		break;
		}
		}
		}
		}
		}
		
		private function roll(number2:int, resource:int):void{
		var resourcecost:int= resource+2;
		var number:Random= new Random(); 
		var result:int= 0;
		trace(getName() + " rolls " + number2 + " dice");
		for (var i:int=0; i<number2; i++) {
		var dice:int= number.nextInt(6)+1;
		result += dice;
		}
		trace(getName() + " rolls a " + result);
		var finalresult:int= usetools(result, resource);
		trace(getName() + " gets " + (finalresult / resourcecost));
		this.resource[resource] += finalresult / resourcecost;
		}
		
		private function usetools(roll:int, resource:int):int{
		var totaltools:int= 0;
		for(var i:int= 0; i < tools.length; i++){
		totaltools+= tools[i];
		}
		switch(totaltools){
		case 1: {
		trace("I rolled a "+roll + " for a " + Card.getResource(resource) + " and do I get more? " + getMore(roll, totaltools, resource) + " but is my tool used? " + toolsUsed[0]);
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		return roll;
		}
		case 2: {
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 3: {
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		return roll;
		}
		case 4: {//211
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		return roll;
		}
		case 5: {//221
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 6: {//222
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 7: {//322
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 8: {//332
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[1]&& !toolsUsed[2]) {
		return roll+useTool(1)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 9: {//333
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 8, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[1]&& !toolsUsed[2]) {
		return roll+useTool(1)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 10: {//433
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 9, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 8, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[1]&& !toolsUsed[2]) {
		return roll+useTool(1)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 11: {//443
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 10, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 9, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 8, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}			
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[1]&& !toolsUsed[2]) {
		return roll+useTool(1)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		case 12: {//444
		if(getMore(roll, totaltools, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 11, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 10, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 9, resource) && !toolsUsed[0]&& !toolsUsed[1]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(1)+useTool(2);
		}
		if(getMore(roll, 8, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 8, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 8, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 7, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 6, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 5, resource) && !toolsUsed[1]&& !toolsUsed[2]) {
		return roll+useTool(1)+useTool(2);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 4, resource) && !toolsUsed[0]&& !toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&& !toolsUsed[1]) {
		return roll+useTool(0)+useTool(1);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[0]&&!toolsUsed[2]) {
		return roll+useTool(0)+useTool(2);
		}
		if(getMore(roll, 3, resource) && !toolsUsed[2]&& !toolsUsed[1]) {
		return roll+useTool(2)+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 2, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[2]) {
		return roll+useTool(2);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[0]) {
		return roll+useTool(0);
		}
		if(getMore(roll, 1, resource) && !toolsUsed[1]) {
		return roll+useTool(1);
		}
		return roll;
		}
		default: {
		trace(getName() + " does not use any tool.");
		return roll;
		}
		}
		
		}
		
		
		public function useTool(i:int):int{
		trace(getName() + " uses his tool " + (i+1) + " which adds " + tools[i]);
		toolsUsed[i] = true;
		return tools[i];
		}
		
		private function getMore(roll:int, toAdd:int, resource:int):Boolean{
		var resourcecost:int= resource+2;
		var original:int= roll/resourcecost;
		var withuse:int= (roll+toAdd)/resourcecost;
		return withuse>original;
		}
		
		public function calculatePoints():void{
		points += cardPoints();
		}
		
		private function cardPoints():int{
		var result:int= 0;
		var multipliers:Array= new int[4];
		var unique:Array= new int[8];
		for(var i:int= 0; i < multipliers.length; i++){
		multipliers[i] = 0;
		}
		for(var i:int= 0; i < unique.length; i++){
		unique[i] = 0;
		}
		for(var i:int= 0; i < cards.length; i++){
		if(cards[i].isEmpty()) break;
		if(cards[i].isMultiplier()){
		multipliers[cards[i].getMultiplierType()] +=cards[i].getMultiplierAmount();
		} else{
		unique[cards[i].getUnique()]++;
		}
		}
		for(var i:int= 0; i < multipliers.length; i++){
		if(multipliers[i] != 0){
		switch(i){
		case 0:
		trace(getName() + " has " + multipliers[i] + "x" + people + "="+(people*multipliers[i])+" for people");
		result+=people*multipliers[i];
		break;
		case 1:
		var totaltools:int=0;
		for(var j:int=0;j<tools.length;j++)
		totaltools+=tools[j];
		trace(getName() + " has " + multipliers[i] + "x" + totaltools + "="+(totaltools*multipliers[i])+" for tools");
		result+=totaltools*multipliers[i];
		break;
		case 2:
		trace(getName() + " has " + multipliers[i] + "x" + buildings.size() + "="+(buildings.size()*multipliers[i])+" for buildings");
		result+=buildings.size()*multipliers[i];
		break;
		default:
		trace(getName() + " has " + multipliers[i] + "x" + foodtrack + "="+(foodtrack*multipliers[i])+" for food track");
		result+=foodtrack*multipliers[i];
		break;
		}
		}
		}
		var totalunique:int= 0;
		var doubledunique:int= 0;
		for(var i:int= 0; i < unique.length; i++){
		if(unique[i]!=0) totalunique++;
		if(unique[i]>1) doubledunique++;
		}
		if(totalunique>0) trace(getName() + " has " + totalunique + " unique cards for "+totalunique*totalunique+" points");
		if(doubledunique>0) trace(getName() + " also has " + doubledunique + " more unique cards for "+doubledunique+" points");
		result += totalunique += doubledunique;
		return result;
		}
		
		public function finalPoints():int{
		return points;
		}
		*/
	}
}