package de.dittner.ftpClient.cmd {
import de.dittner.ftpClient.FtpCmdState;
import de.dittner.ftpClient.utils.FtpClientCmd;
import de.dittner.ftpClient.utils.FtpServerCmd;
import de.dittner.ftpClient.utils.IServerInfo;

import flash.net.Socket;

public class AuthFtpCommand extends FtpCommand {
	public function AuthFtpCommand(cmdSocket:Socket, serverInfo:IServerInfo, state:FtpCmdState) {
		super(cmdSocket, serverInfo, state);
	}

	override public function execute():void {
		cmdSocket.connect(serverInfo.host, parseInt(serverInfo.port));
	}

	override protected function cmdFromServer(cmdNum:uint, cmd:String):void {
		switch (cmdNum) {
			case FtpServerCmd.SERVICE_READY:
				if (traceEnabled) trace("Client: USER " + serverInfo.user);
				cmdSocket.writeUTFBytes(FtpClientCmd.USER + " " + serverInfo.user + CRLF);
				cmdSocket.flush();
				break;
			case FtpServerCmd.USER_OK:
				if (traceEnabled) trace("Client: PASS " + "********");
				cmdSocket.writeUTFBytes(FtpClientCmd.PASS + " " + serverInfo.password + CRLF);
				cmdSocket.flush();
				break;
			case FtpServerCmd.LOGGED_IN:
				state.isAuthenticated = true;
				dispatchSuccess();
				break;
			case FtpServerCmd.NOT_LOGGED:
				dispatchError("Login is failed");
				break;
			case FtpServerCmd.CLOSING_CONTROL_CONN:
				state.isConnectionClosed = true;
				dispatchError("Connection is closed");
				break;

			default :
				if (cmdNum >= 500) dispatchError("Auth with error: " + cmdNum);
				else dispatchError("Unhandled cmd from server: " + cmdNum);
		}
	}
}
}
