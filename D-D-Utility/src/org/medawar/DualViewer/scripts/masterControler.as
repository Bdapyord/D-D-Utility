import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.net.LocalConnection;
import flash.xml.XMLDocument;
import flash.xml.XMLNode;

import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.Tree;
import mx.controls.menuClasses.MenuBarItem;
import mx.core.Window;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.MenuEvent;
import mx.events.ModuleEvent;
import mx.managers.PopUpManager;
import mx.managers.WindowedSystemManager;
import mx.modules.*;

import org.medawar.DualViewer.IHM.createGroup;
import org.medawar.DualViewer.IHM.createView;
import org.medawar.DualViewer.map.SimpleZoomMap;
import org.medawar.DualViewer.map.SocketClient;
import org.medawar.DualViewer.scripts.GroupView;
import org.medawar.DualViewer.scripts.IXMLReciver;
import org.medawar.DualViewer.scripts.Model;
import org.medawar.DualViewer.scripts.XMLReciverServer;
import org.osmf.utils.URL;

import spark.components.NavigatorContent;
import spark.components.TitleWindow;
import spark.components.WindowedApplication;
import spark.events.IndexChangeEvent;


private var client:SocketClient;


private function initConn():void{
	var serverReciever:XMLReciverServer = new XMLReciverServer();
	client = new SocketClient("127.0.0.1",18000,serverReciever);
}

private const dataFilter:FileFilter = new FileFilter("Map data content (mdc)","*.mdc;*.xml;");
private const cmpFilter:FileFilter = new FileFilter("Compaign (cmp)","*.cmp;");
[Bindable]
public static var crntGroup:GroupView;
[Bindable]
public var m:Model= new Model();

private var viewChanged:Boolean=true;
private function init():void{
	initConn();
}
private function initMenu():void{
	
	mBar.addEventListener(MenuEvent.ITEM_CLICK, handleMenuClick);
	
	/*mbi= mBar.menuBarItems[0].menuBarItems[2] as MenuBarItem;
	mbi.addEventListener(MouseEvent.CLICK, saveas);*/
}
private function handleMenuClick(evt:MenuEvent):void{
	switch(evt.label){
		case "New project":
			newProject();
			break;
		case "Open project":
			openGroup();
			break;
		case "Save project":
			saveProject();
			break;
		case "Save project As":
			saveCampaignAs();
			break;
		case "New view":
			newView();
			break;
		case "Open view":
			openView();
			break;
		case "Save view":
			saveView();
			break;
		case "Save view As":
			saveViewAs();
			break;
		default:
			break;						
	}
}

private function changeView(event:IndexChangeEvent):void {
	var theData:String = ""
	viewChanged =true;
	viewContainer.removeAllElements();
	m.setCurrentView(event.newIndex);
	viewContainer.addElement(m.getCurrentView());
	/*if (event.currentTarget.selectedItem.@data) {
	theData = " Data: " + event.currentTarget.selectedItem.@data;
	}
	forChange.text = event.currentTarget.selectedItem.@label + theData; */
}

private function newView():void{
	var c:createView =  createView(PopUpManager.createPopUp( this, createView , true)) as TitleWindow;
	PopUpManager.centerPopUp(c);
	c.crtBtn.addEventListener(MouseEvent.CLICK,function():void{
		c.create();
		if(c.created){
			var v:SimpleZoomMap = new SimpleZoomMap(c.path,c.nameView,m);
			m.addView(v);
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itNwMap").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSASMap").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSMap").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSAsCmp").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSCmp").@enabled="true";
			currentState="Editing";
		}
	})
		;}

private function openView():void{
	Alert.show("O");
}
private function saveView():void{
	crntGroup.seralise();
	
}
private function saveViewAs():void{
	Alert.show("SS");
	
}
private function newProject():void{
	var c:createGroup =  createGroup(PopUpManager.createPopUp( this, createGroup , true)) as TitleWindow;
	PopUpManager.centerPopUp(c);
	c.crtBtn.addEventListener(MouseEvent.CLICK,function():void{
		c.create();
		if(c.created){
			crntGroup = new GroupView(c.nameCm,c.path,c.libPaht,m);
			crntGroup.seralise();
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itNwMap").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSASMap").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSMap").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSAsCmp").@enabled="true";
			mBar.menuBarItems[0].data.item.(valueOf().@id=="itSCmp").@enabled="true";
			currentState="Editing";
		}
	});
}
private function treeLabel(item:Object):String {
	var node:XML = XML(item);
	if( node.localName() == "map" )
		return node.@label;
	else
		return node.@name;
}
private function openGroup():void{
	var f:File = File.applicationStorageDirectory;
	f.browseForOpen("Open group of view",[cmpFilter]);
	f.addEventListener(Event.SELECT, function (event:Event):void {
		crntGroup = new GroupView("","","",m);
		
		crntGroup.unseralise(f);
		mBar.menuBarItems[0].data.item.(valueOf().@id=="itNwMap").@enabled="true";
		mBar.menuBarItems[0].data.item.(valueOf().@id=="itSASMap").@enabled="true";
		mBar.menuBarItems[0].data.item.(valueOf().@id=="itSMap").@enabled="true";
		mBar.menuBarItems[0].data.item.(valueOf().@id=="itSAsCmp").@enabled="true";
		mBar.menuBarItems[0].data.item.(valueOf().@id=="itSCmp").@enabled="true";
		currentState="Editing";
	});		
	
}
private function saveProject():void{
	crntGroup.seralise();
}
private function saveCampaignAs():void{
	Alert.show("SSC");
	
}
protected function handelOpenProject(event:MouseEvent):void
{
	/*
	src="E:\\Projets\\D&DUtility\\D-D-Utility\\map\\result.jpg";
	if(src=="")return;
	var f:File = new File(src+"\\ImageProperties.xml");
	if(!f.exists) {
	Alert.show("The selected directorie is not valid","Error");
	return;
	}	
	//currentState = "manageMap"; 
	
	this.nativeWindow.maximize();		*/
}		
protected function sendDataToClient(event:MouseEvent):void
{
	
	if (client != null)
	{
		if(viewChanged){
			client.send(m.getCurrentView().seralize().toString());
			viewChanged = false;
		}else{
			client.send(m.getCurrentView().getModification());
		}
	}
	else
	{    
		initConn();
		sendDataToClient(null);
	}			
}


protected function addObject(event:MouseEvent):void
{
	
	var f:File = new File(crntGroup.getLibPath());
	f.browseForOpen("Select the object directory");
	f.addEventListener(Event.SELECT, function (event:Event):void {
		m.getCurrentView().addObject(f.nativePath,"");
	});
	
}
