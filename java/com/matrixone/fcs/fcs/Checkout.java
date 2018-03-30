package com.matrixone.fcs.fcs;

import com.matrixone.client.fcs.OutputStreamSource;
import com.matrixone.client.fcs.http.FcsBadDBChecksumException;
import com.matrixone.fcs.common.CheckoutData;
import com.matrixone.fcs.common.FcsException;
import com.matrixone.fcs.common.JobReceipt;
import com.matrixone.fcs.common.JobTicket;
import com.matrixone.fcs.common.Logger;
import com.matrixone.fcs.common.TransportUtil;
import com.matrixone.fcs.fcs.probe.CheckoutProbe;
import com.matrixone.fcs.fcs.probe.Probe;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Iterator;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Checkout
  implements Dispatche
{
  public JobReceipt doIt(FcsServlet paramFcsServlet, String paramString, FcsContext paramFcsContext, HttpServletRequest paramHttpServletRequest, HttpServletResponse paramHttpServletResponse)
    throws FcsException
  {
    try
    {
      paramFcsContext.setErrorPage(FcsServlet.getParam(paramHttpServletRequest, "failurePage", ""));
      String str1 = FcsServlet.getParam(paramHttpServletRequest, "jobTicket", null);

      String str2 = paramHttpServletRequest.getHeader("networkcheckoutchecksum");
      boolean bool1 = Boolean.TRUE.toString().equals(str2);
      paramFcsContext.setNetworkChecksum(bool1);

      JobTicket localJobTicket = new JobTicket(str1, paramFcsContext);
      List localList = localJobTicket.getRequests(CheckoutData.class);

      long l = 0L;
      try {
        l = Long.parseLong(localJobTicket.getTotalTransferBytes());
      } catch (Exception localException2) {
      }
      paramFcsContext.getProbe().setSize(l);

      boolean bool2 = localList.size() > 1;
      HttpOutputStreamSourceHandler localHttpOutputStreamSourceHandler = HttpOutputStreamSourceHandler.getHandler(paramHttpServletRequest, paramHttpServletResponse, paramFcsContext, bool2, FcsServlet.getParamBoolean(paramHttpServletRequest, "attachment", false));

      Iterator localIterator = localList.iterator();

      checkoutInternal(localIterator, paramFcsContext, localHttpOutputStreamSourceHandler);
      localHttpOutputStreamSourceHandler.finish();
      return null;
    }
    catch (FcsException localFcsException) {
      throw localFcsException;
    }
    catch (Exception localException1) {
    	throw new FcsException(localException1);
    }
    
  }

  static long checkoutInternal(Iterator<CheckoutData> paramIterator, FcsContext paramFcsContext, OutputStreamSource paramOutputStreamSource)
    throws FcsException
  {
    long l1 = 0L;
    CheckoutProbe localCheckoutProbe = new CheckoutProbe(paramFcsContext.getProbe());
    paramFcsContext.setProbe(localCheckoutProbe);
    try
    {
      FcsItemController localFcsItemController = new FcsItemController(paramFcsContext, paramIterator);
      while (localFcsItemController.hasNext()) {
        Item localItem = localFcsItemController.next();
        localItem.computeDBChecksum(false);//add by ryan
        String str = localItem.getFileName();
        paramFcsContext.setCurrent(localItem);
        localCheckoutProbe.addFile(localItem.getSize());

        InputStream localInputStream = localItem.getInputStream();
        OutputStream localOutputStream = paramOutputStreamSource.getNextOutputStream(str, false);
        long l2 = 0L;
        try
        {
          l2 = TransportUtil.transport(localInputStream, localOutputStream, localFcsItemController);
        }
        catch (FcsBadDBChecksumException localFcsBadDBChecksumException) {
          if (localItem.isDBChecksumWarnOnly()) {
            Logger.log(localFcsBadDBChecksumException.getMessage() + " for file " + localItem.getFileName(), 3);
          }
          else {
            throw new IOException("Error in the checkout of " + localItem.getFileName(), localFcsBadDBChecksumException);
          }
        }

        //localItem.validateTransferedSize(l2);//comment by ryan

        localOutputStream.close();
        l1 += l2;
        Logger.log(paramFcsContext, "Sending " + l2 + " bytes for file " + str);
      }
    }
    catch (FcsException localFcsException) {
      throw localFcsException;
    }
    catch (Exception localException) {
      throw new FcsException(localException);
    }
    return l1;
  }
}