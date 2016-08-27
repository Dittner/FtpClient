package de.dittner.ftpClient.cmd {
import de.dittner.async.ProgressCommand;

import de.dittner.ftpClient.FtpCmdState;
import de.dittner.ftpClient.utils.ServerInfo;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;

public class FtpCommand extends ProgressCommand {
	protected static const CRLF:String = "\r\n";
	protected static const traceEnabled:Boolean = true;

	public function FtpCommand(cmdSocket:Socket, serverInfo:ServerInfo, state:FtpCmdState) {
		super();
		this.cmdSocket = cmdSocket;
		this.serverInfo = serverInfo;
		this.state = state;
		cmdSocket.addEventListener(ProgressEvent.SOCKET_DATA, onCmdFromServerReceived);
		cmdSocket.addEventListener(Event.CONNECT, onConnectedToServer);
		cmdSocket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
		cmdSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		cmdSocket.addEventListener(Event.CLOSE, onConnectionClosed);
	}

	protected var cmdSocket:Socket;
	protected var serverInfo:ServerInfo;
	protected var state:FtpCmdState;

	protected function onCmdFromServerReceived(e:ProgressEvent):void {
		var code:String = cmdSocket.readUTFBytes(cmdSocket.bytesAvailable);
		var commands:Array = code.split(CRLF);
		var codeNum:uint;
		for each(var cmd:String in commands) {
			if (cmd.length > 3) {
				codeNum = uint(cmd.substr(0, 3) || 0);
				if (traceEnabled) trace(cmd);
				cmdFromServer(codeNum, cmd);
			}
		}
	}

	protected function cmdFromServer(cmdNum:uint, cmd:String):void {}

	protected function onConnectedToServer(e:Event):void {
		if (traceEnabled) trace('CONNECTED TO FTP');
	}

	protected function onConnectionClosed(e:Event):void {
		if (traceEnabled) trace('CONNECTION CLOSED!!!');
	}

	protected function onSocketError(e:IOErrorEvent):void {
		dispatchError(e.text);
	}
	protected function onSecurityError(e:IOErrorEvent):void {
		dispatchError("Socket security error: " + e.toString())
	}

	override public function destroy():void {
		super.destroy();
		cmdSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onCmdFromServerReceived);
		cmdSocket.removeEventListener(Event.CONNECT, onConnectedToServer);
		cmdSocket.removeEventListener(IOErrorEvent.IO_ERROR, onSocketError);
		cmdSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		cmdSocket.removeEventListener(Event.CLOSE, onConnectionClosed);
	}
}
}
