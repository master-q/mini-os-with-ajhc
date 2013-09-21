module Fbfront where
import Foreign.C.String
import Foreign.Ptr
import Data.Word
import Util
import FbfrontStub
import Xenbus
import Xen

foreign export ccall "_nit_fbfront" initFbfront :: CString -> Ptr Word64 -> Int32 -> Int32 -> Int32 -> Int32 -> Word32 -> IO (Ptr Word8)
foreign import ccall "hs_get_fbfront_handler" getFbfrontHandler :: IO (FunPtr (IO ()))
foreign import ccall "hs_get_fbfront_dev_evtchn_ptr" getFbfrontDevEvtchnPtr :: Ptr FbfrontDev -> IO (Ptr EvtchnPort)
foreign import ccall "memset" memset :: Ptr a -> Word8 -> Word32 -> IO ()
initFbfront nodename mfns width height depth stride n = setupTranscation nodename width height depth stride n

setupTranscation nodename width height depth stride n =
  do  name <- if nodename == nullPtr then return "device/vfb/0" else peekCString nodename
      printk $ "******************* FBFRONT for " ++ name ++ " **********\n\n\n"
      dev <- mkFbfrontDev
      name' <- newCString name
      setFbfrontDevNodename dev name'
      let path = name ++ "/backend-id"
      dom <- withCString path xenbusReadInteger
      setFbfrontDevDom dev $ fromInteger $ toInteger dom
      handler <- getFbfrontHandler
      evtchn <- getFbfrontDevEvtchnPtr dev
      evtchnAllocUnbound (fromInteger $ toInteger dom) handler (castPtr dev) evtchn
      s <- allocPage
      setFbfrontDevPage dev s
      memset s 0 pageSize
      -- in
      setXenfbPageInCons s 0
      setXenfbPageInProd s 0
      -- out
      setXenfbPageOutCons s 0
      setXenfbPageOutProd s 0
      -- width
      setFbfrontDevWidth dev width
      setXenfbPageWidth  s   width
      -- height
      setFbfrontDevHeight dev height
      setXenfbPageHeight  s   height
      -- depth
      setFbfrontDevDepth dev depth
      setXenfbPageDepth  s   $ fromInteger $ toInteger depth
      -- stride
      setFbfrontDevStride dev stride
      setXenfbPageLineLength s $ fromInteger $ toInteger stride
      -- mem align
      setFbfrontDevMemLength dev $ fromInteger $ toInteger $ n * pageSize
      setXenfbPageMemLength s $ n * pageSize
      -- other
      setFbfrontDevOffset dev 0
      setFbfrontDevEvents dev nullPtr
      return nullPtr
{-
  printk("******************* FBFRONT for %s **********\n\n\n", nodename);

    dev = malloc(sizeof(*dev));
    memset(dev, 0, sizeof(*dev));
    dev->nodename = strdup(nodename);
#ifdef HAVE_LIBC
    dev->fd = -1;
#endif

    snprintf(path, sizeof(path), "%s/backend-id", nodename);
    dev->dom = xenbus_read_integer(path);
    evtchn_alloc_unbound(dev->dom, fbfront_handler, dev, &dev->evtchn);

    dev->page = s = (struct xenfb_page*) alloc_page();
    memset(s,0,PAGE_SIZE);

    s->in_cons = s->in_prod = 0;
    s->out_cons = s->out_prod = 0;
    dev->width = s->width = width;
    dev->height = s->height = height;
    dev->depth = s->depth = depth;
    dev->stride = s->line_length = stride;
    dev->mem_length = s->mem_length = n * PAGE_SIZE;
    dev->offset = 0;
    dev->events = NULL;

    max_pd = sizeof(s->pd) / sizeof(s->pd[0]);
    mapped = 0;

    for (i = 0; mapped < n && i < max_pd; i++) {
        unsigned long *pd = (unsigned long *) alloc_page();
        for (j = 0; mapped < n && j < PAGE_SIZE / sizeof(unsigned long); j++)
            pd[j] = mfns[mapped++];
        for ( ; j < PAGE_SIZE / sizeof(unsigned long); j++)
            pd[j] = 0;
        s->pd[i] = virt_to_mfn(pd);
    }
    for ( ; i < max_pd; i++)
        s->pd[i] = 0;


 -
 - -}
    --printk("******************* FBFRONT for %s **********\n\n\n", nodename);

againTransaction = undefined
abortTransaction = undefined
fbfrontDone = undefined
fbfrontError = undefined


