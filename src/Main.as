package
{
	import com.chrisaiv.utils.ShowHideManager;
	import com.gskinner.utils.SWFBridgeAS3;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import org.tizianoproject.view.components.Overlay;
	
	public class Main extends Sprite
	{
		private static const SWF_PATH:String = "http://demo.chrisaiv.com/swf/tiziano/wall.swf";
		//private static const SWF_PATH:String = "wall.swf";
		
		private var context:LoaderContext;
		private var loader:Loader;
		private var swfBridge:SWFBridgeAS3;
		
		//Views
		public var wall_mc:MovieClip;
		public var header_mc:MovieClip;
		public var footer_mc:MovieClip;
		
		private var appStage:Stage;
		private var overlay:Overlay

		public function Main()
		{		
			appStage = stage;
			
			swfBridge = new SWFBridgeAS3( "swfBridge", this )
			swfBridge.addEventListener( Event.CONNECT, onConnectHandler );			

			context = new LoaderContext( true );
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e){  }, false, 0, true ); 
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e){trace("IO_ERROR") }, false, 0, true ); 
			loader.load( new URLRequest( SWF_PATH ), context );
			wall_mc.addChild(loader);
		}

		public function onConnectHandler( e:Event ):void
		{
			trace( "onConnectHandler", e.currentTarget );
			swfBridge.send( "sbTest", "Sent From:", loaderInfo.url.substr(loaderInfo.url.lastIndexOf("/")) );
		}

		/**********************************
		*
		**********************************/
		public function onPressThumb( param1, param2 ):void
		{
			//trace( "onPressThumb:", param1.description, param2 );
			overlay = new Overlay( 0, 70, appStage.stageWidth, 484 );
			overlay.name = "overlay";
			overlay.addEventListener( Event.CLOSE, onOverlayCloseHandler, false, 0, true );
			ShowHideManager.addContent( appStage, overlay );
		}

		public function onRollOverThumb( param1, param2 ):void
		{
			trace( "onRollOverThumb:", param1.description, param2 );
			footer_mc.title_txt.text = param1.description;
		}

		public function onRollOutThumb( param1, param2 ):void
		{
			trace( "onRollOutThumb:", param1.description, param2 );	
			footer_mc.title_txt.text = "";
		}

		public function sbTest( param1:String, param2:String ):void
		{
			trace( "main::sbTest: ", param1, param2 );
		}		
		
		private function onOverlayCloseHandler( e:Event ):void
		{
			trace( "onOverlayCloseHandler" );
			ShowHideManager.removeContent( appStage, e.currentTarget.name );
		}
	}
}