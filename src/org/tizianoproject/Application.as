﻿/** * ------------------------------------------------------- * Tiziano Project Minisite * ------------------------------------------------------- *  * Version: 1 * Created: cmendez@tizianoproject.org * Modified: *  * ------------------------------------------------------- * Notes: *  *  * */package org.tizianoproject{		import com.asual.swfaddress.SWFAddress;	import com.asual.swfaddress.SWFAddressEvent;	import com.chargedweb.swfsize.SWFSize;	import com.chargedweb.swfsize.SWFSizeEvent;	import com.chrisaiv.utils.ShowHideManager;	import com.google.analytics.GATracker;	import com.gskinner.utils.SWFBridgeAS3;		import flash.display.DisplayObject;	import flash.display.InteractiveObject;	import flash.display.Loader;	import flash.display.LoaderInfo;	import flash.display.MovieClip;	import flash.display.SimpleButton;	import flash.display.Stage;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.ErrorEvent;	import flash.events.Event;	import flash.events.FullScreenEvent;	import flash.events.IOErrorEvent;	import flash.events.MouseEvent;	import flash.events.SecurityErrorEvent;	import flash.external.ExternalInterface;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.media.SoundLoaderContext;	import flash.media.SoundMixer;	import flash.net.URLRequest;	import flash.system.LoaderContext;	import flash.system.Security;		import nl.demonsters.debugger.MonsterDebugger;		import org.casalib.util.LocationUtil;	import org.tizianoproject.Application;	import org.tizianoproject.events.ArticleViewEvent;	import org.tizianoproject.events.BaseViewEvent;	import org.tizianoproject.events.StoryEvent;	import org.tizianoproject.model.IModel;	import org.tizianoproject.model.MainObjectParams;	import org.tizianoproject.model.XMLLoader;	import org.tizianoproject.model.vo.Author;	import org.tizianoproject.model.vo.Story;	import org.tizianoproject.model.vo.Test;	import org.tizianoproject.utils.DeepLink;	import org.tizianoproject.view.ArticleView;	import org.tizianoproject.view.CompositeView;	import org.tizianoproject.view.DirectoryView;	import org.tizianoproject.view.FooterView;	import org.tizianoproject.view.HeaderView;	import org.tizianoproject.view.InfoView;	import org.tizianoproject.view.ProfileView;	import org.tizianoproject.view.WallView;	import org.tizianoproject.view.components.Background;	import org.tizianoproject.view.components.FullScreen;	import org.tizianoproject.view.components.Overlay;	import org.tizianoproject.view.components.article.Feature;
		public class Application extends CompositeView	{		private static const DOMAIN:String = "http://360.tizianoproject.org/";		private static const XML_PATH:String = DOMAIN + "xml/schema.xml";		private static const SWF_PATH:String = DOMAIN + "swf/wall.swf";				private static const SWF_BRIDGE_ON_SCREEN_RESIZE:String = "onScreenResize";		private static const SWF_BRIDGE_CONNECT:String = "swfBridgeConnect";		private static const SWF_BRIDGE:String = "swfBridge";				private static const DEFAULT_SOUND_BUFFER:Number = 100;		private static const DEFAULT_TWEEN_SPEED:Number = 0.5;								//Model		private var model:IModel;				//Views		private var mainObjectParams:MainObjectParams;				private var compositeView:CompositeView;		private var headerView:HeaderView;		private var profileView:ProfileView		private var footerView:FooterView;		private var articleView:ArticleView;		private var aboutView:InfoView;		private var wallView:WallView;		private var directoryView:DirectoryView;		private var bg:Background;				//SWF Address		private var deepLink:DeepLink;		private var gaTracker:GATracker;		//MonsterDebugger is like Firebug but for Flash		private var monster:MonsterDebugger;		private var swfBridge:SWFBridgeAS3;		private var context:LoaderContext;		private var swfAddress:SWFAddress;		private var swfLoader:Loader;		private var sound:Sound;						public function Application( main:DisplayObject, params:MainObjectParams )		{								//Load the Model			loadModel();						//These are the objects found laying around on the Flash stage			mainObjectParams = params;			//Debugger			monster = new MonsterDebugger( this );		}						override protected function init():void		{			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;						//SWF Sizer must go first in order to record the browser			initChrome( mainObjectParams );												//Determine whether to run locally or from the live server			initWall( SWF_PATH );						initAnalytics();						//Deep Linking			initDeepLinking();		}				//Load the XML Data		private function loadModel():void		{			model = new XMLLoader();			model.addEventListener( Event.COMPLETE, onXMLCompleteHandler, false, 0, true );			model.addEventListener( IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true );			model.addEventListener( IOErrorEvent.NETWORK_ERROR, onErrorHandler, false, 0, true );			model.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler, false, 0, true );			model.load( XML_PATH );		}				/**********************************		 * Init		 **********************************/		private function initAnalytics():void		{			gaTracker = new GATracker(this, "UA-1912258-1", "Bridge", false);		}				//Composite View is how we update Browser Changes through SWFSizer		private function initCompositeView():void		{			//Composite View will update the Browser and Stage changes			compositeView = new CompositeView();			compositeView.add( articleView );			compositeView.add( directoryView );			compositeView.add( profileView );			compositeView.add( headerView );			compositeView.add( footerView );			compositeView.add( bg );			compositeView.add( aboutView );			compositeView.add( wallView );						//Catch Browser Changes and Dispatch them to all the Children of CompositeView			compositeView.initSwfSize();		}				//On Item Roll over, play sound		private function initSound( path:String ):void		{				sound = new Sound();				sound.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true );				sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandler, false, 0, true );				sound.load( new URLRequest( path ), new SoundLoaderContext( DEFAULT_SOUND_BUFFER, true ) );				try{					sound.play( );									}catch( e:Error ){trace( "App:initSound: Error:"); }		}				//The Wall is the AS2 Component		private function initWall( path:String ):void		{			//SWF Bridge Connects to the Wall			swfBridge = new SWFBridgeAS3( SWF_BRIDGE, this );			swfBridge.addEventListener( Event.CONNECT, onConnectHandler, false, 0, true );						//Connect the Wall			wallView = mainObjectParams.wallView;			wallView.loadWall( path );		}				/**********************************		* Deep Linking		**********************************/		private function initDeepLinking():void		{			//Init Deep Linking			deepLink = new DeepLink();			SWFAddress.addEventListener( SWFAddressEvent.INIT, onSwfAddressHandler );			SWFAddress.addEventListener( SWFAddressEvent.CHANGE, onSwfAddressHandler );		}		private function onSwfAddressHandler( e:SWFAddressEvent ):void		{			if( e.value != "/" ){				//Parse the Address URL and determine if it's a "string" or a Number then store it withing deepLink				deepLink.evaluateParam( e.value.substr(1).toLocaleLowerCase() );								trace( "App::onSwfAddressHandler:", e.value, deepLink.type );				execDeepLink();			}		}				private function execDeepLink():void		{			//deepLink.update == true allows for Prev/Next buttons in ArticleView to update SWFAddress without reloading data			if( model.isLoaded() && deepLink.update == true ){				switch( deepLink.type ){					case DeepLink.DIRECTORY:						if( deepLink.param ){							updateDirectoryView( deepLink.param );							gaTracker.trackPageview( "/directory/" );						}						break;					case DeepLink.ABOUT:						if( deepLink.param ) {							updateDirectoryView( deepLink.param );								gaTracker.trackPageview( "/about/" );						}						break;					case DeepLink.STORY:						if( checkDeepLink( deepLink.id ) ){							updateArticleStory( deepLink.id );							gaTracker.trackPageview( "/story/" + deepLink.id );						} 						break;				}			}		}		//Check to see that the Address URL ID exists as a Story ID		private function checkDeepLink( storyID:Number ):Boolean		{			var available:Boolean = false;			//Attempt to find a story with this id:Number			try{				//This will either become a story.id or a -1				available = findArticle( storyID );			} catch( e:Error ){				trace( "App::checkDeepLink: Error", e.message );			}					return available;		}		private function updateDeepLink( address:*, title:String=null, boolean:Boolean=true ):void		{			deepLink.update = boolean;			deepLink.updateAddress( address );			if( title ) deepLink.updateTitle( title );		}				/**********************************		 * Model Requests		 **********************************/		private function getAllAuthorArticlesByID( value:Number, callee:String="" ):Array		{			return  model.getAllAuthorArticlesByID( value, "[App::" + callee + "]" );				}				private function getArticleByArticleID( value:Number, callee:String="" ):Story		{			return model.getArticleByArticleID( value, "[App::" + callee + "]" );		}				private function getAuthorByName( value:String, callee:String="" ):Author		{			return model.getAuthorByName( value, "[App::" + callee + "]" );			}				private function findArticle( value:Number ):Boolean		{			return model.findArticle( value );		}		/**********************************		 * SWFBridge Handlers		 **********************************/		public function onConnectHandler( e:Event ):void		{			swfMessage( "connect" );		}				public function swfMessage( message:String ):void		{			if( message == "connect" ) swfBridge.send( SWF_BRIDGE_CONNECT, "Sent From:", loaderInfo.url.substr(loaderInfo.url.lastIndexOf("/")) );		}				public function onPressThumb( param1:*, param2:* ):void		{			//trace( "App:onPressThumb", param1.id );			var storyID:Number = param1.id;			updateDeepLink( storyID, getArticleByArticleID( storyID ).title, true );					}				public function onRollOverThumb( param1:*, param2:* ):void		{			//trace( "Application::onRollOverThumb:", param1.description, param1.sound, param2 );			initSound( param1.sound );						footerView.updateText( param1.description, param1.subheadline );			footerView.stopTimer();			footerView.showFooter( DEFAULT_TWEEN_SPEED );		}				public function onRollOutThumb( param1:*, param2:* ):void		{			SoundMixer.stopAll();			//trace( "Application::onRollOutThumb:", param1.description, param2 );				footerView.updateText( "", "" );			footerView.startTimer();		}				//This indicates that the AS2 wall is connected		public function swfBridgeConnect( param1:String, param2:String ):void		{			//trace( "Application::swfBridgeConnect: ", param1, param2 );		}						/**********************************		 * VIews		 **********************************/		//Connect the items on the Flash stage to their respective instances		private function initChrome( params:MainObjectParams ):void		{						bg  = params.bg;			bg.load();						headerView	= params.headerView;						footerView	= params.footerView;		}						//DirectoryView is accessed by pressing "Mentors" or "Reporters"		private function initDirectoryView( ):void		{			directoryView = new DirectoryView( model );			directoryView.name = "directoryView";			directoryView.addEventListener( BaseViewEvent.CLOSE, hideView, false, 0, true );			directoryView.addEventListener( BaseViewEvent.OPEN, onBaseViewHandler, false, 0, true );						//Load a Directory			if( deepLink ) if( deepLink.id ) execDeepLink();		}						private function initArticleView( ):void		{			//Initialize the Article View			articleView = new ArticleView( model );			articleView.name = "articleView";			articleView.addEventListener( StoryEvent.NEW_STORY, newStoryHandler, false, 0, true );			articleView.addEventListener( ArticleViewEvent.LOAD_BG, onArticleViewHandler, false, 0, true );			articleView.addEventListener( BaseViewEvent.CLOSE, hideView, false, 0, true );			articleView.addEventListener( BaseViewEvent.OPEN, onBaseViewHandler, false, 0, true );										//////////////////////////////////////			//SWFAddress Test			//////////////////////////////////////			var storyIDs:Array = new Array( "160", "211", "181", "151", "187", "301" );			//deepLink.id = storyIDs[1];						//Now what we have a bonafide Number, let's see if it's a story ID			if( deepLink ) if( deepLink.id ) execDeepLink();					}		//Triggered from Deeplink and SWFAddress		private function updateArticleStory( storyID:Number ):void		{			if( !articleView ) initArticleView();						//Get the Authors Other Stories			var stories:Array = getAllAuthorArticlesByID( storyID, "updateArticleStory" );			//OPen the Article View			updateArticleView( stories );				}				private function updateArticleView( array:Array ):void		{			trace( "Application::updateArticleView" );			//Add new Stories			articleView.authorStories = array;			//Reset the Index			articleView.currentIndex = 0;			//Load			articleView.loadStory();			//Display ArticleView			showView( articleView );		}		private function initProfileView( ):void		{			profileView = new ProfileView( model );			profileView.name = "profileView";			profileView.addEventListener( MouseEvent.CLICK, onProfileClickHandler, false, 0, true );			profileView.addEventListener( BaseViewEvent.CLOSE, hideView, false, 0, true );			profileView.addEventListener( BaseViewEvent.OPEN, onBaseViewHandler, false, 0, true );			//updateProfileView( "Savina Dawood" );		}				private function updateProfileView( name:String ):void		{			var author:Author = getAuthorByName( name, "updateProfileView" )				profileView.vo = author;				profileView.load();				//showView( profileView );		}				private function initAboutView():void		{			aboutView = new InfoView();			aboutView.name = "aboutView";			aboutView.addEventListener( BaseViewEvent.CLOSE, hideView, false, 0, true );		}				/**********************************		 * Show | Hide		 **********************************/		private function showView( view:DisplayObject ):void		{			ShowHideManager.addContent( (this as Application), view );						//Hide the Footer			if( footerView ) footerView.hideFooter( );			//Hide the Wall			if( wallView ) if( wallView.alpha > 0 ) wallView.hideWall( );		}				//Generic view hider		private function hideView( e:BaseViewEvent ):void		{			//Reset Deep Linking			updateDeepLink( "/" );						if( e.type == BaseViewEvent.CLOSE ){				//BaseView.results will pass the name of the view to hide.				//trace( "Application::hideView:", e.results.viewName );				ShowHideManager.removeContent( (this as Application), e.results.viewName );				//Show the Wall				if( wallView ) if( wallView.alpha <= 0 ) wallView.showWall( );							}		}				/**********************************		 * Event Handlers		 **********************************/		//Every time you land on an new article, update the Background		private function onArticleViewHandler( e:ArticleViewEvent ):void		{			//trace( "Application::onArticleViewHandler:", e.results.data );			if( e.type == ArticleViewEvent.LOAD_BG ) bg.load( e.results.data );			}				//Launch the Directories		private function onHeaderClickHandler( e:MouseEvent ):void		{			if( e.target is FullScreen ){				//Do Nothing			}else if( e.target is SimpleButton ){								//Reset Deep Linking				updateDeepLink( "/" );				//Unload everything				ShowHideManager.unloadContent( (this as Application ) );				//Update Deep Link which will trigger updateDirectoryView				switch( e.target.name ){					case "mentorsBtn":						updateDeepLink( "mentors", "Mentors", true );					break;								case "reportersBtn":						updateDeepLink( "reporters", "Reporters", true );					break;					case "aboutBtn":						updateDeepLink( "about", "About", true );					break;				}			}		}				//Show the Directory View		private function updateDirectoryView( viewName:String ):void		{			if( !directoryView ) initDirectoryView();						switch( viewName ){				case "mentorsBtn":					directoryView.query = "Mentor";					showView( directoryView );					break;				case "reportersBtn":					directoryView.query = "Reporter";					showView( directoryView );					break;				case "aboutBtn":					showView( aboutView );					break;			}						}				private function onProfileClickHandler( e:MouseEvent ):void		{			trace( "App::onProfileClickHandler:", e.target.name, e.target );			var feature:Feature;			var isFeature:Boolean = false;			var regExp:RegExp = new RegExp("feature");			//User clicked on the Feature Text or GUI			if( regExp.test(e.target.name) ){				feature = Feature(e.target);				isFeature = true;			}			//User clicked on the Feature Image			else if( e.target.name == "imageLoader" ){				feature = Feature(e.target.parent.parent);				isFeature = true;			}			if( isFeature ){				trace("Barf Barf Barf Barf Barf");								var stories:Array = getAllAuthorArticlesByID( feature.vo.id, "onProfileClickHandler" ) 				updateArticleView( stories );			}		}				//This happens when a person clicks a new story in Article View 360 Perspectives		private function newStoryHandler( e:StoryEvent ):void		{			var story:Story = e.results as Story;			trace( "App::onNewStoryHandler:", story );			updateDeepLink( story.id, story.title, false );		}				private function onBaseViewHandler( e:BaseViewEvent ):void		{			//trace( "App::onBaseViewHandler:", e.results.view );			ShowHideManager.removeContent( (this as Application), "aboutView" );			ShowHideManager.removeContent( (this as Application), "articleView" );			ShowHideManager.removeContent( (this as Application), "profileView" );			ShowHideManager.removeContent( (this as Application), "directoryView" );			//You are searching for which view to open			switch( e.results.view ){				//Open an article + deep link it				case "articleView":					var story:Story = e.results.data as Story;						//Deep Link						updateDeepLink( story.id, story.title, true );					break;				//Open a Profile				case "profileView":					//trace( "onBaseViewHandler:", e.results.data as Author );					profileView.vo = e.results.data as Author;					profileView.load();					showView( profileView );					break;				}		}		private function onErrorHandler( e:ErrorEvent ):void		{			trace( "App::onErrorHandler", e.text );		}				//Model has loaded		private function onXMLCompleteHandler( e:Event ):void		{			//Activate the HeaderView buttons			headerView.addEventListener( MouseEvent.CLICK, onHeaderClickHandler, false, 0, true );						//Enable the Reporter and Mentor Buttons			initArticleView( );			initAboutView();			initDirectoryView()			initProfileView();						initCompositeView();		}				}}