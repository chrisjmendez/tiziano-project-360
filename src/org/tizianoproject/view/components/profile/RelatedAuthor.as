package org.tizianoproject.view.components.profile
{
	import com.chrisaiv.utils.ShowHideManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	import org.tizianoproject.model.vo.Author;
	import org.tizianoproject.view.CompositeView;
	
	public class RelatedAuthor extends CompositeView
	{
		private static const DEFAULT_AVATAR_WIDTH:Number = 50;
		private static const DEFAULT_AVATAR_HEIGHT:Number = 50;
		private static const DEFAULT_POS:Point = new Point( 0, 0 );
		private static const MARGIN_RIGHT:Number = 20;
		
		private var imageLoad:ImageLoad;
		private var bmp:Bitmap;
		
		private var _vo:Author;
		private var _index:Number;
		
		public function RelatedAuthor()
		{
		}

		override protected function init():void
		{
			buttonMode = true;
			y = DEFAULT_POS.y;
			addEventListener(MouseEvent.CLICK, onMouseClickHandler, false, 0, true );
		}
		
		public function load( url:String ):void
		{
			imageLoad = new ImageLoad( new URLRequest( url ), new LoaderContext(true) );
			imageLoad.addEventListener( LoadEvent.COMPLETE, onCompleteHandler, false, 0, true );
			imageLoad.addEventListener( IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true );
			imageLoad.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler, false, 0, true );
			imageLoad.start();
		}

		//Redraw the Image for a smaller size
		private function drawBitmap( ):void
		{
			bmp = imageLoad.contentAsBitmap;
			
			var bmpData:BitmapData = new BitmapData( bmp.width, bmp.height );
				bmpData.draw( bmp );

			bmp.width = DEFAULT_AVATAR_WIDTH;
			bmp.height = DEFAULT_AVATAR_HEIGHT;
			bmp.smoothing = true;
			
			ShowHideManager.addContent( (this as RelatedAuthor), bmp );			
		}
		
		private function clearBitmap():void
		{
			if( bmp ) bmp.bitmapData.dispose();
		}
		
		private function clearLoader():void
		{
			if( imageLoad ) imageLoad.destroy()
		}

		override protected function unload():void
		{
			clearBitmap();
			clearLoader();
		}		
		
		/**********************************
		 * Event Handlers
		 **********************************/
		private function onMouseClickHandler( e:MouseEvent ):void
		{
			trace( "RelatedAuthor::onMouseClickHandler:" );
		}
		
		private function onCompleteHandler( e:Event ):void
		{
			drawBitmap( );
		}		
		
		private function onErrorHandler( e:ErrorEvent ):void
		{
			trace( "RelatedAuthor::onErrorHandler:" );
		}

		/**********************************
		 * Getters Setters
		 **********************************/
		override public function set x( value:Number ):void
		{
			super.x = ( (DEFAULT_AVATAR_WIDTH + MARGIN_RIGHT) * value);
		}
		
		override public function get x():Number
		{
			return super.x;
		}		
		
		public function set vo( value:Author ):void
		{
			_vo = value;
		}
		
		public function get vo():Author
		{
			return _vo;
		}
	}
}