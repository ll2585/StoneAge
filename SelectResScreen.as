package
{
	import flash.display.MovieClip;
	import flash.text.*;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	public class SelectResScreen extends MovieClip 
	{
		var total:Number;
		var unique:Number;
		var selectedArray:Array;
		var textArray:Array;
		var plusminus:Array;
		var selectedNumber:Number;
		var uniqueSelected:Number;
		private var iClicked:Number;
		var card:Card;
		var area:Number;
		public function SelectResScreen(c:Card, n:Number)
		{
			area=n;
			card = c;
			selectedNumber = 0;
			uniqueSelected = 0;
			this.total = c.getTotal();
			this.unique = c.getUniqueAmt();
			var textResult:TextField = new TextField();
			var myFormat:TextFormat = new TextFormat();
			myFormat.font = "Verdana";
			myFormat.size = 14;
			textResult.defaultTextFormat =myFormat;
			textResult.selectable = false;
			textResult.width = 1000;
			textResult.text = "Select ";
			if(c.getMyType()==3){
				textResult.text += " up to "+ String(total);
			}
			else { textResult.text +=String(total) + " total";}
			if((unique != 1&&!c.isCiv()&&c.getMyType()!=3)){
				textResult.text += ", " + String(unique) + " unique";	
			}
			textResult.width = textResult.textWidth+50;
			textResult.height = textResult.textHeight+50;
			textResult.x = 83.95;
			textResult.y = 28.30;
			addChild(textResult);
			selectedArray = new Array(0,0,0,0);
			textArray = new Array(woodAmt,brickAmt,stoneAmt,goldAmt);
			plusminus = new Array(woodMinus,brickMinus,stoneMinus,goldMinus,woodPlus,brickPlus,stonePlus,goldPlus);
			var iconArray:Array = Game.icons;
			myFormat.size = 16;
			quitButton.addEventListener( MouseEvent.CLICK, iQuit );
			doneButton.addEventListener( MouseEvent.CLICK, iDone );
			for(var i:int = 1; i < 5; i++){
			var theicon:Bitmap = DocumentClass.clone(Game.icons[i]);
			theicon.x = 53.95 + 69*(i-1);
			theicon.y = 62.30;
			addChild(theicon);
			plusminus[i-1].addEventListener( MouseEvent.CLICK, onClickMinus(i-1) );
			plusminus[i-1+4].addEventListener( MouseEvent.CLICK, onClickPlus(i-1) );
			updateStuff();
			}
			
		}
		public function theCard( ):Card{
			return card;
		}
		public function iQuit( mouseEvent:MouseEvent ):void{
			dispatchEvent( new NavigationEvent( NavigationEvent.NORESOURCE ) );
		}
		public function iDone( mouseEvent:MouseEvent ):void{
			Game.paymentArray = new Array(1);
			Game.paymentArray[0] = 0;
			for(var i:int = 0; i < selectedArray.length; i++){
				Game.paymentArray.push(selectedArray[i]);
			}
			dispatchEvent( new NavigationEvent( NavigationEvent.BOUGHT ) );
		}
		public function onClickMinus( index:Number ):Function{
			return function(mouseEvent:MouseEvent):void 
			{ 
				selectedArray[index]--;
				selectedNumber--;
				if(selectedArray[index]==0) uniqueSelected--;
				updateStuff();
			}
		}
		public function getLocation( ):Number{
			return area;
		}
		public function onClickPlus( index:Number ):Function{
			return function(mouseEvent:MouseEvent):void 
			{ 
				if(selectedArray[index]==0) uniqueSelected++;
				selectedArray[index]++;
				selectedNumber++;
				updateStuff();

			}
		}
		
		private function updateStuff():void{
			//trace(card.toString());
			trace(selectedNumber + "dsad");
			trace(card.getMyType() + " sadsad");
			if(selectedNumber==total||(card.getMyType()==3 && selectedNumber > 0 )) {doneButton.visible = true;}
			else {doneButton.visible = false;}
		
			for(var i:int = 1; i < 5; i++){
				if(selectedArray[i-1]<=0) {
					plusminus[i-1].visible=false;
				} else {
					plusminus[i-1].visible=true;
				}
				//can't subtract if we have 0 of it
				if(selectedNumber==total ||overUnique(i-1) || needToSelectOthers(i-1) || isOverMax(i-1)){
					plusminus[i-1+4].visible=false;
				} else {
					plusminus[i-1+4].visible=true;
				}
				//can't add if we are over total, are over unique and its 0, or are at our limit, or if we need to select others
				textArray[i-1].text = selectedArray[i-1];
			}
		}
		private function overUnique(i:Number):Boolean{
			return (uniqueSelected==unique&&selectedArray[i]==0);
		}
		private function needToSelectOthers(selected:Number):Boolean{
			return (selectedArray[selected]>0&&(total-selectedNumber<=unique-uniqueSelected)&&card.getMyType()!=3&&card.getMyType()!=0);
		}
		private function isOverMax(i:Number):Boolean{
			//trace("active is " + Game.active.getName());
			return selectedArray[i]>=Game.active.getResource(i+1);
		}
	}
}