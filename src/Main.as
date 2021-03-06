﻿/** ----------------------------------------------------------- * Tiziano Project 360 Main Class   * ----------------------------------------------------------- * Description: Central Nervous System * - --------------------------------------------------------- * Created by: cmendez@tizianoproject.org * Modified by:  * Date Modified: Always * - --------------------------------------------------------- * Copyright ©2010 * - --------------------------------------------------------- * *  */package {	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	import org.tizianoproject.Application;
	import org.tizianoproject.model.MainObjectParams;
	import org.tizianoproject.view.FooterView;
	import org.tizianoproject.view.HeaderView;
	import org.tizianoproject.view.WallView;
	import org.tizianoproject.view.components.Background;
		public class Main extends Sprite	{		private var app:Application;		private var mainObjectParams:MainObjectParams;		//Stage Items		public var wall_mc:WallView;		public var header_mc:HeaderView;		public var footer_mc:FooterView;		public var bg_mc:Background;		public function Main()		{				Security.allowDomain("*");			//Pass these Objects from the Stage to the Application			mainObjectParams = new MainObjectParams();			mainObjectParams.wallView = wall_mc;			mainObjectParams.headerView = header_mc;			mainObjectParams.footerView = footer_mc;			mainObjectParams.bg = bg_mc;			app = new Application( this, mainObjectParams );			app.name = "application";			addChild( app );		}				/**********************************		 * Initialize		 **********************************/		private function getFlashVars():Object		{			return Object( LoaderInfo( this.loaderInfo ).parameters );		}			}}