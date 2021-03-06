package org.tizianoproject.view
{
	import com.anttikupila.utils.JPGSizeExtractor;
	import com.chargedweb.swfsize.SWFSizeEvent;
	import com.chrisaiv.utils.ShowHideManager;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	import org.casalib.util.ArrayUtil;
	import org.casalib.util.StringUtil;
	import org.tizianoproject.events.BaseViewEvent;
	import org.tizianoproject.model.IModel;
	import org.tizianoproject.model.vo.Author;
	import org.tizianoproject.model.vo.Story;
	import org.tizianoproject.view.components.article.Feature;
	import org.tizianoproject.view.components.article.FeatureHolder;
	import org.tizianoproject.view.components.article.Scroller;
	import org.tizianoproject.view.components.profile.RelatedAuthor;

	public class ProfileView extends CompositeView
	{
		//This is the Default Width + Close Button
		private static const MIN_WIDTH:Number = 900;
		//This is the Default Height
		private static const MIN_HEIGHT:Number = 600;
		
		private static const DEFAULT_POS:Point = new Point( 65, 71 );
		private static const DEFAULT_AVATAR_POS:Point = new Point( 11, 11 );
		private static const DEFAULT_RELATED_AUTHOR_POS:Point = new Point( 45, 510);
		private static const DEFAULT_TABLE_COLUMNS:Number = 1;
		private static const MAX_OTHER_AUTHORS:Number = 6;
		private static const MAX_FEATURES:Number = 4;
		
		private static const IMAGE_PADDING_WIDTH:Number = 18;
		private static const IMAGE_PADDING_HEIGHT:Number = 0;
		private static const HTML_PADDING_HACK:String = "<p></p><p></p><p></p><p></p>";
		
		private var iModel:IModel;
		
		public var baseView_mc:BaseView;

		public var avatar_mc:MovieClip;		
		public var name_txt:TextField;
		public var location_txt:TextField;
		public var aux_txt:TextField;
		public var text_txt:TextField;
		public var title_txt:TextField;
		public var other_txt:TextField;
		
		private var loaderContext:LoaderContext;
		private var imageLoad:ImageLoad;
		private var bmp:Bitmap;
		
		private var avatarHolder:MovieClip;
		
		private var relatedAuthorHolder:MovieClip;
		private var relatedAuthor:RelatedAuthor;
		
		private var featureHolder:FeatureHolder;
		private var feature:Feature;
		private var featureScrollBar:Scroller;

		private var browserWidth:Number;
		private var browserHeight:Number;

		private var _vo:Author;
		
		public function ProfileView( m:IModel )
		{
			x = DEFAULT_POS.x;
			y = DEFAULT_POS.y;
			
			iModel = m;
		}

		/**********************************
		 * Model Requests
		 **********************************/
		private function getAllArticlesByAuthorName( authorName:String ):Array
		{
			return iModel.getAllArticlesByAuthorName( authorName );
		}
		
		private function getRelatedAuthors( authorType:String, authorName:String ):Array
		{
			return iModel.getAuthorsByType( authorType, authorName, true );
		}
		
		/**********************************
		 * Init
		 **********************************/
		override protected function init():void
		{
			name_txt.autoSize = TextFieldAutoSize.LEFT;
			
			updatePosition();
			
			baseView_mc.addEventListener( BaseViewEvent.CLOSE, onBaseCloseHandler, false, 0, true );
		}

		override protected function unload():void
		{
			writeName( "" );
			writeLocation( "" );
			writeAux( "" );
			writeIntro( "" );	

			//Destroy the bitmap
			clearBitmap();
			//Destroy the Loader
			clearLoader()

			//Load New Profile
			ShowHideManager.removeContent( (this as ProfileView), "featureScrollBar" );			
			ShowHideManager.unloadContent( featureHolder );
			ShowHideManager.unloadContent( relatedAuthorHolder );
		}
	
		public function load(  ):void
		{
			//trace( "ProfileView::load:", vo.name, vo.intro, vo.city, vo.region, vo.age );
			///////////////////////////
			//Author
			///////////////////////////
			//This was the old way to doing things
			//loadAvatar( vo.avatar );
			//writeIntro( vo.intro );
			
			loadNewAvatar( );

			writeName( vo.name );
			writeLocation( vo.city + ", " + vo.region );
			writeTitle( vo.name );
			writeOtherAuthors( vo.type.toLocaleLowerCase() );

			///////////////////////////
			//Features
			///////////////////////////
			initFeatureHolder();
			
			///////////////////////////
			//Articles
			///////////////////////////			
			loadArticles( getAllArticlesByAuthorName( vo.name ) );
			
			///////////////////////////
			//Related Authors
			///////////////////////////			
			initAuthorHolder();
			var relatedAuthors:Array = getRelatedAuthors( vo.type, vo.name );
			var totalAuthors:Number = (relatedAuthors.length > MAX_OTHER_AUTHORS ) ? MAX_OTHER_AUTHORS : relatedAuthors.length
			for (var i:uint = 0; i <= totalAuthors - 1; i++){
				relatedAuthor = new RelatedAuthor();
				relatedAuthor.name = "relatedAuthor" + i;
				relatedAuthor.x = i;
				relatedAuthor.vo = relatedAuthors[i];
				relatedAuthor.load( relatedAuthors[i].avatar );
				relatedAuthor.addEventListener( MouseEvent.CLICK, onRelatedAuthorClickHandler, false, 0, true );
				ShowHideManager.addContent( relatedAuthorHolder, relatedAuthor );
			}
		}
		
		private function loadNewAvatar( ):void
		{
			var jpgSizeExtractor:JPGSizeExtractor = new JPGSizeExtractor();
				jpgSizeExtractor.addEventListener( JPGSizeExtractor.PARSE_COMPLETE, onParseCompleteHandler, false, 0, true );
				jpgSizeExtractor.addEventListener( JPGSizeExtractor.PARSE_FAILED, onParseFailHandler, false, 0, true );
				jpgSizeExtractor.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler, false, 0, true );
				jpgSizeExtractor.addEventListener( IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true );
				jpgSizeExtractor.addEventListener( IOErrorEvent.NETWORK_ERROR, onErrorHandler, false, 0, true );
				jpgSizeExtractor.extractSize( vo.avatar );
				
			function onParseCompleteHandler( e:Event ):void
			{
				e.currentTarget.removeEventListener(e.type, arguments.callee);
				var w:Number = jpgSizeExtractor.width;
				var h:Number = jpgSizeExtractor.height;
				
				// Embed the container movieclip inside the textfield. This is done by adding an <img> tag to the actual html text from the xml. Remember to add the width and height from the JPGExtractor class, and an id for the movieclip.
				text_txt.htmlText = "<img src='Avatar' align='left' width='"+ w 
									+"' height='"+ h 
									+"' hspace='"+ IMAGE_PADDING_WIDTH 
									+"' vspace='"+ IMAGE_PADDING_HEIGHT 
									+"' id='image' />"+ HTML_PADDING_HACK + vo.intro;

				//Store the embedded movieclip in a variable for reference
				avatarHolder = text_txt.getImageReference( "image" ) as MovieClip;
				avatarHolder.name = "avatarHolder";
				avatarHolder.scaleX = avatarHolder.scaleY = 1;
				avatarHolder.y = 1;
				avatarHolder.width = w;
				avatarHolder.height = h;
				
				loadAvatar( vo.avatar );
			}
			
			function onParseFailHandler( e:Event ):void
			{
				e.currentTarget.removeEventListener(e.type, arguments.callee);
				trace( "ProfileView::onParseFailHandler:" );
			}
		}

		private function loadAvatar( path:String ):void
		{
			imageLoad = new ImageLoad( new URLRequest( path ), new LoaderContext(true) );
			imageLoad.addEventListener(LoadEvent.COMPLETE, onCompleteHandler, false, 0, true );
			imageLoad.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true );
			imageLoad.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandler, false, 0, true );
			imageLoad.start();
		}		

		private function drawBitmap():void
		{
			bmp = imageLoad.contentAsBitmap;
			bmp.x = DEFAULT_AVATAR_POS.x;
			bmp.y = DEFAULT_AVATAR_POS.y;
			bmp.alpha = 1;			
			//Old Way
			//ShowHideManager.addContent( avatar_mc, bmp );
			ShowHideManager.addContent( avatarHolder, bmp );
		}		
		
		private function initFeatureHolder():void
		{
			//Collect all the Features in an Array
			featureHolder = new FeatureHolder();
			featureHolder.name = "featureHolder";
			ShowHideManager.addContent( (this as ProfileView), featureHolder );			
		}
		
		private function initAuthorHolder():void
		{
			relatedAuthorHolder = new MovieClip();
			relatedAuthorHolder.name = "relatedAuthorHolder";
			relatedAuthorHolder.x = DEFAULT_RELATED_AUTHOR_POS.x;
			relatedAuthorHolder.y = DEFAULT_RELATED_AUTHOR_POS.y;
			ShowHideManager.addContent( (this as ProfileView), relatedAuthorHolder );
		}
		
		private function loadArticles( array:Array):void
		{
			var columns:Number = DEFAULT_TABLE_COLUMNS;
			for( var i:Number = 0; i < array.length; i++ ){
				var xx:Number = i%columns;
				var yy:Number = Math.floor(i/columns);

				feature = new Feature( );
				feature.name = "feature" + i;
				feature.vo = array[i];
				feature.addEventListener(MouseEvent.CLICK, onFeatureClickHandler, false, 0, true );
				//Feature.y is overriden to include DEFAULT_Y_POS
				feature.y = (i * feature.height);
				ShowHideManager.addContent( featureHolder, feature );
			}
			
			//If there are more than 5 features, add a Scroll Bar
			
			if( featureHolder.numChildren > MAX_FEATURES ) initFeatureScrollBar();
		}
		
		private function initFeatureScrollBar():void
		{
			//trace( "ProfileView::initFeatureScrollBar:" );
			featureScrollBar = new Scroller( featureHolder );
			featureScrollBar.name = "featureScrollBar";
			ShowHideManager.addContent( (this as ProfileView), featureScrollBar );
		}
		
		private function writeName( value:String ):void
		{
			name_txt.text = value;
		}
		
		private function writeLocation( value:String ):void
		{
			location_txt.text = value;
		}
		
		private function writeAux( value:String ):void
		{
			aux_txt.text = value;
		}
		
		private function writeIntro( value:String ):void
		{
			text_txt.htmlText = value;
		}
		
		private function writeTitle( value:String ):void
		{
			//Find the White Space
			var index:Number = value.search(" " );
			//Strip the name after the white space
			value = value.substr( 0, index );
			//If the first name end's with "s", strip it out
			var pluralizer:String = ( value.substr( -1, 1 ) == "s" ) ? "" : "s";
			title_txt.text = value + "'" + pluralizer + " Stories";
		}
		
		private function writeOtherAuthors( authorType:String ):void
		{
			if( authorType.toLowerCase() == "mentor" ){
				other_txt.text = "Other Mentors";
				//Mentors: University, Students:Age 
				writeAux( vo.age );
			} else {
				other_txt.text = "Other Students" ;				
				//Mentors: University, Students:Age 
				writeAux( vo.age );
			}
		}
		
		private function clearBitmap():void
		{
			//Delete the current image
			if( bmp ) bmp.bitmapData.dispose();			
		}
		
		private function clearLoader():void
		{
			if( imageLoad ) imageLoad.destroy();
		}

		private function sendToApp( obj:Object ):void
		{
			//trace( "ProfileView::sendToApp:", obj.data.authorName );
			dispatchEvent( new BaseViewEvent( BaseViewEvent.OPEN, obj ) );
		}
		
		/**********************************
		 * Resize
		 **********************************/
		override public function browserResize(e:SWFSizeEvent):void
		{
			browserWidth = e.rightX;
			browserHeight = e.bottomY;
			//trace( "DirectoryView::browserResize:", browserWidth, browserHeight );
			
			if( stage ) updatePosition();			
		}
		
		override protected function resize(e:FullScreenEvent):void
		{
			if( stage ){
				updatePosition();
			}
		}
		
		private function updatePosition(  ):void
		{
			if( stage.displayState == StageDisplayState.FULL_SCREEN ){
				x = stage.fullScreenWidth / 2 - ( MIN_WIDTH / 2 );
				y = stage.fullScreenHeight / 2 - ( MIN_HEIGHT / 2 );
			} else {
				//trace( "ArticleView::updatePosition:", browserWidth, browserHeight );
				if( browserWidth && browserHeight ){
					var dynWidth:Number = ( browserWidth > MIN_WIDTH) ? browserWidth : MIN_WIDTH;
					x = ( dynWidth / 2) - ( MIN_WIDTH / 2 );
					
					var dynHeight:Number = ( browserHeight > MIN_HEIGHT ) ? browserHeight : MIN_HEIGHT ;
					var yPos:Number = ( dynHeight / 2) - ( MIN_HEIGHT / 2 );
					y = ( yPos > + DEFAULT_POS.y ) ? yPos : DEFAULT_POS.y;					
				} else {
					x = ( stage.stageWidth / 2) - ( MIN_WIDTH / 2 );
					y = ( ( stage.stageHeight - DEFAULT_POS.y ) / 2) - ( MIN_HEIGHT / 2 ) + DEFAULT_POS.y;
				}
			}
		}
		
		/**********************************
		 * Event Handlers
		 **********************************/
		private function onCompleteHandler( e:LoadEvent ):void
		{
			//trace( "ProfileView::onCompleteHandler:" );
			drawBitmap();
		}
		
		private function onErrorHandler( e:ErrorEvent ):void
		{
			trace( "ProfileView::onErrorHandler:", e.text );	
		}
		
		private function onRelatedAuthorClickHandler( e:Event ):void
		{
//			trace( "ProfileView::onRelatedAuthorClickHandler:"  );
			//Update Data (RelatedAuthor.vo carries the Author object)
			vo = e.currentTarget.vo as Author;	
			//Unload the Views
			unload();
			//Reload the Views
			load();			
		}
		
		private function onFeatureClickHandler( e:MouseEvent ):void
		{
			var object:Object = new Object();
				object.view = "articleView";
				object.data = e.currentTarget.vo as Story;
			sendToApp( object );
		}

		private function onBaseCloseHandler( e:BaseViewEvent ):void
		{
			//trace( "ProfileView::onBaseCloseHandler:" );
			dispatchEvent( e );
		}		
		/**********************************
		 * Read Write Accessors
		 **********************************/
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