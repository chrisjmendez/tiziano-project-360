﻿/** * ------------------------------------------------------- * Text block * ------------------------------------------------------- *  * Version: 1 * Created: cmendez@tizianoproject.org * Modified: 6/16/2010 *  * ------------------------------------------------------- * Notes: * This will write HTML content *  * */package org.tizianoproject.view.components.article{	import com.chrisaiv.utils.ShowHideManager;	import com.chrisaiv.utils.TextFormatter;		import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.Event;	import flash.geom.Point;	import flash.text.Font;	import flash.text.TextField;	import flash.text.TextFieldAutoSize;		import org.casalib.util.LocationUtil;	import org.tizianoproject.view.CompositeView;
		public class Text extends CompositeView	{		private static const DEFAULT_POS:Point = new Point ( 34, 110 );		private static const DEFAULT_TEXT_HOLDER_POS:Point = new Point( 17, 6 );		private static const DEFAULT_WIDTH:Number = 408;		private static const DEFAULT_HEIGHT:Number = 334;				public var text_txt:TextField;				private var textHolder:MovieClip;		private var textField:TextField;		private var textScrollBar:Scroller;				private var font:Font;		private var randomColor:Number = Math.random() * 0xffffff;				public function Text()		{			x = DEFAULT_POS.x;			y = DEFAULT_POS.y;			initTextHolder();			initTextField();		}				/**********************************		 * Init		 **********************************/		private function initTextHolder():void		{			textHolder = new MovieClip();			textHolder.x = DEFAULT_TEXT_HOLDER_POS.x;			textHolder.y = DEFAULT_TEXT_HOLDER_POS.y;			textHolder.graphics.beginFill( randomColor, ( LocationUtil.isIde() ) ? 0.2 : 0 );			textHolder.graphics.drawRect( 0, 0, DEFAULT_WIDTH, DEFAULT_HEIGHT );			textHolder.graphics.endFill();			textHolder.useSmallTrack = true;			ShowHideManager.addContent( (this as Text), textHolder );		}		private function initTextScrollBar():void		{						textScrollBar = new Scroller( textHolder );			textScrollBar.name = "textScrollBar";			ShowHideManager.addContent( (this as Text), textScrollBar );		}					private function initTextField():void		{			font = new AGaramondSmallCaps();						textField = new TextField();			textField.name = "textField";			textField.autoSize = TextFieldAutoSize.LEFT;			textField.defaultTextFormat = TextFormatter.returnTextFormat( font.fontName, 0xffffff, 18, 6 );			textField.embedFonts = true;						textField.selectable = false;			textField.wordWrap = true;			textField.multiline = true;			textField.mouseEnabled = true;			textField.width = DEFAULT_WIDTH;						ShowHideManager.addContent( textHolder, textField );		}				/**********************************		 * Public Methods		 **********************************/		public function load( content:String ):void		{						writeText( content );			initTextScrollBar();					}				public function writeText( string:String ):void		{			textField.htmlText = string;		}				public function clearText():void		{			textField.htmlText = "";		}						/**********************************		 * Event Handlers		 **********************************/	}}