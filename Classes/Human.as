package 
{
	public class Human extends Player
	{
		public function Human(pName:String, pNumber:Number){
			super(pName, pNumber);
			this.human = true;
		}
		
		
		override public function place():Array{
			var toPlace:Array = new Array(1,1,1);
			
			var number:Number= new Number(); 
			var area:int;
			var tobuild:String= "";
/*			IO.stdout.println("Please choose an area:");
			IO.stdout.println(getAreaSummary());
			tobuild = IO.stdin.readLine();
			while(!isLegalPlace(tobuild)){
				IO.stdout.println("Please try again.");
				tobuild = IO.stdin.readLine();
			}
			area = Integer.parseInt(tobuild)-1;
			var toplace:String= "";
			IO.stdout.println("Please the number of people to place:");
			toplace = IO.stdin.readLine();
			while(!isLegalNumber(toplace, area)){
				IO.stdout.println("Please try again.");
				toplace = IO.stdin.readLine();
			}
			var amt:int= Integer.parseInt(toplace);
			Board.areas[area].place(this.number, amt);
			IO.stdout.println(getName() + " will place " + amt + " in the " + Board.areas[area] + ", and there are " + Board.areas[area].emptySpots() + " spots left");
*/		return toPlace;
		}
		
	}
}