package
{

	
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	public class Area {
		
		var capacity:int;
		var resource:int;
		var workers:Array;
		var name:String;
		var pics:Array;
		
		public function Area(name:String, resource:int, capacity:int){
			this.name=name;
			pics = new Array(capacity);
			this.resource = resource;
			this.capacity = capacity;
			workers = new Array(capacity);
			for(var i:int= 0; i < workers.length; i++){
				workers[i] = 99;
				pics[i] = 99;
			}
		}
		
		public function reset(number:int):void{
			trace("we are resetting area " + name + "; before it is " + workers);
			for(var i:int= 0; i < workers.length; i++){
				if(workers[i]==number)workers[i] = 99;
			}
			trace("after it is now " + workers);
		}
		
		public function getCapacity():Number{
			return capacity;
		}
		
		public function getNumber(number:int):int{
			var result:int= 0;
			for(var i:int= 0; i < workers.length; i++){
				if(workers[i] == number){
					result++;
				}
			}
			return result;
		}
		
		public function emptySpots():int{
			var empty:int= 0;
			for(var i:int= 0; i < workers.length; i++){
				if(workers[i] == 99) empty++;
			}
			return empty;
		}
		
		public function place(number:int):void{//places only one dude
			for(var j:int= 0; j < workers.length; j++){
				if(workers[j] == 99) {
					workers[j] = number;
					break;
				}
			}
		}
		public function pushImage(pic:Bitmap):void{
			for(var j:int= 0; j < pics.length; j++){
				if(pics[j] == 99) {
					pics[j] = pic;
					break;
				}
			}
		}
		public function lastOfMe(number:Number):Bitmap{
			for(var j:int= workers.length-1; j >= 0; j--){
				if(workers[j] == number) {
					trace("found a match");
					var toSend:Bitmap = pics[j];
					return toSend;
				}
			}
			return null;
		}
		public function removelastOfMe(number:Number):void{
			for(var j:int= workers.length-1; j >= 0; j--){
				if(workers[j] == number) {
					pics[j]=99;
					break;
				}
			}
		}
		
		public function unPlace(number:int):void{//removes one dude
				for(var j:int= workers.length-1; j >=0; j--){
					if(workers[j] == number) {
						workers[j] = 99;
						break;
					}
				}
		}
		
		
		public function hasAlready(number:int):Boolean{
			for(var j:int= 0; j < workers.length; j++){
				if(workers[j] == number) return true;
			}
			return false;
		}
		
		private function isEmpty():Boolean{
			// TODO Auto-generated method stub
			return false;
		}
		
		public function toString():String{
			return name;
		}
		
	}
}