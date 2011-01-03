package org.medawar.DualViewer.scripts
{
	import org.medawar.DualViewer.map.SimpleZoomMap;

	public class XMLReciverClient implements IXMLReciver
	{
		private var viewer:DualViewerClient;
		private var last:String="";
		public function setViewer(	viewerREC:DualViewerClient):void{
			this.viewer = viewerREC;
		}
		public function recive(message:XML):void
		{
		
			if(message.@label!= last){
				last = message.@label;
				viewer.removeAllElements();
				viewer.map = new SimpleZoomMap("","",viewer.m);
				viewer.addElement(viewer.map);
				viewer.map.load(message);
			}else{
				viewer.map.load(message);
			}
			return;
		}
	}
}