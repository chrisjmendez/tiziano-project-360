﻿/** ----------------------------------------------------------- * Tiziano Project 360 Main Class   * ----------------------------------------------------------- * Description: Central Nervous System * - --------------------------------------------------------- * Created by: cmendez@tizianoproject.org * Modified by:  * Date Modified: Always * - --------------------------------------------------------- * Copyright ©2010 * - --------------------------------------------------------- * *  *  *  */package {	import caurina.transitions.TweenListObj;		import com.chargedweb.swfsize.SWFSize;	import com.chargedweb.swfsize.SWFSizeEvent;	import com.chrisaiv.utils.ShowHideManager;	import com.greensock.TweenLite;	import com.gskinner.utils.SWFBridgeAS3;		import flash.display.DisplayObject;	import flash.display.Loader;	import flash.display.MovieClip;	import flash.display.Sprite;	import flash.display.Stage;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.ErrorEvent;	import flash.events.Event;	import flash.events.FullScreenEvent;	import flash.events.IOErrorEvent;	import flash.events.SecurityErrorEvent;	import flash.external.ExternalInterface;	import flash.net.URLRequest;	import flash.system.LoaderContext;		import nl.demonsters.debugger.MonsterDebugger;		import org.adm.runtime.ModeCheck;	import org.casalib.util.LoadUtil;	import org.casalib.util.LocationUtil;	import org.tizianoproject.controller.Controller;	import org.tizianoproject.controller.IController;	import org.tizianoproject.events.BaseViewEvent;	import org.tizianoproject.model.IModel;	import org.tizianoproject.model.Model;	import org.tizianoproject.view.*;	import org.tizianoproject.view.ArticleView;	import org.tizianoproject.view.components.Background;	import org.tizianoproject.view.components.FullScreen;	import org.tizianoproject.view.components.Overlay;
		public class Main extends Sprite	{		private static const SWF_PATH:String = "http://demo.chrisaiv.com/swf/tiziano/wall.swf";		private static const SWF_LOCAL_PATH:String = "wall.swf";		private static const SWF_BRIDGE:String = "swfBridge";		private static const SWF_BRIDGE_ON_SCREEN_RESIZE:String = "onScreenResize";		private static const SWF_BRIDGE_CONNECT:String = "swfBridgeConnect";				private var context:LoaderContext;		private var swfLoader:Loader;				private var swfBridge:SWFBridgeAS3;				private var model:IModel;		private var controller:IController;				//Views		public var wall_mc:WallView;		public var header_mc:HeaderView;		public var footer_mc:FooterView;		public var bg_mc:Background;				private var headerView:HeaderView;		private var footerView:FooterView;		private var compositeView:CompositeView;		private var articleView:ArticleView;		private var wallView:WallView;		private var studentsView:ListingBrickView;		private var mentorsView:ListingBrickView;				//Components		private var bg:Background;				//MonsterDebugger is like Firebug but for Flash		private var monster:MonsterDebugger;				private var swfSizer:SWFSize;				private var randomColor:Number = Math.random() * 0xffffff;		public function Main()		{					initStage();						//Debugger			monster = new MonsterDebugger( this );			//Model			model = new Model();			//Controller			controller = new Controller( model );			//Views			compositeView = new CompositeView( model, controller );						var online:Boolean = true;			if( online ){								initSwfBridge();								//Determine whether to run locally or from the live server				var path:String = ( LocationUtil.isIde() ) ? SWF_LOCAL_PATH : SWF_PATH;				initWall( path );			} else {				showView( articleView );			}			//showStudentsView();			initChrome();			initArticleView();					}				private function initStage():void		{			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenHandler, false, 0, true );						addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true );					}				private function initSwfBridge():void		{			//SWF Bridge			swfBridge = new SWFBridgeAS3( SWF_BRIDGE, this )			swfBridge.addEventListener( Event.CONNECT, onConnectHandler );					}				private function showTrace( object:* ):void		{			MonsterDebugger.trace( this, object, randomColor );		}				/**********************************		 * 		 **********************************/		private function initWall( path:String ):void		{			wallView = wall_mc;						//Load SWF			context = new LoaderContext( true );			swfLoader = new Loader();							swfLoader.name = "swfLoader";			swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, addWallToStageHandler, false, 0, true ); 			swfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true ); 			swfLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler, false, 0, true );			swfLoader.load( new URLRequest( path ), context );		}				private function initSwfSizer():void		{			swfSizer = SWFSize.getInstance();			swfSizer.addEventListener(SWFSizeEvent.INIT, headerView.swfSizerHandler, false, 0, true );			swfSizer.addEventListener(SWFSizeEvent.INIT, footerView.swfSizerHandler, false, 0, true );			swfSizer.addEventListener(SWFSizeEvent.INIT, articleView.swfSizerHandler, false, 0, true );						swfSizer.addEventListener(SWFSizeEvent.INIT, bg.swfSizerHandler, false, 0, true );						swfSizer.addEventListener(SWFSizeEvent.RESIZE, headerView.swfSizerHandler );			swfSizer.addEventListener(SWFSizeEvent.RESIZE, footerView.swfSizerHandler );						swfSizer.addEventListener(SWFSizeEvent.RESIZE, articleView.swfSizerHandler );			swfSizer.addEventListener(SWFSizeEvent.RESIZE, bg.swfSizerHandler );					}				/**********************************		 * SWFBridge Handlers		 **********************************/		public function onConnectHandler( e:Event ):void		{			swfMessage( "connect" );		}				public function swfMessage( message:String ):void		{			trace( "Main::swfMessage:", message );			switch( message ){				case "connect":					swfBridge.send( SWF_BRIDGE_CONNECT, "Sent From:", loaderInfo.url.substr(loaderInfo.url.lastIndexOf("/")) );					break;				case "fullScreen":					swfBridge.send( SWF_BRIDGE_ON_SCREEN_RESIZE, message );					break;				case "normal":					swfBridge.send( SWF_BRIDGE_ON_SCREEN_RESIZE, message );					break;			}		}				public function onPressThumb( param1:*, param2:* ):void		{			trace( "Main::onPressThumb:", param1, param2 );			showView( articleView );		}		public function onRollOverThumb( param1:*, param2:* ):void		{			//trace( "Main::onRollOverThumb:", param1.description, param2 );			footerView.updateText( param1.description, param2 );			footerView.stopTimer();			footerView.showFooter();		}		public function onRollOutThumb( param1:*, param2:* ):void		{			//trace( "Main::onRollOutThumb:", param1.description, param2 );				footerView.updateText( "", "" );			footerView.startTimer();		}		//This indicates that the AS2 wall is connected		public function swfBridgeConnect( param1:String, param2:String ):void		{			trace( "Main::swfBridgeConnect: ", param1, param2 );		}						/**********************************		 * VIews		 **********************************/		private function initChrome():void		{			//HeaderView is already present on the stage			bg 			= bg_mc;			headerView	= header_mc;			footerView	= footer_mc;		}				private function initArticleView():void		{			//Add an Article Page			articleView = new ArticleView( model, controller );			articleView.name = "articleView";			articleView.addEventListener( BaseViewEvent.CLOSE, hideView );						compositeView.add( articleView );		}				private function showStudentsView():void		{			studentsView = new ListingBrickView( model, controller );			studentsView.name = "studentsView";			articleView.addEventListener( BaseViewEvent.CLOSE, hideView );			compositeView.add( studentsView );			showView( studentsView );		}						/**********************************		 * Show | Hide		 **********************************/		private function showView( view:DisplayObject ):void		{			ShowHideManager.addContent( (this as Main), view );						footerView.hideFooter( 0.5 );						if( wallView ) wallView.hideWall( );		}				//Generic view hider		private function hideView( e:BaseViewEvent ):void		{			//BaseView.results will pass the name of the view to hide.			//trace( "Main::hideView:", e.results.viewName );			ShowHideManager.removeContent( (this as Main), e.results.viewName );			if( wallView ) wallView.showWall( );		}						/**********************************		 * Event Handlers		 **********************************/		private function onAddedToStageHandler( e:Event ):void		{			initSwfSizer();		}				private function onFullScreenHandler( e:FullScreenEvent ):void		{			//Notify the Wall			swfMessage( stage.displayState );		}				private function addWallToStageHandler( e:Event ):void		{			trace( "Main::onCompleteHandler: The Wall has been loaded", e.currentTarget );			ShowHideManager.addContent( wallView, swfLoader );		}				private function onErrorHandler( e:* ):void		{			trace( "Main::onErrorEventHandler:", e.text );		}			}}