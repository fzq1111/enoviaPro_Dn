package com.teamcenter.custom.rc.server.handlers;

import java.net.InetAddress;
import java.net.UnknownHostException;

import javax.xml.ws.Endpoint;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.jface.dialogs.MessageDialog;

import com.teamcenter.custom.web.service.TcService;
import com.teamcenter.custom.web.service.TcServiceImpl;

/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * 
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class ServiceHandler extends AbstractHandler {

	private Endpoint endpoint = null;

	/**
	 * The constructor.
	 */
	public ServiceHandler() {
	}

	/**
	 * the command has been executed, so extract extract the needed information
	 * from the application context.
	 */
	public Object execute(ExecutionEvent event) throws ExecutionException {
		String address = getAddress();
		if (null == endpoint) {
			endpoint = Endpoint.publish(address, new TcServiceImpl());
		}

		IWorkbenchWindow window = HandlerUtil.getActiveWorkbenchWindowChecked(event);
		MessageDialog.openInformation(window.getShell(), "Server", address);
		return endpoint;
	}

	public String getAddress() {
		try {
			return String.format("http://%s:8110/TcService", InetAddress.getLocalHost().getHostAddress());
		} catch (UnknownHostException e) {
			e.printStackTrace();
		}
		return null;
	}
}
