/****************************************************************************
 * Grainuum Software USB Stack                                              *
 *                                                                          *
 * MIT License:                                                             *
 * Copyright (c) 2016 Sean Cross                                            *
 *                                                                          *
 * Permission is hereby granted, free of charge, to any person obtaining a  *
 * copy of this software and associated documentation files (the            *
 * "Software"), to deal in the Software without restriction, including      *
 * without limitation the rights to use, copy, modify, merge, publish,      *
 * distribute, distribute with modifications, sublicense, and/or sell       *
 * copies of the Software, and to permit persons to whom the Software is    *
 * furnished to do so, subject to the following conditions:                 *
 *                                                                          *
 * The above copyright notice and this permission notice shall be included  *
 * in all copies or substantial portions of the Software.                   *
 *                                                                          *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  *
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               *
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   *
 * IN NO EVENT SHALL THE ABOVE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,   *
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR    *
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR    *
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               *
 *                                                                          *
 * Except as contained in this notice, the name(s) of the above copyright   *
 * holders shall not be used in advertising or otherwise to promote the     *
 * sale, use or other dealings in this Software without prior written       *
 * authorization.                                                           *
 ****************************************************************************/

#include <generated/csr.h>
#include <grainuum.h>
#include <printf.h>

__attribute__((weak)) void grainuumConnectPre(struct GrainuumUSB *usb)
{
  (void)usb;
}
__attribute__((weak)) void grainuumConnectPost(struct GrainuumUSB *usb)
{
  (void)usb;
}

__attribute__((weak)) void grainuumDisconnectPre(struct GrainuumUSB *usb)
{
  (void)usb;
}
__attribute__((weak)) void grainuumDisconnectPost(struct GrainuumUSB *usb)
{
  (void)usb;
}

__attribute__((weak)) void grainuumReceivePacket(struct GrainuumUSB *usb)
{
  (void)usb;
}

__attribute__((weak)) void grainuumInitPre(struct GrainuumUSB *usb)
{
  (void)usb;
}

__attribute__((weak)) void grainuumInitPost(struct GrainuumUSB *usb)
{
  (void)usb;
}

/* --- */

void grainuum_receive_packet(struct GrainuumUSB *usb)
{
  grainuumReceivePacket(usb);
}

int grainuumCaptureI(struct GrainuumUSB *usb, uint8_t samples[67])
{
#if 0
  int ret;
  const uint8_t nak_pkt[] = {USB_PID_NAK};
  const uint8_t ack_pkt[] = {USB_PID_ACK};

  ret = usbPhyReadI(usb, samples);
  if (ret <= 0) {
    if (ret != -1)
      usbPhyWriteI(usb, nak_pkt, sizeof(nak_pkt));
    return 0;
  }

  /* Save the byte counter for later inspection */
  samples[11] = ret;

  switch (samples[0]) {
  case USB_PID_IN:
    /* Make sure we have queued data, and that it's for this particular EP */
    if ((!usb->queued_size)
    || (((((const uint16_t *)(samples+1))[0] >> 7) & 0xf) != usb->queued_epnum))
    {
      usbPhyWriteI(usb, nak_pkt, sizeof(nak_pkt));
      break;
    }

    usbPhyWriteI(usb, usb->queued_data, usb->queued_size);
    break;

  case USB_PID_SETUP:
    grainuum_receive_packet(usb);
    break;

  case USB_PID_OUT:
    grainuum_receive_packet(usb);
    break;

  case USB_PID_ACK:
    /* Allow the next byte to be sent */
    usb->queued_size = 0;
    grainuum_receive_packet(usb);
    break;

  case USB_PID_DATA0:
  case USB_PID_DATA1:
    usbPhyWriteI(usb, ack_pkt, sizeof(ack_pkt));
    grainuum_receive_packet(usb);
    break;

  default:
    usbPhyWriteI(usb, nak_pkt, sizeof(nak_pkt));
    break;
  }

  return ret;
#endif
  uint8_t obufbuf[128];
  uint32_t obufbuf_cnt = 0;
  while (!usb_ep_0_out_obuf_empty_read())
  {
    uint32_t obh = usb_ep_0_out_obuf_head_read();
    obufbuf[obufbuf_cnt++] = obh;
    usb_ep_0_out_obuf_head_write(1);
  }

  int i;
  static int loops;
  uint8_t last_tok = usb_ep_0_out_last_tok_read();
  printf("i: %d  b: %d olt: %02x  --", loops, obufbuf_cnt, last_tok); //obe: %d  obh: %02x\n", i, obe, obh);
  for (i = 0; i < obufbuf_cnt; i++)
  {
    printf(" %02x", obufbuf[i]);
  }
  printf("\n");

  usb_ep_0_out_ev_pending_write((1 << 1));

  // Response
  if (!usb_ep_0_in_ibuf_empty_read())
  {
    printf("USB ibuf still has data\n");
    return 0;
  }

  uint32_t usb_in_pending = usb_ep_0_out_ev_pending_read();
  if (usb_in_pending)
  {
    printf("USB EP0 in pending is: %02x\n", usb_in_pending);
    return 0;
  }

  grainuumProcess(usb, last_tok, obufbuf, obufbuf_cnt);

  return 0;
}

int grainuumInitialized(struct GrainuumUSB *usb)
{
  if (!usb)
    return 0;

  return usb->initialized;
}

enum usb_responses {
  USB_STALL = 0b11,
  USB_ACK   = 0b00,
  USB_NAK   = 0b01,
  USB_NONE  = 0b10,
};

void grainuumWriteQueue(struct GrainuumUSB *usb, int epnum,
                        const void *buffer, int size)
{
  usb->queued_data = buffer;
  usb->queued_epnum = epnum;
  usb->queued_size = size;

  int i;
  const uint8_t *buffer_u8 = buffer;
  for (i = 0; i < size; i++)
  {
    usb_ep_0_in_ibuf_head_write(buffer_u8[i]);
  }
  // Indicate that we respond with an ACK
  usb_ep_0_in_respond_write(USB_ACK);
  usb_ep_0_in_ev_pending_write(0xff);
}

void grainuumInit(struct GrainuumUSB *usb,
                  struct GrainuumConfig *cfg)
{

  if (usb->initialized)
    return;

  printf("Initializing USB to %08x, cfg to 0x%08x  0x%08x\n", usb, cfg, cfg->getDescriptor);
  grainuumInitPre(usb);

  usb->cfg = cfg;
  usb->state.usb = usb;
  cfg->usb = usb;

  usb->initialized = 1;

  grainuumInitPost(usb);
}

void grainuumDisconnect(struct GrainuumUSB *usb)
{

  grainuumDisconnectPre(usb);

  usb_pullup_out_write(0);

  grainuumDisconnectPost(usb);
}

void grainuumConnect(struct GrainuumUSB *usb)
{

  grainuumConnectPre(usb);

  usb_pullup_out_write(1);

  grainuumConnectPost(usb);
}
