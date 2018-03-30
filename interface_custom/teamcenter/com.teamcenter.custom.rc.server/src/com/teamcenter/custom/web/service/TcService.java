package com.teamcenter.custom.web.service;

import javax.jws.*;

import javax.jws.soap.SOAPBinding;
import javax.jws.soap.SOAPBinding.Style;

@WebService(targetNamespace = "com.teamcenter.custom.web.service")
@SOAPBinding(style = Style.DOCUMENT)
public interface TcService {

	@WebMethod(action = "getBOM")
	public String getBOM(@WebParam(name = "id") String id, @WebParam(name = "type") String type, @WebParam(name = "objSelects") String objSelects,
			@WebParam(name = "bomSelects") String bomSelects, @WebParam(name = "recurseToLevel") int recurseToLevel, @WebParam(name = "recurseToType") String recurseToType)
			throws Exception;

	@WebMethod(action = "getInfo")
	public String getInfo(@WebParam(name = "id") String id, @WebParam(name = "type") String type, @WebParam(name = "objSelects") String objSelects,
			@WebParam(name = "released") int released) throws Exception;

	@WebMethod(action = "getItem")
	public String getItem(@WebParam(name = "id") String id, @WebParam(name = "type") String type, @WebParam(name = "objSelects") String objSelects) throws Exception;

	@WebMethod(action = "getRevisions")
	public String getRevisions(@WebParam(name = "id") String id, @WebParam(name = "type") String type, @WebParam(name = "objSelects") String objSelects,
			@WebParam(name = "released") int released) throws Exception;

	@WebMethod(action = "getDeliverStatus")
	public String getDeliverStatus(@WebParam(name = "id") String id, @WebParam(name = "type") String type, @WebParam(name = "objSelects") String objSelects,
			@WebParam(name = "staSelects") String staSelects, @WebParam(name = "typeWhereUsed") String typeWhereUsed, @WebParam(name = "flag") String flag) throws Exception;

	@WebMethod(action = "findObjects")
	public String findObjects(@WebParam(name = "query") String query, @WebParam(name = "where") String where, @WebParam(name = "objSelects") String objSelects,
			@WebParam(name = "limit") int limit) throws Exception;
}
