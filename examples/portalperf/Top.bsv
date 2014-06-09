// bsv libraries
import Vector::*;
import FIFO::*;
import Connectable::*;

// portz libraries
import Portal::*;
import Directory::*;
import CtrlMux::*;
import Portal::*;
import MemTypes::*;

// generated by tool
import PortalPerfIndicationProxy::*;
import PortalPerfRequestWrapper::*;

// defined by user
import PortalPerf::*;

typedef enum {PortalPerfIndication, PortalPerfRequest} IfcNames deriving (Eq,Bits);

module mkPortalTop(StdPortalTop#(addrWidth));

   // instantiate user portals
   PortalPerfIndicationProxy portalPerfIndicationProxy <- mkPortalPerfIndicationProxy(PortalPerfIndication);
   
   PortalPerfRequest portalPerfRequest <- mkPortalPerfRequest(portalPerfIndicationProxy.ifc);

   PortalPerfRequestWrapper portalPerfRequestWrapper <- mkPortalPerfRequestWrapper(PortalPerfRequest, portalPerfRequest);
   
   Vector#(2,StdPortal) portals;
   portals[0] = portalPerfIndicationProxy.portalIfc;
   portals[1] = portalPerfRequestWrapper.portalIfc; 

   // instantiate system directory
   StdDirectory dir <- mkStdDirectory(portals);
   
   let ctrl_mux <- mkSlaveMuxDbg(dir,portals);
   
   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
   interface masters = nil;

endmodule : mkPortalTop
