package
{
	import flash.display.MovieClip;
	public class Card {
		var bottom:String;
		var top:String;
		var myType:int;
		var cost:Array;
		public static var NIL:Card= new Card();
		var total:int;
		var unique:int;
		var civcard:Boolean= false;
		var added:Boolean = false;
		public var image:MovieClip;
		public var payment:Array;
		
		public function Card(cost1:int=0, cost2:int=0, cost3:int=0, top:String = "", bottom:String = ""){
			this.top = top;
			cost = new Array(5);
			this.bottom = bottom;
			if(top != "") {
				unique = 99;
				civcard = true;
				myType = 0;
			}else if(cost2==0 && cost3==0){
				myType = 3; //7 resource card
				unique=99;
				total = 7;
			} else if(cost3==0){
				myType = 2;
				this.total=cost1;
				this.unique=cost2;//unique card
			} else{
				myType = 1;
				for(var i:int= 0; i < cost.length; i++){
					cost[i]=0;
				}
				cost[cost1]++;
				cost[cost2]++;
				cost[cost3]++;
			}
		}
		public function isEmpty():Boolean{
			return bottom=="" && civcard;
		}

		public function points(payed:Array):int{
			var points:int= 0;
			for(var i:int= 0; i < payed.length; i++){
				points += (i+2)*(payed[i]);
			}
			return points;
		}
		public function getMyType():int{
			return this.myType;
		}
		public function getTotal():int{
			return this.total;
		}
		public function getUniqueAmt():int{
			return this.unique;
		}
		public function isCiv():Boolean{
			return civcard;
		}
		public function getCost():Array{
			return cost;
		}
		public function getAttribute(i:int):int{
			switch(i){
				case 0: return total;
				case 1: return unique;
				default: return 0;
			}
		}
		public function add():void{
			added = true;
		}
		public function isAdded():Boolean{
			return added;
		}
		public function toString():String{
			if (isEmpty()) return "NIL";
			var result:String= "[";
			if(civcard){
				result+= top + "/" + bottom;
			}
			else{
				switch(this.myType){
					case 1:
						result+= "pay ";
						for(var i:int= 0;i <cost.length; i++){
							if(cost[i]>0)
								result+= cost[i] + " " + getResource(i) + ", ";
						}
						break;
					case 2:
						result+= "pay " + total+", "+ unique+" unique ";
						break;
					
					default:
						result+= "pay up to seven resources ";
						break;
					
				}
			}
			result += "]";
			return result;
		}
		public static function getResource(i:int):String{
			switch(i){
				case 0:
					return "food";
				case 1:return "wood";
				case 2:return "clay";
				case 3:return "stone";
				default:return "gold";
			}
		}
		public function isMultiplier():Boolean{
			if(bottom.length < 2) return false;
			if(bottom.charAt(1)=='x') return true;
			return false;
		}
		public function getMultiplierType():int{
			//0=people, 1=tools, 2=huts, 3=food
			if(bottom.charAt(2)=='h') return 2;
			if(bottom.charAt(2)=='p') return 0;
			if(bottom.charAt(2)=='f') return 3;
			if(bottom.charAt(2)=='t') return 1;
			return -1;
		}
		public function setTotal(c:Number):void{
			total = c;
		}
		public function getMultiplierAmount():int{
			return Number(bottom.substring(0,1));
		}
		public function getUnique():int{
			return (Number(bottom.substring(5))-1);
		}
		public function isResource():Boolean{
			var n:Number = Number(top.substring(0,1));
			if(isNaN(n)) return false;
			if (top.charAt(2)=='p' ) return false;
			return true;
		}
		public function resourceType():int{
			//IO.stdout.println(top);
			if(top.charAt(2)=='f') return 0;
			if(top.charAt(2)=='w') return 1;
			if(top.charAt(2)=='c') return 2;
			if(top.charAt(2)=='s') return 3;
			if(top.charAt(2)=='g') return 4;
			if(top.charAt(2)=='a') return 4;
			return -1;
		}
		public function resourceAmount():int{
			return Number(top.substring(0,1));
		}
		public function addBonus():Boolean{
			if(top.charAt(0)=='+') {
				return true;
			}
			return false;
		}
		public function bonusType():int{
			if(top.charAt(3)=='f') return 0;
			if(top.charAt(3)=='t') return 1;
			return -1;
		}
		public function bonusAmount():int{
			return Number(top.substring(1, 2));
		}
		public function RollType():int{
			if(top.charAt(7)=='w') return 1;
			if(top.charAt(7)=='c') return 2;
			if(top.charAt(7)=='s') return 3;
			if(top.charAt(7)=='g') return 4;
			return -1;
		}
		public function RollAmount():int{
			return Number(top.substring(5, 6));
		}
		public function isRoll():Boolean{
			if(top.substring(0,4)=="roll") return true;
			return false;
		}
		public function isLottery():Boolean{
			if(top.substring(0,4)=="lott") return true;
			return false;
		}
		public function addImage(x:MovieClip):void{
			image = x;
		}
		public function getImage():MovieClip{
			return image;
		}
	}
}