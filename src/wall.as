import com.gskinner.utils.SWFBridgeAS2;
import flash.geom.Rectangle;

/****************************
Full Screen
****************************/
//System.security.allowDomain('*');
Stage.align = "TL";
Stage.scaleMode="noScale";


function goFullScreen():Void{
	if(Stage["displayState"] == "normal"){
        Stage["displayState"] = "fullScreen";
    } else {
        Stage["displayState"] = "normal";
    }    
}

var stageListener:Object = new Object();
stageListener.onResize = function(){
	updateMatrixSize( Stage.width, Stage.height )	
}

stageListener.onFullScreen = function( isFullscreen:Boolean ){
    if(isFullscreen){
		updateMatrixSize( Stage.width, Stage.height )
    }else{
		updateMatrixSize( Stage.width, Stage.height )
    }
}

Stage.addListener( stageListener );

/****************************
SWF Bridge
****************************/
var swfBridge = new SWFBridgeAS2("swfBridge", this);
	swfBridge.addEventListener("connect", onConnectHandler);

function swfMessage(message:String):Void {
	switch (message) {
		case "connect" :
			swfBridge.send( "swfBridgeConnect", "Sent From:",_url.substr(_url.lastIndexOf("/")) );
			break;
	}
}

function onConnectHandler(e):Void {
	swfMessage("connect");
	//Load the XML Data
	loadXML();
}

/****************************
ThumbnailList Event Listeners
****************************/
var matrixListener:Object = new Object();
matrixListener.onPressThumb = function(xmlNode:Object, thumb:MovieClip, clipIndex:Number):Void  {
	swfBridge.send("onPressThumb",xmlNode,clipIndex);
};

matrixListener.onRollOverThumb = function(xmlNode:Object, thumb:MovieClip, clipIndex:Number):Void  {
	swfBridge.send("onRollOverThumb",xmlNode,clipIndex);
};

matrixListener.onRollOutThumb = function(xmlNode:Object, thumb:MovieClip, clipIndex:Number):Void  {
	swfBridge.send("onRollOutThumb",xmlNode,clipIndex);
};

matrixListener.onLoadComplete = function(success:Boolean, totalThumbnails:Number, firstThumb:Object):Void  {
	//trace("onLoadComplete: "+success+" "+totalThumbnails+" "+firstThumb);
};

matrixListener.onLoadXml = function(success:Boolean):Void  {
	//trace("onLoadXml: "+success);
};

matrixListener.onLoadProgress = function(imagesLoaded:Number, totalImages:Number) {
	//trace("onLoadProgress: "+imagesLoaded+" "+totalImages);
};

/****************************
ThumbnailList Component
****************************/
var matrixProps:Object = new Object();
	matrixProps._x = 0;
	matrixProps._y = 0;
	matrixProps._width = Stage.width;
	matrixProps._height = Stage.height;

var main:MovieClip = this;
	main.attachMovie("ThumbnailList", "matrix_mc", main.getNextHighestDepth(), matrixProps );
	
matrix_mc.backgroundColor = 0x000000;
matrix_mc.keepScrollButtonSize = false;
matrix_mc.setSize( Stage.width, Stage.height );
matrix_mc.displayEffect = "ordered show";
matrix_mc.matrix = { lines: 6, columns: 8 };
matrix_mc.rollOverEffect = "black&white";
matrix_mc.border = 0;
matrix_mc.preloader = "circle";
matrix_mc.preloaderColor = 0xFFFFFF;
matrix_mc.navigation = "mouse movement";
//matrix_mc.navigation = "scroll bars";
matrix_mc.background = false;
matrix_mc.thumbBorderSize = 0;
matrix_mc.thumbWidth = 201;
matrix_mc.thumbHeight = 139;
matrix_mc.thumbResizeType = "borderscale";
matrix_mc.thumbSpacing = 25;
matrix_mc.remainActiveOnPress = false;
matrix_mc.addListener(matrixListener);
matrix_mc._visible = false;

function updateMatrixSize( w:Number, h:Number ):Void
{
	matrix_mc.setSize( w, h );
}

function loadXML() {
//	matrix_mc._visible = true;
//	matrix_mc.load("http://tizianoproject.org/360/jumpeye.xml");
}
matrix_mc._visible = true;
matrix_mc.load("http://360.tizianoproject.org/xml/jumpeye.xml");
