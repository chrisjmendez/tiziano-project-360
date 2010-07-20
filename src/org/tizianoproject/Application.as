﻿/** * ------------------------------------------------------- * Tiziano Project Minisite * ------------------------------------------------------- *  * Version: 1 * Created: chrisaiv@gmail.com * Modified: 7/18/2010 *  * ------------------------------------------------------- * Notes: *  *  * */package org.tizianoproject{	import caurina.transitions.TweenListObj;		import com.chargedweb.swfsize.SWFSize;	import com.chargedweb.swfsize.SWFSizeEvent;	import com.chrisaiv.utils.ShowHideManager;	import com.greensock.TweenLite;	import com.gskinner.utils.SWFBridgeAS3;		import flash.display.DisplayObject;	import flash.display.Loader;	import flash.display.LoaderInfo;	import flash.display.MovieClip;	import flash.display.Sprite;	import flash.display.Stage;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.ErrorEvent;	import flash.events.Event;	import flash.events.FullScreenEvent;	import flash.events.IOErrorEvent;	import flash.events.SecurityErrorEvent;	import flash.external.ExternalInterface;	import flash.net.URLRequest;	import flash.system.LoaderContext;		import nl.demonsters.debugger.MonsterDebugger;		import org.adm.runtime.ModeCheck;	import org.casalib.util.LoadUtil;	import org.casalib.util.LocationUtil;	import org.tizianoproject.Application;	import org.tizianoproject.events.BaseViewEvent;	import org.tizianoproject.model.IModel;	import org.tizianoproject.model.MainObjectParams;	import org.tizianoproject.model.XMLLoader;	import org.tizianoproject.model.vo.Story;	import org.tizianoproject.model.vo.Test;	import org.tizianoproject.view.*;	import org.tizianoproject.view.ArticleView;	import org.tizianoproject.view.components.Background;	import org.tizianoproject.view.components.FullScreen;	import org.tizianoproject.view.components.Overlay;
		public class Application extends CompositeView	{		private static const XML_PATH:String = "http://demo.chrisaiv.com/xml/tiziano/schema.xml";			private static const XML_DATA_LOCAL_PATH:String = "http://localhost:8080/xml/tiziano/schema.xml";						private static const SWF_PATH:String = "http://demo.chrisaiv.com/swf/tiziano/wall.swf";		private static const SWF_LOCAL_PATH:String = "wall.swf";				private static const SWF_BRIDGE:String = "swfBridge";		private static const SWF_BRIDGE_ON_SCREEN_RESIZE:String = "onScreenResize";		private static const SWF_BRIDGE_CONNECT:String = "swfBridgeConnect";				private var context:LoaderContext;		private var swfLoader:Loader;		private var swfBridge:SWFBridgeAS3;						//Model		private var model:IModel;				//Views		private var mainObjectParams:MainObjectParams;				private var compositeView:CompositeView;		private var headerView:HeaderView;		private var footerView:FooterView;		private var articleView:ArticleView;		private var wallView:WallView;		private var studentsView:DirectoryView;		private var bg:Background;				//MonsterDebugger is like Firebug but for Flash		private var monster:MonsterDebugger;		//Browser Resiz Notifier		private var swfSizer:SWFSize;				private var randomColor:Number = Math.random() * 0xffffff;				public function Application( main:DisplayObject, params:MainObjectParams )		{			//Load the Model			loadModel();						//Stage Objects			mainObjectParams = params;			//Debugger			monster = new MonsterDebugger( this );						addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true );					}				override protected function init():void		{			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;						//SWF Sizer must go first in order to record the browser			initSwfSizer();			initSwfBridge();			//initStudentsView();			initChrome( mainObjectParams );			var online:Boolean = true;			if( online ){				//Determine whether to run locally or from the live server				var path:String = ( LocationUtil.isIde() ) ? SWF_LOCAL_PATH : SWF_PATH;				//initWall( SWF_PATH );			} else {				showView( articleView );			}		}		private function loadModel():void		{			model = new XMLLoader();			model.addEventListener( Event.COMPLETE, onXMLCompleteHandler, false, 0, true );			model.load( ( LocationUtil.isIde() ) ? XML_DATA_LOCAL_PATH : XML_PATH );		}		private function initSwfBridge():void		{			//SWF Bridge			swfBridge = new SWFBridgeAS3( SWF_BRIDGE, this )			swfBridge.addEventListener( Event.CONNECT, onConnectHandler );					}				private function initWall( path:String ):void		{			wallView = mainObjectParams.wallView;			swfSizer.addEventListener(SWFSizeEvent.INIT, wallView.swfSizerHandler, false, 0, true );			swfSizer.addEventListener(SWFSizeEvent.RESIZE, wallView.swfSizerHandler );							wallView.loadWall( path );		}				private function initSwfSizer():void		{			swfSizer = SWFSize.getInstance();		}				/**********************************		 * SWFBridge Handlers		 **********************************/		public function onConnectHandler( e:Event ):void		{			swfMessage( "connect" );		}				public function swfMessage( message:String ):void		{			switch( message ){				case "connect":					swfBridge.send( SWF_BRIDGE_CONNECT, "Sent From:", loaderInfo.url.substr(loaderInfo.url.lastIndexOf("/")) );					break;			}		}				public function onPressThumb( param1:*, param2:* ):void		{			trace( "Main::onPressThumb:", param1.id );			var storyID:Number = param1.id;			var story:Story = model.getArticleByArticleID( storyID );			var otherStories:Array = model.getOtherArticlesByArticleID( storyID );				otherStories.unshift( story );								updateArticleView( otherStories );		}				public function onRollOverThumb( param1:*, param2:* ):void		{			//trace( "Main::onRollOverThumb:", param1.description, param2 );			footerView.updateText( param1.description, param2 );			footerView.stopTimer();			footerView.showFooter();		}				public function onRollOutThumb( param1:*, param2:* ):void		{			//trace( "Main::onRollOutThumb:", param1.description, param2 );				footerView.updateText( "", "" );			footerView.startTimer();		}				//This indicates that the AS2 wall is connected		public function swfBridgeConnect( param1:String, param2:String ):void		{			trace( "Main::swfBridgeConnect: ", param1, param2 );		}						/**********************************		 * VIews		 **********************************/		private function initChrome( params:MainObjectParams ):void		{			//HeaderView is already present on the stage			bg  = params.bg;			swfSizer.addEventListener(SWFSizeEvent.INIT, bg.swfSizerHandler, false, 0, true );			swfSizer.addEventListener(SWFSizeEvent.RESIZE, bg.swfSizerHandler );													headerView	= params.headerView;			swfSizer.addEventListener(SWFSizeEvent.INIT, headerView.swfSizerHandler, false, 0, true );			swfSizer.addEventListener(SWFSizeEvent.RESIZE, headerView.swfSizerHandler );						footerView	= params.footerView;			swfSizer.addEventListener(SWFSizeEvent.INIT, footerView.swfSizerHandler, false, 0, true );			swfSizer.addEventListener(SWFSizeEvent.RESIZE, footerView.swfSizerHandler );		}						private function initArticleView( ):void		{						//////////////////////////////////////			//Temporary			//////////////////////////////////////			var storyID:Number = 1;			var story:Story = model.getArticleByArticleID( storyID );			var otherStories:Array = model.getOtherArticlesByArticleID( storyID );				otherStories.unshift( story );			//////////////////////////////////////			//Initialize the Article View			articleView = new ArticleView( model );			articleView.name = "articleView";			articleView.addEventListener( BaseViewEvent.CLOSE, hideView );			swfSizer.addEventListener(SWFSizeEvent.INIT, articleView.swfSizerHandler, false, 0, true );			swfSizer.addEventListener(SWFSizeEvent.RESIZE, articleView.swfSizerHandler );			updateArticleView( otherStories );		}				private function updateArticleView( array:Array ):void		{			articleView.stories = array;			articleView.currentIndex = 0;			articleView.loadStory();			showView( articleView );		}				private function initStudentsView( ):void		{			studentsView = new DirectoryView( model );			studentsView.name = "studentsView";			studentsView.addEventListener( BaseViewEvent.CLOSE, hideView );			showView( studentsView );					}				/**********************************		 * Show | Hide		 **********************************/		private function showView( view:DisplayObject ):void		{			ShowHideManager.addContent( (this as Application), view );						if( footerView ) footerView.hideFooter( 0.5 );						if( wallView ) wallView.hideWall( );		}				//Generic view hider		private function hideView( e:BaseViewEvent ):void		{			//BaseView.results will pass the name of the view to hide.			//trace( "Main::hideView:", e.results.viewName );			ShowHideManager.removeContent( (this as Application), e.results.viewName );						if( wallView ) wallView.showWall( );		}		/**********************************		 * Event Handlers		 **********************************/				private function onXMLCompleteHandler( e:Event ):void		{			//initArticleView( );			initStudentsView( );		}			}}