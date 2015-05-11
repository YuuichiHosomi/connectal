
// Copyright (c) 2014 Quanta Research Cambridge, Inc.

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import Vector::*;
import CtrlMux::*;
import Portal::*;
import MemTypes::*;
import HostInterface::*;
import MMU::*;
import MemServer::*;
import GyroCtrlRequest::*;
import GyroCtrlIndication::*;
import MemServerRequest::*;
import MMURequest::*;
import MemServerIndication::*;
import MMUIndication::*;
import GyroController::*;
import ConnectalSpi::*;
import Leds::*;

typedef enum {IfcNames_ControllerRequest, IfcNames_ControllerIndication, IfcNames_HostMemServerIndication, IfcNames_HostMemServerRequest, IfcNames_HostMMURequest, IfcNames_HostMMUIndication, IfcNames_SampleStream} IfcNames deriving (Eq,Bits);

interface GyroSimplePins;
   interface SpiMasterPins spi;
   interface LEDS leds;
endinterface

module mkConnectalTop(ConnectalTop#(PhysAddrWidth,DataBusWidth,GyroSimplePins,1));

   GyroCtrlIndicationProxy cp <- mkGyroCtrlIndicationProxy(IfcNames_ControllerIndication);
   GyroController controller <- mkGyroController(cp.ifc);
   GyroCtrlRequestWrapper cw <- mkGyroCtrlRequestWrapper(IfcNames_ControllerRequest, controller.req);
   
   MMUIndicationProxy hostMMUIndicationProxy <- mkMMUIndicationProxy(IfcNames_HostMMUIndication);
   MMU#(PhysAddrWidth) hostMMU <- mkMMU(0, True, hostMMUIndicationProxy.ifc);
   MMURequestWrapper hostMMURequestWrapper <- mkMMURequestWrapper(IfcNames_HostMMURequest, hostMMU.request);
   
   MemServerIndicationProxy hostMemServerIndicationProxy <- mkMemServerIndicationProxy(IfcNames_HostMemServerIndication);
   MemServer#(PhysAddrWidth,DataBusWidth,1) dma <- mkMemServer(nil, cons(controller.dmaClient,nil), cons(hostMMU,nil), hostMemServerIndicationProxy.ifc);
   MemServerRequestWrapper hostMemServerRequestWrapper <- mkMemServerRequestWrapper(IfcNames_HostMemServerRequest, dma.request);
   
   Vector#(6,StdPortal) portals;
   portals[0] = cp.portalIfc;
   portals[1] = cw.portalIfc;
   portals[2] = hostMemServerRequestWrapper.portalIfc;
   portals[3] = hostMemServerIndicationProxy.portalIfc; 
   portals[4] = hostMMURequestWrapper.portalIfc;
   portals[5] = hostMMUIndicationProxy.portalIfc;
   let ctrl_mux <- mkSlaveMux(portals);
   
   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
   interface masters = dma.masters;
   interface GyroSimplePins pins;
      interface spi = controller.spi;
      interface leds = controller.leds;
   endinterface

endmodule : mkConnectalTop

export GyroSimplePins;
export GyroController::*;
export ConnectalSpi::*;
export mkConnectalTop;

