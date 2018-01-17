package de.dittner.ftpClient.utils {
public interface IServerInfo {
	function get host():String;//server.de
	function get port():String;//21
	function get user():String;
	function get password():String;
	function get remoteDirPath():String;//server.de/public_html/folder
}
}
