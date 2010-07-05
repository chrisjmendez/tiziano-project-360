package org.tizianoproject.view
{
	import com.chargedweb.swfsize.SWFSizeEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.printing.PrintJob;
	
	import org.casalib.util.ValidationUtil;
	
	public class WallView extends MovieClip
	{
		private static const MIN_WIDTH:Number = 800;
		
		private var browserWidth:Number;
		private var browserHeight:Number;
		
		public function WallView()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true );
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler, false, 0, true );
			stage.addEventListener( FullScreenEvent.FULL_SCREEN, onFullScreenHandler, false, 0, true );
		}
		
		private function init():void
		{
			graphics.beginFill( 0xffcc00, 1 );
			graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			graphics.endFill();
			
			browserWidth = width;
			browserHeight = height;
		}
		
		private function updatePosition( value:Number ):void
		{
			if( value > MIN_WIDTH ){
				width = value;
			}
		}
		
		/**********************************
		 * Event
		 **********************************/		
		public function swfSizerHandler( e:SWFSizeEvent ):void
		{
			//trace( "HeaderView::swfSizerHandler:", e.topY, e.bottomY, e.leftX, e.rightX, e.windowWidth, e.windowHeight );
			browserWidth = e.rightX;
			
			updatePosition( browserWidth );
		}
		
		private function onFullScreenHandler( e:FullScreenEvent ):void
		{
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			
			trace( "WallView::onFullScreenHandler:" );
			if( e.fullScreen ){
				width = w;
				height = h;
			} else {
				width = browserWidth;
				height = browserHeight;
			}	
		}
		
		private function onAddedToStageHandler( e:Event ):void
		{
			init();
		}
		
		private function onRemovedFromStageHandler( e:Event ):void
		{
			trace( "WallView::onRemovedFromStageHandler:" );
		}
	}
}