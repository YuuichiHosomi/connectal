#include "DMAIndicationWrapper.h"

class DMAIndication : public DMAIndicationWrapper
{
  PortalMemory *portalMemory;

public:
  DMAIndication(unsigned int id) : DMAIndicationWrapper(id), portalMemory(0) {}
  DMAIndication(PortalMemory *pm, unsigned int id)
    : DMAIndicationWrapper(id), portalMemory(pm)
  {
    pm->useSemaphore();
  }
  DMAIndication(const char* devname, unsigned int addrbits) : DMAIndicationWrapper(devname,addrbits), portalMemory(0) {}
  DMAIndication(PortalMemory *pm, const char* devname, unsigned int addrbits)
    : DMAIndicationWrapper(devname,addrbits)
    , portalMemory(pm)
  {
    pm->useSemaphore();
  }

  virtual void reportStateDbg(const DmaDbgRec& rec){
    fprintf(stderr, "reportStateDbg: {x:%08lx y:%08lx z:%08lx w:%08lx}\n", rec.x,rec.y,rec.z,rec.w);
  }
  virtual void configResp(unsigned long channelId){
    fprintf(stderr, "configResp: %lx\n", channelId);
  }
  virtual void sglistResp(unsigned long channelId, unsigned long idx, unsigned long pa){
    fprintf(stderr, "sglistResp: %lx idx=%lx physAddr=%lx\n", channelId, idx, pa);
    if (portalMemory)
      portalMemory->sglistResp(channelId);
  }
  virtual void sglistEntry(unsigned long idx, unsigned long long physAddr){
    fprintf(stderr, "sglistEntry: idx=%lx physAddr=%llx\n", idx, physAddr);
  }
  virtual void parefResp(unsigned long channelId){
    fprintf(stderr, "parefResp: %lx\n", channelId);
  }
  virtual void badHandle ( const unsigned long handle, const unsigned long address ) {
    fprintf(stderr, "DMAIndication bad handle pref=%lx addr=%lx\n", handle, address);
  }
  virtual void badAddr ( const unsigned long handle, const unsigned long address , const unsigned long long pa) {
    fprintf(stderr, "DMAIndication bad address pref=%lx addr=%lx physaddr=%llx\n", handle, address, pa);
  }
};
