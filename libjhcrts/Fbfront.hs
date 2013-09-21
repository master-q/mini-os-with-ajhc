module Fbfront where
import Foreign.C.String
import Foreign.Ptr
import Data.Word
import Util
import FbfrontStub

foreign export ccall "_nit_fbfront" initFbfront :: CString -> Ptr Word64 -> Int -> Int -> Int -> Int -> Int -> IO (Ptr Word8)
initFbfront nodename mfns width height depth stride n = setupTranscation nodename

setupTranscation nodename =
  do  name <- if nodename == nullPtr then return "device/vfb/0" else peekCString nodename
      printk $ "******************* FBFRONT for " ++ name ++ " **********\n\n\n"
      dev <- mkFbfrontDev
      name' <- newCString name
      setFbfrontDevNodename dev name'
      let path = name ++ "/backend-id"
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


