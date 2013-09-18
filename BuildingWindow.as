package
{
	import flash.display.MovieClip;
	import flash.text.*;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	public class BuildingWindow extends MovieClip 
	{
		var cards:Array;
		var unique:Number;
		var selectedArray:Array;
		var textArray:Array;
		var plusminus:Array;
		var selectedNumber:Number;
		var uniqueSelected:Number;
		private var iClicked:Number;
		var card:Card;
		var area:Number;
		public function BuildingWindow(c:Array)
		{
			cards = c;
			drawCards();
		}
		
		private function drawCards():void{
			for(var i:int = 0; i < cards.length; i++){
				var image:MovieClip = cards[i].getImage();
				image.x = 75.85+(107*(i%8));
				image.y = 92 + Math.floor((i/8))*144;
				addChild(image);
				trace(image.y);
			}
			closeButton.addEventListener( MouseEvent.CLICK, iQuit );
		}
		public function iQuit( mouseEvent:MouseEvent ):void{
			dispatchEvent( new NavigationEvent( NavigationEvent.CLOSESCREEN ) );
		}
		/*		public function theCard( ):Card{
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
		*/
	}
}