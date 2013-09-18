package
{
	
	import flash.events.Event;
	
	class ClickEvent extends Event
	{
		
		public static const FARM:String = "farm";
		public static const TOOLS:String = "tools";
		public static const GOLD:String = "gold";
		public static const WOOD:String = "wood";
		public static const BRICK:String = "brick";
		public static const STONE:String = "stone";
		public static const HUNT:String = "hunt";
		public static const HUT:String = "hut";
		public static const C1:String = "c1";
		public static const C2:String = "c2";
		public static const C3:String = "c3";
		public static const C4:String = "c4";
		public static const B1:String = "b1";
		public static const B2:String = "b2";
		public static const B3:String = "b3";
		public static const B4:String = "b4";
		public static const LOTTERY:String = "lottery";
		
		public static const CHOSE:String = "chose";
		public static const BUY:String = "buy";
		
		public var myString:String;
		public var area:Number;
		
		public function ClickEvent( type:String, place:Number )
		{
			area = place;
			myString = type;
			super( type );
		}
	}
}