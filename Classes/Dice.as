package
{
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.events.Event;
	import flash.events.MouseEvent;
	public class Dice extends MovieClip
	{
		private var face:Bitmap;
		private var bits:Number;
		public function Dice(amt:Number)
		{
			var faceArray:Array = new Array();
			var dices:DiceFace = new DiceFace();
			dices = DocumentClass.cutMe(faceArray, 1, 7);
		 	bits = amt;
		}

		public function getNumber():Number{
			return bits;
		}
		public function getFace():Bitmap{
			return face;
		}
	}
	
}