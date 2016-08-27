package de.dittner.ftpClient.cmd {
import de.dittner.ftpClient.FtpCmdState;
import de.dittner.ftpClient.utils.ServerInfo;

import flash.net.Socket;

public class QuitFtpCommand extends FtpCommand {
	public function QuitFtpCommand(cmdSocket:Socket, serverInfo:ServerInfo, state:FtpCmdState) {
		super(cmdSocket, serverInfo, state);
	}

	override public function execute():void {
		cmdSocket.close();
		setProgress(1);
		dispatchSuccess();
	}

	override protected function cmdFromServer(cmdNum:uint, cmd:String):void {
		switch (cmdNum) {
			default :
				if (cmdNum >= 500) dispatchError("Auth with error: " + cmdNum);
				else dispatchError("Unhandled cmd from server: " + cmdNum);
		}
	}
}
}
