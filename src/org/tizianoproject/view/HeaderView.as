package org.tizianoproject.view
{
	import com.chargedweb.swfsize.SWFSizeEvent;
	import com.chrisaiv.utils.ShowHideManager;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	
	public class HeaderView extends CompositeView
	{
		private static const DEFAULT_BG_COLOR:Number = 0x000000;
		private static const DEFAULT_BG_ALPHA:Number = 0.5;
		private static const DEFAULT_HEIGHT:Number = 70;

		private static const MIN_WIDTH:Number = 450;
		private static const MARGIN_RIGHT:Number = 20;
		
		private var bg:Sprite;
		private var browserWidth:Number;

		public var headerRight_mc:MovieClip;
		public var logo_mc:MovieClip;
		
		private var reportersBtn:SimpleButton;
		private var mentorsBtn:SimpleButton;
		private var aboutBtn:SimpleButton;
		
		public function HeaderView(  )
		{
			//Assign Target
			aboutBtn		= headerRight_mc.aboutBtn;
			mentorsBtn 		= headerRight_mc.mentorsBtn;			
			reportersBtn	= headerRight_mc.reportersBtn;
		}
		
		/**********************************
		 * 
		 **********************************/
		override protected function init():void
		{
			initBackground();
			
			aboutBtn.addEventListener(MouseEvent.CLICK, onMentorClickHandler, false, 0, true );
			mentorsBtn.addEventListener(MouseEvent.CLICK, onMentorClickHandler, false, 0, true );
			reportersBtn.addEventListener(MouseEvent.CLICK, onMentorClickHandler, false, 0, true );
		}
		
		private function onMentorClickHandler( e:MouseEvent ):void
		{
			dispatchEvent( e );
		}
		
		private function updateBackground( value:Number ):void
		{
			//trace( "HeaderView::resizeBackground:", value );
			bg.width = value;
		}
		
		private function updatePosition( value:Number ):void
		{
			if( value > MIN_WIDTH ) headerRight_mc.x = value - MARGIN_RIGHT;
			else headerRight_mc.x = MIN_WIDTH - MARGIN_RIGHT;
		}
		
		/**********************************
		 * 
		 **********************************/
		private function initBackground():void
		{
			bg = new Sprite();
			bg.name = "bg";
			bg.mouseChildren = true;
			bg.mouseEnabled = false;
			
			bg.graphics.beginFill( DEFAULT_BG_COLOR, DEFAULT_BG_ALPHA );
			bg.graphics.drawRect( 0, 0, stage.stageWidth, DEFAULT_HEIGHT );
			bg.graphics.endFill();
			
			bg.graphics.lineStyle(1, 0x666666, 1 );
			bg.graphics.moveTo( 0, DEFAULT_HEIGHT );
			bg.graphics.lineTo( stage.stageWidth, DEFAULT_HEIGHT );
			
			addChildAt( bg, 0 );			
		}
		
		/**********************************
		 * Resize
		 **********************************/		
		override protected function resize(e:FullScreenEvent):void
		{
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			
			//trace( "HeaderView::onFullScreenHandler:", w, h );
			if( stage.displayState == StageDisplayState.FULL_SCREEN ){
				updatePosition( stage.stageWidth - headerRight_mc.width );
				updateBackground( stage.stageWidth );
			} else {
				updatePosition( browserWidth - headerRight_mc.width );
				updateBackground( browserWidth );
			}			
		}
		
		override public function browserResize(e:SWFSizeEvent):void
		{
			//trace( "HeaderView::browserResize:", e.topY, e.bottomY, e.leftX, e.rightX, e.windowWidth, e.windowHeight );
			browserWidth = e.rightX;
			
			updatePosition( browserWidth - headerRight_mc.width );
			updateBackground( browserWidth );			
		}		
	}
}