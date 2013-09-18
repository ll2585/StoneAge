package
{
	
	import flash.events.Event;
	
	class LotteryResult extends Event
	{
		
		public static const LOTTERY:String = "LOTTERY";
		public static const CHOSE:String = "CHOSE";
		public var myString:String;
		public var myArray:Array;
		
		public function LotteryResult( type:String, resArray:Array )
		{
			trace("heyyy");
			myArray = resArray;
			myString = type;
			super( type );
		}
	}
}