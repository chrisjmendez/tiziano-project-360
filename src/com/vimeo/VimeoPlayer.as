/**
 * VimeoPlayer
 * 
 * A wrapper class for Vimeo's video player (codenamed Moogaloop)
 * that allows you to embed easily into any AS3 application.
 * 
 * Example on how to use:
 * 	var vimeo_player = new VimeoPlayer([YOUR_APPLICATIONS_CONSUMER_KEY], 2, 400, 300);
 * 	vimeo_player.addEventListener(Event.COMPLETE, vimeoPlayerLoaded);	
 * 	addChild(vimeo_player);
 * 
 * http://vimeo.com/api/docs/moogaloop
 *
 * Register your application for access to the Moogaloop API at:
 * 
 * http://vimeo.com/api/applications
 * 
 * Param Options
 * http://vimeo.com/api/docs/moogaloop
 */
package com.vimeo{
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.utils.Timer;
	
	public class VimeoPlayer extends Sprite {
		
		private var container:Sprite = new Sprite(); // sprite that holds the player
		private var moogaloop:Object = false; // the player
		private var player_mask:Sprite = new Sprite(); // some sprites inside moogaloop go outside the bounds of the player. we use a mask to hide it
		
		private var player_width:int = 400;
		private var player_height:int = 300;
		
		private var load_timer:Timer = new Timer(200);
		
		public function VimeoPlayer(oauth_key:String, clip_id:int, w:int, h:int) {
			this.setDimensions(w, h);
			
			Security.allowDomain("*");
			Security.loadPolicyFile("http://vimeo.com/moogaloop/crossdomain.xml");
			
			var urlVars:URLVariables = new URLVariables();
				urlVars.cache_clear = new Date().getTime();
				urlVars.oauth_key = oauth_key;
				urlVars.clip_id = clip_id;
				urlVars.width = w;
				urlVars.height = h;
				urlVars.portrait = false;
				urlVars.hd_off = 1;
				urlVars.fullscreen = false;				
				
//			var request:URLRequest = new URLRequest("http://api.vimeo.com/moogaloop_api.swf?oauth_key=" + oauth_key + "&clip_id=" + clip_id + "&width=" + w + "&height=" + h + "&fullscreen=0");
			var request:URLRequest = new URLRequest();
				request.url = "http://api.vimeo.com/moogaloop_api.swf";
				request.data = urlVars;
				request.method = URLRequestMethod.GET;

				var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIOErrorHandler, false, 0, true );
					loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete, false, 0, true );
					loader.addEventListener( IOErrorEvent.IO_ERROR, onIOErrorHandler, false, 0, true );
					loader.addEventListener( IOErrorEvent.NETWORK_ERROR, onIOErrorHandler, false, 0, true );
					loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityHandler, false, 0, true );
					loader.load(request); 
		}
		
		private function setDimensions(w:int, h:int):void {
			player_width  = w;
			player_height = h;
		}
		
		private function onIOErrorHandler( e:IOErrorEvent ):void
		{
			trace( "VimeoPlayer::onIOErrorHandler:", e.text );
		}
		
		private function onSecurityHandler( e:SecurityErrorEvent ):void
		{
			trace( "VimeoPlayer::onSecurityHandler:", e.text );
		}
		
		private function onErrorHandler( e:Event ):void
		{
			trace( "VimeoPlayer::onErrorHandler:" );
		}
		
		private function onComplete(e:Event):void 
		{
			// Finished loading moogaloop
			container.addChild(e.target.loader.content);
			moogaloop = e.target.loader.content;

			// Create the mask for moogaloop
			addChild(player_mask);
			container.mask = player_mask;
			addChild(container);
			
			redrawMask();

			load_timer.addEventListener(TimerEvent.TIMER, playerLoadedCheck );
			load_timer.start();
		}
		
		/**
		 * Wait for Moogaloop to finish setting up
		 */
		private function playerLoadedCheck(e:TimerEvent):void {
			if (moogaloop.player_loaded) {
				// Moogaloop is finished configuring
				load_timer.stop();
				load_timer.removeEventListener(TimerEvent.TIMER, playerLoadedCheck);
				
				// remove moogaloop's mouse listeners listener
				moogaloop.disableMouseMove(); 
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * Fake the mouse move/out events for Moogaloop
		 */
		private function mouseMove(e:MouseEvent):void {
			if (e.stageX >= this.x && e.stageX <= this.x + this.player_width &&
				e.stageY >= this.y && e.stageY <= this.y + this.player_height) {
				moogaloop.mouseMove(e);
			}
			else {
				moogaloop.mouseOut();
			}
		}
		
		private function redrawMask():void {
			with (player_mask.graphics) {
				beginFill(0x000000, 1);
				drawRect(container.x, container.y, player_width, player_height);
				endFill();
			}
		}
		
		public function play():void {
			moogaloop.api_play();
		}
		
		public function pause():void {
			moogaloop.api_pause();
		}
		
		/**
		 * returns duration of video in seconds
		 */
		public function getDuration():int {
			return moogaloop.api_getDuration();
		}
		
		/**
		 * Seek to specific loaded time in video (in seconds)
		 */
		public function seekTo(time:int):void {
			moogaloop.api_seekTo(time);
		}
		
		/**
		 * Change the primary color (i.e. 00ADEF)
		 */
		public function changeColor(hex:String):void {
			moogaloop.api_changeColor(hex);
		}
		
		/**
		 * Load in a different video
		 */
		public function loadVideo(id:int):void {
			moogaloop.api_loadVideo(id);
		}
		
		public function setSize(w:int, h:int):void {
			this.setDimensions(w, h);
			moogaloop.api_setSize(w, h);
			this.redrawMask();
		}
		
		public function stopVideo ( ) : void
		{
			if(moogaloop){
				moogaloop.api_unload( );
			}
		}

		public function close():void
		{
			if(moogaloop) moogaloop.api_unload();
		}

	}
}