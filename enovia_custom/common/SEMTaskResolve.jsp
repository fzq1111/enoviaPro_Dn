<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%@page import="java.util.Iterator"%>
<%
    String mode = emxGetParameter(request, "mode"); 
    StringList busList = new StringList("id");
	StringList relList = new StringList("id[connection]");
	if("SEMTaskResolve".equals(mode))
	{
		 String emxTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
		 String tableRowId = "";
		 for(int i = 0 ;i < emxTableRowId.length; i++)
		 {
			String[] splitValue = emxTableRowId[i].split("\\|");
			tableRowId = splitValue[3];
			String taskId = splitValue[1];
			DomainObject taskObj= new DomainObject(taskId);
			String strType = taskObj.getType(context);
			if(strType.equals("Project Space"))
			{
				continue;
			}
			MapList personList=taskObj.getRelatedObjects(context,"Assigned Tasks","Person",busList,relList,true,false,(short)1,"","");	
			boolean allowed=true;
			if(personList.size()>0)
			{
				MapList childTaskList=taskObj.getRelatedObjects(context,"Subtask","Task",busList,relList,false,true,(short)0,"","");			
				Iterator it = childTaskList.iterator();
				while(it.hasNext())
				{
					Map taskMap = (Map)it.next();
					String childTaskId = (String)taskMap.get("id");
					DomainObject childTaskObj = new DomainObject(childTaskId);
					MapList subPersonList=childTaskObj.getRelatedObjects(context,"Assigned Tasks","Person",busList,relList,true,false,(short)1,"","");	
					if(subPersonList.size()>0)
					{
						continue;
					}else{
						allowed=false;
					}
				}
			}else{
				allowed=false;
			}
			
			if(allowed)
			{
				taskObj.setAttributeValue(context,"SEM Edit Status","P2");
				MapList childTaskList=taskObj.getRelatedObjects(context,"Subtask","Task",busList,relList,false,true,(short)0,"","");			
				Iterator it = childTaskList.iterator();
				while(it.hasNext())
				{
					Map taskMap = (Map)it.next();
					String childTaskId = (String)taskMap.get("id");

					DomainObject childTaskObj = new DomainObject(childTaskId);
					childTaskObj.setAttributeValue(context,"SEM Edit Status","P2");
				}
%>
	
	<script>	
		//parent.location.href = parent.location.href;
		
		parent.emxEditableTable.refreshRowByRowId("<%=tableRowId%>");
		alert("\u4EFB\u52A1\u5DF2\u4E0B\u53D1\u3002");
	</script>

<%				
			}else{
%>
	<script>
		alert("\u4EFB\u52A1\u6216\u8005\u4EFB\u52A1\u5B50\u9879\u672A\u5206\u914D\u4EFB\u52A1\u8D1F\u8D23\u4EBA\uFF0C\u8BF7\u91CD\u65B0\u5206\u914D\u540E\u4EFB\u52A1\u4E0B\u53D1\u5206\u89E3\u3002");
	</script>

<%				
				
			}
		}		 		 
	}
 %>