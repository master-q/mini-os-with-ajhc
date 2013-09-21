struct xenfb_page {
};

struct fbfront_dev {
  uint16_t dom;

    struct xenfb_page* page;
    uint32_t evtchn;

    char* nodename;
    char* backend;
    int request_update;

    int width;
    int height;
    int depth;
    int stride;
    int mem_length;
    int offset;

    struct xenbus_event* events;
};
