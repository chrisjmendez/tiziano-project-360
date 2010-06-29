/** -----------------------------------------------------------
 * BaseView
 * -----------------------------------------------------------
 * Description: BaseView is the base background for all views 
 * - ---------------------------------------------------------
 * Created by: cmendez@tizianoproject.org
 * Modified by: 
 * Date Modified: June 22, 2010
 * - ---------------------------------------------------------
 * Copyright ©2010
 * - ---------------------------------------------------------
 *
 *
 */

package org.tizianoproject.view
{
	import com.chrisaiv.utils.ShowHideManager;
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import org.tizianoproject.events.BaseViewEvent;
	
	public class BaseView extends MovieClip
	{
		public var close_btn:SimpleButton;
		public var bgMc:MovieClip;
		
		private var baseViewArgs:Object;
		
		public function BaseView()
		{			
			baseViewArgs = new Object();			

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler, false, 0, true );
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler, false, 0, true );
		}
		
		private function initBg():void
		{
			graphics.beginFill( 0x000000, 0 );
			graphics.drawRect( -parent.x, -parent.y, stage.stageWidth, stage.stageHeight );
			graphics.endFill();			
		}
		
		private function onAddedToStageHandler( e:Event ):void
		{
			initBg();
			close_btn.addEventListener(MouseEvent.CLICK, onMouseClickHandler, false, 0, true );
			//trace( "Feature::onAddedToStageHandler:" );
		}
		
		private function onRemovedFromStageHandler( e:Event ):void
		{
			close_btn.removeEventListener(MouseEvent.CLICK, onMouseClickHandler );
			//trace( "Feature::onRemovedFromStageHandler:" );
		}	
		
		private function onMouseClickHandler( e:MouseEvent ):void
		{
			//trace( "BaseView::onMouseClickHandler", e.currentTarget.parent.parent.name );
			baseViewArgs.viewName = e.currentTarget.parent.parent.name;			
			dispatchEvent( new BaseViewEvent( BaseViewEvent.CLOSE, baseViewArgs ) );
		}
	}
}