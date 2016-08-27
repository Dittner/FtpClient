package de.dittner.ftpClient.utils {
[RemoteClass(alias="dittner.ftpClient.utils.ServerInfo")]
public class ServerInfo {
	public function ServerInfo() {}

	public var host:String = "server.de";
	public var port:int = 21;
	public var user:String = "";
	public var password:String = "";
	public var remoteDirPath:String = "server.de/public_html/folder";
}
}
