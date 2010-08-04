﻿package org.tizianoproject.view{	import com.chargedweb.swfsize.SWFSizeEvent;	import com.chrisaiv.utils.ShowHideManager;	import com.tis.utils.components.Scrollbar;		import flash.display.MovieClip;	import flash.display.Sprite;	import flash.display.StageDisplayState;	import flash.events.Event;	import flash.events.FullScreenEvent;	import flash.events.MouseEvent;	import flash.geom.Point;	import flash.text.TextField;		import org.tizianoproject.events.BaseViewEvent;	import org.tizianoproject.model.IModel;	import org.tizianoproject.model.vo.Author;	import org.tizianoproject.view.components.article.Scroller;	import org.tizianoproject.view.components.directory.AuthorListing;
	public class DirectoryView extends CompositeView	{		//This is the Default Width + Close Button		private static const MIN_WIDTH:Number = 900;		//This is the Default Height		private static const MIN_HEIGHT:Number = 600;				private static const DEFAULT_POS:Point = new Point( 65, 71 );		private static const DEFAULT_COLUMNS:Number = 3;		private static const DEFAULT_AUTHOR_POS:Point = new Point( 40, 97 );		private static const MARGIN_BOTTOM:Number = 10;		private static const MARGIN_RIGHT:Number = 10;		private static const TABLE_MAX:Number = 12;		private static const DIRECTORY_TITLE_MENTORS:String = "The Tiziano Project Mentors";		private static const DIRECTORY_TITLE_REPORTERS:String = "The Tiziano Project Class of 2010";				private var iModel:IModel;		private var authorListing:AuthorListing;		public var title_txt:TextField;		public var baseView_mc:BaseView;				private var directoryHolder:MovieClip;		private var scrollBar:Scroller;				private var browserWidth:Number;		private var browserHeight:Number;				private var _query:String;		private var _title:String;				public function DirectoryView( m:IModel, q:String="Reporter" )		{			x = DEFAULT_POS.x;			y = DEFAULT_POS.y;						iModel = m;			query = q;		}				override protected function init():void		{			updatePosition();						//Get All Authors based on Type			var authors:Array = iModel.getAuthorsByType( query );						writeTitle( query );						initDirectoryHolder();						createTable( authors );									baseView_mc.addEventListener( BaseViewEvent.CLOSE, onBaseCloseHandler, false, 0, true );		}				private function writeTitle( value:String ):void		{			//trace( "DirectoryView::writeTitle:", value );			//Set the Title			switch ( value.toLowerCase() ){				case "mentor":					title_txt.text = DIRECTORY_TITLE_MENTORS					break;				case "reporter":					title_txt.text = DIRECTORY_TITLE_REPORTERS;					break;			}		}				public function createTable( array:Array ):void		{						var columns:Number = DEFAULT_COLUMNS;			for( var i:Number = 0; i < array.length; i++ ){				var xx:Number = i%columns;				var yy:Number = Math.floor( i/columns );								authorListing = new AuthorListing();				authorListing.name = "authorListing" + i;				//Pass the Value Object to authorListing and let AuthorListing::init() do the rest				authorListing.vo = array[i];				authorListing.x = xx * (authorListing.width  + MARGIN_RIGHT );				authorListing.y = yy * (authorListing.height + MARGIN_BOTTOM );				authorListing.addEventListener( MouseEvent.CLICK, onAuthorClickHandler, false, 0, true );				ShowHideManager.addContent( directoryHolder, authorListing );			}						//If there are more than 5 features, add a Scroll Bar			if( directoryHolder.numChildren > TABLE_MAX ) initFeatureScrollBar();		}				private function initDirectoryHolder():void		{			directoryHolder = new MovieClip();			directoryHolder.name = "directoryHolder";			directoryHolder.x = DEFAULT_AUTHOR_POS.x;			directoryHolder.y = DEFAULT_AUTHOR_POS.y;			ShowHideManager.addContent( (this as DirectoryView ), directoryHolder );		}				private function initFeatureScrollBar():void		{			//trace( "DirectoryView::initFeatureScrollBar:" );			//Create the Features Holder			scrollBar = new Scroller( directoryHolder );			scrollBar.name = "scrollBar";			ShowHideManager.addContent( (this as DirectoryView), scrollBar );		}		/**********************************		 * Resize		 **********************************/		override public function browserResize(e:SWFSizeEvent):void		{			browserWidth = e.rightX;			browserHeight = e.bottomY;			//trace( "DirectoryView::browserResize:", browserWidth, browserHeight );						if( stage ) updatePosition();					}		override protected function resize(e:FullScreenEvent):void		{			if( stage ){				updatePosition();							} 		}						private function updatePosition(  ):void		{			if( stage.displayState == StageDisplayState.FULL_SCREEN ){				x = stage.fullScreenWidth / 2 - ( MIN_WIDTH / 2 );				y = stage.fullScreenHeight / 2 - ( MIN_HEIGHT / 2 );			} else {				//trace( "ArticleView::updatePosition:", browserWidth, browserHeight );				if( browserWidth && browserHeight ){					var dynWidth:Number = ( browserWidth > MIN_WIDTH) ? browserWidth : MIN_WIDTH;					x = ( dynWidth / 2) - ( MIN_WIDTH / 2 );										var dynHeight:Number = ( browserHeight > MIN_HEIGHT ) ? browserHeight : MIN_HEIGHT ;					var yPos:Number = ( dynHeight / 2) - ( MIN_HEIGHT / 2 );					y = ( yPos > + DEFAULT_POS.y ) ? yPos : DEFAULT_POS.y;									} else {					x = ( stage.stageWidth / 2) - ( MIN_WIDTH / 2 );					y = ( ( stage.stageHeight - DEFAULT_POS.y ) / 2) - ( MIN_HEIGHT / 2 ) + DEFAULT_POS.y;				}			}		}		override protected function unload():void		{			//Delete Everything except baseView_mc;			ShowHideManager.unloadContent( (this as DirectoryView), 2 );		}				/**********************************		 * Event Handlers		 **********************************/		private function onAuthorClickHandler( e:MouseEvent ):void		{			//trace( "DirectoryView::onAuthorClickHandler:", Author(e.currentTarget).authorName );			var object:Object = new Object();				object.view = "profileView";				object.data = AuthorListing(e.currentTarget).vo								sendToApp( object );		}				private function sendToApp( obj:Object ):void		{			dispatchEvent( new BaseViewEvent( BaseViewEvent.OPEN, obj ) );		}		private function onBaseCloseHandler( e:BaseViewEvent ):void		{			//trace( "DirectoryView::onBaseCloseHandler:" );			dispatchEvent( e );		}		/**********************************		 * Read Write Accessors		 **********************************/		public function set query( value:String ):void		{			_query = value;		}				public function get query():String		{			return _query;		}	}}