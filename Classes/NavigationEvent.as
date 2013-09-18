package  
{
	import flash.events.Event;
	public class NavigationEvent extends Event 
	{
		public static const RESTART:String = "restart";
		public static const START:String = "start";
		public static const DONE:String = "done";
		public static const OOPS:String = "oops";
		public static const OKAY:String = "okay";
		public static const NORESOURCE:String = "no resources";
		public static const BOUGHT:String = "BOUGHT";
		public static const LOTTERY:String = "lottery";
		public static const ALLCHOSE:String = "ALLCHOSE";
		public static const CLOSESCREEN:String = "CLOSESCREEN";
		public static const TURNOVER:String = "TURNOVER";
		public static const LOTTERYRESUME:String = "LOTTERYRESUME";
		
		public function NavigationEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{ 
			super( type, bubbles, cancelable );
			
		} 
		
		public override function clone():Event 
		{ 
			return new NavigationEvent( type, bubbles, cancelable );
		} 
		
		public override function toString():String 
		{ 
			return formatToString( "NavigationEvent", "type", "bubbles", "cancelable", "eventPhase" ); 
		}
	}
}