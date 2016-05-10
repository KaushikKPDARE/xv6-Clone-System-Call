
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 d0 37 10 80       	mov    $0x801037d0,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 60 88 10 	movl   $0x80108860,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 50 51 00 00       	call   8010519e <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100055:	05 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
8010005f:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 05 11 80       	mov    0x80110574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 fd 50 00 00       	call   801051bf <acquire>

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 05 11 80       	mov    0x80110574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->blockno == blockno){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 18 51 00 00       	call   80105221 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 cd 4a 00 00       	call   80104bf1 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 05 11 80       	mov    0x80110570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 a0 50 00 00       	call   80105221 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 67 88 10 80 	movl   $0x80108867,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 86 26 00 00       	call   8010285e <iderw>
  }
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 78 88 10 80 	movl   $0x80108878,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 49 26 00 00       	call   8010285e <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 7f 88 10 80 	movl   $0x8010887f,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 7e 4f 00 00       	call   801051bf <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 05 11 80       	mov    0x80110574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 28 4a 00 00       	call   80104cca <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 73 4f 00 00       	call   80105221 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 dc 03 00 00       	call   8010076b <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bb:	e8 ff 4d 00 00       	call   801051bf <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 86 88 10 80 	movl   $0x80108886,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 75 03 00 00       	call   8010076b <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 8f 88 10 80 	movl   $0x8010888f,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 9f 02 00 00       	call   8010076b <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 83 02 00 00       	call   8010076b <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 75 02 00 00       	call   8010076b <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 6a 02 00 00       	call   8010076b <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100533:	e8 e9 4c 00 00       	call   80105221 <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 96 88 10 80 	movl   $0x80108896,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 a5 88 10 80 	movl   $0x801088a5,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 dc 4c 00 00       	call   80105270 <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 a7 88 10 80 	movl   $0x801088a7,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
8010068a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068e:	78 09                	js     80100699 <cgaputc+0xcf>
80100690:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100697:	7e 0c                	jle    801006a5 <cgaputc+0xdb>
    panic("pos under/overflow");
80100699:	c7 04 24 ab 88 10 80 	movl   $0x801088ab,(%esp)
801006a0:	e8 95 fe ff ff       	call   8010053a <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006a5:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ac:	7e 53                	jle    80100701 <cgaputc+0x137>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006ae:	a1 00 90 10 80       	mov    0x80109000,%eax
801006b3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b9:	a1 00 90 10 80       	mov    0x80109000,%eax
801006be:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c5:	00 
801006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801006ca:	89 04 24             	mov    %eax,(%esp)
801006cd:	e8 13 4e 00 00       	call   801054e5 <memmove>
    pos -= 80;
801006d2:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d6:	b8 80 07 00 00       	mov    $0x780,%eax
801006db:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006de:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006e1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006e9:	01 c9                	add    %ecx,%ecx
801006eb:	01 c8                	add    %ecx,%eax
801006ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801006f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f8:	00 
801006f9:	89 04 24             	mov    %eax,(%esp)
801006fc:	e8 15 4d 00 00       	call   80105416 <memset>
  }
  
  outb(CRTPORT, 14);
80100701:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100708:	00 
80100709:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100710:	e8 b8 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
80100715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100718:	c1 f8 08             	sar    $0x8,%eax
8010071b:	0f b6 c0             	movzbl %al,%eax
8010071e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100722:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100729:	e8 9f fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
8010072e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100735:	00 
80100736:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010073d:	e8 8b fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100745:	0f b6 c0             	movzbl %al,%eax
80100748:	89 44 24 04          	mov    %eax,0x4(%esp)
8010074c:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100753:	e8 75 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
80100758:	a1 00 90 10 80       	mov    0x80109000,%eax
8010075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100760:	01 d2                	add    %edx,%edx
80100762:	01 d0                	add    %edx,%eax
80100764:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100769:	c9                   	leave  
8010076a:	c3                   	ret    

8010076b <consputc>:

void
consputc(int c)
{
8010076b:	55                   	push   %ebp
8010076c:	89 e5                	mov    %esp,%ebp
8010076e:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100771:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100776:	85 c0                	test   %eax,%eax
80100778:	74 07                	je     80100781 <consputc+0x16>
    cli();
8010077a:	e8 6c fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
8010077f:	eb fe                	jmp    8010077f <consputc+0x14>
  }

  if(c == BACKSPACE){
80100781:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100788:	75 26                	jne    801007b0 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100791:	e8 05 67 00 00       	call   80106e9b <uartputc>
80100796:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079d:	e8 f9 66 00 00       	call   80106e9b <uartputc>
801007a2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a9:	e8 ed 66 00 00       	call   80106e9b <uartputc>
801007ae:	eb 0b                	jmp    801007bb <consputc+0x50>
  } else
    uartputc(c);
801007b0:	8b 45 08             	mov    0x8(%ebp),%eax
801007b3:	89 04 24             	mov    %eax,(%esp)
801007b6:	e8 e0 66 00 00       	call   80106e9b <uartputc>
  cgaputc(c);
801007bb:	8b 45 08             	mov    0x8(%ebp),%eax
801007be:	89 04 24             	mov    %eax,(%esp)
801007c1:	e8 04 fe ff ff       	call   801005ca <cgaputc>
}
801007c6:	c9                   	leave  
801007c7:	c3                   	ret    

801007c8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007c8:	55                   	push   %ebp
801007c9:	89 e5                	mov    %esp,%ebp
801007cb:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007d5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801007dc:	e8 de 49 00 00       	call   801051bf <acquire>
  while((c = getc()) >= 0){
801007e1:	e9 39 01 00 00       	jmp    8010091f <consoleintr+0x157>
    switch(c){
801007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801007e9:	83 f8 10             	cmp    $0x10,%eax
801007ec:	74 1e                	je     8010080c <consoleintr+0x44>
801007ee:	83 f8 10             	cmp    $0x10,%eax
801007f1:	7f 0a                	jg     801007fd <consoleintr+0x35>
801007f3:	83 f8 08             	cmp    $0x8,%eax
801007f6:	74 66                	je     8010085e <consoleintr+0x96>
801007f8:	e9 93 00 00 00       	jmp    80100890 <consoleintr+0xc8>
801007fd:	83 f8 15             	cmp    $0x15,%eax
80100800:	74 31                	je     80100833 <consoleintr+0x6b>
80100802:	83 f8 7f             	cmp    $0x7f,%eax
80100805:	74 57                	je     8010085e <consoleintr+0x96>
80100807:	e9 84 00 00 00       	jmp    80100890 <consoleintr+0xc8>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010080c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100813:	e9 07 01 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100818:	a1 08 08 11 80       	mov    0x80110808,%eax
8010081d:	83 e8 01             	sub    $0x1,%eax
80100820:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
80100825:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010082c:	e8 3a ff ff ff       	call   8010076b <consputc>
80100831:	eb 01                	jmp    80100834 <consoleintr+0x6c>
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100833:	90                   	nop
80100834:	8b 15 08 08 11 80    	mov    0x80110808,%edx
8010083a:	a1 04 08 11 80       	mov    0x80110804,%eax
8010083f:	39 c2                	cmp    %eax,%edx
80100841:	74 16                	je     80100859 <consoleintr+0x91>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100843:	a1 08 08 11 80       	mov    0x80110808,%eax
80100848:	83 e8 01             	sub    $0x1,%eax
8010084b:	83 e0 7f             	and    $0x7f,%eax
8010084e:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100855:	3c 0a                	cmp    $0xa,%al
80100857:	75 bf                	jne    80100818 <consoleintr+0x50>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100859:	e9 c1 00 00 00       	jmp    8010091f <consoleintr+0x157>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010085e:	8b 15 08 08 11 80    	mov    0x80110808,%edx
80100864:	a1 04 08 11 80       	mov    0x80110804,%eax
80100869:	39 c2                	cmp    %eax,%edx
8010086b:	74 1e                	je     8010088b <consoleintr+0xc3>
        input.e--;
8010086d:	a1 08 08 11 80       	mov    0x80110808,%eax
80100872:	83 e8 01             	sub    $0x1,%eax
80100875:	a3 08 08 11 80       	mov    %eax,0x80110808
        consputc(BACKSPACE);
8010087a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100881:	e8 e5 fe ff ff       	call   8010076b <consputc>
      }
      break;
80100886:	e9 94 00 00 00       	jmp    8010091f <consoleintr+0x157>
8010088b:	e9 8f 00 00 00       	jmp    8010091f <consoleintr+0x157>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100894:	0f 84 84 00 00 00    	je     8010091e <consoleintr+0x156>
8010089a:	8b 15 08 08 11 80    	mov    0x80110808,%edx
801008a0:	a1 00 08 11 80       	mov    0x80110800,%eax
801008a5:	29 c2                	sub    %eax,%edx
801008a7:	89 d0                	mov    %edx,%eax
801008a9:	83 f8 7f             	cmp    $0x7f,%eax
801008ac:	77 70                	ja     8010091e <consoleintr+0x156>
        c = (c == '\r') ? '\n' : c;
801008ae:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008b2:	74 05                	je     801008b9 <consoleintr+0xf1>
801008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008b7:	eb 05                	jmp    801008be <consoleintr+0xf6>
801008b9:	b8 0a 00 00 00       	mov    $0xa,%eax
801008be:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008c1:	a1 08 08 11 80       	mov    0x80110808,%eax
801008c6:	8d 50 01             	lea    0x1(%eax),%edx
801008c9:	89 15 08 08 11 80    	mov    %edx,0x80110808
801008cf:	83 e0 7f             	and    $0x7f,%eax
801008d2:	89 c2                	mov    %eax,%edx
801008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008d7:	88 82 80 07 11 80    	mov    %al,-0x7feef880(%edx)
        consputc(c);
801008dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008e0:	89 04 24             	mov    %eax,(%esp)
801008e3:	e8 83 fe ff ff       	call   8010076b <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008e8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801008ec:	74 18                	je     80100906 <consoleintr+0x13e>
801008ee:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801008f2:	74 12                	je     80100906 <consoleintr+0x13e>
801008f4:	a1 08 08 11 80       	mov    0x80110808,%eax
801008f9:	8b 15 00 08 11 80    	mov    0x80110800,%edx
801008ff:	83 ea 80             	sub    $0xffffff80,%edx
80100902:	39 d0                	cmp    %edx,%eax
80100904:	75 18                	jne    8010091e <consoleintr+0x156>
          input.w = input.e;
80100906:	a1 08 08 11 80       	mov    0x80110808,%eax
8010090b:	a3 04 08 11 80       	mov    %eax,0x80110804
          wakeup(&input.r);
80100910:	c7 04 24 00 08 11 80 	movl   $0x80110800,(%esp)
80100917:	e8 ae 43 00 00       	call   80104cca <wakeup>
        }
      }
      break;
8010091c:	eb 00                	jmp    8010091e <consoleintr+0x156>
8010091e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010091f:	8b 45 08             	mov    0x8(%ebp),%eax
80100922:	ff d0                	call   *%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100927:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010092b:	0f 89 b5 fe ff ff    	jns    801007e6 <consoleintr+0x1e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100931:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100938:	e8 e4 48 00 00       	call   80105221 <release>
  if(doprocdump) {
8010093d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100941:	74 05                	je     80100948 <consoleintr+0x180>
    procdump();  // now call procdump() wo. cons.lock held
80100943:	e8 6d 45 00 00       	call   80104eb5 <procdump>
  }
}
80100948:	c9                   	leave  
80100949:	c3                   	ret    

8010094a <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010094a:	55                   	push   %ebp
8010094b:	89 e5                	mov    %esp,%ebp
8010094d:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	89 04 24             	mov    %eax,(%esp)
80100956:	e8 d1 10 00 00       	call   80101a2c <iunlock>
  target = n;
8010095b:	8b 45 10             	mov    0x10(%ebp),%eax
8010095e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100961:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100968:	e8 52 48 00 00       	call   801051bf <acquire>
  while(n > 0){
8010096d:	e9 aa 00 00 00       	jmp    80100a1c <consoleread+0xd2>
    while(input.r == input.w){
80100972:	eb 42                	jmp    801009b6 <consoleread+0x6c>
      if(proc->killed){
80100974:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010097a:	8b 40 24             	mov    0x24(%eax),%eax
8010097d:	85 c0                	test   %eax,%eax
8010097f:	74 21                	je     801009a2 <consoleread+0x58>
        release(&cons.lock);
80100981:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100988:	e8 94 48 00 00       	call   80105221 <release>
        ilock(ip);
8010098d:	8b 45 08             	mov    0x8(%ebp),%eax
80100990:	89 04 24             	mov    %eax,(%esp)
80100993:	e8 40 0f 00 00       	call   801018d8 <ilock>
        return -1;
80100998:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099d:	e9 a5 00 00 00       	jmp    80100a47 <consoleread+0xfd>
      }
      sleep(&input.r, &cons.lock);
801009a2:	c7 44 24 04 c0 b5 10 	movl   $0x8010b5c0,0x4(%esp)
801009a9:	80 
801009aa:	c7 04 24 00 08 11 80 	movl   $0x80110800,(%esp)
801009b1:	e8 3b 42 00 00       	call   80104bf1 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
801009b6:	8b 15 00 08 11 80    	mov    0x80110800,%edx
801009bc:	a1 04 08 11 80       	mov    0x80110804,%eax
801009c1:	39 c2                	cmp    %eax,%edx
801009c3:	74 af                	je     80100974 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009c5:	a1 00 08 11 80       	mov    0x80110800,%eax
801009ca:	8d 50 01             	lea    0x1(%eax),%edx
801009cd:	89 15 00 08 11 80    	mov    %edx,0x80110800
801009d3:	83 e0 7f             	and    $0x7f,%eax
801009d6:	0f b6 80 80 07 11 80 	movzbl -0x7feef880(%eax),%eax
801009dd:	0f be c0             	movsbl %al,%eax
801009e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009e3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009e7:	75 19                	jne    80100a02 <consoleread+0xb8>
      if(n < target){
801009e9:	8b 45 10             	mov    0x10(%ebp),%eax
801009ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009ef:	73 0f                	jae    80100a00 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009f1:	a1 00 08 11 80       	mov    0x80110800,%eax
801009f6:	83 e8 01             	sub    $0x1,%eax
801009f9:	a3 00 08 11 80       	mov    %eax,0x80110800
      }
      break;
801009fe:	eb 26                	jmp    80100a26 <consoleread+0xdc>
80100a00:	eb 24                	jmp    80100a26 <consoleread+0xdc>
    }
    *dst++ = c;
80100a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a05:	8d 50 01             	lea    0x1(%eax),%edx
80100a08:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a0e:	88 10                	mov    %dl,(%eax)
    --n;
80100a10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a14:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a18:	75 02                	jne    80100a1c <consoleread+0xd2>
      break;
80100a1a:	eb 0a                	jmp    80100a26 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a20:	0f 8f 4c ff ff ff    	jg     80100972 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100a26:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a2d:	e8 ef 47 00 00       	call   80105221 <release>
  ilock(ip);
80100a32:	8b 45 08             	mov    0x8(%ebp),%eax
80100a35:	89 04 24             	mov    %eax,(%esp)
80100a38:	e8 9b 0e 00 00       	call   801018d8 <ilock>

  return target - n;
80100a3d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	29 c2                	sub    %eax,%edx
80100a45:	89 d0                	mov    %edx,%eax
}
80100a47:	c9                   	leave  
80100a48:	c3                   	ret    

80100a49 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a49:	55                   	push   %ebp
80100a4a:	89 e5                	mov    %esp,%ebp
80100a4c:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80100a52:	89 04 24             	mov    %eax,(%esp)
80100a55:	e8 d2 0f 00 00       	call   80101a2c <iunlock>
  acquire(&cons.lock);
80100a5a:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a61:	e8 59 47 00 00       	call   801051bf <acquire>
  for(i = 0; i < n; i++)
80100a66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a6d:	eb 1d                	jmp    80100a8c <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a75:	01 d0                	add    %edx,%eax
80100a77:	0f b6 00             	movzbl (%eax),%eax
80100a7a:	0f be c0             	movsbl %al,%eax
80100a7d:	0f b6 c0             	movzbl %al,%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e3 fc ff ff       	call   8010076b <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a88:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a8f:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a92:	7c db                	jl     80100a6f <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a94:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a9b:	e8 81 47 00 00       	call   80105221 <release>
  ilock(ip);
80100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 2d 0e 00 00       	call   801018d8 <ilock>

  return n;
80100aab:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100aae:	c9                   	leave  
80100aaf:	c3                   	ret    

80100ab0 <consoleinit>:

void
consoleinit(void)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100ab6:	c7 44 24 04 be 88 10 	movl   $0x801088be,0x4(%esp)
80100abd:	80 
80100abe:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100ac5:	e8 d4 46 00 00       	call   8010519e <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aca:	c7 05 cc 11 11 80 49 	movl   $0x80100a49,0x801111cc
80100ad1:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ad4:	c7 05 c8 11 11 80 4a 	movl   $0x8010094a,0x801111c8
80100adb:	09 10 80 
  cons.locking = 1;
80100ade:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100ae5:	00 00 00 

  picenable(IRQ_KBD);
80100ae8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100aef:	e8 79 33 00 00       	call   80103e6d <picenable>
  ioapicenable(IRQ_KBD, 0);
80100af4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100afb:	00 
80100afc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100b03:	e8 14 1f 00 00       	call   80102a1c <ioapicenable>
}
80100b08:	c9                   	leave  
80100b09:	c3                   	ret    
80100b0a:	66 90                	xchg   %ax,%ax

80100b0c <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b0c:	55                   	push   %ebp
80100b0d:	89 e5                	mov    %esp,%ebp
80100b0f:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b15:	e8 ae 29 00 00       	call   801034c8 <begin_op>
  if((ip = namei(path)) == 0){
80100b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80100b1d:	89 04 24             	mov    %eax,(%esp)
80100b20:	e8 64 19 00 00       	call   80102489 <namei>
80100b25:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b28:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b2c:	75 0f                	jne    80100b3d <exec+0x31>
    end_op();
80100b2e:	e8 19 2a 00 00       	call   8010354c <end_op>
    return -1;
80100b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b38:	e9 e8 03 00 00       	jmp    80100f25 <exec+0x419>
  }
  ilock(ip);
80100b3d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b40:	89 04 24             	mov    %eax,(%esp)
80100b43:	e8 90 0d 00 00       	call   801018d8 <ilock>
  pgdir = 0;
80100b48:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b4f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b56:	00 
80100b57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b5e:	00 
80100b5f:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b65:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b69:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b6c:	89 04 24             	mov    %eax,(%esp)
80100b6f:	e8 77 12 00 00       	call   80101deb <readi>
80100b74:	83 f8 33             	cmp    $0x33,%eax
80100b77:	77 05                	ja     80100b7e <exec+0x72>
    goto bad;
80100b79:	e9 7b 03 00 00       	jmp    80100ef9 <exec+0x3ed>
  if(elf.magic != ELF_MAGIC)
80100b7e:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b84:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b89:	74 05                	je     80100b90 <exec+0x84>
    goto bad;
80100b8b:	e9 69 03 00 00       	jmp    80100ef9 <exec+0x3ed>

  if((pgdir = setupkvm()) == 0)
80100b90:	e8 5c 74 00 00       	call   80107ff1 <setupkvm>
80100b95:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b98:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b9c:	75 05                	jne    80100ba3 <exec+0x97>
    goto bad;
80100b9e:	e9 56 03 00 00       	jmp    80100ef9 <exec+0x3ed>

  // Load program into memory.
  sz = 0;
80100ba3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100baa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bb1:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bba:	e9 cb 00 00 00       	jmp    80100c8a <exec+0x17e>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bc2:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bc9:	00 
80100bca:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bce:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bdb:	89 04 24             	mov    %eax,(%esp)
80100bde:	e8 08 12 00 00       	call   80101deb <readi>
80100be3:	83 f8 20             	cmp    $0x20,%eax
80100be6:	74 05                	je     80100bed <exec+0xe1>
      goto bad;
80100be8:	e9 0c 03 00 00       	jmp    80100ef9 <exec+0x3ed>
    if(ph.type != ELF_PROG_LOAD)
80100bed:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bf3:	83 f8 01             	cmp    $0x1,%eax
80100bf6:	74 05                	je     80100bfd <exec+0xf1>
      continue;
80100bf8:	e9 80 00 00 00       	jmp    80100c7d <exec+0x171>
    if(ph.memsz < ph.filesz)
80100bfd:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c03:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c09:	39 c2                	cmp    %eax,%edx
80100c0b:	73 05                	jae    80100c12 <exec+0x106>
      goto bad;
80100c0d:	e9 e7 02 00 00       	jmp    80100ef9 <exec+0x3ed>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c12:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c18:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c1e:	01 d0                	add    %edx,%eax
80100c20:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c24:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c27:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c2e:	89 04 24             	mov    %eax,(%esp)
80100c31:	e8 89 77 00 00       	call   801083bf <allocuvm>
80100c36:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c39:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c3d:	75 05                	jne    80100c44 <exec+0x138>
      goto bad;
80100c3f:	e9 b5 02 00 00       	jmp    80100ef9 <exec+0x3ed>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c44:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c4a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c50:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c56:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c5a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c5e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c61:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c65:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c6c:	89 04 24             	mov    %eax,(%esp)
80100c6f:	e8 60 76 00 00       	call   801082d4 <loaduvm>
80100c74:	85 c0                	test   %eax,%eax
80100c76:	79 05                	jns    80100c7d <exec+0x171>
      goto bad;
80100c78:	e9 7c 02 00 00       	jmp    80100ef9 <exec+0x3ed>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c7d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c84:	83 c0 20             	add    $0x20,%eax
80100c87:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c8a:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c91:	0f b7 c0             	movzwl %ax,%eax
80100c94:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c97:	0f 8f 22 ff ff ff    	jg     80100bbf <exec+0xb3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ca0:	89 04 24             	mov    %eax,(%esp)
80100ca3:	e8 ba 0e 00 00       	call   80101b62 <iunlockput>
  end_op();
80100ca8:	e8 9f 28 00 00       	call   8010354c <end_op>
  ip = 0;
80100cad:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb7:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc7:	05 00 20 00 00       	add    $0x2000,%eax
80100ccc:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cda:	89 04 24             	mov    %eax,(%esp)
80100cdd:	e8 dd 76 00 00       	call   801083bf <allocuvm>
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce9:	75 05                	jne    80100cf0 <exec+0x1e4>
    goto bad;
80100ceb:	e9 09 02 00 00       	jmp    80100ef9 <exec+0x3ed>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cff:	89 04 24             	mov    %eax,(%esp)
80100d02:	e8 e8 78 00 00       	call   801085ef <clearpteu>
  sp = sz;
80100d07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0a:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d0d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d14:	e9 9a 00 00 00       	jmp    80100db3 <exec+0x2a7>
    if(argc >= MAXARG)
80100d19:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d1d:	76 05                	jbe    80100d24 <exec+0x218>
      goto bad;
80100d1f:	e9 d5 01 00 00       	jmp    80100ef9 <exec+0x3ed>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d31:	01 d0                	add    %edx,%eax
80100d33:	8b 00                	mov    (%eax),%eax
80100d35:	89 04 24             	mov    %eax,(%esp)
80100d38:	e8 43 49 00 00       	call   80105680 <strlen>
80100d3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d40:	29 c2                	sub    %eax,%edx
80100d42:	89 d0                	mov    %edx,%eax
80100d44:	83 e8 01             	sub    $0x1,%eax
80100d47:	83 e0 fc             	and    $0xfffffffc,%eax
80100d4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d57:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5a:	01 d0                	add    %edx,%eax
80100d5c:	8b 00                	mov    (%eax),%eax
80100d5e:	89 04 24             	mov    %eax,(%esp)
80100d61:	e8 1a 49 00 00       	call   80105680 <strlen>
80100d66:	83 c0 01             	add    $0x1,%eax
80100d69:	89 c2                	mov    %eax,%edx
80100d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d75:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d78:	01 c8                	add    %ecx,%eax
80100d7a:	8b 00                	mov    (%eax),%eax
80100d7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d80:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d8e:	89 04 24             	mov    %eax,(%esp)
80100d91:	e8 1e 7a 00 00       	call   801087b4 <copyout>
80100d96:	85 c0                	test   %eax,%eax
80100d98:	79 05                	jns    80100d9f <exec+0x293>
      goto bad;
80100d9a:	e9 5a 01 00 00       	jmp    80100ef9 <exec+0x3ed>
    ustack[3+argc] = sp;
80100d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da2:	8d 50 03             	lea    0x3(%eax),%edx
80100da5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da8:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100daf:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100db3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc0:	01 d0                	add    %edx,%eax
80100dc2:	8b 00                	mov    (%eax),%eax
80100dc4:	85 c0                	test   %eax,%eax
80100dc6:	0f 85 4d ff ff ff    	jne    80100d19 <exec+0x20d>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcf:	83 c0 03             	add    $0x3,%eax
80100dd2:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dd9:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ddd:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100de4:	ff ff ff 
  ustack[1] = argc;
80100de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dea:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df3:	83 c0 01             	add    $0x1,%eax
80100df6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e00:	29 d0                	sub    %edx,%eax
80100e02:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0b:	83 c0 04             	add    $0x4,%eax
80100e0e:	c1 e0 02             	shl    $0x2,%eax
80100e11:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e17:	83 c0 04             	add    $0x4,%eax
80100e1a:	c1 e0 02             	shl    $0x2,%eax
80100e1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e21:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e27:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e35:	89 04 24             	mov    %eax,(%esp)
80100e38:	e8 77 79 00 00       	call   801087b4 <copyout>
80100e3d:	85 c0                	test   %eax,%eax
80100e3f:	79 05                	jns    80100e46 <exec+0x33a>
    goto bad;
80100e41:	e9 b3 00 00 00       	jmp    80100ef9 <exec+0x3ed>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e46:	8b 45 08             	mov    0x8(%ebp),%eax
80100e49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e52:	eb 17                	jmp    80100e6b <exec+0x35f>
    if(*s == '/')
80100e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e57:	0f b6 00             	movzbl (%eax),%eax
80100e5a:	3c 2f                	cmp    $0x2f,%al
80100e5c:	75 09                	jne    80100e67 <exec+0x35b>
      last = s+1;
80100e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e61:	83 c0 01             	add    $0x1,%eax
80100e64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6e:	0f b6 00             	movzbl (%eax),%eax
80100e71:	84 c0                	test   %al,%al
80100e73:	75 df                	jne    80100e54 <exec+0x348>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7b:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e7e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e85:	00 
80100e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e89:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e8d:	89 14 24             	mov    %edx,(%esp)
80100e90:	e8 a1 47 00 00       	call   80105636 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9b:	8b 40 04             	mov    0x4(%eax),%eax
80100e9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ea1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eaa:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb3:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb6:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebe:	8b 40 18             	mov    0x18(%eax),%eax
80100ec1:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ec7:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed0:	8b 40 18             	mov    0x18(%eax),%eax
80100ed3:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed6:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100edf:	89 04 24             	mov    %eax,(%esp)
80100ee2:	e8 fb 71 00 00       	call   801080e2 <switchuvm>
  freevm(oldpgdir);
80100ee7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eea:	89 04 24             	mov    %eax,(%esp)
80100eed:	e8 63 76 00 00       	call   80108555 <freevm>
  return 0;
80100ef2:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef7:	eb 2c                	jmp    80100f25 <exec+0x419>

 bad:
  if(pgdir)
80100ef9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100efd:	74 0b                	je     80100f0a <exec+0x3fe>
    freevm(pgdir);
80100eff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f02:	89 04 24             	mov    %eax,(%esp)
80100f05:	e8 4b 76 00 00       	call   80108555 <freevm>
  if(ip){
80100f0a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f0e:	74 10                	je     80100f20 <exec+0x414>
    iunlockput(ip);
80100f10:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f13:	89 04 24             	mov    %eax,(%esp)
80100f16:	e8 47 0c 00 00       	call   80101b62 <iunlockput>
    end_op();
80100f1b:	e8 2c 26 00 00       	call   8010354c <end_op>
  }
  return -1;
80100f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f25:	c9                   	leave  
80100f26:	c3                   	ret    
80100f27:	90                   	nop

80100f28 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f28:	55                   	push   %ebp
80100f29:	89 e5                	mov    %esp,%ebp
80100f2b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f2e:	c7 44 24 04 c6 88 10 	movl   $0x801088c6,0x4(%esp)
80100f35:	80 
80100f36:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100f3d:	e8 5c 42 00 00       	call   8010519e <initlock>
}
80100f42:	c9                   	leave  
80100f43:	c3                   	ret    

80100f44 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f44:	55                   	push   %ebp
80100f45:	89 e5                	mov    %esp,%ebp
80100f47:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f4a:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100f51:	e8 69 42 00 00       	call   801051bf <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f56:	c7 45 f4 54 08 11 80 	movl   $0x80110854,-0xc(%ebp)
80100f5d:	eb 29                	jmp    80100f88 <filealloc+0x44>
    if(f->ref == 0){
80100f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f62:	8b 40 04             	mov    0x4(%eax),%eax
80100f65:	85 c0                	test   %eax,%eax
80100f67:	75 1b                	jne    80100f84 <filealloc+0x40>
      f->ref = 1;
80100f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f6c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f73:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100f7a:	e8 a2 42 00 00       	call   80105221 <release>
      return f;
80100f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f82:	eb 1e                	jmp    80100fa2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f84:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f88:	81 7d f4 b4 11 11 80 	cmpl   $0x801111b4,-0xc(%ebp)
80100f8f:	72 ce                	jb     80100f5f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f91:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100f98:	e8 84 42 00 00       	call   80105221 <release>
  return 0;
80100f9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fa2:	c9                   	leave  
80100fa3:	c3                   	ret    

80100fa4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fa4:	55                   	push   %ebp
80100fa5:	89 e5                	mov    %esp,%ebp
80100fa7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100faa:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100fb1:	e8 09 42 00 00       	call   801051bf <acquire>
  if(f->ref < 1)
80100fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb9:	8b 40 04             	mov    0x4(%eax),%eax
80100fbc:	85 c0                	test   %eax,%eax
80100fbe:	7f 0c                	jg     80100fcc <filedup+0x28>
    panic("filedup");
80100fc0:	c7 04 24 cd 88 10 80 	movl   $0x801088cd,(%esp)
80100fc7:	e8 6e f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcf:	8b 40 04             	mov    0x4(%eax),%eax
80100fd2:	8d 50 01             	lea    0x1(%eax),%edx
80100fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fdb:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100fe2:	e8 3a 42 00 00       	call   80105221 <release>
  return f;
80100fe7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fea:	c9                   	leave  
80100feb:	c3                   	ret    

80100fec <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fec:	55                   	push   %ebp
80100fed:	89 e5                	mov    %esp,%ebp
80100fef:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100ff2:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80100ff9:	e8 c1 41 00 00       	call   801051bf <acquire>
  if(f->ref < 1)
80100ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80101001:	8b 40 04             	mov    0x4(%eax),%eax
80101004:	85 c0                	test   %eax,%eax
80101006:	7f 0c                	jg     80101014 <fileclose+0x28>
    panic("fileclose");
80101008:	c7 04 24 d5 88 10 80 	movl   $0x801088d5,(%esp)
8010100f:	e8 26 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80101014:	8b 45 08             	mov    0x8(%ebp),%eax
80101017:	8b 40 04             	mov    0x4(%eax),%eax
8010101a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010101d:	8b 45 08             	mov    0x8(%ebp),%eax
80101020:	89 50 04             	mov    %edx,0x4(%eax)
80101023:	8b 45 08             	mov    0x8(%ebp),%eax
80101026:	8b 40 04             	mov    0x4(%eax),%eax
80101029:	85 c0                	test   %eax,%eax
8010102b:	7e 11                	jle    8010103e <fileclose+0x52>
    release(&ftable.lock);
8010102d:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
80101034:	e8 e8 41 00 00       	call   80105221 <release>
80101039:	e9 82 00 00 00       	jmp    801010c0 <fileclose+0xd4>
    return;
  }
  ff = *f;
8010103e:	8b 45 08             	mov    0x8(%ebp),%eax
80101041:	8b 10                	mov    (%eax),%edx
80101043:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101046:	8b 50 04             	mov    0x4(%eax),%edx
80101049:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010104c:	8b 50 08             	mov    0x8(%eax),%edx
8010104f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101052:	8b 50 0c             	mov    0xc(%eax),%edx
80101055:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101058:	8b 50 10             	mov    0x10(%eax),%edx
8010105b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010105e:	8b 40 14             	mov    0x14(%eax),%eax
80101061:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101064:	8b 45 08             	mov    0x8(%ebp),%eax
80101067:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010106e:	8b 45 08             	mov    0x8(%ebp),%eax
80101071:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101077:	c7 04 24 20 08 11 80 	movl   $0x80110820,(%esp)
8010107e:	e8 9e 41 00 00       	call   80105221 <release>
  
  if(ff.type == FD_PIPE)
80101083:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101086:	83 f8 01             	cmp    $0x1,%eax
80101089:	75 18                	jne    801010a3 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010108b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010108f:	0f be d0             	movsbl %al,%edx
80101092:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101095:	89 54 24 04          	mov    %edx,0x4(%esp)
80101099:	89 04 24             	mov    %eax,(%esp)
8010109c:	e8 7e 30 00 00       	call   8010411f <pipeclose>
801010a1:	eb 1d                	jmp    801010c0 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a6:	83 f8 02             	cmp    $0x2,%eax
801010a9:	75 15                	jne    801010c0 <fileclose+0xd4>
    begin_op();
801010ab:	e8 18 24 00 00       	call   801034c8 <begin_op>
    iput(ff.ip);
801010b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010b3:	89 04 24             	mov    %eax,(%esp)
801010b6:	e8 d6 09 00 00       	call   80101a91 <iput>
    end_op();
801010bb:	e8 8c 24 00 00       	call   8010354c <end_op>
  }
}
801010c0:	c9                   	leave  
801010c1:	c3                   	ret    

801010c2 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010c2:	55                   	push   %ebp
801010c3:	89 e5                	mov    %esp,%ebp
801010c5:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 00                	mov    (%eax),%eax
801010cd:	83 f8 02             	cmp    $0x2,%eax
801010d0:	75 38                	jne    8010110a <filestat+0x48>
    ilock(f->ip);
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 10             	mov    0x10(%eax),%eax
801010d8:	89 04 24             	mov    %eax,(%esp)
801010db:	e8 f8 07 00 00       	call   801018d8 <ilock>
    stati(f->ip, st);
801010e0:	8b 45 08             	mov    0x8(%ebp),%eax
801010e3:	8b 40 10             	mov    0x10(%eax),%eax
801010e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801010ed:	89 04 24             	mov    %eax,(%esp)
801010f0:	e8 b1 0c 00 00       	call   80101da6 <stati>
    iunlock(f->ip);
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	8b 40 10             	mov    0x10(%eax),%eax
801010fb:	89 04 24             	mov    %eax,(%esp)
801010fe:	e8 29 09 00 00       	call   80101a2c <iunlock>
    return 0;
80101103:	b8 00 00 00 00       	mov    $0x0,%eax
80101108:	eb 05                	jmp    8010110f <filestat+0x4d>
  }
  return -1;
8010110a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010110f:	c9                   	leave  
80101110:	c3                   	ret    

80101111 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101111:	55                   	push   %ebp
80101112:	89 e5                	mov    %esp,%ebp
80101114:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101117:	8b 45 08             	mov    0x8(%ebp),%eax
8010111a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010111e:	84 c0                	test   %al,%al
80101120:	75 0a                	jne    8010112c <fileread+0x1b>
    return -1;
80101122:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101127:	e9 9f 00 00 00       	jmp    801011cb <fileread+0xba>
  if(f->type == FD_PIPE)
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 00                	mov    (%eax),%eax
80101131:	83 f8 01             	cmp    $0x1,%eax
80101134:	75 1e                	jne    80101154 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 40 0c             	mov    0xc(%eax),%eax
8010113c:	8b 55 10             	mov    0x10(%ebp),%edx
8010113f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101143:	8b 55 0c             	mov    0xc(%ebp),%edx
80101146:	89 54 24 04          	mov    %edx,0x4(%esp)
8010114a:	89 04 24             	mov    %eax,(%esp)
8010114d:	e8 4e 31 00 00       	call   801042a0 <piperead>
80101152:	eb 77                	jmp    801011cb <fileread+0xba>
  if(f->type == FD_INODE){
80101154:	8b 45 08             	mov    0x8(%ebp),%eax
80101157:	8b 00                	mov    (%eax),%eax
80101159:	83 f8 02             	cmp    $0x2,%eax
8010115c:	75 61                	jne    801011bf <fileread+0xae>
    ilock(f->ip);
8010115e:	8b 45 08             	mov    0x8(%ebp),%eax
80101161:	8b 40 10             	mov    0x10(%eax),%eax
80101164:	89 04 24             	mov    %eax,(%esp)
80101167:	e8 6c 07 00 00       	call   801018d8 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010116c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010116f:	8b 45 08             	mov    0x8(%ebp),%eax
80101172:	8b 50 14             	mov    0x14(%eax),%edx
80101175:	8b 45 08             	mov    0x8(%ebp),%eax
80101178:	8b 40 10             	mov    0x10(%eax),%eax
8010117b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010117f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101183:	8b 55 0c             	mov    0xc(%ebp),%edx
80101186:	89 54 24 04          	mov    %edx,0x4(%esp)
8010118a:	89 04 24             	mov    %eax,(%esp)
8010118d:	e8 59 0c 00 00       	call   80101deb <readi>
80101192:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101195:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101199:	7e 11                	jle    801011ac <fileread+0x9b>
      f->off += r;
8010119b:	8b 45 08             	mov    0x8(%ebp),%eax
8010119e:	8b 50 14             	mov    0x14(%eax),%edx
801011a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a4:	01 c2                	add    %eax,%edx
801011a6:	8b 45 08             	mov    0x8(%ebp),%eax
801011a9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011ac:	8b 45 08             	mov    0x8(%ebp),%eax
801011af:	8b 40 10             	mov    0x10(%eax),%eax
801011b2:	89 04 24             	mov    %eax,(%esp)
801011b5:	e8 72 08 00 00       	call   80101a2c <iunlock>
    return r;
801011ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011bd:	eb 0c                	jmp    801011cb <fileread+0xba>
  }
  panic("fileread");
801011bf:	c7 04 24 df 88 10 80 	movl   $0x801088df,(%esp)
801011c6:	e8 6f f3 ff ff       	call   8010053a <panic>
}
801011cb:	c9                   	leave  
801011cc:	c3                   	ret    

801011cd <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011cd:	55                   	push   %ebp
801011ce:	89 e5                	mov    %esp,%ebp
801011d0:	53                   	push   %ebx
801011d1:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011d4:	8b 45 08             	mov    0x8(%ebp),%eax
801011d7:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011db:	84 c0                	test   %al,%al
801011dd:	75 0a                	jne    801011e9 <filewrite+0x1c>
    return -1;
801011df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e4:	e9 20 01 00 00       	jmp    80101309 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011e9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ec:	8b 00                	mov    (%eax),%eax
801011ee:	83 f8 01             	cmp    $0x1,%eax
801011f1:	75 21                	jne    80101214 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011f3:	8b 45 08             	mov    0x8(%ebp),%eax
801011f6:	8b 40 0c             	mov    0xc(%eax),%eax
801011f9:	8b 55 10             	mov    0x10(%ebp),%edx
801011fc:	89 54 24 08          	mov    %edx,0x8(%esp)
80101200:	8b 55 0c             	mov    0xc(%ebp),%edx
80101203:	89 54 24 04          	mov    %edx,0x4(%esp)
80101207:	89 04 24             	mov    %eax,(%esp)
8010120a:	e8 a2 2f 00 00       	call   801041b1 <pipewrite>
8010120f:	e9 f5 00 00 00       	jmp    80101309 <filewrite+0x13c>
  if(f->type == FD_INODE){
80101214:	8b 45 08             	mov    0x8(%ebp),%eax
80101217:	8b 00                	mov    (%eax),%eax
80101219:	83 f8 02             	cmp    $0x2,%eax
8010121c:	0f 85 db 00 00 00    	jne    801012fd <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101222:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101229:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101230:	e9 a8 00 00 00       	jmp    801012dd <filewrite+0x110>
      int n1 = n - i;
80101235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101238:	8b 55 10             	mov    0x10(%ebp),%edx
8010123b:	29 c2                	sub    %eax,%edx
8010123d:	89 d0                	mov    %edx,%eax
8010123f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101242:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101245:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101248:	7e 06                	jle    80101250 <filewrite+0x83>
        n1 = max;
8010124a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124d:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101250:	e8 73 22 00 00       	call   801034c8 <begin_op>
      ilock(f->ip);
80101255:	8b 45 08             	mov    0x8(%ebp),%eax
80101258:	8b 40 10             	mov    0x10(%eax),%eax
8010125b:	89 04 24             	mov    %eax,(%esp)
8010125e:	e8 75 06 00 00       	call   801018d8 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101263:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101266:	8b 45 08             	mov    0x8(%ebp),%eax
80101269:	8b 50 14             	mov    0x14(%eax),%edx
8010126c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010126f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101272:	01 c3                	add    %eax,%ebx
80101274:	8b 45 08             	mov    0x8(%ebp),%eax
80101277:	8b 40 10             	mov    0x10(%eax),%eax
8010127a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010127e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101282:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101286:	89 04 24             	mov    %eax,(%esp)
80101289:	e8 c1 0c 00 00       	call   80101f4f <writei>
8010128e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101291:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101295:	7e 11                	jle    801012a8 <filewrite+0xdb>
        f->off += r;
80101297:	8b 45 08             	mov    0x8(%ebp),%eax
8010129a:	8b 50 14             	mov    0x14(%eax),%edx
8010129d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a0:	01 c2                	add    %eax,%edx
801012a2:	8b 45 08             	mov    0x8(%ebp),%eax
801012a5:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 40 10             	mov    0x10(%eax),%eax
801012ae:	89 04 24             	mov    %eax,(%esp)
801012b1:	e8 76 07 00 00       	call   80101a2c <iunlock>
      end_op();
801012b6:	e8 91 22 00 00       	call   8010354c <end_op>

      if(r < 0)
801012bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012bf:	79 02                	jns    801012c3 <filewrite+0xf6>
        break;
801012c1:	eb 26                	jmp    801012e9 <filewrite+0x11c>
      if(r != n1)
801012c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012c9:	74 0c                	je     801012d7 <filewrite+0x10a>
        panic("short filewrite");
801012cb:	c7 04 24 e8 88 10 80 	movl   $0x801088e8,(%esp)
801012d2:	e8 63 f2 ff ff       	call   8010053a <panic>
      i += r;
801012d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012da:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e0:	3b 45 10             	cmp    0x10(%ebp),%eax
801012e3:	0f 8c 4c ff ff ff    	jl     80101235 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ec:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ef:	75 05                	jne    801012f6 <filewrite+0x129>
801012f1:	8b 45 10             	mov    0x10(%ebp),%eax
801012f4:	eb 05                	jmp    801012fb <filewrite+0x12e>
801012f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012fb:	eb 0c                	jmp    80101309 <filewrite+0x13c>
  }
  panic("filewrite");
801012fd:	c7 04 24 f8 88 10 80 	movl   $0x801088f8,(%esp)
80101304:	e8 31 f2 ff ff       	call   8010053a <panic>
}
80101309:	83 c4 24             	add    $0x24,%esp
8010130c:	5b                   	pop    %ebx
8010130d:	5d                   	pop    %ebp
8010130e:	c3                   	ret    
8010130f:	90                   	nop

80101310 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101310:	55                   	push   %ebp
80101311:	89 e5                	mov    %esp,%ebp
80101313:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101320:	00 
80101321:	89 04 24             	mov    %eax,(%esp)
80101324:	e8 7d ee ff ff       	call   801001a6 <bread>
80101329:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132f:	83 c0 18             	add    $0x18,%eax
80101332:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
80101339:	00 
8010133a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101341:	89 04 24             	mov    %eax,(%esp)
80101344:	e8 9c 41 00 00       	call   801054e5 <memmove>
  brelse(bp);
80101349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010134c:	89 04 24             	mov    %eax,(%esp)
8010134f:	e8 c3 ee ff ff       	call   80100217 <brelse>
}
80101354:	c9                   	leave  
80101355:	c3                   	ret    

80101356 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101356:	55                   	push   %ebp
80101357:	89 e5                	mov    %esp,%ebp
80101359:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010135c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010135f:	8b 45 08             	mov    0x8(%ebp),%eax
80101362:	89 54 24 04          	mov    %edx,0x4(%esp)
80101366:	89 04 24             	mov    %eax,(%esp)
80101369:	e8 38 ee ff ff       	call   801001a6 <bread>
8010136e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101374:	83 c0 18             	add    $0x18,%eax
80101377:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010137e:	00 
8010137f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101386:	00 
80101387:	89 04 24             	mov    %eax,(%esp)
8010138a:	e8 87 40 00 00       	call   80105416 <memset>
  log_write(bp);
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	89 04 24             	mov    %eax,(%esp)
80101395:	e8 39 23 00 00       	call   801036d3 <log_write>
  brelse(bp);
8010139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139d:	89 04 24             	mov    %eax,(%esp)
801013a0:	e8 72 ee ff ff       	call   80100217 <brelse>
}
801013a5:	c9                   	leave  
801013a6:	c3                   	ret    

801013a7 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013a7:	55                   	push   %ebp
801013a8:	89 e5                	mov    %esp,%ebp
801013aa:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801013ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801013b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013bb:	e9 07 01 00 00       	jmp    801014c7 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
801013c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013c9:	85 c0                	test   %eax,%eax
801013cb:	0f 48 c2             	cmovs  %edx,%eax
801013ce:	c1 f8 0c             	sar    $0xc,%eax
801013d1:	89 c2                	mov    %eax,%edx
801013d3:	a1 38 12 11 80       	mov    0x80111238,%eax
801013d8:	01 d0                	add    %edx,%eax
801013da:	89 44 24 04          	mov    %eax,0x4(%esp)
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	89 04 24             	mov    %eax,(%esp)
801013e4:	e8 bd ed ff ff       	call   801001a6 <bread>
801013e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013f3:	e9 9d 00 00 00       	jmp    80101495 <balloc+0xee>
      m = 1 << (bi % 8);
801013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013fb:	99                   	cltd   
801013fc:	c1 ea 1d             	shr    $0x1d,%edx
801013ff:	01 d0                	add    %edx,%eax
80101401:	83 e0 07             	and    $0x7,%eax
80101404:	29 d0                	sub    %edx,%eax
80101406:	ba 01 00 00 00       	mov    $0x1,%edx
8010140b:	89 c1                	mov    %eax,%ecx
8010140d:	d3 e2                	shl    %cl,%edx
8010140f:	89 d0                	mov    %edx,%eax
80101411:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101414:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101417:	8d 50 07             	lea    0x7(%eax),%edx
8010141a:	85 c0                	test   %eax,%eax
8010141c:	0f 48 c2             	cmovs  %edx,%eax
8010141f:	c1 f8 03             	sar    $0x3,%eax
80101422:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101425:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010142a:	0f b6 c0             	movzbl %al,%eax
8010142d:	23 45 e8             	and    -0x18(%ebp),%eax
80101430:	85 c0                	test   %eax,%eax
80101432:	75 5d                	jne    80101491 <balloc+0xea>
        bp->data[bi/8] |= m;  // Mark block in use.
80101434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101437:	8d 50 07             	lea    0x7(%eax),%edx
8010143a:	85 c0                	test   %eax,%eax
8010143c:	0f 48 c2             	cmovs  %edx,%eax
8010143f:	c1 f8 03             	sar    $0x3,%eax
80101442:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101445:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010144a:	89 d1                	mov    %edx,%ecx
8010144c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010144f:	09 ca                	or     %ecx,%edx
80101451:	89 d1                	mov    %edx,%ecx
80101453:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101456:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010145a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145d:	89 04 24             	mov    %eax,(%esp)
80101460:	e8 6e 22 00 00       	call   801036d3 <log_write>
        brelse(bp);
80101465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101468:	89 04 24             	mov    %eax,(%esp)
8010146b:	e8 a7 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101473:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101476:	01 c2                	add    %eax,%edx
80101478:	8b 45 08             	mov    0x8(%ebp),%eax
8010147b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010147f:	89 04 24             	mov    %eax,(%esp)
80101482:	e8 cf fe ff ff       	call   80101356 <bzero>
        return b + bi;
80101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010148d:	01 d0                	add    %edx,%eax
8010148f:	eb 52                	jmp    801014e3 <balloc+0x13c>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101491:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101495:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010149c:	7f 17                	jg     801014b5 <balloc+0x10e>
8010149e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a4:	01 d0                	add    %edx,%eax
801014a6:	89 c2                	mov    %eax,%edx
801014a8:	a1 20 12 11 80       	mov    0x80111220,%eax
801014ad:	39 c2                	cmp    %eax,%edx
801014af:	0f 82 43 ff ff ff    	jb     801013f8 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b8:	89 04 24             	mov    %eax,(%esp)
801014bb:	e8 57 ed ff ff       	call   80100217 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801014c0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ca:	a1 20 12 11 80       	mov    0x80111220,%eax
801014cf:	39 c2                	cmp    %eax,%edx
801014d1:	0f 82 e9 fe ff ff    	jb     801013c0 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014d7:	c7 04 24 04 89 10 80 	movl   $0x80108904,(%esp)
801014de:	e8 57 f0 ff ff       	call   8010053a <panic>
}
801014e3:	c9                   	leave  
801014e4:	c3                   	ret    

801014e5 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e5:	55                   	push   %ebp
801014e6:	89 e5                	mov    %esp,%ebp
801014e8:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801014eb:	c7 44 24 04 20 12 11 	movl   $0x80111220,0x4(%esp)
801014f2:	80 
801014f3:	8b 45 08             	mov    0x8(%ebp),%eax
801014f6:	89 04 24             	mov    %eax,(%esp)
801014f9:	e8 12 fe ff ff       	call   80101310 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801014fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101501:	c1 e8 0c             	shr    $0xc,%eax
80101504:	89 c2                	mov    %eax,%edx
80101506:	a1 38 12 11 80       	mov    0x80111238,%eax
8010150b:	01 c2                	add    %eax,%edx
8010150d:	8b 45 08             	mov    0x8(%ebp),%eax
80101510:	89 54 24 04          	mov    %edx,0x4(%esp)
80101514:	89 04 24             	mov    %eax,(%esp)
80101517:	e8 8a ec ff ff       	call   801001a6 <bread>
8010151c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010151f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101522:	25 ff 0f 00 00       	and    $0xfff,%eax
80101527:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010152a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152d:	99                   	cltd   
8010152e:	c1 ea 1d             	shr    $0x1d,%edx
80101531:	01 d0                	add    %edx,%eax
80101533:	83 e0 07             	and    $0x7,%eax
80101536:	29 d0                	sub    %edx,%eax
80101538:	ba 01 00 00 00       	mov    $0x1,%edx
8010153d:	89 c1                	mov    %eax,%ecx
8010153f:	d3 e2                	shl    %cl,%edx
80101541:	89 d0                	mov    %edx,%eax
80101543:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101549:	8d 50 07             	lea    0x7(%eax),%edx
8010154c:	85 c0                	test   %eax,%eax
8010154e:	0f 48 c2             	cmovs  %edx,%eax
80101551:	c1 f8 03             	sar    $0x3,%eax
80101554:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101557:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010155c:	0f b6 c0             	movzbl %al,%eax
8010155f:	23 45 ec             	and    -0x14(%ebp),%eax
80101562:	85 c0                	test   %eax,%eax
80101564:	75 0c                	jne    80101572 <bfree+0x8d>
    panic("freeing free block");
80101566:	c7 04 24 1a 89 10 80 	movl   $0x8010891a,(%esp)
8010156d:	e8 c8 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101575:	8d 50 07             	lea    0x7(%eax),%edx
80101578:	85 c0                	test   %eax,%eax
8010157a:	0f 48 c2             	cmovs  %edx,%eax
8010157d:	c1 f8 03             	sar    $0x3,%eax
80101580:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101583:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101588:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010158b:	f7 d1                	not    %ecx
8010158d:	21 ca                	and    %ecx,%edx
8010158f:	89 d1                	mov    %edx,%ecx
80101591:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101594:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159b:	89 04 24             	mov    %eax,(%esp)
8010159e:	e8 30 21 00 00       	call   801036d3 <log_write>
  brelse(bp);
801015a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a6:	89 04 24             	mov    %eax,(%esp)
801015a9:	e8 69 ec ff ff       	call   80100217 <brelse>
}
801015ae:	c9                   	leave  
801015af:	c3                   	ret    

801015b0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801015b0:	55                   	push   %ebp
801015b1:	89 e5                	mov    %esp,%ebp
801015b3:	57                   	push   %edi
801015b4:	56                   	push   %esi
801015b5:	53                   	push   %ebx
801015b6:	83 ec 3c             	sub    $0x3c,%esp
  initlock(&icache.lock, "icache");
801015b9:	c7 44 24 04 2d 89 10 	movl   $0x8010892d,0x4(%esp)
801015c0:	80 
801015c1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015c8:	e8 d1 3b 00 00       	call   8010519e <initlock>
  readsb(dev, &sb);
801015cd:	c7 44 24 04 20 12 11 	movl   $0x80111220,0x4(%esp)
801015d4:	80 
801015d5:	8b 45 08             	mov    0x8(%ebp),%eax
801015d8:	89 04 24             	mov    %eax,(%esp)
801015db:	e8 30 fd ff ff       	call   80101310 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
801015e0:	a1 38 12 11 80       	mov    0x80111238,%eax
801015e5:	8b 3d 34 12 11 80    	mov    0x80111234,%edi
801015eb:	8b 35 30 12 11 80    	mov    0x80111230,%esi
801015f1:	8b 1d 2c 12 11 80    	mov    0x8011122c,%ebx
801015f7:	8b 0d 28 12 11 80    	mov    0x80111228,%ecx
801015fd:	8b 15 24 12 11 80    	mov    0x80111224,%edx
80101603:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101606:	8b 15 20 12 11 80    	mov    0x80111220,%edx
8010160c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101610:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101614:	89 74 24 14          	mov    %esi,0x14(%esp)
80101618:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010161c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101623:	89 44 24 08          	mov    %eax,0x8(%esp)
80101627:	89 d0                	mov    %edx,%eax
80101629:	89 44 24 04          	mov    %eax,0x4(%esp)
8010162d:	c7 04 24 34 89 10 80 	movl   $0x80108934,(%esp)
80101634:	e8 67 ed ff ff       	call   801003a0 <cprintf>
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101639:	83 c4 3c             	add    $0x3c,%esp
8010163c:	5b                   	pop    %ebx
8010163d:	5e                   	pop    %esi
8010163e:	5f                   	pop    %edi
8010163f:	5d                   	pop    %ebp
80101640:	c3                   	ret    

80101641 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101641:	55                   	push   %ebp
80101642:	89 e5                	mov    %esp,%ebp
80101644:	83 ec 28             	sub    $0x28,%esp
80101647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010164a:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010164e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101655:	e9 9e 00 00 00       	jmp    801016f8 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
8010165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010165d:	c1 e8 03             	shr    $0x3,%eax
80101660:	89 c2                	mov    %eax,%edx
80101662:	a1 34 12 11 80       	mov    0x80111234,%eax
80101667:	01 d0                	add    %edx,%eax
80101669:	89 44 24 04          	mov    %eax,0x4(%esp)
8010166d:	8b 45 08             	mov    0x8(%ebp),%eax
80101670:	89 04 24             	mov    %eax,(%esp)
80101673:	e8 2e eb ff ff       	call   801001a6 <bread>
80101678:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167e:	8d 50 18             	lea    0x18(%eax),%edx
80101681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101684:	83 e0 07             	and    $0x7,%eax
80101687:	c1 e0 06             	shl    $0x6,%eax
8010168a:	01 d0                	add    %edx,%eax
8010168c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010168f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101692:	0f b7 00             	movzwl (%eax),%eax
80101695:	66 85 c0             	test   %ax,%ax
80101698:	75 4f                	jne    801016e9 <ialloc+0xa8>
      memset(dip, 0, sizeof(*dip));
8010169a:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801016a1:	00 
801016a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016a9:	00 
801016aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016ad:	89 04 24             	mov    %eax,(%esp)
801016b0:	e8 61 3d 00 00       	call   80105416 <memset>
      dip->type = type;
801016b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016b8:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801016bc:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c2:	89 04 24             	mov    %eax,(%esp)
801016c5:	e8 09 20 00 00       	call   801036d3 <log_write>
      brelse(bp);
801016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016cd:	89 04 24             	mov    %eax,(%esp)
801016d0:	e8 42 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801016dc:	8b 45 08             	mov    0x8(%ebp),%eax
801016df:	89 04 24             	mov    %eax,(%esp)
801016e2:	e8 ed 00 00 00       	call   801017d4 <iget>
801016e7:	eb 2b                	jmp    80101714 <ialloc+0xd3>
    }
    brelse(bp);
801016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ec:	89 04 24             	mov    %eax,(%esp)
801016ef:	e8 23 eb ff ff       	call   80100217 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016fb:	a1 28 12 11 80       	mov    0x80111228,%eax
80101700:	39 c2                	cmp    %eax,%edx
80101702:	0f 82 52 ff ff ff    	jb     8010165a <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101708:	c7 04 24 87 89 10 80 	movl   $0x80108987,(%esp)
8010170f:	e8 26 ee ff ff       	call   8010053a <panic>
}
80101714:	c9                   	leave  
80101715:	c3                   	ret    

80101716 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101716:	55                   	push   %ebp
80101717:	89 e5                	mov    %esp,%ebp
80101719:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010171c:	8b 45 08             	mov    0x8(%ebp),%eax
8010171f:	8b 40 04             	mov    0x4(%eax),%eax
80101722:	c1 e8 03             	shr    $0x3,%eax
80101725:	89 c2                	mov    %eax,%edx
80101727:	a1 34 12 11 80       	mov    0x80111234,%eax
8010172c:	01 c2                	add    %eax,%edx
8010172e:	8b 45 08             	mov    0x8(%ebp),%eax
80101731:	8b 00                	mov    (%eax),%eax
80101733:	89 54 24 04          	mov    %edx,0x4(%esp)
80101737:	89 04 24             	mov    %eax,(%esp)
8010173a:	e8 67 ea ff ff       	call   801001a6 <bread>
8010173f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101745:	8d 50 18             	lea    0x18(%eax),%edx
80101748:	8b 45 08             	mov    0x8(%ebp),%eax
8010174b:	8b 40 04             	mov    0x4(%eax),%eax
8010174e:	83 e0 07             	and    $0x7,%eax
80101751:	c1 e0 06             	shl    $0x6,%eax
80101754:	01 d0                	add    %edx,%eax
80101756:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101759:	8b 45 08             	mov    0x8(%ebp),%eax
8010175c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101760:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101763:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101766:	8b 45 08             	mov    0x8(%ebp),%eax
80101769:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010176d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101770:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101774:	8b 45 08             	mov    0x8(%ebp),%eax
80101777:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101782:	8b 45 08             	mov    0x8(%ebp),%eax
80101785:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010178c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101790:	8b 45 08             	mov    0x8(%ebp),%eax
80101793:	8b 50 18             	mov    0x18(%eax),%edx
80101796:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101799:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010179c:	8b 45 08             	mov    0x8(%ebp),%eax
8010179f:	8d 50 1c             	lea    0x1c(%eax),%edx
801017a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a5:	83 c0 0c             	add    $0xc,%eax
801017a8:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801017af:	00 
801017b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801017b4:	89 04 24             	mov    %eax,(%esp)
801017b7:	e8 29 3d 00 00       	call   801054e5 <memmove>
  log_write(bp);
801017bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bf:	89 04 24             	mov    %eax,(%esp)
801017c2:	e8 0c 1f 00 00       	call   801036d3 <log_write>
  brelse(bp);
801017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ca:	89 04 24             	mov    %eax,(%esp)
801017cd:	e8 45 ea ff ff       	call   80100217 <brelse>
}
801017d2:	c9                   	leave  
801017d3:	c3                   	ret    

801017d4 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017d4:	55                   	push   %ebp
801017d5:	89 e5                	mov    %esp,%ebp
801017d7:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017da:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801017e1:	e8 d9 39 00 00       	call   801051bf <acquire>

  // Is the inode already cached?
  empty = 0;
801017e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ed:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
801017f4:	eb 59                	jmp    8010184f <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f9:	8b 40 08             	mov    0x8(%eax),%eax
801017fc:	85 c0                	test   %eax,%eax
801017fe:	7e 35                	jle    80101835 <iget+0x61>
80101800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101803:	8b 00                	mov    (%eax),%eax
80101805:	3b 45 08             	cmp    0x8(%ebp),%eax
80101808:	75 2b                	jne    80101835 <iget+0x61>
8010180a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180d:	8b 40 04             	mov    0x4(%eax),%eax
80101810:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101813:	75 20                	jne    80101835 <iget+0x61>
      ip->ref++;
80101815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101818:	8b 40 08             	mov    0x8(%eax),%eax
8010181b:	8d 50 01             	lea    0x1(%eax),%edx
8010181e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101821:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101824:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010182b:	e8 f1 39 00 00       	call   80105221 <release>
      return ip;
80101830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101833:	eb 6f                	jmp    801018a4 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101835:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101839:	75 10                	jne    8010184b <iget+0x77>
8010183b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183e:	8b 40 08             	mov    0x8(%eax),%eax
80101841:	85 c0                	test   %eax,%eax
80101843:	75 06                	jne    8010184b <iget+0x77>
      empty = ip;
80101845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101848:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010184b:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
8010184f:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
80101856:	72 9e                	jb     801017f6 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101858:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010185c:	75 0c                	jne    8010186a <iget+0x96>
    panic("iget: no inodes");
8010185e:	c7 04 24 99 89 10 80 	movl   $0x80108999,(%esp)
80101865:	e8 d0 ec ff ff       	call   8010053a <panic>

  ip = empty;
8010186a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010186d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101873:	8b 55 08             	mov    0x8(%ebp),%edx
80101876:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010187e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101884:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101895:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010189c:	e8 80 39 00 00       	call   80105221 <release>

  return ip;
801018a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018a4:	c9                   	leave  
801018a5:	c3                   	ret    

801018a6 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018a6:	55                   	push   %ebp
801018a7:	89 e5                	mov    %esp,%ebp
801018a9:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801018ac:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018b3:	e8 07 39 00 00       	call   801051bf <acquire>
  ip->ref++;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 08             	mov    0x8(%eax),%eax
801018be:	8d 50 01             	lea    0x1(%eax),%edx
801018c1:	8b 45 08             	mov    0x8(%ebp),%eax
801018c4:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018c7:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018ce:	e8 4e 39 00 00       	call   80105221 <release>
  return ip;
801018d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018d6:	c9                   	leave  
801018d7:	c3                   	ret    

801018d8 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018d8:	55                   	push   %ebp
801018d9:	89 e5                	mov    %esp,%ebp
801018db:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018e2:	74 0a                	je     801018ee <ilock+0x16>
801018e4:	8b 45 08             	mov    0x8(%ebp),%eax
801018e7:	8b 40 08             	mov    0x8(%eax),%eax
801018ea:	85 c0                	test   %eax,%eax
801018ec:	7f 0c                	jg     801018fa <ilock+0x22>
    panic("ilock");
801018ee:	c7 04 24 a9 89 10 80 	movl   $0x801089a9,(%esp)
801018f5:	e8 40 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801018fa:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101901:	e8 b9 38 00 00       	call   801051bf <acquire>
  while(ip->flags & I_BUSY)
80101906:	eb 13                	jmp    8010191b <ilock+0x43>
    sleep(ip, &icache.lock);
80101908:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
8010190f:	80 
80101910:	8b 45 08             	mov    0x8(%ebp),%eax
80101913:	89 04 24             	mov    %eax,(%esp)
80101916:	e8 d6 32 00 00       	call   80104bf1 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010191b:	8b 45 08             	mov    0x8(%ebp),%eax
8010191e:	8b 40 0c             	mov    0xc(%eax),%eax
80101921:	83 e0 01             	and    $0x1,%eax
80101924:	85 c0                	test   %eax,%eax
80101926:	75 e0                	jne    80101908 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101928:	8b 45 08             	mov    0x8(%ebp),%eax
8010192b:	8b 40 0c             	mov    0xc(%eax),%eax
8010192e:	83 c8 01             	or     $0x1,%eax
80101931:	89 c2                	mov    %eax,%edx
80101933:	8b 45 08             	mov    0x8(%ebp),%eax
80101936:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101939:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101940:	e8 dc 38 00 00       	call   80105221 <release>

  if(!(ip->flags & I_VALID)){
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	8b 40 0c             	mov    0xc(%eax),%eax
8010194b:	83 e0 02             	and    $0x2,%eax
8010194e:	85 c0                	test   %eax,%eax
80101950:	0f 85 d4 00 00 00    	jne    80101a2a <ilock+0x152>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101956:	8b 45 08             	mov    0x8(%ebp),%eax
80101959:	8b 40 04             	mov    0x4(%eax),%eax
8010195c:	c1 e8 03             	shr    $0x3,%eax
8010195f:	89 c2                	mov    %eax,%edx
80101961:	a1 34 12 11 80       	mov    0x80111234,%eax
80101966:	01 c2                	add    %eax,%edx
80101968:	8b 45 08             	mov    0x8(%ebp),%eax
8010196b:	8b 00                	mov    (%eax),%eax
8010196d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101971:	89 04 24             	mov    %eax,(%esp)
80101974:	e8 2d e8 ff ff       	call   801001a6 <bread>
80101979:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010197c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197f:	8d 50 18             	lea    0x18(%eax),%edx
80101982:	8b 45 08             	mov    0x8(%ebp),%eax
80101985:	8b 40 04             	mov    0x4(%eax),%eax
80101988:	83 e0 07             	and    $0x7,%eax
8010198b:	c1 e0 06             	shl    $0x6,%eax
8010198e:	01 d0                	add    %edx,%eax
80101990:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101996:	0f b7 10             	movzwl (%eax),%edx
80101999:	8b 45 08             	mov    0x8(%ebp),%eax
8010199c:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a3:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019a7:	8b 45 08             	mov    0x8(%ebp),%eax
801019aa:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019b5:	8b 45 08             	mov    0x8(%ebp),%eax
801019b8:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bf:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019c3:	8b 45 08             	mov    0x8(%ebp),%eax
801019c6:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cd:	8b 50 08             	mov    0x8(%eax),%edx
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019d9:	8d 50 0c             	lea    0xc(%eax),%edx
801019dc:	8b 45 08             	mov    0x8(%ebp),%eax
801019df:	83 c0 1c             	add    $0x1c,%eax
801019e2:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019e9:	00 
801019ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801019ee:	89 04 24             	mov    %eax,(%esp)
801019f1:	e8 ef 3a 00 00       	call   801054e5 <memmove>
    brelse(bp);
801019f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f9:	89 04 24             	mov    %eax,(%esp)
801019fc:	e8 16 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101a01:	8b 45 08             	mov    0x8(%ebp),%eax
80101a04:	8b 40 0c             	mov    0xc(%eax),%eax
80101a07:	83 c8 02             	or     $0x2,%eax
80101a0a:	89 c2                	mov    %eax,%edx
80101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0f:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a19:	66 85 c0             	test   %ax,%ax
80101a1c:	75 0c                	jne    80101a2a <ilock+0x152>
      panic("ilock: no type");
80101a1e:	c7 04 24 af 89 10 80 	movl   $0x801089af,(%esp)
80101a25:	e8 10 eb ff ff       	call   8010053a <panic>
  }
}
80101a2a:	c9                   	leave  
80101a2b:	c3                   	ret    

80101a2c <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a2c:	55                   	push   %ebp
80101a2d:	89 e5                	mov    %esp,%ebp
80101a2f:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a36:	74 17                	je     80101a4f <iunlock+0x23>
80101a38:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3b:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3e:	83 e0 01             	and    $0x1,%eax
80101a41:	85 c0                	test   %eax,%eax
80101a43:	74 0a                	je     80101a4f <iunlock+0x23>
80101a45:	8b 45 08             	mov    0x8(%ebp),%eax
80101a48:	8b 40 08             	mov    0x8(%eax),%eax
80101a4b:	85 c0                	test   %eax,%eax
80101a4d:	7f 0c                	jg     80101a5b <iunlock+0x2f>
    panic("iunlock");
80101a4f:	c7 04 24 be 89 10 80 	movl   $0x801089be,(%esp)
80101a56:	e8 df ea ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101a5b:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a62:	e8 58 37 00 00       	call   801051bf <acquire>
  ip->flags &= ~I_BUSY;
80101a67:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6a:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6d:	83 e0 fe             	and    $0xfffffffe,%eax
80101a70:	89 c2                	mov    %eax,%edx
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	89 04 24             	mov    %eax,(%esp)
80101a7e:	e8 47 32 00 00       	call   80104cca <wakeup>
  release(&icache.lock);
80101a83:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a8a:	e8 92 37 00 00       	call   80105221 <release>
}
80101a8f:	c9                   	leave  
80101a90:	c3                   	ret    

80101a91 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a91:	55                   	push   %ebp
80101a92:	89 e5                	mov    %esp,%ebp
80101a94:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a97:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a9e:	e8 1c 37 00 00       	call   801051bf <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	8b 40 08             	mov    0x8(%eax),%eax
80101aa9:	83 f8 01             	cmp    $0x1,%eax
80101aac:	0f 85 93 00 00 00    	jne    80101b45 <iput+0xb4>
80101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab5:	8b 40 0c             	mov    0xc(%eax),%eax
80101ab8:	83 e0 02             	and    $0x2,%eax
80101abb:	85 c0                	test   %eax,%eax
80101abd:	0f 84 82 00 00 00    	je     80101b45 <iput+0xb4>
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101aca:	66 85 c0             	test   %ax,%ax
80101acd:	75 76                	jne    80101b45 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101acf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ad5:	83 e0 01             	and    $0x1,%eax
80101ad8:	85 c0                	test   %eax,%eax
80101ada:	74 0c                	je     80101ae8 <iput+0x57>
      panic("iput busy");
80101adc:	c7 04 24 c6 89 10 80 	movl   $0x801089c6,(%esp)
80101ae3:	e8 52 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aeb:	8b 40 0c             	mov    0xc(%eax),%eax
80101aee:	83 c8 01             	or     $0x1,%eax
80101af1:	89 c2                	mov    %eax,%edx
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101af9:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101b00:	e8 1c 37 00 00       	call   80105221 <release>
    itrunc(ip);
80101b05:	8b 45 08             	mov    0x8(%ebp),%eax
80101b08:	89 04 24             	mov    %eax,(%esp)
80101b0b:	e8 7d 01 00 00       	call   80101c8d <itrunc>
    ip->type = 0;
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b19:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1c:	89 04 24             	mov    %eax,(%esp)
80101b1f:	e8 f2 fb ff ff       	call   80101716 <iupdate>
    acquire(&icache.lock);
80101b24:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101b2b:	e8 8f 36 00 00       	call   801051bf <acquire>
    ip->flags = 0;
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3d:	89 04 24             	mov    %eax,(%esp)
80101b40:	e8 85 31 00 00       	call   80104cca <wakeup>
  }
  ip->ref--;
80101b45:	8b 45 08             	mov    0x8(%ebp),%eax
80101b48:	8b 40 08             	mov    0x8(%eax),%eax
80101b4b:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b54:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101b5b:	e8 c1 36 00 00       	call   80105221 <release>
}
80101b60:	c9                   	leave  
80101b61:	c3                   	ret    

80101b62 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b62:	55                   	push   %ebp
80101b63:	89 e5                	mov    %esp,%ebp
80101b65:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6b:	89 04 24             	mov    %eax,(%esp)
80101b6e:	e8 b9 fe ff ff       	call   80101a2c <iunlock>
  iput(ip);
80101b73:	8b 45 08             	mov    0x8(%ebp),%eax
80101b76:	89 04 24             	mov    %eax,(%esp)
80101b79:	e8 13 ff ff ff       	call   80101a91 <iput>
}
80101b7e:	c9                   	leave  
80101b7f:	c3                   	ret    

80101b80 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b80:	55                   	push   %ebp
80101b81:	89 e5                	mov    %esp,%ebp
80101b83:	53                   	push   %ebx
80101b84:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b87:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b8b:	77 3e                	ja     80101bcb <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b90:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b93:	83 c2 04             	add    $0x4,%edx
80101b96:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ba1:	75 20                	jne    80101bc3 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	8b 00                	mov    (%eax),%eax
80101ba8:	89 04 24             	mov    %eax,(%esp)
80101bab:	e8 f7 f7 ff ff       	call   801013a7 <balloc>
80101bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb6:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bb9:	8d 4a 04             	lea    0x4(%edx),%ecx
80101bbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bbf:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc6:	e9 bc 00 00 00       	jmp    80101c87 <bmap+0x107>
  }
  bn -= NDIRECT;
80101bcb:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101bcf:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bd3:	0f 87 a2 00 00 00    	ja     80101c7b <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdc:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be6:	75 19                	jne    80101c01 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	8b 00                	mov    (%eax),%eax
80101bed:	89 04 24             	mov    %eax,(%esp)
80101bf0:	e8 b2 f7 ff ff       	call   801013a7 <balloc>
80101bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfe:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 00                	mov    (%eax),%eax
80101c06:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c09:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c0d:	89 04 24             	mov    %eax,(%esp)
80101c10:	e8 91 e5 ff ff       	call   801001a6 <bread>
80101c15:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1b:	83 c0 18             	add    $0x18,%eax
80101c1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c21:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c2e:	01 d0                	add    %edx,%eax
80101c30:	8b 00                	mov    (%eax),%eax
80101c32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c39:	75 30                	jne    80101c6b <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c3e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c48:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4e:	8b 00                	mov    (%eax),%eax
80101c50:	89 04 24             	mov    %eax,(%esp)
80101c53:	e8 4f f7 ff ff       	call   801013a7 <balloc>
80101c58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5e:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c63:	89 04 24             	mov    %eax,(%esp)
80101c66:	e8 68 1a 00 00       	call   801036d3 <log_write>
    }
    brelse(bp);
80101c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c6e:	89 04 24             	mov    %eax,(%esp)
80101c71:	e8 a1 e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c79:	eb 0c                	jmp    80101c87 <bmap+0x107>
  }

  panic("bmap: out of range");
80101c7b:	c7 04 24 d0 89 10 80 	movl   $0x801089d0,(%esp)
80101c82:	e8 b3 e8 ff ff       	call   8010053a <panic>
}
80101c87:	83 c4 24             	add    $0x24,%esp
80101c8a:	5b                   	pop    %ebx
80101c8b:	5d                   	pop    %ebp
80101c8c:	c3                   	ret    

80101c8d <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c8d:	55                   	push   %ebp
80101c8e:	89 e5                	mov    %esp,%ebp
80101c90:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c9a:	eb 44                	jmp    80101ce0 <itrunc+0x53>
    if(ip->addrs[i]){
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ca2:	83 c2 04             	add    $0x4,%edx
80101ca5:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101ca9:	85 c0                	test   %eax,%eax
80101cab:	74 2f                	je     80101cdc <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb3:	83 c2 04             	add    $0x4,%edx
80101cb6:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	8b 00                	mov    (%eax),%eax
80101cbf:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cc3:	89 04 24             	mov    %eax,(%esp)
80101cc6:	e8 1a f8 ff ff       	call   801014e5 <bfree>
      ip->addrs[i] = 0;
80101ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd1:	83 c2 04             	add    $0x4,%edx
80101cd4:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cdb:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cdc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ce0:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ce4:	7e b6                	jle    80101c9c <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce9:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cec:	85 c0                	test   %eax,%eax
80101cee:	0f 84 9b 00 00 00    	je     80101d8f <itrunc+0x102>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf7:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cfa:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfd:	8b 00                	mov    (%eax),%eax
80101cff:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d03:	89 04 24             	mov    %eax,(%esp)
80101d06:	e8 9b e4 ff ff       	call   801001a6 <bread>
80101d0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d11:	83 c0 18             	add    $0x18,%eax
80101d14:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d17:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d1e:	eb 3b                	jmp    80101d5b <itrunc+0xce>
      if(a[j])
80101d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d23:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d2d:	01 d0                	add    %edx,%eax
80101d2f:	8b 00                	mov    (%eax),%eax
80101d31:	85 c0                	test   %eax,%eax
80101d33:	74 22                	je     80101d57 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101d42:	01 d0                	add    %edx,%eax
80101d44:	8b 10                	mov    (%eax),%edx
80101d46:	8b 45 08             	mov    0x8(%ebp),%eax
80101d49:	8b 00                	mov    (%eax),%eax
80101d4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d4f:	89 04 24             	mov    %eax,(%esp)
80101d52:	e8 8e f7 ff ff       	call   801014e5 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d57:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5e:	83 f8 7f             	cmp    $0x7f,%eax
80101d61:	76 bd                	jbe    80101d20 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d66:	89 04 24             	mov    %eax,(%esp)
80101d69:	e8 a9 e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d71:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 00                	mov    (%eax),%eax
80101d79:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d7d:	89 04 24             	mov    %eax,(%esp)
80101d80:	e8 60 f7 ff ff       	call   801014e5 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d85:	8b 45 08             	mov    0x8(%ebp),%eax
80101d88:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d92:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d99:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9c:	89 04 24             	mov    %eax,(%esp)
80101d9f:	e8 72 f9 ff ff       	call   80101716 <iupdate>
}
80101da4:	c9                   	leave  
80101da5:	c3                   	ret    

80101da6 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101da6:	55                   	push   %ebp
80101da7:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101da9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dac:	8b 00                	mov    (%eax),%eax
80101dae:	89 c2                	mov    %eax,%edx
80101db0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db3:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101db6:	8b 45 08             	mov    0x8(%ebp),%eax
80101db9:	8b 50 04             	mov    0x4(%eax),%edx
80101dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbf:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dcc:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dd9:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80101de0:	8b 50 18             	mov    0x18(%eax),%edx
80101de3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101de9:	5d                   	pop    %ebp
80101dea:	c3                   	ret    

80101deb <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101deb:	55                   	push   %ebp
80101dec:	89 e5                	mov    %esp,%ebp
80101dee:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101df1:	8b 45 08             	mov    0x8(%ebp),%eax
80101df4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101df8:	66 83 f8 03          	cmp    $0x3,%ax
80101dfc:	75 60                	jne    80101e5e <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101e01:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e05:	66 85 c0             	test   %ax,%ax
80101e08:	78 20                	js     80101e2a <readi+0x3f>
80101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e11:	66 83 f8 09          	cmp    $0x9,%ax
80101e15:	7f 13                	jg     80101e2a <readi+0x3f>
80101e17:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e1e:	98                   	cwtl   
80101e1f:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101e26:	85 c0                	test   %eax,%eax
80101e28:	75 0a                	jne    80101e34 <readi+0x49>
      return -1;
80101e2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e2f:	e9 19 01 00 00       	jmp    80101f4d <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101e34:	8b 45 08             	mov    0x8(%ebp),%eax
80101e37:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e3b:	98                   	cwtl   
80101e3c:	8b 04 c5 c0 11 11 80 	mov    -0x7feeee40(,%eax,8),%eax
80101e43:	8b 55 14             	mov    0x14(%ebp),%edx
80101e46:	89 54 24 08          	mov    %edx,0x8(%esp)
80101e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e4d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e51:	8b 55 08             	mov    0x8(%ebp),%edx
80101e54:	89 14 24             	mov    %edx,(%esp)
80101e57:	ff d0                	call   *%eax
80101e59:	e9 ef 00 00 00       	jmp    80101f4d <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e61:	8b 40 18             	mov    0x18(%eax),%eax
80101e64:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e67:	72 0d                	jb     80101e76 <readi+0x8b>
80101e69:	8b 45 14             	mov    0x14(%ebp),%eax
80101e6c:	8b 55 10             	mov    0x10(%ebp),%edx
80101e6f:	01 d0                	add    %edx,%eax
80101e71:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e74:	73 0a                	jae    80101e80 <readi+0x95>
    return -1;
80101e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e7b:	e9 cd 00 00 00       	jmp    80101f4d <readi+0x162>
  if(off + n > ip->size)
80101e80:	8b 45 14             	mov    0x14(%ebp),%eax
80101e83:	8b 55 10             	mov    0x10(%ebp),%edx
80101e86:	01 c2                	add    %eax,%edx
80101e88:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8b:	8b 40 18             	mov    0x18(%eax),%eax
80101e8e:	39 c2                	cmp    %eax,%edx
80101e90:	76 0c                	jbe    80101e9e <readi+0xb3>
    n = ip->size - off;
80101e92:	8b 45 08             	mov    0x8(%ebp),%eax
80101e95:	8b 40 18             	mov    0x18(%eax),%eax
80101e98:	2b 45 10             	sub    0x10(%ebp),%eax
80101e9b:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ea5:	e9 94 00 00 00       	jmp    80101f3e <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101eaa:	8b 45 10             	mov    0x10(%ebp),%eax
80101ead:	c1 e8 09             	shr    $0x9,%eax
80101eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	89 04 24             	mov    %eax,(%esp)
80101eba:	e8 c1 fc ff ff       	call   80101b80 <bmap>
80101ebf:	8b 55 08             	mov    0x8(%ebp),%edx
80101ec2:	8b 12                	mov    (%edx),%edx
80101ec4:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ec8:	89 14 24             	mov    %edx,(%esp)
80101ecb:	e8 d6 e2 ff ff       	call   801001a6 <bread>
80101ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ed3:	8b 45 10             	mov    0x10(%ebp),%eax
80101ed6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101edb:	89 c2                	mov    %eax,%edx
80101edd:	b8 00 02 00 00       	mov    $0x200,%eax
80101ee2:	29 d0                	sub    %edx,%eax
80101ee4:	89 c2                	mov    %eax,%edx
80101ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ee9:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101eec:	29 c1                	sub    %eax,%ecx
80101eee:	89 c8                	mov    %ecx,%eax
80101ef0:	39 c2                	cmp    %eax,%edx
80101ef2:	0f 46 c2             	cmovbe %edx,%eax
80101ef5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ef8:	8b 45 10             	mov    0x10(%ebp),%eax
80101efb:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f00:	8d 50 10             	lea    0x10(%eax),%edx
80101f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f06:	01 d0                	add    %edx,%eax
80101f08:	8d 50 08             	lea    0x8(%eax),%edx
80101f0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f0e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f12:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f16:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f19:	89 04 24             	mov    %eax,(%esp)
80101f1c:	e8 c4 35 00 00       	call   801054e5 <memmove>
    brelse(bp);
80101f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f24:	89 04 24             	mov    %eax,(%esp)
80101f27:	e8 eb e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f2f:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f35:	01 45 10             	add    %eax,0x10(%ebp)
80101f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f3b:	01 45 0c             	add    %eax,0xc(%ebp)
80101f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f41:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f44:	0f 82 60 ff ff ff    	jb     80101eaa <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f4a:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f4d:	c9                   	leave  
80101f4e:	c3                   	ret    

80101f4f <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f4f:	55                   	push   %ebp
80101f50:	89 e5                	mov    %esp,%ebp
80101f52:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f5c:	66 83 f8 03          	cmp    $0x3,%ax
80101f60:	75 60                	jne    80101fc2 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f62:	8b 45 08             	mov    0x8(%ebp),%eax
80101f65:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f69:	66 85 c0             	test   %ax,%ax
80101f6c:	78 20                	js     80101f8e <writei+0x3f>
80101f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f71:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f75:	66 83 f8 09          	cmp    $0x9,%ax
80101f79:	7f 13                	jg     80101f8e <writei+0x3f>
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f82:	98                   	cwtl   
80101f83:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
80101f8a:	85 c0                	test   %eax,%eax
80101f8c:	75 0a                	jne    80101f98 <writei+0x49>
      return -1;
80101f8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f93:	e9 44 01 00 00       	jmp    801020dc <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80101f98:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f9f:	98                   	cwtl   
80101fa0:	8b 04 c5 c4 11 11 80 	mov    -0x7feeee3c(,%eax,8),%eax
80101fa7:	8b 55 14             	mov    0x14(%ebp),%edx
80101faa:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fae:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fb1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fb5:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb8:	89 14 24             	mov    %edx,(%esp)
80101fbb:	ff d0                	call   *%eax
80101fbd:	e9 1a 01 00 00       	jmp    801020dc <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80101fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc5:	8b 40 18             	mov    0x18(%eax),%eax
80101fc8:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fcb:	72 0d                	jb     80101fda <writei+0x8b>
80101fcd:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd0:	8b 55 10             	mov    0x10(%ebp),%edx
80101fd3:	01 d0                	add    %edx,%eax
80101fd5:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fd8:	73 0a                	jae    80101fe4 <writei+0x95>
    return -1;
80101fda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fdf:	e9 f8 00 00 00       	jmp    801020dc <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
80101fe4:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe7:	8b 55 10             	mov    0x10(%ebp),%edx
80101fea:	01 d0                	add    %edx,%eax
80101fec:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101ff1:	76 0a                	jbe    80101ffd <writei+0xae>
    return -1;
80101ff3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff8:	e9 df 00 00 00       	jmp    801020dc <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101ffd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102004:	e9 9f 00 00 00       	jmp    801020a8 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102009:	8b 45 10             	mov    0x10(%ebp),%eax
8010200c:	c1 e8 09             	shr    $0x9,%eax
8010200f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102013:	8b 45 08             	mov    0x8(%ebp),%eax
80102016:	89 04 24             	mov    %eax,(%esp)
80102019:	e8 62 fb ff ff       	call   80101b80 <bmap>
8010201e:	8b 55 08             	mov    0x8(%ebp),%edx
80102021:	8b 12                	mov    (%edx),%edx
80102023:	89 44 24 04          	mov    %eax,0x4(%esp)
80102027:	89 14 24             	mov    %edx,(%esp)
8010202a:	e8 77 e1 ff ff       	call   801001a6 <bread>
8010202f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102032:	8b 45 10             	mov    0x10(%ebp),%eax
80102035:	25 ff 01 00 00       	and    $0x1ff,%eax
8010203a:	89 c2                	mov    %eax,%edx
8010203c:	b8 00 02 00 00       	mov    $0x200,%eax
80102041:	29 d0                	sub    %edx,%eax
80102043:	89 c2                	mov    %eax,%edx
80102045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102048:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010204b:	29 c1                	sub    %eax,%ecx
8010204d:	89 c8                	mov    %ecx,%eax
8010204f:	39 c2                	cmp    %eax,%edx
80102051:	0f 46 c2             	cmovbe %edx,%eax
80102054:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102057:	8b 45 10             	mov    0x10(%ebp),%eax
8010205a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010205f:	8d 50 10             	lea    0x10(%eax),%edx
80102062:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102065:	01 d0                	add    %edx,%eax
80102067:	8d 50 08             	lea    0x8(%eax),%edx
8010206a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010206d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102071:	8b 45 0c             	mov    0xc(%ebp),%eax
80102074:	89 44 24 04          	mov    %eax,0x4(%esp)
80102078:	89 14 24             	mov    %edx,(%esp)
8010207b:	e8 65 34 00 00       	call   801054e5 <memmove>
    log_write(bp);
80102080:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102083:	89 04 24             	mov    %eax,(%esp)
80102086:	e8 48 16 00 00       	call   801036d3 <log_write>
    brelse(bp);
8010208b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010208e:	89 04 24             	mov    %eax,(%esp)
80102091:	e8 81 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102096:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102099:	01 45 f4             	add    %eax,-0xc(%ebp)
8010209c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209f:	01 45 10             	add    %eax,0x10(%ebp)
801020a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a5:	01 45 0c             	add    %eax,0xc(%ebp)
801020a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ab:	3b 45 14             	cmp    0x14(%ebp),%eax
801020ae:	0f 82 55 ff ff ff    	jb     80102009 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801020b4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801020b8:	74 1f                	je     801020d9 <writei+0x18a>
801020ba:	8b 45 08             	mov    0x8(%ebp),%eax
801020bd:	8b 40 18             	mov    0x18(%eax),%eax
801020c0:	3b 45 10             	cmp    0x10(%ebp),%eax
801020c3:	73 14                	jae    801020d9 <writei+0x18a>
    ip->size = off;
801020c5:	8b 45 08             	mov    0x8(%ebp),%eax
801020c8:	8b 55 10             	mov    0x10(%ebp),%edx
801020cb:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801020ce:	8b 45 08             	mov    0x8(%ebp),%eax
801020d1:	89 04 24             	mov    %eax,(%esp)
801020d4:	e8 3d f6 ff ff       	call   80101716 <iupdate>
  }
  return n;
801020d9:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020dc:	c9                   	leave  
801020dd:	c3                   	ret    

801020de <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020de:	55                   	push   %ebp
801020df:	89 e5                	mov    %esp,%ebp
801020e1:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020e4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020eb:	00 
801020ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801020f3:	8b 45 08             	mov    0x8(%ebp),%eax
801020f6:	89 04 24             	mov    %eax,(%esp)
801020f9:	e8 8a 34 00 00       	call   80105588 <strncmp>
}
801020fe:	c9                   	leave  
801020ff:	c3                   	ret    

80102100 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102100:	55                   	push   %ebp
80102101:	89 e5                	mov    %esp,%ebp
80102103:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102106:	8b 45 08             	mov    0x8(%ebp),%eax
80102109:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010210d:	66 83 f8 01          	cmp    $0x1,%ax
80102111:	74 0c                	je     8010211f <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102113:	c7 04 24 e3 89 10 80 	movl   $0x801089e3,(%esp)
8010211a:	e8 1b e4 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010211f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102126:	e9 88 00 00 00       	jmp    801021b3 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010212b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102132:	00 
80102133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102136:	89 44 24 08          	mov    %eax,0x8(%esp)
8010213a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010213d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102141:	8b 45 08             	mov    0x8(%ebp),%eax
80102144:	89 04 24             	mov    %eax,(%esp)
80102147:	e8 9f fc ff ff       	call   80101deb <readi>
8010214c:	83 f8 10             	cmp    $0x10,%eax
8010214f:	74 0c                	je     8010215d <dirlookup+0x5d>
      panic("dirlink read");
80102151:	c7 04 24 f5 89 10 80 	movl   $0x801089f5,(%esp)
80102158:	e8 dd e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
8010215d:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102161:	66 85 c0             	test   %ax,%ax
80102164:	75 02                	jne    80102168 <dirlookup+0x68>
      continue;
80102166:	eb 47                	jmp    801021af <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102168:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010216b:	83 c0 02             	add    $0x2,%eax
8010216e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102172:	8b 45 0c             	mov    0xc(%ebp),%eax
80102175:	89 04 24             	mov    %eax,(%esp)
80102178:	e8 61 ff ff ff       	call   801020de <namecmp>
8010217d:	85 c0                	test   %eax,%eax
8010217f:	75 2e                	jne    801021af <dirlookup+0xaf>
      // entry matches path element
      if(poff)
80102181:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102185:	74 08                	je     8010218f <dirlookup+0x8f>
        *poff = off;
80102187:	8b 45 10             	mov    0x10(%ebp),%eax
8010218a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010218d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010218f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102193:	0f b7 c0             	movzwl %ax,%eax
80102196:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102199:	8b 45 08             	mov    0x8(%ebp),%eax
8010219c:	8b 00                	mov    (%eax),%eax
8010219e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801021a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a5:	89 04 24             	mov    %eax,(%esp)
801021a8:	e8 27 f6 ff ff       	call   801017d4 <iget>
801021ad:	eb 18                	jmp    801021c7 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801021af:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	8b 40 18             	mov    0x18(%eax),%eax
801021b9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021bc:	0f 87 69 ff ff ff    	ja     8010212b <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021c7:	c9                   	leave  
801021c8:	c3                   	ret    

801021c9 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021c9:	55                   	push   %ebp
801021ca:	89 e5                	mov    %esp,%ebp
801021cc:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021d6:	00 
801021d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801021da:	89 44 24 04          	mov    %eax,0x4(%esp)
801021de:	8b 45 08             	mov    0x8(%ebp),%eax
801021e1:	89 04 24             	mov    %eax,(%esp)
801021e4:	e8 17 ff ff ff       	call   80102100 <dirlookup>
801021e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021f0:	74 15                	je     80102207 <dirlink+0x3e>
    iput(ip);
801021f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f5:	89 04 24             	mov    %eax,(%esp)
801021f8:	e8 94 f8 ff ff       	call   80101a91 <iput>
    return -1;
801021fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102202:	e9 b7 00 00 00       	jmp    801022be <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102207:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220e:	eb 46                	jmp    80102256 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102213:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010221a:	00 
8010221b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010221f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102222:	89 44 24 04          	mov    %eax,0x4(%esp)
80102226:	8b 45 08             	mov    0x8(%ebp),%eax
80102229:	89 04 24             	mov    %eax,(%esp)
8010222c:	e8 ba fb ff ff       	call   80101deb <readi>
80102231:	83 f8 10             	cmp    $0x10,%eax
80102234:	74 0c                	je     80102242 <dirlink+0x79>
      panic("dirlink read");
80102236:	c7 04 24 f5 89 10 80 	movl   $0x801089f5,(%esp)
8010223d:	e8 f8 e2 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
80102242:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102246:	66 85 c0             	test   %ax,%ax
80102249:	75 02                	jne    8010224d <dirlink+0x84>
      break;
8010224b:	eb 16                	jmp    80102263 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010224d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102250:	83 c0 10             	add    $0x10,%eax
80102253:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102256:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102259:	8b 45 08             	mov    0x8(%ebp),%eax
8010225c:	8b 40 18             	mov    0x18(%eax),%eax
8010225f:	39 c2                	cmp    %eax,%edx
80102261:	72 ad                	jb     80102210 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102263:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010226a:	00 
8010226b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010226e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102272:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102275:	83 c0 02             	add    $0x2,%eax
80102278:	89 04 24             	mov    %eax,(%esp)
8010227b:	e8 5e 33 00 00       	call   801055de <strncpy>
  de.inum = inum;
80102280:	8b 45 10             	mov    0x10(%ebp),%eax
80102283:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010228a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102291:	00 
80102292:	89 44 24 08          	mov    %eax,0x8(%esp)
80102296:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102299:	89 44 24 04          	mov    %eax,0x4(%esp)
8010229d:	8b 45 08             	mov    0x8(%ebp),%eax
801022a0:	89 04 24             	mov    %eax,(%esp)
801022a3:	e8 a7 fc ff ff       	call   80101f4f <writei>
801022a8:	83 f8 10             	cmp    $0x10,%eax
801022ab:	74 0c                	je     801022b9 <dirlink+0xf0>
    panic("dirlink");
801022ad:	c7 04 24 02 8a 10 80 	movl   $0x80108a02,(%esp)
801022b4:	e8 81 e2 ff ff       	call   8010053a <panic>
  
  return 0;
801022b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022be:	c9                   	leave  
801022bf:	c3                   	ret    

801022c0 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022c0:	55                   	push   %ebp
801022c1:	89 e5                	mov    %esp,%ebp
801022c3:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022c6:	eb 04                	jmp    801022cc <skipelem+0xc>
    path++;
801022c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022cc:	8b 45 08             	mov    0x8(%ebp),%eax
801022cf:	0f b6 00             	movzbl (%eax),%eax
801022d2:	3c 2f                	cmp    $0x2f,%al
801022d4:	74 f2                	je     801022c8 <skipelem+0x8>
    path++;
  if(*path == 0)
801022d6:	8b 45 08             	mov    0x8(%ebp),%eax
801022d9:	0f b6 00             	movzbl (%eax),%eax
801022dc:	84 c0                	test   %al,%al
801022de:	75 0a                	jne    801022ea <skipelem+0x2a>
    return 0;
801022e0:	b8 00 00 00 00       	mov    $0x0,%eax
801022e5:	e9 86 00 00 00       	jmp    80102370 <skipelem+0xb0>
  s = path;
801022ea:	8b 45 08             	mov    0x8(%ebp),%eax
801022ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022f0:	eb 04                	jmp    801022f6 <skipelem+0x36>
    path++;
801022f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022f6:	8b 45 08             	mov    0x8(%ebp),%eax
801022f9:	0f b6 00             	movzbl (%eax),%eax
801022fc:	3c 2f                	cmp    $0x2f,%al
801022fe:	74 0a                	je     8010230a <skipelem+0x4a>
80102300:	8b 45 08             	mov    0x8(%ebp),%eax
80102303:	0f b6 00             	movzbl (%eax),%eax
80102306:	84 c0                	test   %al,%al
80102308:	75 e8                	jne    801022f2 <skipelem+0x32>
    path++;
  len = path - s;
8010230a:	8b 55 08             	mov    0x8(%ebp),%edx
8010230d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102310:	29 c2                	sub    %eax,%edx
80102312:	89 d0                	mov    %edx,%eax
80102314:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102317:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010231b:	7e 1c                	jle    80102339 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
8010231d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102324:	00 
80102325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102328:	89 44 24 04          	mov    %eax,0x4(%esp)
8010232c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010232f:	89 04 24             	mov    %eax,(%esp)
80102332:	e8 ae 31 00 00       	call   801054e5 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102337:	eb 2a                	jmp    80102363 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102339:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010233c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102343:	89 44 24 04          	mov    %eax,0x4(%esp)
80102347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010234a:	89 04 24             	mov    %eax,(%esp)
8010234d:	e8 93 31 00 00       	call   801054e5 <memmove>
    name[len] = 0;
80102352:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102355:	8b 45 0c             	mov    0xc(%ebp),%eax
80102358:	01 d0                	add    %edx,%eax
8010235a:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010235d:	eb 04                	jmp    80102363 <skipelem+0xa3>
    path++;
8010235f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102363:	8b 45 08             	mov    0x8(%ebp),%eax
80102366:	0f b6 00             	movzbl (%eax),%eax
80102369:	3c 2f                	cmp    $0x2f,%al
8010236b:	74 f2                	je     8010235f <skipelem+0x9f>
    path++;
  return path;
8010236d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102370:	c9                   	leave  
80102371:	c3                   	ret    

80102372 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102372:	55                   	push   %ebp
80102373:	89 e5                	mov    %esp,%ebp
80102375:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102378:	8b 45 08             	mov    0x8(%ebp),%eax
8010237b:	0f b6 00             	movzbl (%eax),%eax
8010237e:	3c 2f                	cmp    $0x2f,%al
80102380:	75 1c                	jne    8010239e <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102382:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102389:	00 
8010238a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102391:	e8 3e f4 ff ff       	call   801017d4 <iget>
80102396:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102399:	e9 af 00 00 00       	jmp    8010244d <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010239e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023a4:	8b 40 68             	mov    0x68(%eax),%eax
801023a7:	89 04 24             	mov    %eax,(%esp)
801023aa:	e8 f7 f4 ff ff       	call   801018a6 <idup>
801023af:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023b2:	e9 96 00 00 00       	jmp    8010244d <namex+0xdb>
    ilock(ip);
801023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ba:	89 04 24             	mov    %eax,(%esp)
801023bd:	e8 16 f5 ff ff       	call   801018d8 <ilock>
    if(ip->type != T_DIR){
801023c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023c9:	66 83 f8 01          	cmp    $0x1,%ax
801023cd:	74 15                	je     801023e4 <namex+0x72>
      iunlockput(ip);
801023cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d2:	89 04 24             	mov    %eax,(%esp)
801023d5:	e8 88 f7 ff ff       	call   80101b62 <iunlockput>
      return 0;
801023da:	b8 00 00 00 00       	mov    $0x0,%eax
801023df:	e9 a3 00 00 00       	jmp    80102487 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801023e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023e8:	74 1d                	je     80102407 <namex+0x95>
801023ea:	8b 45 08             	mov    0x8(%ebp),%eax
801023ed:	0f b6 00             	movzbl (%eax),%eax
801023f0:	84 c0                	test   %al,%al
801023f2:	75 13                	jne    80102407 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801023f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f7:	89 04 24             	mov    %eax,(%esp)
801023fa:	e8 2d f6 ff ff       	call   80101a2c <iunlock>
      return ip;
801023ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102402:	e9 80 00 00 00       	jmp    80102487 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102407:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010240e:	00 
8010240f:	8b 45 10             	mov    0x10(%ebp),%eax
80102412:	89 44 24 04          	mov    %eax,0x4(%esp)
80102416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102419:	89 04 24             	mov    %eax,(%esp)
8010241c:	e8 df fc ff ff       	call   80102100 <dirlookup>
80102421:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102424:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102428:	75 12                	jne    8010243c <namex+0xca>
      iunlockput(ip);
8010242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242d:	89 04 24             	mov    %eax,(%esp)
80102430:	e8 2d f7 ff ff       	call   80101b62 <iunlockput>
      return 0;
80102435:	b8 00 00 00 00       	mov    $0x0,%eax
8010243a:	eb 4b                	jmp    80102487 <namex+0x115>
    }
    iunlockput(ip);
8010243c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243f:	89 04 24             	mov    %eax,(%esp)
80102442:	e8 1b f7 ff ff       	call   80101b62 <iunlockput>
    ip = next;
80102447:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010244a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010244d:	8b 45 10             	mov    0x10(%ebp),%eax
80102450:	89 44 24 04          	mov    %eax,0x4(%esp)
80102454:	8b 45 08             	mov    0x8(%ebp),%eax
80102457:	89 04 24             	mov    %eax,(%esp)
8010245a:	e8 61 fe ff ff       	call   801022c0 <skipelem>
8010245f:	89 45 08             	mov    %eax,0x8(%ebp)
80102462:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102466:	0f 85 4b ff ff ff    	jne    801023b7 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010246c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102470:	74 12                	je     80102484 <namex+0x112>
    iput(ip);
80102472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102475:	89 04 24             	mov    %eax,(%esp)
80102478:	e8 14 f6 ff ff       	call   80101a91 <iput>
    return 0;
8010247d:	b8 00 00 00 00       	mov    $0x0,%eax
80102482:	eb 03                	jmp    80102487 <namex+0x115>
  }
  return ip;
80102484:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102487:	c9                   	leave  
80102488:	c3                   	ret    

80102489 <namei>:

struct inode*
namei(char *path)
{
80102489:	55                   	push   %ebp
8010248a:	89 e5                	mov    %esp,%ebp
8010248c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010248f:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102492:	89 44 24 08          	mov    %eax,0x8(%esp)
80102496:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010249d:	00 
8010249e:	8b 45 08             	mov    0x8(%ebp),%eax
801024a1:	89 04 24             	mov    %eax,(%esp)
801024a4:	e8 c9 fe ff ff       	call   80102372 <namex>
}
801024a9:	c9                   	leave  
801024aa:	c3                   	ret    

801024ab <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024ab:	55                   	push   %ebp
801024ac:	89 e5                	mov    %esp,%ebp
801024ae:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801024b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b4:	89 44 24 08          	mov    %eax,0x8(%esp)
801024b8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024bf:	00 
801024c0:	8b 45 08             	mov    0x8(%ebp),%eax
801024c3:	89 04 24             	mov    %eax,(%esp)
801024c6:	e8 a7 fe ff ff       	call   80102372 <namex>
}
801024cb:	c9                   	leave  
801024cc:	c3                   	ret    
801024cd:	66 90                	xchg   %ax,%ax
801024cf:	90                   	nop

801024d0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024d0:	55                   	push   %ebp
801024d1:	89 e5                	mov    %esp,%ebp
801024d3:	83 ec 14             	sub    $0x14,%esp
801024d6:	8b 45 08             	mov    0x8(%ebp),%eax
801024d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024dd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801024e1:	89 c2                	mov    %eax,%edx
801024e3:	ec                   	in     (%dx),%al
801024e4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801024e7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801024eb:	c9                   	leave  
801024ec:	c3                   	ret    

801024ed <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024ed:	55                   	push   %ebp
801024ee:	89 e5                	mov    %esp,%ebp
801024f0:	57                   	push   %edi
801024f1:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024f2:	8b 55 08             	mov    0x8(%ebp),%edx
801024f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024f8:	8b 45 10             	mov    0x10(%ebp),%eax
801024fb:	89 cb                	mov    %ecx,%ebx
801024fd:	89 df                	mov    %ebx,%edi
801024ff:	89 c1                	mov    %eax,%ecx
80102501:	fc                   	cld    
80102502:	f3 6d                	rep insl (%dx),%es:(%edi)
80102504:	89 c8                	mov    %ecx,%eax
80102506:	89 fb                	mov    %edi,%ebx
80102508:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010250b:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010250e:	5b                   	pop    %ebx
8010250f:	5f                   	pop    %edi
80102510:	5d                   	pop    %ebp
80102511:	c3                   	ret    

80102512 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102512:	55                   	push   %ebp
80102513:	89 e5                	mov    %esp,%ebp
80102515:	83 ec 08             	sub    $0x8,%esp
80102518:	8b 55 08             	mov    0x8(%ebp),%edx
8010251b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010251e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102522:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102525:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102529:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010252d:	ee                   	out    %al,(%dx)
}
8010252e:	c9                   	leave  
8010252f:	c3                   	ret    

80102530 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102530:	55                   	push   %ebp
80102531:	89 e5                	mov    %esp,%ebp
80102533:	56                   	push   %esi
80102534:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102535:	8b 55 08             	mov    0x8(%ebp),%edx
80102538:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010253b:	8b 45 10             	mov    0x10(%ebp),%eax
8010253e:	89 cb                	mov    %ecx,%ebx
80102540:	89 de                	mov    %ebx,%esi
80102542:	89 c1                	mov    %eax,%ecx
80102544:	fc                   	cld    
80102545:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102547:	89 c8                	mov    %ecx,%eax
80102549:	89 f3                	mov    %esi,%ebx
8010254b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010254e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102551:	5b                   	pop    %ebx
80102552:	5e                   	pop    %esi
80102553:	5d                   	pop    %ebp
80102554:	c3                   	ret    

80102555 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102555:	55                   	push   %ebp
80102556:	89 e5                	mov    %esp,%ebp
80102558:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010255b:	90                   	nop
8010255c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102563:	e8 68 ff ff ff       	call   801024d0 <inb>
80102568:	0f b6 c0             	movzbl %al,%eax
8010256b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010256e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102571:	25 c0 00 00 00       	and    $0xc0,%eax
80102576:	83 f8 40             	cmp    $0x40,%eax
80102579:	75 e1                	jne    8010255c <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010257b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010257f:	74 11                	je     80102592 <idewait+0x3d>
80102581:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102584:	83 e0 21             	and    $0x21,%eax
80102587:	85 c0                	test   %eax,%eax
80102589:	74 07                	je     80102592 <idewait+0x3d>
    return -1;
8010258b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102590:	eb 05                	jmp    80102597 <idewait+0x42>
  return 0;
80102592:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102597:	c9                   	leave  
80102598:	c3                   	ret    

80102599 <ideinit>:

void
ideinit(void)
{
80102599:	55                   	push   %ebp
8010259a:	89 e5                	mov    %esp,%ebp
8010259c:	83 ec 28             	sub    $0x28,%esp
  int i;
  
  initlock(&idelock, "ide");
8010259f:	c7 44 24 04 0a 8a 10 	movl   $0x80108a0a,0x4(%esp)
801025a6:	80 
801025a7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801025ae:	e8 eb 2b 00 00       	call   8010519e <initlock>
  picenable(IRQ_IDE);
801025b3:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025ba:	e8 ae 18 00 00       	call   80103e6d <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025bf:	a1 40 29 11 80       	mov    0x80112940,%eax
801025c4:	83 e8 01             	sub    $0x1,%eax
801025c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801025cb:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025d2:	e8 45 04 00 00       	call   80102a1c <ioapicenable>
  idewait(0);
801025d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025de:	e8 72 ff ff ff       	call   80102555 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025e3:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025ea:	00 
801025eb:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025f2:	e8 1b ff ff ff       	call   80102512 <outb>
  for(i=0; i<1000; i++){
801025f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025fe:	eb 20                	jmp    80102620 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102600:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102607:	e8 c4 fe ff ff       	call   801024d0 <inb>
8010260c:	84 c0                	test   %al,%al
8010260e:	74 0c                	je     8010261c <ideinit+0x83>
      havedisk1 = 1;
80102610:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102617:	00 00 00 
      break;
8010261a:	eb 0d                	jmp    80102629 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010261c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102620:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102627:	7e d7                	jle    80102600 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102629:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102630:	00 
80102631:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102638:	e8 d5 fe ff ff       	call   80102512 <outb>
}
8010263d:	c9                   	leave  
8010263e:	c3                   	ret    

8010263f <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010263f:	55                   	push   %ebp
80102640:	89 e5                	mov    %esp,%ebp
80102642:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102645:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102649:	75 0c                	jne    80102657 <idestart+0x18>
    panic("idestart");
8010264b:	c7 04 24 0e 8a 10 80 	movl   $0x80108a0e,(%esp)
80102652:	e8 e3 de ff ff       	call   8010053a <panic>
  if(b->blockno >= FSSIZE)
80102657:	8b 45 08             	mov    0x8(%ebp),%eax
8010265a:	8b 40 08             	mov    0x8(%eax),%eax
8010265d:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102662:	76 0c                	jbe    80102670 <idestart+0x31>
    panic("incorrect blockno");
80102664:	c7 04 24 17 8a 10 80 	movl   $0x80108a17,(%esp)
8010266b:	e8 ca de ff ff       	call   8010053a <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102670:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102677:	8b 45 08             	mov    0x8(%ebp),%eax
8010267a:	8b 50 08             	mov    0x8(%eax),%edx
8010267d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102680:	0f af c2             	imul   %edx,%eax
80102683:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102686:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010268a:	7e 0c                	jle    80102698 <idestart+0x59>
8010268c:	c7 04 24 0e 8a 10 80 	movl   $0x80108a0e,(%esp)
80102693:	e8 a2 de ff ff       	call   8010053a <panic>
  
  idewait(0);
80102698:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010269f:	e8 b1 fe ff ff       	call   80102555 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801026a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026ab:	00 
801026ac:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801026b3:	e8 5a fe ff ff       	call   80102512 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801026b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026bb:	0f b6 c0             	movzbl %al,%eax
801026be:	89 44 24 04          	mov    %eax,0x4(%esp)
801026c2:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801026c9:	e8 44 fe ff ff       	call   80102512 <outb>
  outb(0x1f3, sector & 0xff);
801026ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026d1:	0f b6 c0             	movzbl %al,%eax
801026d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d8:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801026df:	e8 2e fe ff ff       	call   80102512 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801026e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026e7:	c1 f8 08             	sar    $0x8,%eax
801026ea:	0f b6 c0             	movzbl %al,%eax
801026ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801026f1:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801026f8:	e8 15 fe ff ff       	call   80102512 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801026fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102700:	c1 f8 10             	sar    $0x10,%eax
80102703:	0f b6 c0             	movzbl %al,%eax
80102706:	89 44 24 04          	mov    %eax,0x4(%esp)
8010270a:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102711:	e8 fc fd ff ff       	call   80102512 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102716:	8b 45 08             	mov    0x8(%ebp),%eax
80102719:	8b 40 04             	mov    0x4(%eax),%eax
8010271c:	83 e0 01             	and    $0x1,%eax
8010271f:	c1 e0 04             	shl    $0x4,%eax
80102722:	89 c2                	mov    %eax,%edx
80102724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102727:	c1 f8 18             	sar    $0x18,%eax
8010272a:	83 e0 0f             	and    $0xf,%eax
8010272d:	09 d0                	or     %edx,%eax
8010272f:	83 c8 e0             	or     $0xffffffe0,%eax
80102732:	0f b6 c0             	movzbl %al,%eax
80102735:	89 44 24 04          	mov    %eax,0x4(%esp)
80102739:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102740:	e8 cd fd ff ff       	call   80102512 <outb>
  if(b->flags & B_DIRTY){
80102745:	8b 45 08             	mov    0x8(%ebp),%eax
80102748:	8b 00                	mov    (%eax),%eax
8010274a:	83 e0 04             	and    $0x4,%eax
8010274d:	85 c0                	test   %eax,%eax
8010274f:	74 34                	je     80102785 <idestart+0x146>
    outb(0x1f7, IDE_CMD_WRITE);
80102751:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102758:	00 
80102759:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102760:	e8 ad fd ff ff       	call   80102512 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102765:	8b 45 08             	mov    0x8(%ebp),%eax
80102768:	83 c0 18             	add    $0x18,%eax
8010276b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102772:	00 
80102773:	89 44 24 04          	mov    %eax,0x4(%esp)
80102777:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010277e:	e8 ad fd ff ff       	call   80102530 <outsl>
80102783:	eb 14                	jmp    80102799 <idestart+0x15a>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102785:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
8010278c:	00 
8010278d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102794:	e8 79 fd ff ff       	call   80102512 <outb>
  }
}
80102799:	c9                   	leave  
8010279a:	c3                   	ret    

8010279b <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010279b:	55                   	push   %ebp
8010279c:	89 e5                	mov    %esp,%ebp
8010279e:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801027a1:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027a8:	e8 12 2a 00 00       	call   801051bf <acquire>
  if((b = idequeue) == 0){
801027ad:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b9:	75 11                	jne    801027cc <ideintr+0x31>
    release(&idelock);
801027bb:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027c2:	e8 5a 2a 00 00       	call   80105221 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801027c7:	e9 90 00 00 00       	jmp    8010285c <ideintr+0xc1>
  }
  idequeue = b->qnext;
801027cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027cf:	8b 40 14             	mov    0x14(%eax),%eax
801027d2:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027da:	8b 00                	mov    (%eax),%eax
801027dc:	83 e0 04             	and    $0x4,%eax
801027df:	85 c0                	test   %eax,%eax
801027e1:	75 2e                	jne    80102811 <ideintr+0x76>
801027e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027ea:	e8 66 fd ff ff       	call   80102555 <idewait>
801027ef:	85 c0                	test   %eax,%eax
801027f1:	78 1e                	js     80102811 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801027f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f6:	83 c0 18             	add    $0x18,%eax
801027f9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102800:	00 
80102801:	89 44 24 04          	mov    %eax,0x4(%esp)
80102805:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010280c:	e8 dc fc ff ff       	call   801024ed <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102814:	8b 00                	mov    (%eax),%eax
80102816:	83 c8 02             	or     $0x2,%eax
80102819:	89 c2                	mov    %eax,%edx
8010281b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010281e:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102823:	8b 00                	mov    (%eax),%eax
80102825:	83 e0 fb             	and    $0xfffffffb,%eax
80102828:	89 c2                	mov    %eax,%edx
8010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282d:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010282f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102832:	89 04 24             	mov    %eax,(%esp)
80102835:	e8 90 24 00 00       	call   80104cca <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010283a:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010283f:	85 c0                	test   %eax,%eax
80102841:	74 0d                	je     80102850 <ideintr+0xb5>
    idestart(idequeue);
80102843:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102848:	89 04 24             	mov    %eax,(%esp)
8010284b:	e8 ef fd ff ff       	call   8010263f <idestart>

  release(&idelock);
80102850:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102857:	e8 c5 29 00 00       	call   80105221 <release>
}
8010285c:	c9                   	leave  
8010285d:	c3                   	ret    

8010285e <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010285e:	55                   	push   %ebp
8010285f:	89 e5                	mov    %esp,%ebp
80102861:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102864:	8b 45 08             	mov    0x8(%ebp),%eax
80102867:	8b 00                	mov    (%eax),%eax
80102869:	83 e0 01             	and    $0x1,%eax
8010286c:	85 c0                	test   %eax,%eax
8010286e:	75 0c                	jne    8010287c <iderw+0x1e>
    panic("iderw: buf not busy");
80102870:	c7 04 24 29 8a 10 80 	movl   $0x80108a29,(%esp)
80102877:	e8 be dc ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010287c:	8b 45 08             	mov    0x8(%ebp),%eax
8010287f:	8b 00                	mov    (%eax),%eax
80102881:	83 e0 06             	and    $0x6,%eax
80102884:	83 f8 02             	cmp    $0x2,%eax
80102887:	75 0c                	jne    80102895 <iderw+0x37>
    panic("iderw: nothing to do");
80102889:	c7 04 24 3d 8a 10 80 	movl   $0x80108a3d,(%esp)
80102890:	e8 a5 dc ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
80102895:	8b 45 08             	mov    0x8(%ebp),%eax
80102898:	8b 40 04             	mov    0x4(%eax),%eax
8010289b:	85 c0                	test   %eax,%eax
8010289d:	74 15                	je     801028b4 <iderw+0x56>
8010289f:	a1 38 b6 10 80       	mov    0x8010b638,%eax
801028a4:	85 c0                	test   %eax,%eax
801028a6:	75 0c                	jne    801028b4 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801028a8:	c7 04 24 52 8a 10 80 	movl   $0x80108a52,(%esp)
801028af:	e8 86 dc ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028b4:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028bb:	e8 ff 28 00 00       	call   801051bf <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801028c0:	8b 45 08             	mov    0x8(%ebp),%eax
801028c3:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028ca:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
801028d1:	eb 0b                	jmp    801028de <iderw+0x80>
801028d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d6:	8b 00                	mov    (%eax),%eax
801028d8:	83 c0 14             	add    $0x14,%eax
801028db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e1:	8b 00                	mov    (%eax),%eax
801028e3:	85 c0                	test   %eax,%eax
801028e5:	75 ec                	jne    801028d3 <iderw+0x75>
    ;
  *pp = b;
801028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ea:	8b 55 08             	mov    0x8(%ebp),%edx
801028ed:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028ef:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028f4:	3b 45 08             	cmp    0x8(%ebp),%eax
801028f7:	75 0d                	jne    80102906 <iderw+0xa8>
    idestart(b);
801028f9:	8b 45 08             	mov    0x8(%ebp),%eax
801028fc:	89 04 24             	mov    %eax,(%esp)
801028ff:	e8 3b fd ff ff       	call   8010263f <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102904:	eb 15                	jmp    8010291b <iderw+0xbd>
80102906:	eb 13                	jmp    8010291b <iderw+0xbd>
    sleep(b, &idelock);
80102908:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
8010290f:	80 
80102910:	8b 45 08             	mov    0x8(%ebp),%eax
80102913:	89 04 24             	mov    %eax,(%esp)
80102916:	e8 d6 22 00 00       	call   80104bf1 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010291b:	8b 45 08             	mov    0x8(%ebp),%eax
8010291e:	8b 00                	mov    (%eax),%eax
80102920:	83 e0 06             	and    $0x6,%eax
80102923:	83 f8 02             	cmp    $0x2,%eax
80102926:	75 e0                	jne    80102908 <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
80102928:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010292f:	e8 ed 28 00 00       	call   80105221 <release>
}
80102934:	c9                   	leave  
80102935:	c3                   	ret    
80102936:	66 90                	xchg   %ax,%ax

80102938 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102938:	55                   	push   %ebp
80102939:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010293b:	a1 14 22 11 80       	mov    0x80112214,%eax
80102940:	8b 55 08             	mov    0x8(%ebp),%edx
80102943:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102945:	a1 14 22 11 80       	mov    0x80112214,%eax
8010294a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010294d:	5d                   	pop    %ebp
8010294e:	c3                   	ret    

8010294f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010294f:	55                   	push   %ebp
80102950:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102952:	a1 14 22 11 80       	mov    0x80112214,%eax
80102957:	8b 55 08             	mov    0x8(%ebp),%edx
8010295a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010295c:	a1 14 22 11 80       	mov    0x80112214,%eax
80102961:	8b 55 0c             	mov    0xc(%ebp),%edx
80102964:	89 50 10             	mov    %edx,0x10(%eax)
}
80102967:	5d                   	pop    %ebp
80102968:	c3                   	ret    

80102969 <ioapicinit>:

void
ioapicinit(void)
{
80102969:	55                   	push   %ebp
8010296a:	89 e5                	mov    %esp,%ebp
8010296c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010296f:	a1 44 23 11 80       	mov    0x80112344,%eax
80102974:	85 c0                	test   %eax,%eax
80102976:	75 05                	jne    8010297d <ioapicinit+0x14>
    return;
80102978:	e9 9d 00 00 00       	jmp    80102a1a <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
8010297d:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
80102984:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102987:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010298e:	e8 a5 ff ff ff       	call   80102938 <ioapicread>
80102993:	c1 e8 10             	shr    $0x10,%eax
80102996:	25 ff 00 00 00       	and    $0xff,%eax
8010299b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010299e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801029a5:	e8 8e ff ff ff       	call   80102938 <ioapicread>
801029aa:	c1 e8 18             	shr    $0x18,%eax
801029ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029b0:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
801029b7:	0f b6 c0             	movzbl %al,%eax
801029ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029bd:	74 0c                	je     801029cb <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029bf:	c7 04 24 70 8a 10 80 	movl   $0x80108a70,(%esp)
801029c6:	e8 d5 d9 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029d2:	eb 3e                	jmp    80102a12 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d7:	83 c0 20             	add    $0x20,%eax
801029da:	0d 00 00 01 00       	or     $0x10000,%eax
801029df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029e2:	83 c2 08             	add    $0x8,%edx
801029e5:	01 d2                	add    %edx,%edx
801029e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801029eb:	89 14 24             	mov    %edx,(%esp)
801029ee:	e8 5c ff ff ff       	call   8010294f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f6:	83 c0 08             	add    $0x8,%eax
801029f9:	01 c0                	add    %eax,%eax
801029fb:	83 c0 01             	add    $0x1,%eax
801029fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102a05:	00 
80102a06:	89 04 24             	mov    %eax,(%esp)
80102a09:	e8 41 ff ff ff       	call   8010294f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a15:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a18:	7e ba                	jle    801029d4 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a1a:	c9                   	leave  
80102a1b:	c3                   	ret    

80102a1c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a1c:	55                   	push   %ebp
80102a1d:	89 e5                	mov    %esp,%ebp
80102a1f:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102a22:	a1 44 23 11 80       	mov    0x80112344,%eax
80102a27:	85 c0                	test   %eax,%eax
80102a29:	75 02                	jne    80102a2d <ioapicenable+0x11>
    return;
80102a2b:	eb 37                	jmp    80102a64 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a30:	83 c0 20             	add    $0x20,%eax
80102a33:	8b 55 08             	mov    0x8(%ebp),%edx
80102a36:	83 c2 08             	add    $0x8,%edx
80102a39:	01 d2                	add    %edx,%edx
80102a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a3f:	89 14 24             	mov    %edx,(%esp)
80102a42:	e8 08 ff ff ff       	call   8010294f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a47:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a4a:	c1 e0 18             	shl    $0x18,%eax
80102a4d:	8b 55 08             	mov    0x8(%ebp),%edx
80102a50:	83 c2 08             	add    $0x8,%edx
80102a53:	01 d2                	add    %edx,%edx
80102a55:	83 c2 01             	add    $0x1,%edx
80102a58:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a5c:	89 14 24             	mov    %edx,(%esp)
80102a5f:	e8 eb fe ff ff       	call   8010294f <ioapicwrite>
}
80102a64:	c9                   	leave  
80102a65:	c3                   	ret    
80102a66:	66 90                	xchg   %ax,%ax

80102a68 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a68:	55                   	push   %ebp
80102a69:	89 e5                	mov    %esp,%ebp
80102a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6e:	05 00 00 00 80       	add    $0x80000000,%eax
80102a73:	5d                   	pop    %ebp
80102a74:	c3                   	ret    

80102a75 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a75:	55                   	push   %ebp
80102a76:	89 e5                	mov    %esp,%ebp
80102a78:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a7b:	c7 44 24 04 a2 8a 10 	movl   $0x80108aa2,0x4(%esp)
80102a82:	80 
80102a83:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102a8a:	e8 0f 27 00 00       	call   8010519e <initlock>
  kmem.use_lock = 0;
80102a8f:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
80102a96:	00 00 00 
  freerange(vstart, vend);
80102a99:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa3:	89 04 24             	mov    %eax,(%esp)
80102aa6:	e8 26 00 00 00       	call   80102ad1 <freerange>
}
80102aab:	c9                   	leave  
80102aac:	c3                   	ret    

80102aad <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102aad:	55                   	push   %ebp
80102aae:	89 e5                	mov    %esp,%ebp
80102ab0:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aba:	8b 45 08             	mov    0x8(%ebp),%eax
80102abd:	89 04 24             	mov    %eax,(%esp)
80102ac0:	e8 0c 00 00 00       	call   80102ad1 <freerange>
  kmem.use_lock = 1;
80102ac5:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102acc:	00 00 00 
}
80102acf:	c9                   	leave  
80102ad0:	c3                   	ret    

80102ad1 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102ad1:	55                   	push   %ebp
80102ad2:	89 e5                	mov    %esp,%ebp
80102ad4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80102ada:	05 ff 0f 00 00       	add    $0xfff,%eax
80102adf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ae7:	eb 12                	jmp    80102afb <freerange+0x2a>
    kfree(p);
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	89 04 24             	mov    %eax,(%esp)
80102aef:	e8 16 00 00 00       	call   80102b0a <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102af4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afe:	05 00 10 00 00       	add    $0x1000,%eax
80102b03:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b06:	76 e1                	jbe    80102ae9 <freerange+0x18>
    kfree(p);
}
80102b08:	c9                   	leave  
80102b09:	c3                   	ret    

80102b0a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b0a:	55                   	push   %ebp
80102b0b:	89 e5                	mov    %esp,%ebp
80102b0d:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b10:	8b 45 08             	mov    0x8(%ebp),%eax
80102b13:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b18:	85 c0                	test   %eax,%eax
80102b1a:	75 1b                	jne    80102b37 <kfree+0x2d>
80102b1c:	81 7d 08 3c 51 11 80 	cmpl   $0x8011513c,0x8(%ebp)
80102b23:	72 12                	jb     80102b37 <kfree+0x2d>
80102b25:	8b 45 08             	mov    0x8(%ebp),%eax
80102b28:	89 04 24             	mov    %eax,(%esp)
80102b2b:	e8 38 ff ff ff       	call   80102a68 <v2p>
80102b30:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b35:	76 0c                	jbe    80102b43 <kfree+0x39>
    panic("kfree");
80102b37:	c7 04 24 a7 8a 10 80 	movl   $0x80108aa7,(%esp)
80102b3e:	e8 f7 d9 ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b43:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b4a:	00 
80102b4b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b52:	00 
80102b53:	8b 45 08             	mov    0x8(%ebp),%eax
80102b56:	89 04 24             	mov    %eax,(%esp)
80102b59:	e8 b8 28 00 00       	call   80105416 <memset>

  if(kmem.use_lock)
80102b5e:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b63:	85 c0                	test   %eax,%eax
80102b65:	74 0c                	je     80102b73 <kfree+0x69>
    acquire(&kmem.lock);
80102b67:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b6e:	e8 4c 26 00 00       	call   801051bf <acquire>
  r = (struct run*)v;
80102b73:	8b 45 08             	mov    0x8(%ebp),%eax
80102b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b79:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b82:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b87:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b8c:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b91:	85 c0                	test   %eax,%eax
80102b93:	74 0c                	je     80102ba1 <kfree+0x97>
    release(&kmem.lock);
80102b95:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b9c:	e8 80 26 00 00       	call   80105221 <release>
}
80102ba1:	c9                   	leave  
80102ba2:	c3                   	ret    

80102ba3 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ba3:	55                   	push   %ebp
80102ba4:	89 e5                	mov    %esp,%ebp
80102ba6:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ba9:	a1 54 22 11 80       	mov    0x80112254,%eax
80102bae:	85 c0                	test   %eax,%eax
80102bb0:	74 0c                	je     80102bbe <kalloc+0x1b>
    acquire(&kmem.lock);
80102bb2:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102bb9:	e8 01 26 00 00       	call   801051bf <acquire>
  r = kmem.freelist;
80102bbe:	a1 58 22 11 80       	mov    0x80112258,%eax
80102bc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bca:	74 0a                	je     80102bd6 <kalloc+0x33>
    kmem.freelist = r->next;
80102bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bcf:	8b 00                	mov    (%eax),%eax
80102bd1:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102bd6:	a1 54 22 11 80       	mov    0x80112254,%eax
80102bdb:	85 c0                	test   %eax,%eax
80102bdd:	74 0c                	je     80102beb <kalloc+0x48>
    release(&kmem.lock);
80102bdf:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102be6:	e8 36 26 00 00       	call   80105221 <release>
  return (char*)r;
80102beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bee:	c9                   	leave  
80102bef:	c3                   	ret    

80102bf0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102bf0:	55                   	push   %ebp
80102bf1:	89 e5                	mov    %esp,%ebp
80102bf3:	83 ec 14             	sub    $0x14,%esp
80102bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bfd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c01:	89 c2                	mov    %eax,%edx
80102c03:	ec                   	in     (%dx),%al
80102c04:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c07:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c0b:	c9                   	leave  
80102c0c:	c3                   	ret    

80102c0d <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c0d:	55                   	push   %ebp
80102c0e:	89 e5                	mov    %esp,%ebp
80102c10:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c13:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102c1a:	e8 d1 ff ff ff       	call   80102bf0 <inb>
80102c1f:	0f b6 c0             	movzbl %al,%eax
80102c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c28:	83 e0 01             	and    $0x1,%eax
80102c2b:	85 c0                	test   %eax,%eax
80102c2d:	75 0a                	jne    80102c39 <kbdgetc+0x2c>
    return -1;
80102c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c34:	e9 25 01 00 00       	jmp    80102d5e <kbdgetc+0x151>
  data = inb(KBDATAP);
80102c39:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c40:	e8 ab ff ff ff       	call   80102bf0 <inb>
80102c45:	0f b6 c0             	movzbl %al,%eax
80102c48:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c4b:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c52:	75 17                	jne    80102c6b <kbdgetc+0x5e>
    shift |= E0ESC;
80102c54:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c59:	83 c8 40             	or     $0x40,%eax
80102c5c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c61:	b8 00 00 00 00       	mov    $0x0,%eax
80102c66:	e9 f3 00 00 00       	jmp    80102d5e <kbdgetc+0x151>
  } else if(data & 0x80){
80102c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6e:	25 80 00 00 00       	and    $0x80,%eax
80102c73:	85 c0                	test   %eax,%eax
80102c75:	74 45                	je     80102cbc <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c77:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c7c:	83 e0 40             	and    $0x40,%eax
80102c7f:	85 c0                	test   %eax,%eax
80102c81:	75 08                	jne    80102c8b <kbdgetc+0x7e>
80102c83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c86:	83 e0 7f             	and    $0x7f,%eax
80102c89:	eb 03                	jmp    80102c8e <kbdgetc+0x81>
80102c8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c94:	05 20 90 10 80       	add    $0x80109020,%eax
80102c99:	0f b6 00             	movzbl (%eax),%eax
80102c9c:	83 c8 40             	or     $0x40,%eax
80102c9f:	0f b6 c0             	movzbl %al,%eax
80102ca2:	f7 d0                	not    %eax
80102ca4:	89 c2                	mov    %eax,%edx
80102ca6:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cab:	21 d0                	and    %edx,%eax
80102cad:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102cb2:	b8 00 00 00 00       	mov    $0x0,%eax
80102cb7:	e9 a2 00 00 00       	jmp    80102d5e <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102cbc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cc1:	83 e0 40             	and    $0x40,%eax
80102cc4:	85 c0                	test   %eax,%eax
80102cc6:	74 14                	je     80102cdc <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cc8:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ccf:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cd4:	83 e0 bf             	and    $0xffffffbf,%eax
80102cd7:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102cdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cdf:	05 20 90 10 80       	add    $0x80109020,%eax
80102ce4:	0f b6 00             	movzbl (%eax),%eax
80102ce7:	0f b6 d0             	movzbl %al,%edx
80102cea:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cef:	09 d0                	or     %edx,%eax
80102cf1:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cf9:	05 20 91 10 80       	add    $0x80109120,%eax
80102cfe:	0f b6 00             	movzbl (%eax),%eax
80102d01:	0f b6 d0             	movzbl %al,%edx
80102d04:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d09:	31 d0                	xor    %edx,%eax
80102d0b:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d10:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d15:	83 e0 03             	and    $0x3,%eax
80102d18:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102d1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d22:	01 d0                	add    %edx,%eax
80102d24:	0f b6 00             	movzbl (%eax),%eax
80102d27:	0f b6 c0             	movzbl %al,%eax
80102d2a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d2d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d32:	83 e0 08             	and    $0x8,%eax
80102d35:	85 c0                	test   %eax,%eax
80102d37:	74 22                	je     80102d5b <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102d39:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d3d:	76 0c                	jbe    80102d4b <kbdgetc+0x13e>
80102d3f:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d43:	77 06                	ja     80102d4b <kbdgetc+0x13e>
      c += 'A' - 'a';
80102d45:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d49:	eb 10                	jmp    80102d5b <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102d4b:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d4f:	76 0a                	jbe    80102d5b <kbdgetc+0x14e>
80102d51:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d55:	77 04                	ja     80102d5b <kbdgetc+0x14e>
      c += 'a' - 'A';
80102d57:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d5e:	c9                   	leave  
80102d5f:	c3                   	ret    

80102d60 <kbdintr>:

void
kbdintr(void)
{
80102d60:	55                   	push   %ebp
80102d61:	89 e5                	mov    %esp,%ebp
80102d63:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d66:	c7 04 24 0d 2c 10 80 	movl   $0x80102c0d,(%esp)
80102d6d:	e8 56 da ff ff       	call   801007c8 <consoleintr>
}
80102d72:	c9                   	leave  
80102d73:	c3                   	ret    

80102d74 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d74:	55                   	push   %ebp
80102d75:	89 e5                	mov    %esp,%ebp
80102d77:	83 ec 14             	sub    $0x14,%esp
80102d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d81:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d85:	89 c2                	mov    %eax,%edx
80102d87:	ec                   	in     (%dx),%al
80102d88:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d8b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d8f:	c9                   	leave  
80102d90:	c3                   	ret    

80102d91 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d91:	55                   	push   %ebp
80102d92:	89 e5                	mov    %esp,%ebp
80102d94:	83 ec 08             	sub    $0x8,%esp
80102d97:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d9d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102da1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102da4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102da8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102dac:	ee                   	out    %al,(%dx)
}
80102dad:	c9                   	leave  
80102dae:	c3                   	ret    

80102daf <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102daf:	55                   	push   %ebp
80102db0:	89 e5                	mov    %esp,%ebp
80102db2:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102db5:	9c                   	pushf  
80102db6:	58                   	pop    %eax
80102db7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102dba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102dbd:	c9                   	leave  
80102dbe:	c3                   	ret    

80102dbf <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102dbf:	55                   	push   %ebp
80102dc0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102dc2:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102dc7:	8b 55 08             	mov    0x8(%ebp),%edx
80102dca:	c1 e2 02             	shl    $0x2,%edx
80102dcd:	01 c2                	add    %eax,%edx
80102dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dd2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102dd4:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102dd9:	83 c0 20             	add    $0x20,%eax
80102ddc:	8b 00                	mov    (%eax),%eax
}
80102dde:	5d                   	pop    %ebp
80102ddf:	c3                   	ret    

80102de0 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102de0:	55                   	push   %ebp
80102de1:	89 e5                	mov    %esp,%ebp
80102de3:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102de6:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102deb:	85 c0                	test   %eax,%eax
80102ded:	75 05                	jne    80102df4 <lapicinit+0x14>
    return;
80102def:	e9 43 01 00 00       	jmp    80102f37 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102df4:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102dfb:	00 
80102dfc:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102e03:	e8 b7 ff ff ff       	call   80102dbf <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e08:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102e0f:	00 
80102e10:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102e17:	e8 a3 ff ff ff       	call   80102dbf <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e1c:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e23:	00 
80102e24:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e2b:	e8 8f ff ff ff       	call   80102dbf <lapicw>
  lapicw(TICR, 10000000); 
80102e30:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e37:	00 
80102e38:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e3f:	e8 7b ff ff ff       	call   80102dbf <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e44:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e4b:	00 
80102e4c:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e53:	e8 67 ff ff ff       	call   80102dbf <lapicw>
  lapicw(LINT1, MASKED);
80102e58:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e5f:	00 
80102e60:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e67:	e8 53 ff ff ff       	call   80102dbf <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e6c:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e71:	83 c0 30             	add    $0x30,%eax
80102e74:	8b 00                	mov    (%eax),%eax
80102e76:	c1 e8 10             	shr    $0x10,%eax
80102e79:	0f b6 c0             	movzbl %al,%eax
80102e7c:	83 f8 03             	cmp    $0x3,%eax
80102e7f:	76 14                	jbe    80102e95 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102e81:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e88:	00 
80102e89:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e90:	e8 2a ff ff ff       	call   80102dbf <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e95:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e9c:	00 
80102e9d:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102ea4:	e8 16 ff ff ff       	call   80102dbf <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102ea9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb0:	00 
80102eb1:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102eb8:	e8 02 ff ff ff       	call   80102dbf <lapicw>
  lapicw(ESR, 0);
80102ebd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ec4:	00 
80102ec5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102ecc:	e8 ee fe ff ff       	call   80102dbf <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ed1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ed8:	00 
80102ed9:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ee0:	e8 da fe ff ff       	call   80102dbf <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ee5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eec:	00 
80102eed:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ef4:	e8 c6 fe ff ff       	call   80102dbf <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ef9:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102f00:	00 
80102f01:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f08:	e8 b2 fe ff ff       	call   80102dbf <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f0d:	90                   	nop
80102f0e:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f13:	05 00 03 00 00       	add    $0x300,%eax
80102f18:	8b 00                	mov    (%eax),%eax
80102f1a:	25 00 10 00 00       	and    $0x1000,%eax
80102f1f:	85 c0                	test   %eax,%eax
80102f21:	75 eb                	jne    80102f0e <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f23:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f2a:	00 
80102f2b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f32:	e8 88 fe ff ff       	call   80102dbf <lapicw>
}
80102f37:	c9                   	leave  
80102f38:	c3                   	ret    

80102f39 <cpunum>:

int
cpunum(void)
{
80102f39:	55                   	push   %ebp
80102f3a:	89 e5                	mov    %esp,%ebp
80102f3c:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f3f:	e8 6b fe ff ff       	call   80102daf <readeflags>
80102f44:	25 00 02 00 00       	and    $0x200,%eax
80102f49:	85 c0                	test   %eax,%eax
80102f4b:	74 25                	je     80102f72 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102f4d:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102f52:	8d 50 01             	lea    0x1(%eax),%edx
80102f55:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102f5b:	85 c0                	test   %eax,%eax
80102f5d:	75 13                	jne    80102f72 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f5f:	8b 45 04             	mov    0x4(%ebp),%eax
80102f62:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f66:	c7 04 24 b0 8a 10 80 	movl   $0x80108ab0,(%esp)
80102f6d:	e8 2e d4 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f72:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f77:	85 c0                	test   %eax,%eax
80102f79:	74 0f                	je     80102f8a <cpunum+0x51>
    return lapic[ID]>>24;
80102f7b:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f80:	83 c0 20             	add    $0x20,%eax
80102f83:	8b 00                	mov    (%eax),%eax
80102f85:	c1 e8 18             	shr    $0x18,%eax
80102f88:	eb 05                	jmp    80102f8f <cpunum+0x56>
  return 0;
80102f8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f8f:	c9                   	leave  
80102f90:	c3                   	ret    

80102f91 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f91:	55                   	push   %ebp
80102f92:	89 e5                	mov    %esp,%ebp
80102f94:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f97:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f9c:	85 c0                	test   %eax,%eax
80102f9e:	74 14                	je     80102fb4 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102fa0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fa7:	00 
80102fa8:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102faf:	e8 0b fe ff ff       	call   80102dbf <lapicw>
}
80102fb4:	c9                   	leave  
80102fb5:	c3                   	ret    

80102fb6 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fb6:	55                   	push   %ebp
80102fb7:	89 e5                	mov    %esp,%ebp
}
80102fb9:	5d                   	pop    %ebp
80102fba:	c3                   	ret    

80102fbb <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fbb:	55                   	push   %ebp
80102fbc:	89 e5                	mov    %esp,%ebp
80102fbe:	83 ec 1c             	sub    $0x1c,%esp
80102fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80102fc4:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fc7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fce:	00 
80102fcf:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fd6:	e8 b6 fd ff ff       	call   80102d91 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fdb:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fe2:	00 
80102fe3:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102fea:	e8 a2 fd ff ff       	call   80102d91 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fef:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102ff6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ff9:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102ffe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103001:	8d 50 02             	lea    0x2(%eax),%edx
80103004:	8b 45 0c             	mov    0xc(%ebp),%eax
80103007:	c1 e8 04             	shr    $0x4,%eax
8010300a:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010300d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103011:	c1 e0 18             	shl    $0x18,%eax
80103014:	89 44 24 04          	mov    %eax,0x4(%esp)
80103018:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010301f:	e8 9b fd ff ff       	call   80102dbf <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103024:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
8010302b:	00 
8010302c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103033:	e8 87 fd ff ff       	call   80102dbf <lapicw>
  microdelay(200);
80103038:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010303f:	e8 72 ff ff ff       	call   80102fb6 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103044:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010304b:	00 
8010304c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103053:	e8 67 fd ff ff       	call   80102dbf <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103058:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010305f:	e8 52 ff ff ff       	call   80102fb6 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103064:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010306b:	eb 40                	jmp    801030ad <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010306d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103071:	c1 e0 18             	shl    $0x18,%eax
80103074:	89 44 24 04          	mov    %eax,0x4(%esp)
80103078:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010307f:	e8 3b fd ff ff       	call   80102dbf <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103084:	8b 45 0c             	mov    0xc(%ebp),%eax
80103087:	c1 e8 0c             	shr    $0xc,%eax
8010308a:	80 cc 06             	or     $0x6,%ah
8010308d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103091:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103098:	e8 22 fd ff ff       	call   80102dbf <lapicw>
    microdelay(200);
8010309d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030a4:	e8 0d ff ff ff       	call   80102fb6 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801030ad:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801030b1:	7e ba                	jle    8010306d <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801030b3:	c9                   	leave  
801030b4:	c3                   	ret    

801030b5 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801030b5:	55                   	push   %ebp
801030b6:	89 e5                	mov    %esp,%ebp
801030b8:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030bb:	8b 45 08             	mov    0x8(%ebp),%eax
801030be:	0f b6 c0             	movzbl %al,%eax
801030c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801030c5:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030cc:	e8 c0 fc ff ff       	call   80102d91 <outb>
  microdelay(200);
801030d1:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030d8:	e8 d9 fe ff ff       	call   80102fb6 <microdelay>

  return inb(CMOS_RETURN);
801030dd:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030e4:	e8 8b fc ff ff       	call   80102d74 <inb>
801030e9:	0f b6 c0             	movzbl %al,%eax
}
801030ec:	c9                   	leave  
801030ed:	c3                   	ret    

801030ee <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030ee:	55                   	push   %ebp
801030ef:	89 e5                	mov    %esp,%ebp
801030f1:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030fb:	e8 b5 ff ff ff       	call   801030b5 <cmos_read>
80103100:	8b 55 08             	mov    0x8(%ebp),%edx
80103103:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103105:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010310c:	e8 a4 ff ff ff       	call   801030b5 <cmos_read>
80103111:	8b 55 08             	mov    0x8(%ebp),%edx
80103114:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103117:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010311e:	e8 92 ff ff ff       	call   801030b5 <cmos_read>
80103123:	8b 55 08             	mov    0x8(%ebp),%edx
80103126:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103129:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103130:	e8 80 ff ff ff       	call   801030b5 <cmos_read>
80103135:	8b 55 08             	mov    0x8(%ebp),%edx
80103138:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010313b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103142:	e8 6e ff ff ff       	call   801030b5 <cmos_read>
80103147:	8b 55 08             	mov    0x8(%ebp),%edx
8010314a:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010314d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103154:	e8 5c ff ff ff       	call   801030b5 <cmos_read>
80103159:	8b 55 08             	mov    0x8(%ebp),%edx
8010315c:	89 42 14             	mov    %eax,0x14(%edx)
}
8010315f:	c9                   	leave  
80103160:	c3                   	ret    

80103161 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103161:	55                   	push   %ebp
80103162:	89 e5                	mov    %esp,%ebp
80103164:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103167:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010316e:	e8 42 ff ff ff       	call   801030b5 <cmos_read>
80103173:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103176:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103179:	83 e0 04             	and    $0x4,%eax
8010317c:	85 c0                	test   %eax,%eax
8010317e:	0f 94 c0             	sete   %al
80103181:	0f b6 c0             	movzbl %al,%eax
80103184:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103187:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010318a:	89 04 24             	mov    %eax,(%esp)
8010318d:	e8 5c ff ff ff       	call   801030ee <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103192:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103199:	e8 17 ff ff ff       	call   801030b5 <cmos_read>
8010319e:	25 80 00 00 00       	and    $0x80,%eax
801031a3:	85 c0                	test   %eax,%eax
801031a5:	74 02                	je     801031a9 <cmostime+0x48>
        continue;
801031a7:	eb 36                	jmp    801031df <cmostime+0x7e>
    fill_rtcdate(&t2);
801031a9:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031ac:	89 04 24             	mov    %eax,(%esp)
801031af:	e8 3a ff ff ff       	call   801030ee <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031b4:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031bb:	00 
801031bc:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801031c3:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031c6:	89 04 24             	mov    %eax,(%esp)
801031c9:	e8 bf 22 00 00       	call   8010548d <memcmp>
801031ce:	85 c0                	test   %eax,%eax
801031d0:	75 0d                	jne    801031df <cmostime+0x7e>
      break;
801031d2:	90                   	nop
  }

  // convert
  if (bcd) {
801031d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031d7:	0f 84 ac 00 00 00    	je     80103289 <cmostime+0x128>
801031dd:	eb 02                	jmp    801031e1 <cmostime+0x80>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031df:	eb a6                	jmp    80103187 <cmostime+0x26>

  // convert
  if (bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031e4:	c1 e8 04             	shr    $0x4,%eax
801031e7:	89 c2                	mov    %eax,%edx
801031e9:	89 d0                	mov    %edx,%eax
801031eb:	c1 e0 02             	shl    $0x2,%eax
801031ee:	01 d0                	add    %edx,%eax
801031f0:	01 c0                	add    %eax,%eax
801031f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031f5:	83 e2 0f             	and    $0xf,%edx
801031f8:	01 d0                	add    %edx,%eax
801031fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103200:	c1 e8 04             	shr    $0x4,%eax
80103203:	89 c2                	mov    %eax,%edx
80103205:	89 d0                	mov    %edx,%eax
80103207:	c1 e0 02             	shl    $0x2,%eax
8010320a:	01 d0                	add    %edx,%eax
8010320c:	01 c0                	add    %eax,%eax
8010320e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103211:	83 e2 0f             	and    $0xf,%edx
80103214:	01 d0                	add    %edx,%eax
80103216:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103219:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010321c:	c1 e8 04             	shr    $0x4,%eax
8010321f:	89 c2                	mov    %eax,%edx
80103221:	89 d0                	mov    %edx,%eax
80103223:	c1 e0 02             	shl    $0x2,%eax
80103226:	01 d0                	add    %edx,%eax
80103228:	01 c0                	add    %eax,%eax
8010322a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010322d:	83 e2 0f             	and    $0xf,%edx
80103230:	01 d0                	add    %edx,%eax
80103232:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103235:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103238:	c1 e8 04             	shr    $0x4,%eax
8010323b:	89 c2                	mov    %eax,%edx
8010323d:	89 d0                	mov    %edx,%eax
8010323f:	c1 e0 02             	shl    $0x2,%eax
80103242:	01 d0                	add    %edx,%eax
80103244:	01 c0                	add    %eax,%eax
80103246:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103249:	83 e2 0f             	and    $0xf,%edx
8010324c:	01 d0                	add    %edx,%eax
8010324e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103251:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103254:	c1 e8 04             	shr    $0x4,%eax
80103257:	89 c2                	mov    %eax,%edx
80103259:	89 d0                	mov    %edx,%eax
8010325b:	c1 e0 02             	shl    $0x2,%eax
8010325e:	01 d0                	add    %edx,%eax
80103260:	01 c0                	add    %eax,%eax
80103262:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103265:	83 e2 0f             	and    $0xf,%edx
80103268:	01 d0                	add    %edx,%eax
8010326a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010326d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103270:	c1 e8 04             	shr    $0x4,%eax
80103273:	89 c2                	mov    %eax,%edx
80103275:	89 d0                	mov    %edx,%eax
80103277:	c1 e0 02             	shl    $0x2,%eax
8010327a:	01 d0                	add    %edx,%eax
8010327c:	01 c0                	add    %eax,%eax
8010327e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103281:	83 e2 0f             	and    $0xf,%edx
80103284:	01 d0                	add    %edx,%eax
80103286:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103289:	8b 45 08             	mov    0x8(%ebp),%eax
8010328c:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010328f:	89 10                	mov    %edx,(%eax)
80103291:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103294:	89 50 04             	mov    %edx,0x4(%eax)
80103297:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010329a:	89 50 08             	mov    %edx,0x8(%eax)
8010329d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032a0:	89 50 0c             	mov    %edx,0xc(%eax)
801032a3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032a6:	89 50 10             	mov    %edx,0x10(%eax)
801032a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032ac:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032af:	8b 45 08             	mov    0x8(%ebp),%eax
801032b2:	8b 40 14             	mov    0x14(%eax),%eax
801032b5:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032bb:	8b 45 08             	mov    0x8(%ebp),%eax
801032be:	89 50 14             	mov    %edx,0x14(%eax)
}
801032c1:	c9                   	leave  
801032c2:	c3                   	ret    
801032c3:	90                   	nop

801032c4 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801032c4:	55                   	push   %ebp
801032c5:	89 e5                	mov    %esp,%ebp
801032c7:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032ca:	c7 44 24 04 dc 8a 10 	movl   $0x80108adc,0x4(%esp)
801032d1:	80 
801032d2:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801032d9:	e8 c0 1e 00 00       	call   8010519e <initlock>
  readsb(dev, &sb);
801032de:	8d 45 dc             	lea    -0x24(%ebp),%eax
801032e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801032e5:	8b 45 08             	mov    0x8(%ebp),%eax
801032e8:	89 04 24             	mov    %eax,(%esp)
801032eb:	e8 20 e0 ff ff       	call   80101310 <readsb>
  log.start = sb.logstart;
801032f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f3:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
801032f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032fb:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = dev;
80103300:	8b 45 08             	mov    0x8(%ebp),%eax
80103303:	a3 a4 22 11 80       	mov    %eax,0x801122a4
  recover_from_log();
80103308:	e8 9a 01 00 00       	call   801034a7 <recover_from_log>
}
8010330d:	c9                   	leave  
8010330e:	c3                   	ret    

8010330f <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010330f:	55                   	push   %ebp
80103310:	89 e5                	mov    %esp,%ebp
80103312:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103315:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010331c:	e9 8c 00 00 00       	jmp    801033ad <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103321:	8b 15 94 22 11 80    	mov    0x80112294,%edx
80103327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332a:	01 d0                	add    %edx,%eax
8010332c:	83 c0 01             	add    $0x1,%eax
8010332f:	89 c2                	mov    %eax,%edx
80103331:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103336:	89 54 24 04          	mov    %edx,0x4(%esp)
8010333a:	89 04 24             	mov    %eax,(%esp)
8010333d:	e8 64 ce ff ff       	call   801001a6 <bread>
80103342:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103348:	83 c0 10             	add    $0x10,%eax
8010334b:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103352:	89 c2                	mov    %eax,%edx
80103354:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103359:	89 54 24 04          	mov    %edx,0x4(%esp)
8010335d:	89 04 24             	mov    %eax,(%esp)
80103360:	e8 41 ce ff ff       	call   801001a6 <bread>
80103365:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103368:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336b:	8d 50 18             	lea    0x18(%eax),%edx
8010336e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103371:	83 c0 18             	add    $0x18,%eax
80103374:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010337b:	00 
8010337c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103380:	89 04 24             	mov    %eax,(%esp)
80103383:	e8 5d 21 00 00       	call   801054e5 <memmove>
    bwrite(dbuf);  // write dst to disk
80103388:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010338b:	89 04 24             	mov    %eax,(%esp)
8010338e:	e8 4a ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103396:	89 04 24             	mov    %eax,(%esp)
80103399:	e8 79 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010339e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a1:	89 04 24             	mov    %eax,(%esp)
801033a4:	e8 6e ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033ad:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801033b2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033b5:	0f 8f 66 ff ff ff    	jg     80103321 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033bb:	c9                   	leave  
801033bc:	c3                   	ret    

801033bd <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033bd:	55                   	push   %ebp
801033be:	89 e5                	mov    %esp,%ebp
801033c0:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033c3:	a1 94 22 11 80       	mov    0x80112294,%eax
801033c8:	89 c2                	mov    %eax,%edx
801033ca:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801033d3:	89 04 24             	mov    %eax,(%esp)
801033d6:	e8 cb cd ff ff       	call   801001a6 <bread>
801033db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e1:	83 c0 18             	add    $0x18,%eax
801033e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ea:	8b 00                	mov    (%eax),%eax
801033ec:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
801033f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033f8:	eb 1b                	jmp    80103415 <read_head+0x58>
    log.lh.block[i] = lh->block[i];
801033fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103400:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103404:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103407:	83 c2 10             	add    $0x10,%edx
8010340a:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103411:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103415:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010341a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010341d:	7f db                	jg     801033fa <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010341f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103422:	89 04 24             	mov    %eax,(%esp)
80103425:	e8 ed cd ff ff       	call   80100217 <brelse>
}
8010342a:	c9                   	leave  
8010342b:	c3                   	ret    

8010342c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010342c:	55                   	push   %ebp
8010342d:	89 e5                	mov    %esp,%ebp
8010342f:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103432:	a1 94 22 11 80       	mov    0x80112294,%eax
80103437:	89 c2                	mov    %eax,%edx
80103439:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010343e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103442:	89 04 24             	mov    %eax,(%esp)
80103445:	e8 5c cd ff ff       	call   801001a6 <bread>
8010344a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010344d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103450:	83 c0 18             	add    $0x18,%eax
80103453:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103456:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
8010345c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345f:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103461:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103468:	eb 1b                	jmp    80103485 <write_head+0x59>
    hb->block[i] = log.lh.block[i];
8010346a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010346d:	83 c0 10             	add    $0x10,%eax
80103470:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
80103477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010347d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103481:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103485:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010348a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010348d:	7f db                	jg     8010346a <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010348f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103492:	89 04 24             	mov    %eax,(%esp)
80103495:	e8 43 cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010349a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349d:	89 04 24             	mov    %eax,(%esp)
801034a0:	e8 72 cd ff ff       	call   80100217 <brelse>
}
801034a5:	c9                   	leave  
801034a6:	c3                   	ret    

801034a7 <recover_from_log>:

static void
recover_from_log(void)
{
801034a7:	55                   	push   %ebp
801034a8:	89 e5                	mov    %esp,%ebp
801034aa:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034ad:	e8 0b ff ff ff       	call   801033bd <read_head>
  install_trans(); // if committed, copy from log to disk
801034b2:	e8 58 fe ff ff       	call   8010330f <install_trans>
  log.lh.n = 0;
801034b7:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
801034be:	00 00 00 
  write_head(); // clear the log
801034c1:	e8 66 ff ff ff       	call   8010342c <write_head>
}
801034c6:	c9                   	leave  
801034c7:	c3                   	ret    

801034c8 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034c8:	55                   	push   %ebp
801034c9:	89 e5                	mov    %esp,%ebp
801034cb:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034ce:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034d5:	e8 e5 1c 00 00       	call   801051bf <acquire>
  while(1){
    if(log.committing){
801034da:	a1 a0 22 11 80       	mov    0x801122a0,%eax
801034df:	85 c0                	test   %eax,%eax
801034e1:	74 16                	je     801034f9 <begin_op+0x31>
      sleep(&log, &log.lock);
801034e3:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
801034ea:	80 
801034eb:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034f2:	e8 fa 16 00 00       	call   80104bf1 <sleep>
801034f7:	eb 4f                	jmp    80103548 <begin_op+0x80>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034f9:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
801034ff:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103504:	8d 50 01             	lea    0x1(%eax),%edx
80103507:	89 d0                	mov    %edx,%eax
80103509:	c1 e0 02             	shl    $0x2,%eax
8010350c:	01 d0                	add    %edx,%eax
8010350e:	01 c0                	add    %eax,%eax
80103510:	01 c8                	add    %ecx,%eax
80103512:	83 f8 1e             	cmp    $0x1e,%eax
80103515:	7e 16                	jle    8010352d <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103517:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
8010351e:	80 
8010351f:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103526:	e8 c6 16 00 00       	call   80104bf1 <sleep>
8010352b:	eb 1b                	jmp    80103548 <begin_op+0x80>
    } else {
      log.outstanding += 1;
8010352d:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103532:	83 c0 01             	add    $0x1,%eax
80103535:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
8010353a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103541:	e8 db 1c 00 00       	call   80105221 <release>
      break;
80103546:	eb 02                	jmp    8010354a <begin_op+0x82>
    }
  }
80103548:	eb 90                	jmp    801034da <begin_op+0x12>
}
8010354a:	c9                   	leave  
8010354b:	c3                   	ret    

8010354c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010354c:	55                   	push   %ebp
8010354d:	89 e5                	mov    %esp,%ebp
8010354f:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103552:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103559:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103560:	e8 5a 1c 00 00       	call   801051bf <acquire>
  log.outstanding -= 1;
80103565:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010356a:	83 e8 01             	sub    $0x1,%eax
8010356d:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103572:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103577:	85 c0                	test   %eax,%eax
80103579:	74 0c                	je     80103587 <end_op+0x3b>
    panic("log.committing");
8010357b:	c7 04 24 e0 8a 10 80 	movl   $0x80108ae0,(%esp)
80103582:	e8 b3 cf ff ff       	call   8010053a <panic>
  if(log.outstanding == 0){
80103587:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010358c:	85 c0                	test   %eax,%eax
8010358e:	75 13                	jne    801035a3 <end_op+0x57>
    do_commit = 1;
80103590:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103597:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
8010359e:	00 00 00 
801035a1:	eb 0c                	jmp    801035af <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801035a3:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801035aa:	e8 1b 17 00 00       	call   80104cca <wakeup>
  }
  release(&log.lock);
801035af:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801035b6:	e8 66 1c 00 00       	call   80105221 <release>

  if(do_commit){
801035bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035bf:	74 33                	je     801035f4 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035c1:	e8 de 00 00 00       	call   801036a4 <commit>
    acquire(&log.lock);
801035c6:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801035cd:	e8 ed 1b 00 00       	call   801051bf <acquire>
    log.committing = 0;
801035d2:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
801035d9:	00 00 00 
    wakeup(&log);
801035dc:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801035e3:	e8 e2 16 00 00       	call   80104cca <wakeup>
    release(&log.lock);
801035e8:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801035ef:	e8 2d 1c 00 00       	call   80105221 <release>
  }
}
801035f4:	c9                   	leave  
801035f5:	c3                   	ret    

801035f6 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035f6:	55                   	push   %ebp
801035f7:	89 e5                	mov    %esp,%ebp
801035f9:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103603:	e9 8c 00 00 00       	jmp    80103694 <write_log+0x9e>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103608:	8b 15 94 22 11 80    	mov    0x80112294,%edx
8010360e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103611:	01 d0                	add    %edx,%eax
80103613:	83 c0 01             	add    $0x1,%eax
80103616:	89 c2                	mov    %eax,%edx
80103618:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010361d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103621:	89 04 24             	mov    %eax,(%esp)
80103624:	e8 7d cb ff ff       	call   801001a6 <bread>
80103629:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010362c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010362f:	83 c0 10             	add    $0x10,%eax
80103632:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103639:	89 c2                	mov    %eax,%edx
8010363b:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103640:	89 54 24 04          	mov    %edx,0x4(%esp)
80103644:	89 04 24             	mov    %eax,(%esp)
80103647:	e8 5a cb ff ff       	call   801001a6 <bread>
8010364c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010364f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103652:	8d 50 18             	lea    0x18(%eax),%edx
80103655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103658:	83 c0 18             	add    $0x18,%eax
8010365b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103662:	00 
80103663:	89 54 24 04          	mov    %edx,0x4(%esp)
80103667:	89 04 24             	mov    %eax,(%esp)
8010366a:	e8 76 1e 00 00       	call   801054e5 <memmove>
    bwrite(to);  // write the log
8010366f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103672:	89 04 24             	mov    %eax,(%esp)
80103675:	e8 63 cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
8010367a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010367d:	89 04 24             	mov    %eax,(%esp)
80103680:	e8 92 cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103685:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103688:	89 04 24             	mov    %eax,(%esp)
8010368b:	e8 87 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103690:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103694:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103699:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010369c:	0f 8f 66 ff ff ff    	jg     80103608 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801036a2:	c9                   	leave  
801036a3:	c3                   	ret    

801036a4 <commit>:

static void
commit()
{
801036a4:	55                   	push   %ebp
801036a5:	89 e5                	mov    %esp,%ebp
801036a7:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801036aa:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036af:	85 c0                	test   %eax,%eax
801036b1:	7e 1e                	jle    801036d1 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036b3:	e8 3e ff ff ff       	call   801035f6 <write_log>
    write_head();    // Write header to disk -- the real commit
801036b8:	e8 6f fd ff ff       	call   8010342c <write_head>
    install_trans(); // Now install writes to home locations
801036bd:	e8 4d fc ff ff       	call   8010330f <install_trans>
    log.lh.n = 0; 
801036c2:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
801036c9:	00 00 00 
    write_head();    // Erase the transaction from the log
801036cc:	e8 5b fd ff ff       	call   8010342c <write_head>
  }
}
801036d1:	c9                   	leave  
801036d2:	c3                   	ret    

801036d3 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036d3:	55                   	push   %ebp
801036d4:	89 e5                	mov    %esp,%ebp
801036d6:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036d9:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036de:	83 f8 1d             	cmp    $0x1d,%eax
801036e1:	7f 12                	jg     801036f5 <log_write+0x22>
801036e3:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036e8:	8b 15 98 22 11 80    	mov    0x80112298,%edx
801036ee:	83 ea 01             	sub    $0x1,%edx
801036f1:	39 d0                	cmp    %edx,%eax
801036f3:	7c 0c                	jl     80103701 <log_write+0x2e>
    panic("too big a transaction");
801036f5:	c7 04 24 ef 8a 10 80 	movl   $0x80108aef,(%esp)
801036fc:	e8 39 ce ff ff       	call   8010053a <panic>
  if (log.outstanding < 1)
80103701:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103706:	85 c0                	test   %eax,%eax
80103708:	7f 0c                	jg     80103716 <log_write+0x43>
    panic("log_write outside of trans");
8010370a:	c7 04 24 05 8b 10 80 	movl   $0x80108b05,(%esp)
80103711:	e8 24 ce ff ff       	call   8010053a <panic>

  acquire(&log.lock);
80103716:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010371d:	e8 9d 1a 00 00       	call   801051bf <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103722:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103729:	eb 1f                	jmp    8010374a <log_write+0x77>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010372b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010372e:	83 c0 10             	add    $0x10,%eax
80103731:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103738:	89 c2                	mov    %eax,%edx
8010373a:	8b 45 08             	mov    0x8(%ebp),%eax
8010373d:	8b 40 08             	mov    0x8(%eax),%eax
80103740:	39 c2                	cmp    %eax,%edx
80103742:	75 02                	jne    80103746 <log_write+0x73>
      break;
80103744:	eb 0e                	jmp    80103754 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103746:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010374a:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010374f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103752:	7f d7                	jg     8010372b <log_write+0x58>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103754:	8b 45 08             	mov    0x8(%ebp),%eax
80103757:	8b 40 08             	mov    0x8(%eax),%eax
8010375a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010375d:	83 c2 10             	add    $0x10,%edx
80103760:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
80103767:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010376c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010376f:	75 0d                	jne    8010377e <log_write+0xab>
    log.lh.n++;
80103771:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103776:	83 c0 01             	add    $0x1,%eax
80103779:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
8010377e:	8b 45 08             	mov    0x8(%ebp),%eax
80103781:	8b 00                	mov    (%eax),%eax
80103783:	83 c8 04             	or     $0x4,%eax
80103786:	89 c2                	mov    %eax,%edx
80103788:	8b 45 08             	mov    0x8(%ebp),%eax
8010378b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010378d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103794:	e8 88 1a 00 00       	call   80105221 <release>
}
80103799:	c9                   	leave  
8010379a:	c3                   	ret    
8010379b:	90                   	nop

8010379c <v2p>:
8010379c:	55                   	push   %ebp
8010379d:	89 e5                	mov    %esp,%ebp
8010379f:	8b 45 08             	mov    0x8(%ebp),%eax
801037a2:	05 00 00 00 80       	add    $0x80000000,%eax
801037a7:	5d                   	pop    %ebp
801037a8:	c3                   	ret    

801037a9 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801037a9:	55                   	push   %ebp
801037aa:	89 e5                	mov    %esp,%ebp
801037ac:	8b 45 08             	mov    0x8(%ebp),%eax
801037af:	05 00 00 00 80       	add    $0x80000000,%eax
801037b4:	5d                   	pop    %ebp
801037b5:	c3                   	ret    

801037b6 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037b6:	55                   	push   %ebp
801037b7:	89 e5                	mov    %esp,%ebp
801037b9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037bc:	8b 55 08             	mov    0x8(%ebp),%edx
801037bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801037c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037c5:	f0 87 02             	lock xchg %eax,(%edx)
801037c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037ce:	c9                   	leave  
801037cf:	c3                   	ret    

801037d0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037d0:	55                   	push   %ebp
801037d1:	89 e5                	mov    %esp,%ebp
801037d3:	83 e4 f0             	and    $0xfffffff0,%esp
801037d6:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037d9:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037e0:	80 
801037e1:	c7 04 24 3c 51 11 80 	movl   $0x8011513c,(%esp)
801037e8:	e8 88 f2 ff ff       	call   80102a75 <kinit1>
  kvmalloc();      // kernel page table
801037ed:	e8 bc 48 00 00       	call   801080ae <kvmalloc>
  mpinit();        // collect info about this machine
801037f2:	e8 43 04 00 00       	call   80103c3a <mpinit>
  lapicinit();
801037f7:	e8 e4 f5 ff ff       	call   80102de0 <lapicinit>
  seginit();       // set up segments
801037fc:	e8 40 42 00 00       	call   80107a41 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103801:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103807:	0f b6 00             	movzbl (%eax),%eax
8010380a:	0f b6 c0             	movzbl %al,%eax
8010380d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103811:	c7 04 24 20 8b 10 80 	movl   $0x80108b20,(%esp)
80103818:	e8 83 cb ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
8010381d:	e8 79 06 00 00       	call   80103e9b <picinit>
  ioapicinit();    // another interrupt controller
80103822:	e8 42 f1 ff ff       	call   80102969 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103827:	e8 84 d2 ff ff       	call   80100ab0 <consoleinit>
  uartinit();      // serial port
8010382c:	e8 5a 35 00 00       	call   80106d8b <uartinit>
  pinit();         // process table
80103831:	e8 74 0b 00 00       	call   801043aa <pinit>
  tvinit();        // trap vectors
80103836:	e8 ff 30 00 00       	call   8010693a <tvinit>
  binit();         // buffer cache
8010383b:	e8 f4 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103840:	e8 e3 d6 ff ff       	call   80100f28 <fileinit>
  ideinit();       // disk
80103845:	e8 4f ed ff ff       	call   80102599 <ideinit>
  if(!ismp)
8010384a:	a1 44 23 11 80       	mov    0x80112344,%eax
8010384f:	85 c0                	test   %eax,%eax
80103851:	75 05                	jne    80103858 <main+0x88>
    timerinit();   // uniprocessor timer
80103853:	e8 2a 30 00 00       	call   80106882 <timerinit>
  startothers();   // start other processors
80103858:	e8 7f 00 00 00       	call   801038dc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010385d:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103864:	8e 
80103865:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010386c:	e8 3c f2 ff ff       	call   80102aad <kinit2>
  userinit();      // first user process
80103871:	e8 4f 0c 00 00       	call   801044c5 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103876:	e8 1a 00 00 00       	call   80103895 <mpmain>

8010387b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010387b:	55                   	push   %ebp
8010387c:	89 e5                	mov    %esp,%ebp
8010387e:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103881:	e8 3f 48 00 00       	call   801080c5 <switchkvm>
  seginit();
80103886:	e8 b6 41 00 00       	call   80107a41 <seginit>
  lapicinit();
8010388b:	e8 50 f5 ff ff       	call   80102de0 <lapicinit>
  mpmain();
80103890:	e8 00 00 00 00       	call   80103895 <mpmain>

80103895 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103895:	55                   	push   %ebp
80103896:	89 e5                	mov    %esp,%ebp
80103898:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010389b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038a1:	0f b6 00             	movzbl (%eax),%eax
801038a4:	0f b6 c0             	movzbl %al,%eax
801038a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801038ab:	c7 04 24 37 8b 10 80 	movl   $0x80108b37,(%esp)
801038b2:	e8 e9 ca ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
801038b7:	e8 f2 31 00 00       	call   80106aae <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801038bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038c2:	05 a8 00 00 00       	add    $0xa8,%eax
801038c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038ce:	00 
801038cf:	89 04 24             	mov    %eax,(%esp)
801038d2:	e8 df fe ff ff       	call   801037b6 <xchg>
  scheduler();     // start running processes
801038d7:	e8 5a 11 00 00       	call   80104a36 <scheduler>

801038dc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038dc:	55                   	push   %ebp
801038dd:	89 e5                	mov    %esp,%ebp
801038df:	53                   	push   %ebx
801038e0:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038e3:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038ea:	e8 ba fe ff ff       	call   801037a9 <p2v>
801038ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038f2:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801038fb:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
80103902:	80 
80103903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103906:	89 04 24             	mov    %eax,(%esp)
80103909:	e8 d7 1b 00 00       	call   801054e5 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010390e:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
80103915:	e9 85 00 00 00       	jmp    8010399f <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
8010391a:	e8 1a f6 ff ff       	call   80102f39 <cpunum>
8010391f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103925:	05 60 23 11 80       	add    $0x80112360,%eax
8010392a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010392d:	75 02                	jne    80103931 <startothers+0x55>
      continue;
8010392f:	eb 67                	jmp    80103998 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103931:	e8 6d f2 ff ff       	call   80102ba3 <kalloc>
80103936:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103939:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010393c:	83 e8 04             	sub    $0x4,%eax
8010393f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103942:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103948:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010394a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394d:	83 e8 08             	sub    $0x8,%eax
80103950:	c7 00 7b 38 10 80    	movl   $0x8010387b,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103956:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103959:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010395c:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103963:	e8 34 fe ff ff       	call   8010379c <v2p>
80103968:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010396a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010396d:	89 04 24             	mov    %eax,(%esp)
80103970:	e8 27 fe ff ff       	call   8010379c <v2p>
80103975:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103978:	0f b6 12             	movzbl (%edx),%edx
8010397b:	0f b6 d2             	movzbl %dl,%edx
8010397e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103982:	89 14 24             	mov    %edx,(%esp)
80103985:	e8 31 f6 ff ff       	call   80102fbb <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010398a:	90                   	nop
8010398b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010398e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103994:	85 c0                	test   %eax,%eax
80103996:	74 f3                	je     8010398b <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103998:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010399f:	a1 40 29 11 80       	mov    0x80112940,%eax
801039a4:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039aa:	05 60 23 11 80       	add    $0x80112360,%eax
801039af:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039b2:	0f 87 62 ff ff ff    	ja     8010391a <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039b8:	83 c4 24             	add    $0x24,%esp
801039bb:	5b                   	pop    %ebx
801039bc:	5d                   	pop    %ebp
801039bd:	c3                   	ret    
801039be:	66 90                	xchg   %ax,%ax

801039c0 <p2v>:
801039c0:	55                   	push   %ebp
801039c1:	89 e5                	mov    %esp,%ebp
801039c3:	8b 45 08             	mov    0x8(%ebp),%eax
801039c6:	05 00 00 00 80       	add    $0x80000000,%eax
801039cb:	5d                   	pop    %ebp
801039cc:	c3                   	ret    

801039cd <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039cd:	55                   	push   %ebp
801039ce:	89 e5                	mov    %esp,%ebp
801039d0:	83 ec 14             	sub    $0x14,%esp
801039d3:	8b 45 08             	mov    0x8(%ebp),%eax
801039d6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039da:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801039de:	89 c2                	mov    %eax,%edx
801039e0:	ec                   	in     (%dx),%al
801039e1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039e4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801039e8:	c9                   	leave  
801039e9:	c3                   	ret    

801039ea <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039ea:	55                   	push   %ebp
801039eb:	89 e5                	mov    %esp,%ebp
801039ed:	83 ec 08             	sub    $0x8,%esp
801039f0:	8b 55 08             	mov    0x8(%ebp),%edx
801039f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801039f6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039fa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039fd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a01:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a05:	ee                   	out    %al,(%dx)
}
80103a06:	c9                   	leave  
80103a07:	c3                   	ret    

80103a08 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103a08:	55                   	push   %ebp
80103a09:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103a0b:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103a10:	89 c2                	mov    %eax,%edx
80103a12:	b8 60 23 11 80       	mov    $0x80112360,%eax
80103a17:	29 c2                	sub    %eax,%edx
80103a19:	89 d0                	mov    %edx,%eax
80103a1b:	c1 f8 02             	sar    $0x2,%eax
80103a1e:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a24:	5d                   	pop    %ebp
80103a25:	c3                   	ret    

80103a26 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a26:	55                   	push   %ebp
80103a27:	89 e5                	mov    %esp,%ebp
80103a29:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a2c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a3a:	eb 15                	jmp    80103a51 <sum+0x2b>
    sum += addr[i];
80103a3c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a42:	01 d0                	add    %edx,%eax
80103a44:	0f b6 00             	movzbl (%eax),%eax
80103a47:	0f b6 c0             	movzbl %al,%eax
80103a4a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a4d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a54:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a57:	7c e3                	jl     80103a3c <sum+0x16>
    sum += addr[i];
  return sum;
80103a59:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a5c:	c9                   	leave  
80103a5d:	c3                   	ret    

80103a5e <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a5e:	55                   	push   %ebp
80103a5f:	89 e5                	mov    %esp,%ebp
80103a61:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a64:	8b 45 08             	mov    0x8(%ebp),%eax
80103a67:	89 04 24             	mov    %eax,(%esp)
80103a6a:	e8 51 ff ff ff       	call   801039c0 <p2v>
80103a6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a72:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a78:	01 d0                	add    %edx,%eax
80103a7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a83:	eb 3f                	jmp    80103ac4 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a85:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a8c:	00 
80103a8d:	c7 44 24 04 48 8b 10 	movl   $0x80108b48,0x4(%esp)
80103a94:	80 
80103a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a98:	89 04 24             	mov    %eax,(%esp)
80103a9b:	e8 ed 19 00 00       	call   8010548d <memcmp>
80103aa0:	85 c0                	test   %eax,%eax
80103aa2:	75 1c                	jne    80103ac0 <mpsearch1+0x62>
80103aa4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103aab:	00 
80103aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaf:	89 04 24             	mov    %eax,(%esp)
80103ab2:	e8 6f ff ff ff       	call   80103a26 <sum>
80103ab7:	84 c0                	test   %al,%al
80103ab9:	75 05                	jne    80103ac0 <mpsearch1+0x62>
      return (struct mp*)p;
80103abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abe:	eb 11                	jmp    80103ad1 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ac0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103aca:	72 b9                	jb     80103a85 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ad1:	c9                   	leave  
80103ad2:	c3                   	ret    

80103ad3 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ad3:	55                   	push   %ebp
80103ad4:	89 e5                	mov    %esp,%ebp
80103ad6:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ad9:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae3:	83 c0 0f             	add    $0xf,%eax
80103ae6:	0f b6 00             	movzbl (%eax),%eax
80103ae9:	0f b6 c0             	movzbl %al,%eax
80103aec:	c1 e0 08             	shl    $0x8,%eax
80103aef:	89 c2                	mov    %eax,%edx
80103af1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af4:	83 c0 0e             	add    $0xe,%eax
80103af7:	0f b6 00             	movzbl (%eax),%eax
80103afa:	0f b6 c0             	movzbl %al,%eax
80103afd:	09 d0                	or     %edx,%eax
80103aff:	c1 e0 04             	shl    $0x4,%eax
80103b02:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b09:	74 21                	je     80103b2c <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b0b:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b12:	00 
80103b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b16:	89 04 24             	mov    %eax,(%esp)
80103b19:	e8 40 ff ff ff       	call   80103a5e <mpsearch1>
80103b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b21:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b25:	74 50                	je     80103b77 <mpsearch+0xa4>
      return mp;
80103b27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b2a:	eb 5f                	jmp    80103b8b <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2f:	83 c0 14             	add    $0x14,%eax
80103b32:	0f b6 00             	movzbl (%eax),%eax
80103b35:	0f b6 c0             	movzbl %al,%eax
80103b38:	c1 e0 08             	shl    $0x8,%eax
80103b3b:	89 c2                	mov    %eax,%edx
80103b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b40:	83 c0 13             	add    $0x13,%eax
80103b43:	0f b6 00             	movzbl (%eax),%eax
80103b46:	0f b6 c0             	movzbl %al,%eax
80103b49:	09 d0                	or     %edx,%eax
80103b4b:	c1 e0 0a             	shl    $0xa,%eax
80103b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b54:	2d 00 04 00 00       	sub    $0x400,%eax
80103b59:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b60:	00 
80103b61:	89 04 24             	mov    %eax,(%esp)
80103b64:	e8 f5 fe ff ff       	call   80103a5e <mpsearch1>
80103b69:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b70:	74 05                	je     80103b77 <mpsearch+0xa4>
      return mp;
80103b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b75:	eb 14                	jmp    80103b8b <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b77:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b7e:	00 
80103b7f:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b86:	e8 d3 fe ff ff       	call   80103a5e <mpsearch1>
}
80103b8b:	c9                   	leave  
80103b8c:	c3                   	ret    

80103b8d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b8d:	55                   	push   %ebp
80103b8e:	89 e5                	mov    %esp,%ebp
80103b90:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b93:	e8 3b ff ff ff       	call   80103ad3 <mpsearch>
80103b98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b9f:	74 0a                	je     80103bab <mpconfig+0x1e>
80103ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba4:	8b 40 04             	mov    0x4(%eax),%eax
80103ba7:	85 c0                	test   %eax,%eax
80103ba9:	75 0a                	jne    80103bb5 <mpconfig+0x28>
    return 0;
80103bab:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb0:	e9 83 00 00 00       	jmp    80103c38 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb8:	8b 40 04             	mov    0x4(%eax),%eax
80103bbb:	89 04 24             	mov    %eax,(%esp)
80103bbe:	e8 fd fd ff ff       	call   801039c0 <p2v>
80103bc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bc6:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bcd:	00 
80103bce:	c7 44 24 04 4d 8b 10 	movl   $0x80108b4d,0x4(%esp)
80103bd5:	80 
80103bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd9:	89 04 24             	mov    %eax,(%esp)
80103bdc:	e8 ac 18 00 00       	call   8010548d <memcmp>
80103be1:	85 c0                	test   %eax,%eax
80103be3:	74 07                	je     80103bec <mpconfig+0x5f>
    return 0;
80103be5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bea:	eb 4c                	jmp    80103c38 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bef:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bf3:	3c 01                	cmp    $0x1,%al
80103bf5:	74 12                	je     80103c09 <mpconfig+0x7c>
80103bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfa:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bfe:	3c 04                	cmp    $0x4,%al
80103c00:	74 07                	je     80103c09 <mpconfig+0x7c>
    return 0;
80103c02:	b8 00 00 00 00       	mov    $0x0,%eax
80103c07:	eb 2f                	jmp    80103c38 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c10:	0f b7 c0             	movzwl %ax,%eax
80103c13:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1a:	89 04 24             	mov    %eax,(%esp)
80103c1d:	e8 04 fe ff ff       	call   80103a26 <sum>
80103c22:	84 c0                	test   %al,%al
80103c24:	74 07                	je     80103c2d <mpconfig+0xa0>
    return 0;
80103c26:	b8 00 00 00 00       	mov    $0x0,%eax
80103c2b:	eb 0b                	jmp    80103c38 <mpconfig+0xab>
  *pmp = mp;
80103c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c30:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c33:	89 10                	mov    %edx,(%eax)
  return conf;
80103c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c38:	c9                   	leave  
80103c39:	c3                   	ret    

80103c3a <mpinit>:

void
mpinit(void)
{
80103c3a:	55                   	push   %ebp
80103c3b:	89 e5                	mov    %esp,%ebp
80103c3d:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c40:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103c47:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c4a:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c4d:	89 04 24             	mov    %eax,(%esp)
80103c50:	e8 38 ff ff ff       	call   80103b8d <mpconfig>
80103c55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c5c:	75 05                	jne    80103c63 <mpinit+0x29>
    return;
80103c5e:	e9 9c 01 00 00       	jmp    80103dff <mpinit+0x1c5>
  ismp = 1;
80103c63:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103c6a:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c70:	8b 40 24             	mov    0x24(%eax),%eax
80103c73:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7b:	83 c0 2c             	add    $0x2c,%eax
80103c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c84:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c88:	0f b7 d0             	movzwl %ax,%edx
80103c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8e:	01 d0                	add    %edx,%eax
80103c90:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c93:	e9 f4 00 00 00       	jmp    80103d8c <mpinit+0x152>
    switch(*p){
80103c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9b:	0f b6 00             	movzbl (%eax),%eax
80103c9e:	0f b6 c0             	movzbl %al,%eax
80103ca1:	83 f8 04             	cmp    $0x4,%eax
80103ca4:	0f 87 bf 00 00 00    	ja     80103d69 <mpinit+0x12f>
80103caa:	8b 04 85 90 8b 10 80 	mov    -0x7fef7470(,%eax,4),%eax
80103cb1:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103cb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cbc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cc0:	0f b6 d0             	movzbl %al,%edx
80103cc3:	a1 40 29 11 80       	mov    0x80112940,%eax
80103cc8:	39 c2                	cmp    %eax,%edx
80103cca:	74 2d                	je     80103cf9 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103ccc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ccf:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cd3:	0f b6 d0             	movzbl %al,%edx
80103cd6:	a1 40 29 11 80       	mov    0x80112940,%eax
80103cdb:	89 54 24 08          	mov    %edx,0x8(%esp)
80103cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ce3:	c7 04 24 52 8b 10 80 	movl   $0x80108b52,(%esp)
80103cea:	e8 b1 c6 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103cef:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103cf6:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cfc:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103d00:	0f b6 c0             	movzbl %al,%eax
80103d03:	83 e0 02             	and    $0x2,%eax
80103d06:	85 c0                	test   %eax,%eax
80103d08:	74 15                	je     80103d1f <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103d0a:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d0f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d15:	05 60 23 11 80       	add    $0x80112360,%eax
80103d1a:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103d1f:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103d25:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d2a:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103d30:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103d36:	88 02                	mov    %al,(%edx)
      ncpu++;
80103d38:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d3d:	83 c0 01             	add    $0x1,%eax
80103d40:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103d45:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d49:	eb 41                	jmp    80103d8c <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d54:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d58:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103d5d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d61:	eb 29                	jmp    80103d8c <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d63:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d67:	eb 23                	jmp    80103d8c <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6c:	0f b6 00             	movzbl (%eax),%eax
80103d6f:	0f b6 c0             	movzbl %al,%eax
80103d72:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d76:	c7 04 24 70 8b 10 80 	movl   $0x80108b70,(%esp)
80103d7d:	e8 1e c6 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103d82:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103d89:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d92:	0f 82 00 ff ff ff    	jb     80103c98 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d98:	a1 44 23 11 80       	mov    0x80112344,%eax
80103d9d:	85 c0                	test   %eax,%eax
80103d9f:	75 1d                	jne    80103dbe <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103da1:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103da8:	00 00 00 
    lapic = 0;
80103dab:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103db2:	00 00 00 
    ioapicid = 0;
80103db5:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103dbc:	eb 41                	jmp    80103dff <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103dbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc1:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dc5:	84 c0                	test   %al,%al
80103dc7:	74 36                	je     80103dff <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dc9:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103dd0:	00 
80103dd1:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103dd8:	e8 0d fc ff ff       	call   801039ea <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ddd:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103de4:	e8 e4 fb ff ff       	call   801039cd <inb>
80103de9:	83 c8 01             	or     $0x1,%eax
80103dec:	0f b6 c0             	movzbl %al,%eax
80103def:	89 44 24 04          	mov    %eax,0x4(%esp)
80103df3:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dfa:	e8 eb fb ff ff       	call   801039ea <outb>
  }
}
80103dff:	c9                   	leave  
80103e00:	c3                   	ret    
80103e01:	66 90                	xchg   %ax,%ax
80103e03:	90                   	nop

80103e04 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e04:	55                   	push   %ebp
80103e05:	89 e5                	mov    %esp,%ebp
80103e07:	83 ec 08             	sub    $0x8,%esp
80103e0a:	8b 55 08             	mov    0x8(%ebp),%edx
80103e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e10:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e14:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e17:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e1b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e1f:	ee                   	out    %al,(%dx)
}
80103e20:	c9                   	leave  
80103e21:	c3                   	ret    

80103e22 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e22:	55                   	push   %ebp
80103e23:	89 e5                	mov    %esp,%ebp
80103e25:	83 ec 0c             	sub    $0xc,%esp
80103e28:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e2f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e33:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103e39:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e3d:	0f b6 c0             	movzbl %al,%eax
80103e40:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e44:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e4b:	e8 b4 ff ff ff       	call   80103e04 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e50:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e54:	66 c1 e8 08          	shr    $0x8,%ax
80103e58:	0f b6 c0             	movzbl %al,%eax
80103e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e5f:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e66:	e8 99 ff ff ff       	call   80103e04 <outb>
}
80103e6b:	c9                   	leave  
80103e6c:	c3                   	ret    

80103e6d <picenable>:

void
picenable(int irq)
{
80103e6d:	55                   	push   %ebp
80103e6e:	89 e5                	mov    %esp,%ebp
80103e70:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e73:	8b 45 08             	mov    0x8(%ebp),%eax
80103e76:	ba 01 00 00 00       	mov    $0x1,%edx
80103e7b:	89 c1                	mov    %eax,%ecx
80103e7d:	d3 e2                	shl    %cl,%edx
80103e7f:	89 d0                	mov    %edx,%eax
80103e81:	f7 d0                	not    %eax
80103e83:	89 c2                	mov    %eax,%edx
80103e85:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e8c:	21 d0                	and    %edx,%eax
80103e8e:	0f b7 c0             	movzwl %ax,%eax
80103e91:	89 04 24             	mov    %eax,(%esp)
80103e94:	e8 89 ff ff ff       	call   80103e22 <picsetmask>
}
80103e99:	c9                   	leave  
80103e9a:	c3                   	ret    

80103e9b <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e9b:	55                   	push   %ebp
80103e9c:	89 e5                	mov    %esp,%ebp
80103e9e:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ea1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ea8:	00 
80103ea9:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eb0:	e8 4f ff ff ff       	call   80103e04 <outb>
  outb(IO_PIC2+1, 0xFF);
80103eb5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ebc:	00 
80103ebd:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ec4:	e8 3b ff ff ff       	call   80103e04 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103ec9:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ed0:	00 
80103ed1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ed8:	e8 27 ff ff ff       	call   80103e04 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103edd:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ee4:	00 
80103ee5:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eec:	e8 13 ff ff ff       	call   80103e04 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ef1:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ef8:	00 
80103ef9:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f00:	e8 ff fe ff ff       	call   80103e04 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f05:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f0c:	00 
80103f0d:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f14:	e8 eb fe ff ff       	call   80103e04 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f19:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103f20:	00 
80103f21:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f28:	e8 d7 fe ff ff       	call   80103e04 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f2d:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103f34:	00 
80103f35:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f3c:	e8 c3 fe ff ff       	call   80103e04 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f41:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f48:	00 
80103f49:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f50:	e8 af fe ff ff       	call   80103e04 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f55:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f5c:	00 
80103f5d:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f64:	e8 9b fe ff ff       	call   80103e04 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f69:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f70:	00 
80103f71:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f78:	e8 87 fe ff ff       	call   80103e04 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f7d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f84:	00 
80103f85:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f8c:	e8 73 fe ff ff       	call   80103e04 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f91:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f98:	00 
80103f99:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103fa0:	e8 5f fe ff ff       	call   80103e04 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103fa5:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103fac:	00 
80103fad:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103fb4:	e8 4b fe ff ff       	call   80103e04 <outb>

  if(irqmask != 0xFFFF)
80103fb9:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fc0:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fc4:	74 12                	je     80103fd8 <picinit+0x13d>
    picsetmask(irqmask);
80103fc6:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103fcd:	0f b7 c0             	movzwl %ax,%eax
80103fd0:	89 04 24             	mov    %eax,(%esp)
80103fd3:	e8 4a fe ff ff       	call   80103e22 <picsetmask>
}
80103fd8:	c9                   	leave  
80103fd9:	c3                   	ret    
80103fda:	66 90                	xchg   %ax,%ax

80103fdc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fdc:	55                   	push   %ebp
80103fdd:	89 e5                	mov    %esp,%ebp
80103fdf:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fe2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff5:	8b 10                	mov    (%eax),%edx
80103ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffa:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103ffc:	e8 43 cf ff ff       	call   80100f44 <filealloc>
80104001:	8b 55 08             	mov    0x8(%ebp),%edx
80104004:	89 02                	mov    %eax,(%edx)
80104006:	8b 45 08             	mov    0x8(%ebp),%eax
80104009:	8b 00                	mov    (%eax),%eax
8010400b:	85 c0                	test   %eax,%eax
8010400d:	0f 84 c8 00 00 00    	je     801040db <pipealloc+0xff>
80104013:	e8 2c cf ff ff       	call   80100f44 <filealloc>
80104018:	8b 55 0c             	mov    0xc(%ebp),%edx
8010401b:	89 02                	mov    %eax,(%edx)
8010401d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104020:	8b 00                	mov    (%eax),%eax
80104022:	85 c0                	test   %eax,%eax
80104024:	0f 84 b1 00 00 00    	je     801040db <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010402a:	e8 74 eb ff ff       	call   80102ba3 <kalloc>
8010402f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104032:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104036:	75 05                	jne    8010403d <pipealloc+0x61>
    goto bad;
80104038:	e9 9e 00 00 00       	jmp    801040db <pipealloc+0xff>
  p->readopen = 1;
8010403d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104040:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104047:	00 00 00 
  p->writeopen = 1;
8010404a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404d:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104054:	00 00 00 
  p->nwrite = 0;
80104057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405a:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104061:	00 00 00 
  p->nread = 0;
80104064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104067:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010406e:	00 00 00 
  initlock(&p->lock, "pipe");
80104071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104074:	c7 44 24 04 a4 8b 10 	movl   $0x80108ba4,0x4(%esp)
8010407b:	80 
8010407c:	89 04 24             	mov    %eax,(%esp)
8010407f:	e8 1a 11 00 00       	call   8010519e <initlock>
  (*f0)->type = FD_PIPE;
80104084:	8b 45 08             	mov    0x8(%ebp),%eax
80104087:	8b 00                	mov    (%eax),%eax
80104089:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010408f:	8b 45 08             	mov    0x8(%ebp),%eax
80104092:	8b 00                	mov    (%eax),%eax
80104094:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104098:	8b 45 08             	mov    0x8(%ebp),%eax
8010409b:	8b 00                	mov    (%eax),%eax
8010409d:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040a1:	8b 45 08             	mov    0x8(%ebp),%eax
801040a4:	8b 00                	mov    (%eax),%eax
801040a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040a9:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801040af:	8b 00                	mov    (%eax),%eax
801040b1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ba:	8b 00                	mov    (%eax),%eax
801040bc:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c3:	8b 00                	mov    (%eax),%eax
801040c5:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cc:	8b 00                	mov    (%eax),%eax
801040ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040d1:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040d4:	b8 00 00 00 00       	mov    $0x0,%eax
801040d9:	eb 42                	jmp    8010411d <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
801040db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040df:	74 0b                	je     801040ec <pipealloc+0x110>
    kfree((char*)p);
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	89 04 24             	mov    %eax,(%esp)
801040e7:	e8 1e ea ff ff       	call   80102b0a <kfree>
  if(*f0)
801040ec:	8b 45 08             	mov    0x8(%ebp),%eax
801040ef:	8b 00                	mov    (%eax),%eax
801040f1:	85 c0                	test   %eax,%eax
801040f3:	74 0d                	je     80104102 <pipealloc+0x126>
    fileclose(*f0);
801040f5:	8b 45 08             	mov    0x8(%ebp),%eax
801040f8:	8b 00                	mov    (%eax),%eax
801040fa:	89 04 24             	mov    %eax,(%esp)
801040fd:	e8 ea ce ff ff       	call   80100fec <fileclose>
  if(*f1)
80104102:	8b 45 0c             	mov    0xc(%ebp),%eax
80104105:	8b 00                	mov    (%eax),%eax
80104107:	85 c0                	test   %eax,%eax
80104109:	74 0d                	je     80104118 <pipealloc+0x13c>
    fileclose(*f1);
8010410b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410e:	8b 00                	mov    (%eax),%eax
80104110:	89 04 24             	mov    %eax,(%esp)
80104113:	e8 d4 ce ff ff       	call   80100fec <fileclose>
  return -1;
80104118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010411d:	c9                   	leave  
8010411e:	c3                   	ret    

8010411f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010411f:	55                   	push   %ebp
80104120:	89 e5                	mov    %esp,%ebp
80104122:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104125:	8b 45 08             	mov    0x8(%ebp),%eax
80104128:	89 04 24             	mov    %eax,(%esp)
8010412b:	e8 8f 10 00 00       	call   801051bf <acquire>
  if(writable){
80104130:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104134:	74 1f                	je     80104155 <pipeclose+0x36>
    p->writeopen = 0;
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104140:	00 00 00 
    wakeup(&p->nread);
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	05 34 02 00 00       	add    $0x234,%eax
8010414b:	89 04 24             	mov    %eax,(%esp)
8010414e:	e8 77 0b 00 00       	call   80104cca <wakeup>
80104153:	eb 1d                	jmp    80104172 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104155:	8b 45 08             	mov    0x8(%ebp),%eax
80104158:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010415f:	00 00 00 
    wakeup(&p->nwrite);
80104162:	8b 45 08             	mov    0x8(%ebp),%eax
80104165:	05 38 02 00 00       	add    $0x238,%eax
8010416a:	89 04 24             	mov    %eax,(%esp)
8010416d:	e8 58 0b 00 00       	call   80104cca <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104172:	8b 45 08             	mov    0x8(%ebp),%eax
80104175:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010417b:	85 c0                	test   %eax,%eax
8010417d:	75 25                	jne    801041a4 <pipeclose+0x85>
8010417f:	8b 45 08             	mov    0x8(%ebp),%eax
80104182:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104188:	85 c0                	test   %eax,%eax
8010418a:	75 18                	jne    801041a4 <pipeclose+0x85>
    release(&p->lock);
8010418c:	8b 45 08             	mov    0x8(%ebp),%eax
8010418f:	89 04 24             	mov    %eax,(%esp)
80104192:	e8 8a 10 00 00       	call   80105221 <release>
    kfree((char*)p);
80104197:	8b 45 08             	mov    0x8(%ebp),%eax
8010419a:	89 04 24             	mov    %eax,(%esp)
8010419d:	e8 68 e9 ff ff       	call   80102b0a <kfree>
801041a2:	eb 0b                	jmp    801041af <pipeclose+0x90>
  } else
    release(&p->lock);
801041a4:	8b 45 08             	mov    0x8(%ebp),%eax
801041a7:	89 04 24             	mov    %eax,(%esp)
801041aa:	e8 72 10 00 00       	call   80105221 <release>
}
801041af:	c9                   	leave  
801041b0:	c3                   	ret    

801041b1 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041b1:	55                   	push   %ebp
801041b2:	89 e5                	mov    %esp,%ebp
801041b4:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801041b7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ba:	89 04 24             	mov    %eax,(%esp)
801041bd:	e8 fd 0f 00 00       	call   801051bf <acquire>
  for(i = 0; i < n; i++){
801041c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041c9:	e9 a6 00 00 00       	jmp    80104274 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ce:	eb 57                	jmp    80104227 <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
801041d0:	8b 45 08             	mov    0x8(%ebp),%eax
801041d3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041d9:	85 c0                	test   %eax,%eax
801041db:	74 0d                	je     801041ea <pipewrite+0x39>
801041dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041e3:	8b 40 24             	mov    0x24(%eax),%eax
801041e6:	85 c0                	test   %eax,%eax
801041e8:	74 15                	je     801041ff <pipewrite+0x4e>
        release(&p->lock);
801041ea:	8b 45 08             	mov    0x8(%ebp),%eax
801041ed:	89 04 24             	mov    %eax,(%esp)
801041f0:	e8 2c 10 00 00       	call   80105221 <release>
        return -1;
801041f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041fa:	e9 9f 00 00 00       	jmp    8010429e <pipewrite+0xed>
      }
      wakeup(&p->nread);
801041ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104202:	05 34 02 00 00       	add    $0x234,%eax
80104207:	89 04 24             	mov    %eax,(%esp)
8010420a:	e8 bb 0a 00 00       	call   80104cca <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010420f:	8b 45 08             	mov    0x8(%ebp),%eax
80104212:	8b 55 08             	mov    0x8(%ebp),%edx
80104215:	81 c2 38 02 00 00    	add    $0x238,%edx
8010421b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010421f:	89 14 24             	mov    %edx,(%esp)
80104222:	e8 ca 09 00 00       	call   80104bf1 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104227:	8b 45 08             	mov    0x8(%ebp),%eax
8010422a:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104230:	8b 45 08             	mov    0x8(%ebp),%eax
80104233:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104239:	05 00 02 00 00       	add    $0x200,%eax
8010423e:	39 c2                	cmp    %eax,%edx
80104240:	74 8e                	je     801041d0 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104242:	8b 45 08             	mov    0x8(%ebp),%eax
80104245:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010424b:	8d 48 01             	lea    0x1(%eax),%ecx
8010424e:	8b 55 08             	mov    0x8(%ebp),%edx
80104251:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104257:	25 ff 01 00 00       	and    $0x1ff,%eax
8010425c:	89 c1                	mov    %eax,%ecx
8010425e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104261:	8b 45 0c             	mov    0xc(%ebp),%eax
80104264:	01 d0                	add    %edx,%eax
80104266:	0f b6 10             	movzbl (%eax),%edx
80104269:	8b 45 08             	mov    0x8(%ebp),%eax
8010426c:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104270:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104277:	3b 45 10             	cmp    0x10(%ebp),%eax
8010427a:	0f 8c 4e ff ff ff    	jl     801041ce <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104280:	8b 45 08             	mov    0x8(%ebp),%eax
80104283:	05 34 02 00 00       	add    $0x234,%eax
80104288:	89 04 24             	mov    %eax,(%esp)
8010428b:	e8 3a 0a 00 00       	call   80104cca <wakeup>
  release(&p->lock);
80104290:	8b 45 08             	mov    0x8(%ebp),%eax
80104293:	89 04 24             	mov    %eax,(%esp)
80104296:	e8 86 0f 00 00       	call   80105221 <release>
  return n;
8010429b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010429e:	c9                   	leave  
8010429f:	c3                   	ret    

801042a0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042a0:	55                   	push   %ebp
801042a1:	89 e5                	mov    %esp,%ebp
801042a3:	53                   	push   %ebx
801042a4:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	89 04 24             	mov    %eax,(%esp)
801042ad:	e8 0d 0f 00 00       	call   801051bf <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042b2:	eb 3a                	jmp    801042ee <piperead+0x4e>
    if(proc->killed){
801042b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ba:	8b 40 24             	mov    0x24(%eax),%eax
801042bd:	85 c0                	test   %eax,%eax
801042bf:	74 15                	je     801042d6 <piperead+0x36>
      release(&p->lock);
801042c1:	8b 45 08             	mov    0x8(%ebp),%eax
801042c4:	89 04 24             	mov    %eax,(%esp)
801042c7:	e8 55 0f 00 00       	call   80105221 <release>
      return -1;
801042cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042d1:	e9 b5 00 00 00       	jmp    8010438b <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042d6:	8b 45 08             	mov    0x8(%ebp),%eax
801042d9:	8b 55 08             	mov    0x8(%ebp),%edx
801042dc:	81 c2 34 02 00 00    	add    $0x234,%edx
801042e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801042e6:	89 14 24             	mov    %edx,(%esp)
801042e9:	e8 03 09 00 00       	call   80104bf1 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042ee:	8b 45 08             	mov    0x8(%ebp),%eax
801042f1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042f7:	8b 45 08             	mov    0x8(%ebp),%eax
801042fa:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104300:	39 c2                	cmp    %eax,%edx
80104302:	75 0d                	jne    80104311 <piperead+0x71>
80104304:	8b 45 08             	mov    0x8(%ebp),%eax
80104307:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010430d:	85 c0                	test   %eax,%eax
8010430f:	75 a3                	jne    801042b4 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104311:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104318:	eb 4b                	jmp    80104365 <piperead+0xc5>
    if(p->nread == p->nwrite)
8010431a:	8b 45 08             	mov    0x8(%ebp),%eax
8010431d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010432c:	39 c2                	cmp    %eax,%edx
8010432e:	75 02                	jne    80104332 <piperead+0x92>
      break;
80104330:	eb 3b                	jmp    8010436d <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104332:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104335:	8b 45 0c             	mov    0xc(%ebp),%eax
80104338:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010433b:	8b 45 08             	mov    0x8(%ebp),%eax
8010433e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104344:	8d 48 01             	lea    0x1(%eax),%ecx
80104347:	8b 55 08             	mov    0x8(%ebp),%edx
8010434a:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104350:	25 ff 01 00 00       	and    $0x1ff,%eax
80104355:	89 c2                	mov    %eax,%edx
80104357:	8b 45 08             	mov    0x8(%ebp),%eax
8010435a:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
8010435f:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104361:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104368:	3b 45 10             	cmp    0x10(%ebp),%eax
8010436b:	7c ad                	jl     8010431a <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010436d:	8b 45 08             	mov    0x8(%ebp),%eax
80104370:	05 38 02 00 00       	add    $0x238,%eax
80104375:	89 04 24             	mov    %eax,(%esp)
80104378:	e8 4d 09 00 00       	call   80104cca <wakeup>
  release(&p->lock);
8010437d:	8b 45 08             	mov    0x8(%ebp),%eax
80104380:	89 04 24             	mov    %eax,(%esp)
80104383:	e8 99 0e 00 00       	call   80105221 <release>
  return i;
80104388:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010438b:	83 c4 24             	add    $0x24,%esp
8010438e:	5b                   	pop    %ebx
8010438f:	5d                   	pop    %ebp
80104390:	c3                   	ret    
80104391:	66 90                	xchg   %ax,%ax
80104393:	90                   	nop

80104394 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104394:	55                   	push   %ebp
80104395:	89 e5                	mov    %esp,%ebp
80104397:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010439a:	9c                   	pushf  
8010439b:	58                   	pop    %eax
8010439c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010439f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043a2:	c9                   	leave  
801043a3:	c3                   	ret    

801043a4 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043a4:	55                   	push   %ebp
801043a5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043a7:	fb                   	sti    
}
801043a8:	5d                   	pop    %ebp
801043a9:	c3                   	ret    

801043aa <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043aa:	55                   	push   %ebp
801043ab:	89 e5                	mov    %esp,%ebp
801043ad:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801043b0:	c7 44 24 04 a9 8b 10 	movl   $0x80108ba9,0x4(%esp)
801043b7:	80 
801043b8:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801043bf:	e8 da 0d 00 00       	call   8010519e <initlock>
}
801043c4:	c9                   	leave  
801043c5:	c3                   	ret    

801043c6 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043c6:	55                   	push   %ebp
801043c7:	89 e5                	mov    %esp,%ebp
801043c9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043cc:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801043d3:	e8 e7 0d 00 00       	call   801051bf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043d8:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801043df:	eb 50                	jmp    80104431 <allocproc+0x6b>
    if(p->state == UNUSED)
801043e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e4:	8b 40 0c             	mov    0xc(%eax),%eax
801043e7:	85 c0                	test   %eax,%eax
801043e9:	75 42                	jne    8010442d <allocproc+0x67>
      goto found;
801043eb:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ef:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043f6:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043fb:	8d 50 01             	lea    0x1(%eax),%edx
801043fe:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104404:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104407:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010440a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104411:	e8 0b 0e 00 00       	call   80105221 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104416:	e8 88 e7 ff ff       	call   80102ba3 <kalloc>
8010441b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010441e:	89 42 08             	mov    %eax,0x8(%edx)
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	8b 40 08             	mov    0x8(%eax),%eax
80104427:	85 c0                	test   %eax,%eax
80104429:	75 33                	jne    8010445e <allocproc+0x98>
8010442b:	eb 20                	jmp    8010444d <allocproc+0x87>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010442d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104431:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104438:	72 a7                	jb     801043e1 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010443a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104441:	e8 db 0d 00 00       	call   80105221 <release>
  return 0;
80104446:	b8 00 00 00 00       	mov    $0x0,%eax
8010444b:	eb 76                	jmp    801044c3 <allocproc+0xfd>
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010444d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104450:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104457:	b8 00 00 00 00       	mov    $0x0,%eax
8010445c:	eb 65                	jmp    801044c3 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
8010445e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104461:	8b 40 08             	mov    0x8(%eax),%eax
80104464:	05 00 10 00 00       	add    $0x1000,%eax
80104469:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010446c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104473:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104476:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104479:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010447d:	ba f4 68 10 80       	mov    $0x801068f4,%edx
80104482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104485:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104487:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104491:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104497:	8b 40 1c             	mov    0x1c(%eax),%eax
8010449a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801044a1:	00 
801044a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044a9:	00 
801044aa:	89 04 24             	mov    %eax,(%esp)
801044ad:	e8 64 0f 00 00       	call   80105416 <memset>
  p->context->eip = (uint)forkret;
801044b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b5:	8b 40 1c             	mov    0x1c(%eax),%eax
801044b8:	ba b2 4b 10 80       	mov    $0x80104bb2,%edx
801044bd:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044c3:	c9                   	leave  
801044c4:	c3                   	ret    

801044c5 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044c5:	55                   	push   %ebp
801044c6:	89 e5                	mov    %esp,%ebp
801044c8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044cb:	e8 f6 fe ff ff       	call   801043c6 <allocproc>
801044d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801044db:	e8 11 3b 00 00       	call   80107ff1 <setupkvm>
801044e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e3:	89 42 04             	mov    %eax,0x4(%edx)
801044e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e9:	8b 40 04             	mov    0x4(%eax),%eax
801044ec:	85 c0                	test   %eax,%eax
801044ee:	75 0c                	jne    801044fc <userinit+0x37>
    panic("userinit: out of memory?");
801044f0:	c7 04 24 b0 8b 10 80 	movl   $0x80108bb0,(%esp)
801044f7:	e8 3e c0 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044fc:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 04             	mov    0x4(%eax),%eax
80104507:	89 54 24 08          	mov    %edx,0x8(%esp)
8010450b:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104512:	80 
80104513:	89 04 24             	mov    %eax,(%esp)
80104516:	e8 2e 3d 00 00       	call   80108249 <inituvm>
  p->sz = PGSIZE;
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	8b 40 18             	mov    0x18(%eax),%eax
8010452a:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104531:	00 
80104532:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104539:	00 
8010453a:	89 04 24             	mov    %eax,(%esp)
8010453d:	e8 d4 0e 00 00       	call   80105416 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 40 18             	mov    0x18(%eax),%eax
80104548:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	8b 40 18             	mov    0x18(%eax),%eax
80104554:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010455a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455d:	8b 40 18             	mov    0x18(%eax),%eax
80104560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104563:	8b 52 18             	mov    0x18(%edx),%edx
80104566:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010456a:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010456e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104571:	8b 40 18             	mov    0x18(%eax),%eax
80104574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104577:	8b 52 18             	mov    0x18(%edx),%edx
8010457a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010457e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	8b 40 18             	mov    0x18(%eax),%eax
80104588:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010458f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104592:	8b 40 18             	mov    0x18(%eax),%eax
80104595:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459f:	8b 40 18             	mov    0x18(%eax),%eax
801045a2:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ac:	83 c0 6c             	add    $0x6c,%eax
801045af:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045b6:	00 
801045b7:	c7 44 24 04 c9 8b 10 	movl   $0x80108bc9,0x4(%esp)
801045be:	80 
801045bf:	89 04 24             	mov    %eax,(%esp)
801045c2:	e8 6f 10 00 00       	call   80105636 <safestrcpy>
  p->cwd = namei("/");
801045c7:	c7 04 24 d2 8b 10 80 	movl   $0x80108bd2,(%esp)
801045ce:	e8 b6 de ff ff       	call   80102489 <namei>
801045d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d6:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045e3:	c9                   	leave  
801045e4:	c3                   	ret    

801045e5 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045e5:	55                   	push   %ebp
801045e6:	89 e5                	mov    %esp,%ebp
801045e8:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f1:	8b 00                	mov    (%eax),%eax
801045f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045f6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045fa:	7e 34                	jle    80104630 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045fc:	8b 55 08             	mov    0x8(%ebp),%edx
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	01 c2                	add    %eax,%edx
80104604:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010460a:	8b 40 04             	mov    0x4(%eax),%eax
8010460d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104614:	89 54 24 04          	mov    %edx,0x4(%esp)
80104618:	89 04 24             	mov    %eax,(%esp)
8010461b:	e8 9f 3d 00 00       	call   801083bf <allocuvm>
80104620:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104623:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104627:	75 41                	jne    8010466a <growproc+0x85>
      return -1;
80104629:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462e:	eb 58                	jmp    80104688 <growproc+0xa3>
  } else if(n < 0){
80104630:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104634:	79 34                	jns    8010466a <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104636:	8b 55 08             	mov    0x8(%ebp),%edx
80104639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463c:	01 c2                	add    %eax,%edx
8010463e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104644:	8b 40 04             	mov    0x4(%eax),%eax
80104647:	89 54 24 08          	mov    %edx,0x8(%esp)
8010464b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104652:	89 04 24             	mov    %eax,(%esp)
80104655:	e8 3f 3e 00 00       	call   80108499 <deallocuvm>
8010465a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010465d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104661:	75 07                	jne    8010466a <growproc+0x85>
      return -1;
80104663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104668:	eb 1e                	jmp    80104688 <growproc+0xa3>
  }
  proc->sz = sz;
8010466a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104670:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104673:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104675:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010467b:	89 04 24             	mov    %eax,(%esp)
8010467e:	e8 5f 3a 00 00       	call   801080e2 <switchuvm>
  return 0;
80104683:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104688:	c9                   	leave  
80104689:	c3                   	ret    

8010468a <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010468a:	55                   	push   %ebp
8010468b:	89 e5                	mov    %esp,%ebp
8010468d:	57                   	push   %edi
8010468e:	56                   	push   %esi
8010468f:	53                   	push   %ebx
80104690:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104693:	e8 2e fd ff ff       	call   801043c6 <allocproc>
80104698:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010469b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010469f:	75 0a                	jne    801046ab <fork+0x21>
    return -1;
801046a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046a6:	e9 52 01 00 00       	jmp    801047fd <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801046ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b1:	8b 10                	mov    (%eax),%edx
801046b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b9:	8b 40 04             	mov    0x4(%eax),%eax
801046bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801046c0:	89 04 24             	mov    %eax,(%esp)
801046c3:	e8 6d 3f 00 00       	call   80108635 <copyuvm>
801046c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046cb:	89 42 04             	mov    %eax,0x4(%edx)
801046ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d1:	8b 40 04             	mov    0x4(%eax),%eax
801046d4:	85 c0                	test   %eax,%eax
801046d6:	75 2c                	jne    80104704 <fork+0x7a>
    kfree(np->kstack);
801046d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046db:	8b 40 08             	mov    0x8(%eax),%eax
801046de:	89 04 24             	mov    %eax,(%esp)
801046e1:	e8 24 e4 ff ff       	call   80102b0a <kfree>
    np->kstack = 0;
801046e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ff:	e9 f9 00 00 00       	jmp    801047fd <fork+0x173>
  }
  np->sz = proc->sz;
80104704:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470a:	8b 10                	mov    (%eax),%edx
8010470c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010470f:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104711:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104718:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471b:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010471e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104721:	8b 50 18             	mov    0x18(%eax),%edx
80104724:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472a:	8b 40 18             	mov    0x18(%eax),%eax
8010472d:	89 c3                	mov    %eax,%ebx
8010472f:	b8 13 00 00 00       	mov    $0x13,%eax
80104734:	89 d7                	mov    %edx,%edi
80104736:	89 de                	mov    %ebx,%esi
80104738:	89 c1                	mov    %eax,%ecx
8010473a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010473c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473f:	8b 40 18             	mov    0x18(%eax),%eax
80104742:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104749:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104750:	eb 3d                	jmp    8010478f <fork+0x105>
    if(proc->ofile[i])
80104752:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104758:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010475b:	83 c2 08             	add    $0x8,%edx
8010475e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104762:	85 c0                	test   %eax,%eax
80104764:	74 25                	je     8010478b <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104766:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010476f:	83 c2 08             	add    $0x8,%edx
80104772:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104776:	89 04 24             	mov    %eax,(%esp)
80104779:	e8 26 c8 ff ff       	call   80100fa4 <filedup>
8010477e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104781:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104784:	83 c1 08             	add    $0x8,%ecx
80104787:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010478b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010478f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104793:	7e bd                	jle    80104752 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104795:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479b:	8b 40 68             	mov    0x68(%eax),%eax
8010479e:	89 04 24             	mov    %eax,(%esp)
801047a1:	e8 00 d1 ff ff       	call   801018a6 <idup>
801047a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047a9:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801047ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b2:	8d 50 6c             	lea    0x6c(%eax),%edx
801047b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b8:	83 c0 6c             	add    $0x6c,%eax
801047bb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047c2:	00 
801047c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801047c7:	89 04 24             	mov    %eax,(%esp)
801047ca:	e8 67 0e 00 00       	call   80105636 <safestrcpy>
 
  pid = np->pid;
801047cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d2:	8b 40 10             	mov    0x10(%eax),%eax
801047d5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801047d8:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047df:	e8 db 09 00 00       	call   801051bf <acquire>
  np->state = RUNNABLE;
801047e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047ee:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047f5:	e8 27 0a 00 00       	call   80105221 <release>
  
  return pid;
801047fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047fd:	83 c4 2c             	add    $0x2c,%esp
80104800:	5b                   	pop    %ebx
80104801:	5e                   	pop    %esi
80104802:	5f                   	pop    %edi
80104803:	5d                   	pop    %ebp
80104804:	c3                   	ret    

80104805 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104805:	55                   	push   %ebp
80104806:	89 e5                	mov    %esp,%ebp
80104808:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010480b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104812:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104817:	39 c2                	cmp    %eax,%edx
80104819:	75 0c                	jne    80104827 <exit+0x22>
    panic("init exiting");
8010481b:	c7 04 24 d4 8b 10 80 	movl   $0x80108bd4,(%esp)
80104822:	e8 13 bd ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104827:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010482e:	eb 44                	jmp    80104874 <exit+0x6f>
    if(proc->ofile[fd]){
80104830:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104836:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104839:	83 c2 08             	add    $0x8,%edx
8010483c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104840:	85 c0                	test   %eax,%eax
80104842:	74 2c                	je     80104870 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104844:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010484d:	83 c2 08             	add    $0x8,%edx
80104850:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104854:	89 04 24             	mov    %eax,(%esp)
80104857:	e8 90 c7 ff ff       	call   80100fec <fileclose>
      proc->ofile[fd] = 0;
8010485c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104862:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104865:	83 c2 08             	add    $0x8,%edx
80104868:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010486f:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104870:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104874:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104878:	7e b6                	jle    80104830 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010487a:	e8 49 ec ff ff       	call   801034c8 <begin_op>
  iput(proc->cwd);
8010487f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104885:	8b 40 68             	mov    0x68(%eax),%eax
80104888:	89 04 24             	mov    %eax,(%esp)
8010488b:	e8 01 d2 ff ff       	call   80101a91 <iput>
  end_op();
80104890:	e8 b7 ec ff ff       	call   8010354c <end_op>
  proc->cwd = 0;
80104895:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489b:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801048a2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801048a9:	e8 11 09 00 00       	call   801051bf <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801048ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b4:	8b 40 14             	mov    0x14(%eax),%eax
801048b7:	89 04 24             	mov    %eax,(%esp)
801048ba:	e8 cd 03 00 00       	call   80104c8c <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048bf:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801048c6:	eb 38                	jmp    80104900 <exit+0xfb>
    if(p->parent == proc){
801048c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048cb:	8b 50 14             	mov    0x14(%eax),%edx
801048ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d4:	39 c2                	cmp    %eax,%edx
801048d6:	75 24                	jne    801048fc <exit+0xf7>
      p->parent = initproc;
801048d8:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e1:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e7:	8b 40 0c             	mov    0xc(%eax),%eax
801048ea:	83 f8 05             	cmp    $0x5,%eax
801048ed:	75 0d                	jne    801048fc <exit+0xf7>
        wakeup1(initproc);
801048ef:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048f4:	89 04 24             	mov    %eax,(%esp)
801048f7:	e8 90 03 00 00       	call   80104c8c <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048fc:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104900:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104907:	72 bf                	jb     801048c8 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104909:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104916:	e8 b3 01 00 00       	call   80104ace <sched>
  panic("zombie exit");
8010491b:	c7 04 24 e1 8b 10 80 	movl   $0x80108be1,(%esp)
80104922:	e8 13 bc ff ff       	call   8010053a <panic>

80104927 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104927:	55                   	push   %ebp
80104928:	89 e5                	mov    %esp,%ebp
8010492a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010492d:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104934:	e8 86 08 00 00       	call   801051bf <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104939:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104940:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104947:	e9 9a 00 00 00       	jmp    801049e6 <wait+0xbf>
      if(p->parent != proc)
8010494c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494f:	8b 50 14             	mov    0x14(%eax),%edx
80104952:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104958:	39 c2                	cmp    %eax,%edx
8010495a:	74 05                	je     80104961 <wait+0x3a>
        continue;
8010495c:	e9 81 00 00 00       	jmp    801049e2 <wait+0xbb>
      havekids = 1;
80104961:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496b:	8b 40 0c             	mov    0xc(%eax),%eax
8010496e:	83 f8 05             	cmp    $0x5,%eax
80104971:	75 6f                	jne    801049e2 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104976:	8b 40 10             	mov    0x10(%eax),%eax
80104979:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010497c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497f:	8b 40 08             	mov    0x8(%eax),%eax
80104982:	89 04 24             	mov    %eax,(%esp)
80104985:	e8 80 e1 ff ff       	call   80102b0a <kfree>
        p->kstack = 0;
8010498a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104997:	8b 40 04             	mov    0x4(%eax),%eax
8010499a:	89 04 24             	mov    %eax,(%esp)
8010499d:	e8 b3 3b 00 00       	call   80108555 <freevm>
        p->state = UNUSED;
801049a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049af:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c3:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ca:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049d1:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049d8:	e8 44 08 00 00       	call   80105221 <release>
        return pid;
801049dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049e0:	eb 52                	jmp    80104a34 <wait+0x10d>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e2:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049e6:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
801049ed:	0f 82 59 ff ff ff    	jb     8010494c <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049f7:	74 0d                	je     80104a06 <wait+0xdf>
801049f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ff:	8b 40 24             	mov    0x24(%eax),%eax
80104a02:	85 c0                	test   %eax,%eax
80104a04:	74 13                	je     80104a19 <wait+0xf2>
      release(&ptable.lock);
80104a06:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a0d:	e8 0f 08 00 00       	call   80105221 <release>
      return -1;
80104a12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a17:	eb 1b                	jmp    80104a34 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1f:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
80104a26:	80 
80104a27:	89 04 24             	mov    %eax,(%esp)
80104a2a:	e8 c2 01 00 00       	call   80104bf1 <sleep>
  }
80104a2f:	e9 05 ff ff ff       	jmp    80104939 <wait+0x12>
}
80104a34:	c9                   	leave  
80104a35:	c3                   	ret    

80104a36 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a36:	55                   	push   %ebp
80104a37:	89 e5                	mov    %esp,%ebp
80104a39:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a3c:	e8 63 f9 ff ff       	call   801043a4 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a41:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a48:	e8 72 07 00 00       	call   801051bf <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a4d:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a54:	eb 5e                	jmp    80104ab4 <scheduler+0x7e>
      if(p->state != RUNNABLE)
80104a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a59:	8b 40 0c             	mov    0xc(%eax),%eax
80104a5c:	83 f8 03             	cmp    $0x3,%eax
80104a5f:	74 02                	je     80104a63 <scheduler+0x2d>
        continue;
80104a61:	eb 4d                	jmp    80104ab0 <scheduler+0x7a>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a66:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6f:	89 04 24             	mov    %eax,(%esp)
80104a72:	e8 6b 36 00 00       	call   801080e2 <switchuvm>
      p->state = RUNNING;
80104a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7a:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a87:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a8a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104a91:	83 c2 04             	add    $0x4,%edx
80104a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a98:	89 14 24             	mov    %edx,(%esp)
80104a9b:	e8 08 0c 00 00       	call   801056a8 <swtch>
      switchkvm();
80104aa0:	e8 20 36 00 00       	call   801080c5 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104aa5:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104aac:	00 00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab0:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ab4:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104abb:	72 99                	jb     80104a56 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104abd:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ac4:	e8 58 07 00 00       	call   80105221 <release>

  }
80104ac9:	e9 6e ff ff ff       	jmp    80104a3c <scheduler+0x6>

80104ace <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ace:	55                   	push   %ebp
80104acf:	89 e5                	mov    %esp,%ebp
80104ad1:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104ad4:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104adb:	e8 09 08 00 00       	call   801052e9 <holding>
80104ae0:	85 c0                	test   %eax,%eax
80104ae2:	75 0c                	jne    80104af0 <sched+0x22>
    panic("sched ptable.lock");
80104ae4:	c7 04 24 ed 8b 10 80 	movl   $0x80108bed,(%esp)
80104aeb:	e8 4a ba ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
80104af0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104af6:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104afc:	83 f8 01             	cmp    $0x1,%eax
80104aff:	74 0c                	je     80104b0d <sched+0x3f>
    panic("sched locks");
80104b01:	c7 04 24 ff 8b 10 80 	movl   $0x80108bff,(%esp)
80104b08:	e8 2d ba ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
80104b0d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b13:	8b 40 0c             	mov    0xc(%eax),%eax
80104b16:	83 f8 04             	cmp    $0x4,%eax
80104b19:	75 0c                	jne    80104b27 <sched+0x59>
    panic("sched running");
80104b1b:	c7 04 24 0b 8c 10 80 	movl   $0x80108c0b,(%esp)
80104b22:	e8 13 ba ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
80104b27:	e8 68 f8 ff ff       	call   80104394 <readeflags>
80104b2c:	25 00 02 00 00       	and    $0x200,%eax
80104b31:	85 c0                	test   %eax,%eax
80104b33:	74 0c                	je     80104b41 <sched+0x73>
    panic("sched interruptible");
80104b35:	c7 04 24 19 8c 10 80 	movl   $0x80108c19,(%esp)
80104b3c:	e8 f9 b9 ff ff       	call   8010053a <panic>
  intena = cpu->intena;
80104b41:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b47:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b56:	8b 40 04             	mov    0x4(%eax),%eax
80104b59:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b60:	83 c2 1c             	add    $0x1c,%edx
80104b63:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b67:	89 14 24             	mov    %edx,(%esp)
80104b6a:	e8 39 0b 00 00       	call   801056a8 <swtch>
  cpu->intena = intena;
80104b6f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b78:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104b7e:	c9                   	leave  
80104b7f:	c3                   	ret    

80104b80 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b80:	55                   	push   %ebp
80104b81:	89 e5                	mov    %esp,%ebp
80104b83:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b86:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b8d:	e8 2d 06 00 00       	call   801051bf <acquire>
  proc->state = RUNNABLE;
80104b92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b98:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b9f:	e8 2a ff ff ff       	call   80104ace <sched>
  release(&ptable.lock);
80104ba4:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104bab:	e8 71 06 00 00       	call   80105221 <release>
}
80104bb0:	c9                   	leave  
80104bb1:	c3                   	ret    

80104bb2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104bb2:	55                   	push   %ebp
80104bb3:	89 e5                	mov    %esp,%ebp
80104bb5:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104bb8:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104bbf:	e8 5d 06 00 00       	call   80105221 <release>

  if (first) {
80104bc4:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104bc9:	85 c0                	test   %eax,%eax
80104bcb:	74 22                	je     80104bef <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104bcd:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104bd4:	00 00 00 
    iinit(ROOTDEV);
80104bd7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bde:	e8 cd c9 ff ff       	call   801015b0 <iinit>
    initlog(ROOTDEV);
80104be3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bea:	e8 d5 e6 ff ff       	call   801032c4 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104bef:	c9                   	leave  
80104bf0:	c3                   	ret    

80104bf1 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bf1:	55                   	push   %ebp
80104bf2:	89 e5                	mov    %esp,%ebp
80104bf4:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104bf7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bfd:	85 c0                	test   %eax,%eax
80104bff:	75 0c                	jne    80104c0d <sleep+0x1c>
    panic("sleep");
80104c01:	c7 04 24 2d 8c 10 80 	movl   $0x80108c2d,(%esp)
80104c08:	e8 2d b9 ff ff       	call   8010053a <panic>

  if(lk == 0)
80104c0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c11:	75 0c                	jne    80104c1f <sleep+0x2e>
    panic("sleep without lk");
80104c13:	c7 04 24 33 8c 10 80 	movl   $0x80108c33,(%esp)
80104c1a:	e8 1b b9 ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104c1f:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c26:	74 17                	je     80104c3f <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104c28:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c2f:	e8 8b 05 00 00       	call   801051bf <acquire>
    release(lk);
80104c34:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c37:	89 04 24             	mov    %eax,(%esp)
80104c3a:	e8 e2 05 00 00       	call   80105221 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104c3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c45:	8b 55 08             	mov    0x8(%ebp),%edx
80104c48:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104c4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c51:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104c58:	e8 71 fe ff ff       	call   80104ace <sched>

  // Tidy up.
  proc->chan = 0;
80104c5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c63:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c6a:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c71:	74 17                	je     80104c8a <sleep+0x99>
    release(&ptable.lock);
80104c73:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c7a:	e8 a2 05 00 00       	call   80105221 <release>
    acquire(lk);
80104c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c82:	89 04 24             	mov    %eax,(%esp)
80104c85:	e8 35 05 00 00       	call   801051bf <acquire>
  }
}
80104c8a:	c9                   	leave  
80104c8b:	c3                   	ret    

80104c8c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c8c:	55                   	push   %ebp
80104c8d:	89 e5                	mov    %esp,%ebp
80104c8f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c92:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104c99:	eb 24                	jmp    80104cbf <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104c9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c9e:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca1:	83 f8 02             	cmp    $0x2,%eax
80104ca4:	75 15                	jne    80104cbb <wakeup1+0x2f>
80104ca6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ca9:	8b 40 20             	mov    0x20(%eax),%eax
80104cac:	3b 45 08             	cmp    0x8(%ebp),%eax
80104caf:	75 0a                	jne    80104cbb <wakeup1+0x2f>
      p->state = RUNNABLE;
80104cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104cb4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104cbb:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104cbf:	81 7d fc 94 48 11 80 	cmpl   $0x80114894,-0x4(%ebp)
80104cc6:	72 d3                	jb     80104c9b <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104cc8:	c9                   	leave  
80104cc9:	c3                   	ret    

80104cca <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cca:	55                   	push   %ebp
80104ccb:	89 e5                	mov    %esp,%ebp
80104ccd:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104cd0:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cd7:	e8 e3 04 00 00       	call   801051bf <acquire>
  wakeup1(chan);
80104cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdf:	89 04 24             	mov    %eax,(%esp)
80104ce2:	e8 a5 ff ff ff       	call   80104c8c <wakeup1>
  release(&ptable.lock);
80104ce7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cee:	e8 2e 05 00 00       	call   80105221 <release>
}
80104cf3:	c9                   	leave  
80104cf4:	c3                   	ret    

80104cf5 <join>:

int
join(void** stack)
{
80104cf5:	55                   	push   %ebp
80104cf6:	89 e5                	mov    %esp,%ebp
80104cf8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int y, pid;
  acquire(&ptable.lock);
80104cfb:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d02:	e8 b8 04 00 00       	call   801051bf <acquire>
  for(;;){
    y = 0;
80104d07:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d0e:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104d15:	e9 d3 00 00 00       	jmp    80104ded <join+0xf8>
      if(p->parent != proc || p->pgdir != p->parent->pgdir){continue;}
80104d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d1d:	8b 50 14             	mov    0x14(%eax),%edx
80104d20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d26:	39 c2                	cmp    %eax,%edx
80104d28:	75 13                	jne    80104d3d <join+0x48>
80104d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2d:	8b 50 04             	mov    0x4(%eax),%edx
80104d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d33:	8b 40 14             	mov    0x14(%eax),%eax
80104d36:	8b 40 04             	mov    0x4(%eax),%eax
80104d39:	39 c2                	cmp    %eax,%edx
80104d3b:	74 05                	je     80104d42 <join+0x4d>
80104d3d:	e9 a7 00 00 00       	jmp    80104de9 <join+0xf4>
      y = 1;
80104d42:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d4f:	83 f8 05             	cmp    $0x5,%eax
80104d52:	0f 85 91 00 00 00    	jne    80104de9 <join+0xf4>
        void * stackAddr = (void*) p->parent->tf->esp + 7*sizeof(void*);
80104d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5b:	8b 40 14             	mov    0x14(%eax),%eax
80104d5e:	8b 40 18             	mov    0x18(%eax),%eax
80104d61:	8b 40 44             	mov    0x44(%eax),%eax
80104d64:	83 c0 1c             	add    $0x1c,%eax
80104d67:	89 45 ec             	mov    %eax,-0x14(%ebp)
	*(uint*)stackAddr = p->tf->ebp;
80104d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6d:	8b 40 18             	mov    0x18(%eax),%eax
80104d70:	8b 50 08             	mov    0x8(%eax),%edx
80104d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d76:	89 10                	mov    %edx,(%eax)
	*(uint*)stackAddr += 3*sizeof(void*) -PGSIZE ;
80104d78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d7b:	8b 00                	mov    (%eax),%eax
80104d7d:	8d 90 0c f0 ff ff    	lea    -0xff4(%eax),%edx
80104d83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d86:	89 10                	mov    %edx,(%eax)
	pid = p->pid;
80104d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8b:	8b 40 10             	mov    0x10(%eax),%eax
80104d8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d94:	8b 40 08             	mov    0x8(%eax),%eax
80104d97:	89 04 24             	mov    %eax,(%esp)
80104d9a:	e8 6b dd ff ff       	call   80102b0a <kfree>
        p->kstack = 0;
80104d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	p->state = UNUSED;
80104da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dac:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dca:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd1:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104dd8:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ddf:	e8 3d 04 00 00       	call   80105221 <release>
        return pid;
80104de4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104de7:	eb 52                	jmp    80104e3b <join+0x146>
  struct proc *p;
  int y, pid;
  acquire(&ptable.lock);
  for(;;){
    y = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104de9:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ded:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104df4:	0f 82 20 ff ff ff    	jb     80104d1a <join+0x25>
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }
    if(!y || proc->killed){
80104dfa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104dfe:	74 0d                	je     80104e0d <join+0x118>
80104e00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e06:	8b 40 24             	mov    0x24(%eax),%eax
80104e09:	85 c0                	test   %eax,%eax
80104e0b:	74 13                	je     80104e20 <join+0x12b>
      release(&ptable.lock);
80104e0d:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e14:	e8 08 04 00 00       	call   80105221 <release>
      return -1;
80104e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e1e:	eb 1b                	jmp    80104e3b <join+0x146>
    }
    sleep(proc, &ptable.lock);
80104e20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e26:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
80104e2d:	80 
80104e2e:	89 04 24             	mov    %eax,(%esp)
80104e31:	e8 bb fd ff ff       	call   80104bf1 <sleep>
  }
80104e36:	e9 cc fe ff ff       	jmp    80104d07 <join+0x12>
}
80104e3b:	c9                   	leave  
80104e3c:	c3                   	ret    

80104e3d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e3d:	55                   	push   %ebp
80104e3e:	89 e5                	mov    %esp,%ebp
80104e40:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e43:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e4a:	e8 70 03 00 00       	call   801051bf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e4f:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104e56:	eb 41                	jmp    80104e99 <kill+0x5c>
    if(p->pid == pid){
80104e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5b:	8b 40 10             	mov    0x10(%eax),%eax
80104e5e:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e61:	75 32                	jne    80104e95 <kill+0x58>
      p->killed = 1;
80104e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e66:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e70:	8b 40 0c             	mov    0xc(%eax),%eax
80104e73:	83 f8 02             	cmp    $0x2,%eax
80104e76:	75 0a                	jne    80104e82 <kill+0x45>
        p->state = RUNNABLE;
80104e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e82:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e89:	e8 93 03 00 00       	call   80105221 <release>
      return 0;
80104e8e:	b8 00 00 00 00       	mov    $0x0,%eax
80104e93:	eb 1e                	jmp    80104eb3 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e95:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104e99:	81 7d f4 94 48 11 80 	cmpl   $0x80114894,-0xc(%ebp)
80104ea0:	72 b6                	jb     80104e58 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104ea2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ea9:	e8 73 03 00 00       	call   80105221 <release>
  return -1;
80104eae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eb3:	c9                   	leave  
80104eb4:	c3                   	ret    

80104eb5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104eb5:	55                   	push   %ebp
80104eb6:	89 e5                	mov    %esp,%ebp
80104eb8:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ebb:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104ec2:	e9 d6 00 00 00       	jmp    80104f9d <procdump+0xe8>
    if(p->state == UNUSED)
80104ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eca:	8b 40 0c             	mov    0xc(%eax),%eax
80104ecd:	85 c0                	test   %eax,%eax
80104ecf:	75 05                	jne    80104ed6 <procdump+0x21>
      continue;
80104ed1:	e9 c3 00 00 00       	jmp    80104f99 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed9:	8b 40 0c             	mov    0xc(%eax),%eax
80104edc:	83 f8 05             	cmp    $0x5,%eax
80104edf:	77 23                	ja     80104f04 <procdump+0x4f>
80104ee1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee7:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104eee:	85 c0                	test   %eax,%eax
80104ef0:	74 12                	je     80104f04 <procdump+0x4f>
      state = states[p->state];
80104ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef8:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104eff:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f02:	eb 07                	jmp    80104f0b <procdump+0x56>
    else
      state = "???";
80104f04:	c7 45 ec 44 8c 10 80 	movl   $0x80108c44,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f14:	8b 40 10             	mov    0x10(%eax),%eax
80104f17:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f1e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f22:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f26:	c7 04 24 48 8c 10 80 	movl   $0x80108c48,(%esp)
80104f2d:	e8 6e b4 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f35:	8b 40 0c             	mov    0xc(%eax),%eax
80104f38:	83 f8 02             	cmp    $0x2,%eax
80104f3b:	75 50                	jne    80104f8d <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f40:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f43:	8b 40 0c             	mov    0xc(%eax),%eax
80104f46:	83 c0 08             	add    $0x8,%eax
80104f49:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f4c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f50:	89 04 24             	mov    %eax,(%esp)
80104f53:	e8 18 03 00 00       	call   80105270 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104f58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f5f:	eb 1b                	jmp    80104f7c <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f64:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f68:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f6c:	c7 04 24 51 8c 10 80 	movl   $0x80108c51,(%esp)
80104f73:	e8 28 b4 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f7c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f80:	7f 0b                	jg     80104f8d <procdump+0xd8>
80104f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f85:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f89:	85 c0                	test   %eax,%eax
80104f8b:	75 d4                	jne    80104f61 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f8d:	c7 04 24 55 8c 10 80 	movl   $0x80108c55,(%esp)
80104f94:	e8 07 b4 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f99:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104f9d:	81 7d f0 94 48 11 80 	cmpl   $0x80114894,-0x10(%ebp)
80104fa4:	0f 82 1d ff ff ff    	jb     80104ec7 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104faa:	c9                   	leave  
80104fab:	c3                   	ret    

80104fac <clone>:

int clone(void(*fn)(void*), void *arg, void*stack)
{
80104fac:	55                   	push   %ebp
80104fad:	89 e5                	mov    %esp,%ebp
80104faf:	57                   	push   %edi
80104fb0:	56                   	push   %esi
80104fb1:	53                   	push   %ebx
80104fb2:	83 ec 3c             	sub    $0x3c,%esp
  int i, pid;
  struct proc *np;
  if((np = allocproc()) == 0)
80104fb5:	e8 0c f4 ff ff       	call   801043c6 <allocproc>
80104fba:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104fbd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104fc1:	75 0a                	jne    80104fcd <clone+0x21>
    return -1;
80104fc3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc8:	e9 91 01 00 00       	jmp    8010515e <clone+0x1b2>

  np->pgdir = proc->pgdir;
80104fcd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fd3:	8b 50 04             	mov    0x4(%eax),%edx
80104fd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fd9:	89 50 04             	mov    %edx,0x4(%eax)
  np->sz = proc->sz;
80104fdc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fe2:	8b 10                	mov    (%eax),%edx
80104fe4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fe7:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104fe9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ff3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104ff6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ff9:	8b 50 18             	mov    0x18(%eax),%edx
80104ffc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105002:	8b 40 18             	mov    0x18(%eax),%eax
80105005:	89 c3                	mov    %eax,%ebx
80105007:	b8 13 00 00 00       	mov    $0x13,%eax
8010500c:	89 d7                	mov    %edx,%edi
8010500e:	89 de                	mov    %ebx,%esi
80105010:	89 c1                	mov    %eax,%ecx
80105012:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  void * stackArg, *stackReturn;
  stackReturn = stack + 4096 -2* sizeof(void *);
80105014:	8b 45 10             	mov    0x10(%ebp),%eax
80105017:	05 f8 0f 00 00       	add    $0xff8,%eax
8010501c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  *(uint*)stackReturn = 0xFFFFFFF;
8010501f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105022:	c7 00 ff ff ff 0f    	movl   $0xfffffff,(%eax)

  stackArg = stack + 4096 - sizeof(void *);
80105028:	8b 45 10             	mov    0x10(%ebp),%eax
8010502b:	05 fc 0f 00 00       	add    $0xffc,%eax
80105030:	89 45 d8             	mov    %eax,-0x28(%ebp)
  *(uint*)stackArg = (uint)arg;
80105033:	8b 55 0c             	mov    0xc(%ebp),%edx
80105036:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105039:	89 10                	mov    %edx,(%eax)

  np->tf->esp = (int) stack;
8010503b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010503e:	8b 40 18             	mov    0x18(%eax),%eax
80105041:	8b 55 10             	mov    0x10(%ebp),%edx
80105044:	89 50 44             	mov    %edx,0x44(%eax)
  memmove((void*)np->tf->esp, stack, PGSIZE);
80105047:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010504a:	8b 40 18             	mov    0x18(%eax),%eax
8010504d:	8b 40 44             	mov    0x44(%eax),%eax
80105050:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105057:	00 
80105058:	8b 55 10             	mov    0x10(%ebp),%edx
8010505b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010505f:	89 04 24             	mov    %eax,(%esp)
80105062:	e8 7e 04 00 00       	call   801054e5 <memmove>
  np->tf->esp += PGSIZE -2*sizeof(void*) ;
80105067:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010506a:	8b 40 18             	mov    0x18(%eax),%eax
8010506d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105070:	8b 52 18             	mov    0x18(%edx),%edx
80105073:	8b 52 44             	mov    0x44(%edx),%edx
80105076:	81 c2 f8 0f 00 00    	add    $0xff8,%edx
8010507c:	89 50 44             	mov    %edx,0x44(%eax)
  np->tf->ebp = np->tf->esp;
8010507f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105082:	8b 40 18             	mov    0x18(%eax),%eax
80105085:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105088:	8b 52 18             	mov    0x18(%edx),%edx
8010508b:	8b 52 44             	mov    0x44(%edx),%edx
8010508e:	89 50 08             	mov    %edx,0x8(%eax)
  np->tf->eip = (int) fn;
80105091:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105094:	8b 40 18             	mov    0x18(%eax),%eax
80105097:	8b 55 08             	mov    0x8(%ebp),%edx
8010509a:	89 50 38             	mov    %edx,0x38(%eax)
  
  for(i = 0; i < NOFILE; i++)
8010509d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801050a4:	eb 3d                	jmp    801050e3 <clone+0x137>
    if(proc->ofile[i])
801050a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050af:	83 c2 08             	add    $0x8,%edx
801050b2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050b6:	85 c0                	test   %eax,%eax
801050b8:	74 25                	je     801050df <clone+0x133>
      np->ofile[i] = filedup(proc->ofile[i]);
801050ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801050c3:	83 c2 08             	add    $0x8,%edx
801050c6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050ca:	89 04 24             	mov    %eax,(%esp)
801050cd:	e8 d2 be ff ff       	call   80100fa4 <filedup>
801050d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
801050d5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801050d8:	83 c1 08             	add    $0x8,%ecx
801050db:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  memmove((void*)np->tf->esp, stack, PGSIZE);
  np->tf->esp += PGSIZE -2*sizeof(void*) ;
  np->tf->ebp = np->tf->esp;
  np->tf->eip = (int) fn;
  
  for(i = 0; i < NOFILE; i++)
801050df:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801050e3:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801050e7:	7e bd                	jle    801050a6 <clone+0xfa>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801050e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ef:	8b 40 68             	mov    0x68(%eax),%eax
801050f2:	89 04 24             	mov    %eax,(%esp)
801050f5:	e8 ac c7 ff ff       	call   801018a6 <idup>
801050fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
801050fd:	89 42 68             	mov    %eax,0x68(%edx)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80105100:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105106:	8d 50 6c             	lea    0x6c(%eax),%edx
80105109:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010510c:	83 c0 6c             	add    $0x6c,%eax
8010510f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105116:	00 
80105117:	89 54 24 04          	mov    %edx,0x4(%esp)
8010511b:	89 04 24             	mov    %eax,(%esp)
8010511e:	e8 13 05 00 00       	call   80105636 <safestrcpy>
  pid = np->pid;
80105123:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105126:	8b 40 10             	mov    0x10(%eax),%eax
80105129:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  np->tf->eax = 0;
8010512c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010512f:	8b 40 18             	mov    0x18(%eax),%eax
80105132:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  acquire(&ptable.lock);
80105139:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80105140:	e8 7a 00 00 00       	call   801051bf <acquire>
  np->state = RUNNABLE;
80105145:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105148:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);  
8010514f:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80105156:	e8 c6 00 00 00       	call   80105221 <release>
  return pid;
8010515b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010515e:	83 c4 3c             	add    $0x3c,%esp
80105161:	5b                   	pop    %ebx
80105162:	5e                   	pop    %esi
80105163:	5f                   	pop    %edi
80105164:	5d                   	pop    %ebp
80105165:	c3                   	ret    
80105166:	66 90                	xchg   %ax,%ax

80105168 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105168:	55                   	push   %ebp
80105169:	89 e5                	mov    %esp,%ebp
8010516b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010516e:	9c                   	pushf  
8010516f:	58                   	pop    %eax
80105170:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105173:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105176:	c9                   	leave  
80105177:	c3                   	ret    

80105178 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105178:	55                   	push   %ebp
80105179:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010517b:	fa                   	cli    
}
8010517c:	5d                   	pop    %ebp
8010517d:	c3                   	ret    

8010517e <sti>:

static inline void
sti(void)
{
8010517e:	55                   	push   %ebp
8010517f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105181:	fb                   	sti    
}
80105182:	5d                   	pop    %ebp
80105183:	c3                   	ret    

80105184 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105184:	55                   	push   %ebp
80105185:	89 e5                	mov    %esp,%ebp
80105187:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010518a:	8b 55 08             	mov    0x8(%ebp),%edx
8010518d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105190:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105193:	f0 87 02             	lock xchg %eax,(%edx)
80105196:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105199:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010519c:	c9                   	leave  
8010519d:	c3                   	ret    

8010519e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010519e:	55                   	push   %ebp
8010519f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801051a1:	8b 45 08             	mov    0x8(%ebp),%eax
801051a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801051a7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801051aa:	8b 45 08             	mov    0x8(%ebp),%eax
801051ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801051b3:	8b 45 08             	mov    0x8(%ebp),%eax
801051b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051bd:	5d                   	pop    %ebp
801051be:	c3                   	ret    

801051bf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051bf:	55                   	push   %ebp
801051c0:	89 e5                	mov    %esp,%ebp
801051c2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051c5:	e8 49 01 00 00       	call   80105313 <pushcli>
  if(holding(lk))
801051ca:	8b 45 08             	mov    0x8(%ebp),%eax
801051cd:	89 04 24             	mov    %eax,(%esp)
801051d0:	e8 14 01 00 00       	call   801052e9 <holding>
801051d5:	85 c0                	test   %eax,%eax
801051d7:	74 0c                	je     801051e5 <acquire+0x26>
    panic("acquire");
801051d9:	c7 04 24 81 8c 10 80 	movl   $0x80108c81,(%esp)
801051e0:	e8 55 b3 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801051e5:	90                   	nop
801051e6:	8b 45 08             	mov    0x8(%ebp),%eax
801051e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051f0:	00 
801051f1:	89 04 24             	mov    %eax,(%esp)
801051f4:	e8 8b ff ff ff       	call   80105184 <xchg>
801051f9:	85 c0                	test   %eax,%eax
801051fb:	75 e9                	jne    801051e6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801051fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105200:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105207:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010520a:	8b 45 08             	mov    0x8(%ebp),%eax
8010520d:	83 c0 0c             	add    $0xc,%eax
80105210:	89 44 24 04          	mov    %eax,0x4(%esp)
80105214:	8d 45 08             	lea    0x8(%ebp),%eax
80105217:	89 04 24             	mov    %eax,(%esp)
8010521a:	e8 51 00 00 00       	call   80105270 <getcallerpcs>
}
8010521f:	c9                   	leave  
80105220:	c3                   	ret    

80105221 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105221:	55                   	push   %ebp
80105222:	89 e5                	mov    %esp,%ebp
80105224:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105227:	8b 45 08             	mov    0x8(%ebp),%eax
8010522a:	89 04 24             	mov    %eax,(%esp)
8010522d:	e8 b7 00 00 00       	call   801052e9 <holding>
80105232:	85 c0                	test   %eax,%eax
80105234:	75 0c                	jne    80105242 <release+0x21>
    panic("release");
80105236:	c7 04 24 89 8c 10 80 	movl   $0x80108c89,(%esp)
8010523d:	e8 f8 b2 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
80105242:	8b 45 08             	mov    0x8(%ebp),%eax
80105245:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010524c:	8b 45 08             	mov    0x8(%ebp),%eax
8010524f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105256:	8b 45 08             	mov    0x8(%ebp),%eax
80105259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105260:	00 
80105261:	89 04 24             	mov    %eax,(%esp)
80105264:	e8 1b ff ff ff       	call   80105184 <xchg>

  popcli();
80105269:	e8 e9 00 00 00       	call   80105357 <popcli>
}
8010526e:	c9                   	leave  
8010526f:	c3                   	ret    

80105270 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105270:	55                   	push   %ebp
80105271:	89 e5                	mov    %esp,%ebp
80105273:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105276:	8b 45 08             	mov    0x8(%ebp),%eax
80105279:	83 e8 08             	sub    $0x8,%eax
8010527c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010527f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105286:	eb 38                	jmp    801052c0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105288:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010528c:	74 38                	je     801052c6 <getcallerpcs+0x56>
8010528e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105295:	76 2f                	jbe    801052c6 <getcallerpcs+0x56>
80105297:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010529b:	74 29                	je     801052c6 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010529d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801052aa:	01 c2                	add    %eax,%edx
801052ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052af:	8b 40 04             	mov    0x4(%eax),%eax
801052b2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052b7:	8b 00                	mov    (%eax),%eax
801052b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801052bc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052c0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052c4:	7e c2                	jle    80105288 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052c6:	eb 19                	jmp    801052e1 <getcallerpcs+0x71>
    pcs[i] = 0;
801052c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052cb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d5:	01 d0                	add    %edx,%eax
801052d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052dd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052e1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052e5:	7e e1                	jle    801052c8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801052e7:	c9                   	leave  
801052e8:	c3                   	ret    

801052e9 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052e9:	55                   	push   %ebp
801052ea:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801052ec:	8b 45 08             	mov    0x8(%ebp),%eax
801052ef:	8b 00                	mov    (%eax),%eax
801052f1:	85 c0                	test   %eax,%eax
801052f3:	74 17                	je     8010530c <holding+0x23>
801052f5:	8b 45 08             	mov    0x8(%ebp),%eax
801052f8:	8b 50 08             	mov    0x8(%eax),%edx
801052fb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105301:	39 c2                	cmp    %eax,%edx
80105303:	75 07                	jne    8010530c <holding+0x23>
80105305:	b8 01 00 00 00       	mov    $0x1,%eax
8010530a:	eb 05                	jmp    80105311 <holding+0x28>
8010530c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105311:	5d                   	pop    %ebp
80105312:	c3                   	ret    

80105313 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105313:	55                   	push   %ebp
80105314:	89 e5                	mov    %esp,%ebp
80105316:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105319:	e8 4a fe ff ff       	call   80105168 <readeflags>
8010531e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105321:	e8 52 fe ff ff       	call   80105178 <cli>
  if(cpu->ncli++ == 0)
80105326:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010532d:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105333:	8d 48 01             	lea    0x1(%eax),%ecx
80105336:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010533c:	85 c0                	test   %eax,%eax
8010533e:	75 15                	jne    80105355 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105340:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105346:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105349:	81 e2 00 02 00 00    	and    $0x200,%edx
8010534f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105355:	c9                   	leave  
80105356:	c3                   	ret    

80105357 <popcli>:

void
popcli(void)
{
80105357:	55                   	push   %ebp
80105358:	89 e5                	mov    %esp,%ebp
8010535a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010535d:	e8 06 fe ff ff       	call   80105168 <readeflags>
80105362:	25 00 02 00 00       	and    $0x200,%eax
80105367:	85 c0                	test   %eax,%eax
80105369:	74 0c                	je     80105377 <popcli+0x20>
    panic("popcli - interruptible");
8010536b:	c7 04 24 91 8c 10 80 	movl   $0x80108c91,(%esp)
80105372:	e8 c3 b1 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
80105377:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010537d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105383:	83 ea 01             	sub    $0x1,%edx
80105386:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010538c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105392:	85 c0                	test   %eax,%eax
80105394:	79 0c                	jns    801053a2 <popcli+0x4b>
    panic("popcli");
80105396:	c7 04 24 a8 8c 10 80 	movl   $0x80108ca8,(%esp)
8010539d:	e8 98 b1 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
801053a2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053a8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053ae:	85 c0                	test   %eax,%eax
801053b0:	75 15                	jne    801053c7 <popcli+0x70>
801053b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053b8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053be:	85 c0                	test   %eax,%eax
801053c0:	74 05                	je     801053c7 <popcli+0x70>
    sti();
801053c2:	e8 b7 fd ff ff       	call   8010517e <sti>
}
801053c7:	c9                   	leave  
801053c8:	c3                   	ret    
801053c9:	66 90                	xchg   %ax,%ax
801053cb:	90                   	nop

801053cc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053cc:	55                   	push   %ebp
801053cd:	89 e5                	mov    %esp,%ebp
801053cf:	57                   	push   %edi
801053d0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053d4:	8b 55 10             	mov    0x10(%ebp),%edx
801053d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053da:	89 cb                	mov    %ecx,%ebx
801053dc:	89 df                	mov    %ebx,%edi
801053de:	89 d1                	mov    %edx,%ecx
801053e0:	fc                   	cld    
801053e1:	f3 aa                	rep stos %al,%es:(%edi)
801053e3:	89 ca                	mov    %ecx,%edx
801053e5:	89 fb                	mov    %edi,%ebx
801053e7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053ea:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053ed:	5b                   	pop    %ebx
801053ee:	5f                   	pop    %edi
801053ef:	5d                   	pop    %ebp
801053f0:	c3                   	ret    

801053f1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053f1:	55                   	push   %ebp
801053f2:	89 e5                	mov    %esp,%ebp
801053f4:	57                   	push   %edi
801053f5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053f9:	8b 55 10             	mov    0x10(%ebp),%edx
801053fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ff:	89 cb                	mov    %ecx,%ebx
80105401:	89 df                	mov    %ebx,%edi
80105403:	89 d1                	mov    %edx,%ecx
80105405:	fc                   	cld    
80105406:	f3 ab                	rep stos %eax,%es:(%edi)
80105408:	89 ca                	mov    %ecx,%edx
8010540a:	89 fb                	mov    %edi,%ebx
8010540c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010540f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105412:	5b                   	pop    %ebx
80105413:	5f                   	pop    %edi
80105414:	5d                   	pop    %ebp
80105415:	c3                   	ret    

80105416 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105416:	55                   	push   %ebp
80105417:	89 e5                	mov    %esp,%ebp
80105419:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010541c:	8b 45 08             	mov    0x8(%ebp),%eax
8010541f:	83 e0 03             	and    $0x3,%eax
80105422:	85 c0                	test   %eax,%eax
80105424:	75 49                	jne    8010546f <memset+0x59>
80105426:	8b 45 10             	mov    0x10(%ebp),%eax
80105429:	83 e0 03             	and    $0x3,%eax
8010542c:	85 c0                	test   %eax,%eax
8010542e:	75 3f                	jne    8010546f <memset+0x59>
    c &= 0xFF;
80105430:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105437:	8b 45 10             	mov    0x10(%ebp),%eax
8010543a:	c1 e8 02             	shr    $0x2,%eax
8010543d:	89 c2                	mov    %eax,%edx
8010543f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105442:	c1 e0 18             	shl    $0x18,%eax
80105445:	89 c1                	mov    %eax,%ecx
80105447:	8b 45 0c             	mov    0xc(%ebp),%eax
8010544a:	c1 e0 10             	shl    $0x10,%eax
8010544d:	09 c1                	or     %eax,%ecx
8010544f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105452:	c1 e0 08             	shl    $0x8,%eax
80105455:	09 c8                	or     %ecx,%eax
80105457:	0b 45 0c             	or     0xc(%ebp),%eax
8010545a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010545e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105462:	8b 45 08             	mov    0x8(%ebp),%eax
80105465:	89 04 24             	mov    %eax,(%esp)
80105468:	e8 84 ff ff ff       	call   801053f1 <stosl>
8010546d:	eb 19                	jmp    80105488 <memset+0x72>
  } else
    stosb(dst, c, n);
8010546f:	8b 45 10             	mov    0x10(%ebp),%eax
80105472:	89 44 24 08          	mov    %eax,0x8(%esp)
80105476:	8b 45 0c             	mov    0xc(%ebp),%eax
80105479:	89 44 24 04          	mov    %eax,0x4(%esp)
8010547d:	8b 45 08             	mov    0x8(%ebp),%eax
80105480:	89 04 24             	mov    %eax,(%esp)
80105483:	e8 44 ff ff ff       	call   801053cc <stosb>
  return dst;
80105488:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010548b:	c9                   	leave  
8010548c:	c3                   	ret    

8010548d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010548d:	55                   	push   %ebp
8010548e:	89 e5                	mov    %esp,%ebp
80105490:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105493:	8b 45 08             	mov    0x8(%ebp),%eax
80105496:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105499:	8b 45 0c             	mov    0xc(%ebp),%eax
8010549c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010549f:	eb 30                	jmp    801054d1 <memcmp+0x44>
    if(*s1 != *s2)
801054a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054a4:	0f b6 10             	movzbl (%eax),%edx
801054a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054aa:	0f b6 00             	movzbl (%eax),%eax
801054ad:	38 c2                	cmp    %al,%dl
801054af:	74 18                	je     801054c9 <memcmp+0x3c>
      return *s1 - *s2;
801054b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054b4:	0f b6 00             	movzbl (%eax),%eax
801054b7:	0f b6 d0             	movzbl %al,%edx
801054ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054bd:	0f b6 00             	movzbl (%eax),%eax
801054c0:	0f b6 c0             	movzbl %al,%eax
801054c3:	29 c2                	sub    %eax,%edx
801054c5:	89 d0                	mov    %edx,%eax
801054c7:	eb 1a                	jmp    801054e3 <memcmp+0x56>
    s1++, s2++;
801054c9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054cd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054d1:	8b 45 10             	mov    0x10(%ebp),%eax
801054d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801054d7:	89 55 10             	mov    %edx,0x10(%ebp)
801054da:	85 c0                	test   %eax,%eax
801054dc:	75 c3                	jne    801054a1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801054de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054e3:	c9                   	leave  
801054e4:	c3                   	ret    

801054e5 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054e5:	55                   	push   %ebp
801054e6:	89 e5                	mov    %esp,%ebp
801054e8:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054f1:	8b 45 08             	mov    0x8(%ebp),%eax
801054f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054fa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054fd:	73 3d                	jae    8010553c <memmove+0x57>
801054ff:	8b 45 10             	mov    0x10(%ebp),%eax
80105502:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105505:	01 d0                	add    %edx,%eax
80105507:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010550a:	76 30                	jbe    8010553c <memmove+0x57>
    s += n;
8010550c:	8b 45 10             	mov    0x10(%ebp),%eax
8010550f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105512:	8b 45 10             	mov    0x10(%ebp),%eax
80105515:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105518:	eb 13                	jmp    8010552d <memmove+0x48>
      *--d = *--s;
8010551a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010551e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105522:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105525:	0f b6 10             	movzbl (%eax),%edx
80105528:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010552b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010552d:	8b 45 10             	mov    0x10(%ebp),%eax
80105530:	8d 50 ff             	lea    -0x1(%eax),%edx
80105533:	89 55 10             	mov    %edx,0x10(%ebp)
80105536:	85 c0                	test   %eax,%eax
80105538:	75 e0                	jne    8010551a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010553a:	eb 26                	jmp    80105562 <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010553c:	eb 17                	jmp    80105555 <memmove+0x70>
      *d++ = *s++;
8010553e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105541:	8d 50 01             	lea    0x1(%eax),%edx
80105544:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105547:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010554a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010554d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105550:	0f b6 12             	movzbl (%edx),%edx
80105553:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105555:	8b 45 10             	mov    0x10(%ebp),%eax
80105558:	8d 50 ff             	lea    -0x1(%eax),%edx
8010555b:	89 55 10             	mov    %edx,0x10(%ebp)
8010555e:	85 c0                	test   %eax,%eax
80105560:	75 dc                	jne    8010553e <memmove+0x59>
      *d++ = *s++;

  return dst;
80105562:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105565:	c9                   	leave  
80105566:	c3                   	ret    

80105567 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105567:	55                   	push   %ebp
80105568:	89 e5                	mov    %esp,%ebp
8010556a:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010556d:	8b 45 10             	mov    0x10(%ebp),%eax
80105570:	89 44 24 08          	mov    %eax,0x8(%esp)
80105574:	8b 45 0c             	mov    0xc(%ebp),%eax
80105577:	89 44 24 04          	mov    %eax,0x4(%esp)
8010557b:	8b 45 08             	mov    0x8(%ebp),%eax
8010557e:	89 04 24             	mov    %eax,(%esp)
80105581:	e8 5f ff ff ff       	call   801054e5 <memmove>
}
80105586:	c9                   	leave  
80105587:	c3                   	ret    

80105588 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105588:	55                   	push   %ebp
80105589:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010558b:	eb 0c                	jmp    80105599 <strncmp+0x11>
    n--, p++, q++;
8010558d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105591:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105595:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105599:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010559d:	74 1a                	je     801055b9 <strncmp+0x31>
8010559f:	8b 45 08             	mov    0x8(%ebp),%eax
801055a2:	0f b6 00             	movzbl (%eax),%eax
801055a5:	84 c0                	test   %al,%al
801055a7:	74 10                	je     801055b9 <strncmp+0x31>
801055a9:	8b 45 08             	mov    0x8(%ebp),%eax
801055ac:	0f b6 10             	movzbl (%eax),%edx
801055af:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b2:	0f b6 00             	movzbl (%eax),%eax
801055b5:	38 c2                	cmp    %al,%dl
801055b7:	74 d4                	je     8010558d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801055b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055bd:	75 07                	jne    801055c6 <strncmp+0x3e>
    return 0;
801055bf:	b8 00 00 00 00       	mov    $0x0,%eax
801055c4:	eb 16                	jmp    801055dc <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801055c6:	8b 45 08             	mov    0x8(%ebp),%eax
801055c9:	0f b6 00             	movzbl (%eax),%eax
801055cc:	0f b6 d0             	movzbl %al,%edx
801055cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d2:	0f b6 00             	movzbl (%eax),%eax
801055d5:	0f b6 c0             	movzbl %al,%eax
801055d8:	29 c2                	sub    %eax,%edx
801055da:	89 d0                	mov    %edx,%eax
}
801055dc:	5d                   	pop    %ebp
801055dd:	c3                   	ret    

801055de <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055de:	55                   	push   %ebp
801055df:	89 e5                	mov    %esp,%ebp
801055e1:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055e4:	8b 45 08             	mov    0x8(%ebp),%eax
801055e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801055ea:	90                   	nop
801055eb:	8b 45 10             	mov    0x10(%ebp),%eax
801055ee:	8d 50 ff             	lea    -0x1(%eax),%edx
801055f1:	89 55 10             	mov    %edx,0x10(%ebp)
801055f4:	85 c0                	test   %eax,%eax
801055f6:	7e 1e                	jle    80105616 <strncpy+0x38>
801055f8:	8b 45 08             	mov    0x8(%ebp),%eax
801055fb:	8d 50 01             	lea    0x1(%eax),%edx
801055fe:	89 55 08             	mov    %edx,0x8(%ebp)
80105601:	8b 55 0c             	mov    0xc(%ebp),%edx
80105604:	8d 4a 01             	lea    0x1(%edx),%ecx
80105607:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010560a:	0f b6 12             	movzbl (%edx),%edx
8010560d:	88 10                	mov    %dl,(%eax)
8010560f:	0f b6 00             	movzbl (%eax),%eax
80105612:	84 c0                	test   %al,%al
80105614:	75 d5                	jne    801055eb <strncpy+0xd>
    ;
  while(n-- > 0)
80105616:	eb 0c                	jmp    80105624 <strncpy+0x46>
    *s++ = 0;
80105618:	8b 45 08             	mov    0x8(%ebp),%eax
8010561b:	8d 50 01             	lea    0x1(%eax),%edx
8010561e:	89 55 08             	mov    %edx,0x8(%ebp)
80105621:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105624:	8b 45 10             	mov    0x10(%ebp),%eax
80105627:	8d 50 ff             	lea    -0x1(%eax),%edx
8010562a:	89 55 10             	mov    %edx,0x10(%ebp)
8010562d:	85 c0                	test   %eax,%eax
8010562f:	7f e7                	jg     80105618 <strncpy+0x3a>
    *s++ = 0;
  return os;
80105631:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105634:	c9                   	leave  
80105635:	c3                   	ret    

80105636 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105636:	55                   	push   %ebp
80105637:	89 e5                	mov    %esp,%ebp
80105639:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010563c:	8b 45 08             	mov    0x8(%ebp),%eax
8010563f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105642:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105646:	7f 05                	jg     8010564d <safestrcpy+0x17>
    return os;
80105648:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010564b:	eb 31                	jmp    8010567e <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010564d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105651:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105655:	7e 1e                	jle    80105675 <safestrcpy+0x3f>
80105657:	8b 45 08             	mov    0x8(%ebp),%eax
8010565a:	8d 50 01             	lea    0x1(%eax),%edx
8010565d:	89 55 08             	mov    %edx,0x8(%ebp)
80105660:	8b 55 0c             	mov    0xc(%ebp),%edx
80105663:	8d 4a 01             	lea    0x1(%edx),%ecx
80105666:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105669:	0f b6 12             	movzbl (%edx),%edx
8010566c:	88 10                	mov    %dl,(%eax)
8010566e:	0f b6 00             	movzbl (%eax),%eax
80105671:	84 c0                	test   %al,%al
80105673:	75 d8                	jne    8010564d <safestrcpy+0x17>
    ;
  *s = 0;
80105675:	8b 45 08             	mov    0x8(%ebp),%eax
80105678:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010567b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010567e:	c9                   	leave  
8010567f:	c3                   	ret    

80105680 <strlen>:

int
strlen(const char *s)
{
80105680:	55                   	push   %ebp
80105681:	89 e5                	mov    %esp,%ebp
80105683:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105686:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010568d:	eb 04                	jmp    80105693 <strlen+0x13>
8010568f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105693:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105696:	8b 45 08             	mov    0x8(%ebp),%eax
80105699:	01 d0                	add    %edx,%eax
8010569b:	0f b6 00             	movzbl (%eax),%eax
8010569e:	84 c0                	test   %al,%al
801056a0:	75 ed                	jne    8010568f <strlen+0xf>
    ;
  return n;
801056a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056a5:	c9                   	leave  
801056a6:	c3                   	ret    
801056a7:	90                   	nop

801056a8 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801056a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056ac:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056b0:	55                   	push   %ebp
  pushl %ebx
801056b1:	53                   	push   %ebx
  pushl %esi
801056b2:	56                   	push   %esi
  pushl %edi
801056b3:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056b4:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056b6:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056b8:	5f                   	pop    %edi
  popl %esi
801056b9:	5e                   	pop    %esi
  popl %ebx
801056ba:	5b                   	pop    %ebx
  popl %ebp
801056bb:	5d                   	pop    %ebp
  ret
801056bc:	c3                   	ret    
801056bd:	66 90                	xchg   %ax,%ax
801056bf:	90                   	nop

801056c0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801056c0:	55                   	push   %ebp
801056c1:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801056c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c9:	8b 00                	mov    (%eax),%eax
801056cb:	3b 45 08             	cmp    0x8(%ebp),%eax
801056ce:	76 12                	jbe    801056e2 <fetchint+0x22>
801056d0:	8b 45 08             	mov    0x8(%ebp),%eax
801056d3:	8d 50 04             	lea    0x4(%eax),%edx
801056d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056dc:	8b 00                	mov    (%eax),%eax
801056de:	39 c2                	cmp    %eax,%edx
801056e0:	76 07                	jbe    801056e9 <fetchint+0x29>
    return -1;
801056e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e7:	eb 0f                	jmp    801056f8 <fetchint+0x38>
  *ip = *(int*)(addr);
801056e9:	8b 45 08             	mov    0x8(%ebp),%eax
801056ec:	8b 10                	mov    (%eax),%edx
801056ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f1:	89 10                	mov    %edx,(%eax)
  return 0;
801056f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056f8:	5d                   	pop    %ebp
801056f9:	c3                   	ret    

801056fa <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801056fa:	55                   	push   %ebp
801056fb:	89 e5                	mov    %esp,%ebp
801056fd:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105700:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105706:	8b 00                	mov    (%eax),%eax
80105708:	3b 45 08             	cmp    0x8(%ebp),%eax
8010570b:	77 07                	ja     80105714 <fetchstr+0x1a>
    return -1;
8010570d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105712:	eb 46                	jmp    8010575a <fetchstr+0x60>
  *pp = (char*)addr;
80105714:	8b 55 08             	mov    0x8(%ebp),%edx
80105717:	8b 45 0c             	mov    0xc(%ebp),%eax
8010571a:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010571c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105722:	8b 00                	mov    (%eax),%eax
80105724:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105727:	8b 45 0c             	mov    0xc(%ebp),%eax
8010572a:	8b 00                	mov    (%eax),%eax
8010572c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010572f:	eb 1c                	jmp    8010574d <fetchstr+0x53>
    if(*s == 0)
80105731:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105734:	0f b6 00             	movzbl (%eax),%eax
80105737:	84 c0                	test   %al,%al
80105739:	75 0e                	jne    80105749 <fetchstr+0x4f>
      return s - *pp;
8010573b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010573e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105741:	8b 00                	mov    (%eax),%eax
80105743:	29 c2                	sub    %eax,%edx
80105745:	89 d0                	mov    %edx,%eax
80105747:	eb 11                	jmp    8010575a <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105749:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010574d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105750:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105753:	72 dc                	jb     80105731 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105755:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010575a:	c9                   	leave  
8010575b:	c3                   	ret    

8010575c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010575c:	55                   	push   %ebp
8010575d:	89 e5                	mov    %esp,%ebp
8010575f:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105762:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105768:	8b 40 18             	mov    0x18(%eax),%eax
8010576b:	8b 50 44             	mov    0x44(%eax),%edx
8010576e:	8b 45 08             	mov    0x8(%ebp),%eax
80105771:	c1 e0 02             	shl    $0x2,%eax
80105774:	01 d0                	add    %edx,%eax
80105776:	8d 50 04             	lea    0x4(%eax),%edx
80105779:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105780:	89 14 24             	mov    %edx,(%esp)
80105783:	e8 38 ff ff ff       	call   801056c0 <fetchint>
}
80105788:	c9                   	leave  
80105789:	c3                   	ret    

8010578a <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010578a:	55                   	push   %ebp
8010578b:	89 e5                	mov    %esp,%ebp
8010578d:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105790:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105793:	89 44 24 04          	mov    %eax,0x4(%esp)
80105797:	8b 45 08             	mov    0x8(%ebp),%eax
8010579a:	89 04 24             	mov    %eax,(%esp)
8010579d:	e8 ba ff ff ff       	call   8010575c <argint>
801057a2:	85 c0                	test   %eax,%eax
801057a4:	79 07                	jns    801057ad <argptr+0x23>
    return -1;
801057a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ab:	eb 3d                	jmp    801057ea <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801057ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057b0:	89 c2                	mov    %eax,%edx
801057b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b8:	8b 00                	mov    (%eax),%eax
801057ba:	39 c2                	cmp    %eax,%edx
801057bc:	73 16                	jae    801057d4 <argptr+0x4a>
801057be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c1:	89 c2                	mov    %eax,%edx
801057c3:	8b 45 10             	mov    0x10(%ebp),%eax
801057c6:	01 c2                	add    %eax,%edx
801057c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ce:	8b 00                	mov    (%eax),%eax
801057d0:	39 c2                	cmp    %eax,%edx
801057d2:	76 07                	jbe    801057db <argptr+0x51>
    return -1;
801057d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d9:	eb 0f                	jmp    801057ea <argptr+0x60>
  *pp = (char*)i;
801057db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057de:	89 c2                	mov    %eax,%edx
801057e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801057e3:	89 10                	mov    %edx,(%eax)
  return 0;
801057e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057ea:	c9                   	leave  
801057eb:	c3                   	ret    

801057ec <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057ec:	55                   	push   %ebp
801057ed:	89 e5                	mov    %esp,%ebp
801057ef:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057f2:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801057f9:	8b 45 08             	mov    0x8(%ebp),%eax
801057fc:	89 04 24             	mov    %eax,(%esp)
801057ff:	e8 58 ff ff ff       	call   8010575c <argint>
80105804:	85 c0                	test   %eax,%eax
80105806:	79 07                	jns    8010580f <argstr+0x23>
    return -1;
80105808:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580d:	eb 12                	jmp    80105821 <argstr+0x35>
  return fetchstr(addr, pp);
8010580f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105812:	8b 55 0c             	mov    0xc(%ebp),%edx
80105815:	89 54 24 04          	mov    %edx,0x4(%esp)
80105819:	89 04 24             	mov    %eax,(%esp)
8010581c:	e8 d9 fe ff ff       	call   801056fa <fetchstr>
}
80105821:	c9                   	leave  
80105822:	c3                   	ret    

80105823 <syscall>:
[SYS_join]   sys_join,
};

void
syscall(void)
{
80105823:	55                   	push   %ebp
80105824:	89 e5                	mov    %esp,%ebp
80105826:	53                   	push   %ebx
80105827:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010582a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105830:	8b 40 18             	mov    0x18(%eax),%eax
80105833:	8b 40 1c             	mov    0x1c(%eax),%eax
80105836:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105839:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010583d:	7e 30                	jle    8010586f <syscall+0x4c>
8010583f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105842:	83 f8 17             	cmp    $0x17,%eax
80105845:	77 28                	ja     8010586f <syscall+0x4c>
80105847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010584a:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105851:	85 c0                	test   %eax,%eax
80105853:	74 1a                	je     8010586f <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105855:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010585b:	8b 58 18             	mov    0x18(%eax),%ebx
8010585e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105861:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105868:	ff d0                	call   *%eax
8010586a:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010586d:	eb 3d                	jmp    801058ac <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010586f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105875:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105878:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010587e:	8b 40 10             	mov    0x10(%eax),%eax
80105881:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105884:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010588c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105890:	c7 04 24 af 8c 10 80 	movl   $0x80108caf,(%esp)
80105897:	e8 04 ab ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010589c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a2:	8b 40 18             	mov    0x18(%eax),%eax
801058a5:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801058ac:	83 c4 24             	add    $0x24,%esp
801058af:	5b                   	pop    %ebx
801058b0:	5d                   	pop    %ebp
801058b1:	c3                   	ret    
801058b2:	66 90                	xchg   %ax,%ax

801058b4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801058b4:	55                   	push   %ebp
801058b5:	89 e5                	mov    %esp,%ebp
801058b7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801058ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c1:	8b 45 08             	mov    0x8(%ebp),%eax
801058c4:	89 04 24             	mov    %eax,(%esp)
801058c7:	e8 90 fe ff ff       	call   8010575c <argint>
801058cc:	85 c0                	test   %eax,%eax
801058ce:	79 07                	jns    801058d7 <argfd+0x23>
    return -1;
801058d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d5:	eb 50                	jmp    80105927 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801058d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058da:	85 c0                	test   %eax,%eax
801058dc:	78 21                	js     801058ff <argfd+0x4b>
801058de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e1:	83 f8 0f             	cmp    $0xf,%eax
801058e4:	7f 19                	jg     801058ff <argfd+0x4b>
801058e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058ef:	83 c2 08             	add    $0x8,%edx
801058f2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058fd:	75 07                	jne    80105906 <argfd+0x52>
    return -1;
801058ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105904:	eb 21                	jmp    80105927 <argfd+0x73>
  if(pfd)
80105906:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010590a:	74 08                	je     80105914 <argfd+0x60>
    *pfd = fd;
8010590c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010590f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105912:	89 10                	mov    %edx,(%eax)
  if(pf)
80105914:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105918:	74 08                	je     80105922 <argfd+0x6e>
    *pf = f;
8010591a:	8b 45 10             	mov    0x10(%ebp),%eax
8010591d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105920:	89 10                	mov    %edx,(%eax)
  return 0;
80105922:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105927:	c9                   	leave  
80105928:	c3                   	ret    

80105929 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105929:	55                   	push   %ebp
8010592a:	89 e5                	mov    %esp,%ebp
8010592c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010592f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105936:	eb 30                	jmp    80105968 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105938:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010593e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105941:	83 c2 08             	add    $0x8,%edx
80105944:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105948:	85 c0                	test   %eax,%eax
8010594a:	75 18                	jne    80105964 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010594c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105952:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105955:	8d 4a 08             	lea    0x8(%edx),%ecx
80105958:	8b 55 08             	mov    0x8(%ebp),%edx
8010595b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010595f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105962:	eb 0f                	jmp    80105973 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105964:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105968:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010596c:	7e ca                	jle    80105938 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010596e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105973:	c9                   	leave  
80105974:	c3                   	ret    

80105975 <sys_dup>:

int
sys_dup(void)
{
80105975:	55                   	push   %ebp
80105976:	89 e5                	mov    %esp,%ebp
80105978:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010597b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010597e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105982:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105989:	00 
8010598a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105991:	e8 1e ff ff ff       	call   801058b4 <argfd>
80105996:	85 c0                	test   %eax,%eax
80105998:	79 07                	jns    801059a1 <sys_dup+0x2c>
    return -1;
8010599a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010599f:	eb 29                	jmp    801059ca <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a4:	89 04 24             	mov    %eax,(%esp)
801059a7:	e8 7d ff ff ff       	call   80105929 <fdalloc>
801059ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059b3:	79 07                	jns    801059bc <sys_dup+0x47>
    return -1;
801059b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ba:	eb 0e                	jmp    801059ca <sys_dup+0x55>
  filedup(f);
801059bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bf:	89 04 24             	mov    %eax,(%esp)
801059c2:	e8 dd b5 ff ff       	call   80100fa4 <filedup>
  return fd;
801059c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059ca:	c9                   	leave  
801059cb:	c3                   	ret    

801059cc <sys_read>:

int
sys_read(void)
{
801059cc:	55                   	push   %ebp
801059cd:	89 e5                	mov    %esp,%ebp
801059cf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801059d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059e0:	00 
801059e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059e8:	e8 c7 fe ff ff       	call   801058b4 <argfd>
801059ed:	85 c0                	test   %eax,%eax
801059ef:	78 35                	js     80105a26 <sys_read+0x5a>
801059f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059ff:	e8 58 fd ff ff       	call   8010575c <argint>
80105a04:	85 c0                	test   %eax,%eax
80105a06:	78 1e                	js     80105a26 <sys_read+0x5a>
80105a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a0f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a1d:	e8 68 fd ff ff       	call   8010578a <argptr>
80105a22:	85 c0                	test   %eax,%eax
80105a24:	79 07                	jns    80105a2d <sys_read+0x61>
    return -1;
80105a26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2b:	eb 19                	jmp    80105a46 <sys_read+0x7a>
  return fileread(f, p, n);
80105a2d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a30:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a36:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a3a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a3e:	89 04 24             	mov    %eax,(%esp)
80105a41:	e8 cb b6 ff ff       	call   80101111 <fileread>
}
80105a46:	c9                   	leave  
80105a47:	c3                   	ret    

80105a48 <sys_write>:

int
sys_write(void)
{
80105a48:	55                   	push   %ebp
80105a49:	89 e5                	mov    %esp,%ebp
80105a4b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a51:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a5c:	00 
80105a5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a64:	e8 4b fe ff ff       	call   801058b4 <argfd>
80105a69:	85 c0                	test   %eax,%eax
80105a6b:	78 35                	js     80105aa2 <sys_write+0x5a>
80105a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a70:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a74:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a7b:	e8 dc fc ff ff       	call   8010575c <argint>
80105a80:	85 c0                	test   %eax,%eax
80105a82:	78 1e                	js     80105aa2 <sys_write+0x5a>
80105a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a87:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a92:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a99:	e8 ec fc ff ff       	call   8010578a <argptr>
80105a9e:	85 c0                	test   %eax,%eax
80105aa0:	79 07                	jns    80105aa9 <sys_write+0x61>
    return -1;
80105aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa7:	eb 19                	jmp    80105ac2 <sys_write+0x7a>
  return filewrite(f, p, n);
80105aa9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105aac:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ab6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aba:	89 04 24             	mov    %eax,(%esp)
80105abd:	e8 0b b7 ff ff       	call   801011cd <filewrite>
}
80105ac2:	c9                   	leave  
80105ac3:	c3                   	ret    

80105ac4 <sys_close>:

int
sys_close(void)
{
80105ac4:	55                   	push   %ebp
80105ac5:	89 e5                	mov    %esp,%ebp
80105ac7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105aca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105adf:	e8 d0 fd ff ff       	call   801058b4 <argfd>
80105ae4:	85 c0                	test   %eax,%eax
80105ae6:	79 07                	jns    80105aef <sys_close+0x2b>
    return -1;
80105ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aed:	eb 24                	jmp    80105b13 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105aef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105af5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105af8:	83 c2 08             	add    $0x8,%edx
80105afb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b02:	00 
  fileclose(f);
80105b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b06:	89 04 24             	mov    %eax,(%esp)
80105b09:	e8 de b4 ff ff       	call   80100fec <fileclose>
  return 0;
80105b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b13:	c9                   	leave  
80105b14:	c3                   	ret    

80105b15 <sys_fstat>:

int
sys_fstat(void)
{
80105b15:	55                   	push   %ebp
80105b16:	89 e5                	mov    %esp,%ebp
80105b18:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b29:	00 
80105b2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b31:	e8 7e fd ff ff       	call   801058b4 <argfd>
80105b36:	85 c0                	test   %eax,%eax
80105b38:	78 1f                	js     80105b59 <sys_fstat+0x44>
80105b3a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b41:	00 
80105b42:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b45:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b50:	e8 35 fc ff ff       	call   8010578a <argptr>
80105b55:	85 c0                	test   %eax,%eax
80105b57:	79 07                	jns    80105b60 <sys_fstat+0x4b>
    return -1;
80105b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5e:	eb 12                	jmp    80105b72 <sys_fstat+0x5d>
  return filestat(f, st);
80105b60:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b66:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b6a:	89 04 24             	mov    %eax,(%esp)
80105b6d:	e8 50 b5 ff ff       	call   801010c2 <filestat>
}
80105b72:	c9                   	leave  
80105b73:	c3                   	ret    

80105b74 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b74:	55                   	push   %ebp
80105b75:	89 e5                	mov    %esp,%ebp
80105b77:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b7a:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b88:	e8 5f fc ff ff       	call   801057ec <argstr>
80105b8d:	85 c0                	test   %eax,%eax
80105b8f:	78 17                	js     80105ba8 <sys_link+0x34>
80105b91:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b9f:	e8 48 fc ff ff       	call   801057ec <argstr>
80105ba4:	85 c0                	test   %eax,%eax
80105ba6:	79 0a                	jns    80105bb2 <sys_link+0x3e>
    return -1;
80105ba8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bad:	e9 42 01 00 00       	jmp    80105cf4 <sys_link+0x180>

  begin_op();
80105bb2:	e8 11 d9 ff ff       	call   801034c8 <begin_op>
  if((ip = namei(old)) == 0){
80105bb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105bba:	89 04 24             	mov    %eax,(%esp)
80105bbd:	e8 c7 c8 ff ff       	call   80102489 <namei>
80105bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bc9:	75 0f                	jne    80105bda <sys_link+0x66>
    end_op();
80105bcb:	e8 7c d9 ff ff       	call   8010354c <end_op>
    return -1;
80105bd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd5:	e9 1a 01 00 00       	jmp    80105cf4 <sys_link+0x180>
  }

  ilock(ip);
80105bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bdd:	89 04 24             	mov    %eax,(%esp)
80105be0:	e8 f3 bc ff ff       	call   801018d8 <ilock>
  if(ip->type == T_DIR){
80105be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105bec:	66 83 f8 01          	cmp    $0x1,%ax
80105bf0:	75 1a                	jne    80105c0c <sys_link+0x98>
    iunlockput(ip);
80105bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf5:	89 04 24             	mov    %eax,(%esp)
80105bf8:	e8 65 bf ff ff       	call   80101b62 <iunlockput>
    end_op();
80105bfd:	e8 4a d9 ff ff       	call   8010354c <end_op>
    return -1;
80105c02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c07:	e9 e8 00 00 00       	jmp    80105cf4 <sys_link+0x180>
  }

  ip->nlink++;
80105c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c13:	8d 50 01             	lea    0x1(%eax),%edx
80105c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c19:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c20:	89 04 24             	mov    %eax,(%esp)
80105c23:	e8 ee ba ff ff       	call   80101716 <iupdate>
  iunlock(ip);
80105c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2b:	89 04 24             	mov    %eax,(%esp)
80105c2e:	e8 f9 bd ff ff       	call   80101a2c <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105c33:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c36:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c39:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c3d:	89 04 24             	mov    %eax,(%esp)
80105c40:	e8 66 c8 ff ff       	call   801024ab <nameiparent>
80105c45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c4c:	75 02                	jne    80105c50 <sys_link+0xdc>
    goto bad;
80105c4e:	eb 68                	jmp    80105cb8 <sys_link+0x144>
  ilock(dp);
80105c50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c53:	89 04 24             	mov    %eax,(%esp)
80105c56:	e8 7d bc ff ff       	call   801018d8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c5e:	8b 10                	mov    (%eax),%edx
80105c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c63:	8b 00                	mov    (%eax),%eax
80105c65:	39 c2                	cmp    %eax,%edx
80105c67:	75 20                	jne    80105c89 <sys_link+0x115>
80105c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6c:	8b 40 04             	mov    0x4(%eax),%eax
80105c6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c73:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7d:	89 04 24             	mov    %eax,(%esp)
80105c80:	e8 44 c5 ff ff       	call   801021c9 <dirlink>
80105c85:	85 c0                	test   %eax,%eax
80105c87:	79 0d                	jns    80105c96 <sys_link+0x122>
    iunlockput(dp);
80105c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8c:	89 04 24             	mov    %eax,(%esp)
80105c8f:	e8 ce be ff ff       	call   80101b62 <iunlockput>
    goto bad;
80105c94:	eb 22                	jmp    80105cb8 <sys_link+0x144>
  }
  iunlockput(dp);
80105c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c99:	89 04 24             	mov    %eax,(%esp)
80105c9c:	e8 c1 be ff ff       	call   80101b62 <iunlockput>
  iput(ip);
80105ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca4:	89 04 24             	mov    %eax,(%esp)
80105ca7:	e8 e5 bd ff ff       	call   80101a91 <iput>

  end_op();
80105cac:	e8 9b d8 ff ff       	call   8010354c <end_op>

  return 0;
80105cb1:	b8 00 00 00 00       	mov    $0x0,%eax
80105cb6:	eb 3c                	jmp    80105cf4 <sys_link+0x180>

bad:
  ilock(ip);
80105cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cbb:	89 04 24             	mov    %eax,(%esp)
80105cbe:	e8 15 bc ff ff       	call   801018d8 <ilock>
  ip->nlink--;
80105cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cca:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd0:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd7:	89 04 24             	mov    %eax,(%esp)
80105cda:	e8 37 ba ff ff       	call   80101716 <iupdate>
  iunlockput(ip);
80105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce2:	89 04 24             	mov    %eax,(%esp)
80105ce5:	e8 78 be ff ff       	call   80101b62 <iunlockput>
  end_op();
80105cea:	e8 5d d8 ff ff       	call   8010354c <end_op>
  return -1;
80105cef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cf4:	c9                   	leave  
80105cf5:	c3                   	ret    

80105cf6 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105cf6:	55                   	push   %ebp
80105cf7:	89 e5                	mov    %esp,%ebp
80105cf9:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105cfc:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d03:	eb 4b                	jmp    80105d50 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d08:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d0f:	00 
80105d10:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d14:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d17:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80105d1e:	89 04 24             	mov    %eax,(%esp)
80105d21:	e8 c5 c0 ff ff       	call   80101deb <readi>
80105d26:	83 f8 10             	cmp    $0x10,%eax
80105d29:	74 0c                	je     80105d37 <isdirempty+0x41>
      panic("isdirempty: readi");
80105d2b:	c7 04 24 cb 8c 10 80 	movl   $0x80108ccb,(%esp)
80105d32:	e8 03 a8 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105d37:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d3b:	66 85 c0             	test   %ax,%ax
80105d3e:	74 07                	je     80105d47 <isdirempty+0x51>
      return 0;
80105d40:	b8 00 00 00 00       	mov    $0x0,%eax
80105d45:	eb 1b                	jmp    80105d62 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4a:	83 c0 10             	add    $0x10,%eax
80105d4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d53:	8b 45 08             	mov    0x8(%ebp),%eax
80105d56:	8b 40 18             	mov    0x18(%eax),%eax
80105d59:	39 c2                	cmp    %eax,%edx
80105d5b:	72 a8                	jb     80105d05 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105d5d:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d62:	c9                   	leave  
80105d63:	c3                   	ret    

80105d64 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d64:	55                   	push   %ebp
80105d65:	89 e5                	mov    %esp,%ebp
80105d67:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d6a:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d78:	e8 6f fa ff ff       	call   801057ec <argstr>
80105d7d:	85 c0                	test   %eax,%eax
80105d7f:	79 0a                	jns    80105d8b <sys_unlink+0x27>
    return -1;
80105d81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d86:	e9 af 01 00 00       	jmp    80105f3a <sys_unlink+0x1d6>

  begin_op();
80105d8b:	e8 38 d7 ff ff       	call   801034c8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d90:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d93:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d96:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d9a:	89 04 24             	mov    %eax,(%esp)
80105d9d:	e8 09 c7 ff ff       	call   801024ab <nameiparent>
80105da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105da5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105da9:	75 0f                	jne    80105dba <sys_unlink+0x56>
    end_op();
80105dab:	e8 9c d7 ff ff       	call   8010354c <end_op>
    return -1;
80105db0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db5:	e9 80 01 00 00       	jmp    80105f3a <sys_unlink+0x1d6>
  }

  ilock(dp);
80105dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbd:	89 04 24             	mov    %eax,(%esp)
80105dc0:	e8 13 bb ff ff       	call   801018d8 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105dc5:	c7 44 24 04 dd 8c 10 	movl   $0x80108cdd,0x4(%esp)
80105dcc:	80 
80105dcd:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105dd0:	89 04 24             	mov    %eax,(%esp)
80105dd3:	e8 06 c3 ff ff       	call   801020de <namecmp>
80105dd8:	85 c0                	test   %eax,%eax
80105dda:	0f 84 45 01 00 00    	je     80105f25 <sys_unlink+0x1c1>
80105de0:	c7 44 24 04 df 8c 10 	movl   $0x80108cdf,0x4(%esp)
80105de7:	80 
80105de8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105deb:	89 04 24             	mov    %eax,(%esp)
80105dee:	e8 eb c2 ff ff       	call   801020de <namecmp>
80105df3:	85 c0                	test   %eax,%eax
80105df5:	0f 84 2a 01 00 00    	je     80105f25 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105dfb:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e02:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e05:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0c:	89 04 24             	mov    %eax,(%esp)
80105e0f:	e8 ec c2 ff ff       	call   80102100 <dirlookup>
80105e14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e1b:	75 05                	jne    80105e22 <sys_unlink+0xbe>
    goto bad;
80105e1d:	e9 03 01 00 00       	jmp    80105f25 <sys_unlink+0x1c1>
  ilock(ip);
80105e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e25:	89 04 24             	mov    %eax,(%esp)
80105e28:	e8 ab ba ff ff       	call   801018d8 <ilock>

  if(ip->nlink < 1)
80105e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e30:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e34:	66 85 c0             	test   %ax,%ax
80105e37:	7f 0c                	jg     80105e45 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105e39:	c7 04 24 e2 8c 10 80 	movl   $0x80108ce2,(%esp)
80105e40:	e8 f5 a6 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e48:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e4c:	66 83 f8 01          	cmp    $0x1,%ax
80105e50:	75 1f                	jne    80105e71 <sys_unlink+0x10d>
80105e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e55:	89 04 24             	mov    %eax,(%esp)
80105e58:	e8 99 fe ff ff       	call   80105cf6 <isdirempty>
80105e5d:	85 c0                	test   %eax,%eax
80105e5f:	75 10                	jne    80105e71 <sys_unlink+0x10d>
    iunlockput(ip);
80105e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e64:	89 04 24             	mov    %eax,(%esp)
80105e67:	e8 f6 bc ff ff       	call   80101b62 <iunlockput>
    goto bad;
80105e6c:	e9 b4 00 00 00       	jmp    80105f25 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105e71:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e78:	00 
80105e79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e80:	00 
80105e81:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e84:	89 04 24             	mov    %eax,(%esp)
80105e87:	e8 8a f5 ff ff       	call   80105416 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e8c:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e8f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e96:	00 
80105e97:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e9b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea5:	89 04 24             	mov    %eax,(%esp)
80105ea8:	e8 a2 c0 ff ff       	call   80101f4f <writei>
80105ead:	83 f8 10             	cmp    $0x10,%eax
80105eb0:	74 0c                	je     80105ebe <sys_unlink+0x15a>
    panic("unlink: writei");
80105eb2:	c7 04 24 f4 8c 10 80 	movl   $0x80108cf4,(%esp)
80105eb9:	e8 7c a6 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ec5:	66 83 f8 01          	cmp    $0x1,%ax
80105ec9:	75 1c                	jne    80105ee7 <sys_unlink+0x183>
    dp->nlink--;
80105ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ece:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ed2:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edf:	89 04 24             	mov    %eax,(%esp)
80105ee2:	e8 2f b8 ff ff       	call   80101716 <iupdate>
  }
  iunlockput(dp);
80105ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eea:	89 04 24             	mov    %eax,(%esp)
80105eed:	e8 70 bc ff ff       	call   80101b62 <iunlockput>

  ip->nlink--;
80105ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ef9:	8d 50 ff             	lea    -0x1(%eax),%edx
80105efc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eff:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f06:	89 04 24             	mov    %eax,(%esp)
80105f09:	e8 08 b8 ff ff       	call   80101716 <iupdate>
  iunlockput(ip);
80105f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f11:	89 04 24             	mov    %eax,(%esp)
80105f14:	e8 49 bc ff ff       	call   80101b62 <iunlockput>

  end_op();
80105f19:	e8 2e d6 ff ff       	call   8010354c <end_op>

  return 0;
80105f1e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f23:	eb 15                	jmp    80105f3a <sys_unlink+0x1d6>

bad:
  iunlockput(dp);
80105f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f28:	89 04 24             	mov    %eax,(%esp)
80105f2b:	e8 32 bc ff ff       	call   80101b62 <iunlockput>
  end_op();
80105f30:	e8 17 d6 ff ff       	call   8010354c <end_op>
  return -1;
80105f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f3a:	c9                   	leave  
80105f3b:	c3                   	ret    

80105f3c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f3c:	55                   	push   %ebp
80105f3d:	89 e5                	mov    %esp,%ebp
80105f3f:	83 ec 48             	sub    $0x48,%esp
80105f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f45:	8b 55 10             	mov    0x10(%ebp),%edx
80105f48:	8b 45 14             	mov    0x14(%ebp),%eax
80105f4b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f4f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f53:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f57:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f61:	89 04 24             	mov    %eax,(%esp)
80105f64:	e8 42 c5 ff ff       	call   801024ab <nameiparent>
80105f69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f70:	75 0a                	jne    80105f7c <create+0x40>
    return 0;
80105f72:	b8 00 00 00 00       	mov    $0x0,%eax
80105f77:	e9 7e 01 00 00       	jmp    801060fa <create+0x1be>
  ilock(dp);
80105f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f7f:	89 04 24             	mov    %eax,(%esp)
80105f82:	e8 51 b9 ff ff       	call   801018d8 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f87:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f8e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f91:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f98:	89 04 24             	mov    %eax,(%esp)
80105f9b:	e8 60 c1 ff ff       	call   80102100 <dirlookup>
80105fa0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fa3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa7:	74 47                	je     80105ff0 <create+0xb4>
    iunlockput(dp);
80105fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fac:	89 04 24             	mov    %eax,(%esp)
80105faf:	e8 ae bb ff ff       	call   80101b62 <iunlockput>
    ilock(ip);
80105fb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb7:	89 04 24             	mov    %eax,(%esp)
80105fba:	e8 19 b9 ff ff       	call   801018d8 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105fbf:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105fc4:	75 15                	jne    80105fdb <create+0x9f>
80105fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fcd:	66 83 f8 02          	cmp    $0x2,%ax
80105fd1:	75 08                	jne    80105fdb <create+0x9f>
      return ip;
80105fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd6:	e9 1f 01 00 00       	jmp    801060fa <create+0x1be>
    iunlockput(ip);
80105fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fde:	89 04 24             	mov    %eax,(%esp)
80105fe1:	e8 7c bb ff ff       	call   80101b62 <iunlockput>
    return 0;
80105fe6:	b8 00 00 00 00       	mov    $0x0,%eax
80105feb:	e9 0a 01 00 00       	jmp    801060fa <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105ff0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff7:	8b 00                	mov    (%eax),%eax
80105ff9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ffd:	89 04 24             	mov    %eax,(%esp)
80106000:	e8 3c b6 ff ff       	call   80101641 <ialloc>
80106005:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106008:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010600c:	75 0c                	jne    8010601a <create+0xde>
    panic("create: ialloc");
8010600e:	c7 04 24 03 8d 10 80 	movl   $0x80108d03,(%esp)
80106015:	e8 20 a5 ff ff       	call   8010053a <panic>

  ilock(ip);
8010601a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601d:	89 04 24             	mov    %eax,(%esp)
80106020:	e8 b3 b8 ff ff       	call   801018d8 <ilock>
  ip->major = major;
80106025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106028:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010602c:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106033:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106037:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010603b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603e:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106047:	89 04 24             	mov    %eax,(%esp)
8010604a:	e8 c7 b6 ff ff       	call   80101716 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010604f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106054:	75 6a                	jne    801060c0 <create+0x184>
    dp->nlink++;  // for ".."
80106056:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106059:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010605d:	8d 50 01             	lea    0x1(%eax),%edx
80106060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106063:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606a:	89 04 24             	mov    %eax,(%esp)
8010606d:	e8 a4 b6 ff ff       	call   80101716 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106072:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106075:	8b 40 04             	mov    0x4(%eax),%eax
80106078:	89 44 24 08          	mov    %eax,0x8(%esp)
8010607c:	c7 44 24 04 dd 8c 10 	movl   $0x80108cdd,0x4(%esp)
80106083:	80 
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	89 04 24             	mov    %eax,(%esp)
8010608a:	e8 3a c1 ff ff       	call   801021c9 <dirlink>
8010608f:	85 c0                	test   %eax,%eax
80106091:	78 21                	js     801060b4 <create+0x178>
80106093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106096:	8b 40 04             	mov    0x4(%eax),%eax
80106099:	89 44 24 08          	mov    %eax,0x8(%esp)
8010609d:	c7 44 24 04 df 8c 10 	movl   $0x80108cdf,0x4(%esp)
801060a4:	80 
801060a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a8:	89 04 24             	mov    %eax,(%esp)
801060ab:	e8 19 c1 ff ff       	call   801021c9 <dirlink>
801060b0:	85 c0                	test   %eax,%eax
801060b2:	79 0c                	jns    801060c0 <create+0x184>
      panic("create dots");
801060b4:	c7 04 24 12 8d 10 80 	movl   $0x80108d12,(%esp)
801060bb:	e8 7a a4 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801060c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c3:	8b 40 04             	mov    0x4(%eax),%eax
801060c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801060ca:	8d 45 de             	lea    -0x22(%ebp),%eax
801060cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801060d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d4:	89 04 24             	mov    %eax,(%esp)
801060d7:	e8 ed c0 ff ff       	call   801021c9 <dirlink>
801060dc:	85 c0                	test   %eax,%eax
801060de:	79 0c                	jns    801060ec <create+0x1b0>
    panic("create: dirlink");
801060e0:	c7 04 24 1e 8d 10 80 	movl   $0x80108d1e,(%esp)
801060e7:	e8 4e a4 ff ff       	call   8010053a <panic>

  iunlockput(dp);
801060ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ef:	89 04 24             	mov    %eax,(%esp)
801060f2:	e8 6b ba ff ff       	call   80101b62 <iunlockput>

  return ip;
801060f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060fa:	c9                   	leave  
801060fb:	c3                   	ret    

801060fc <sys_open>:

int
sys_open(void)
{
801060fc:	55                   	push   %ebp
801060fd:	89 e5                	mov    %esp,%ebp
801060ff:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106102:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106105:	89 44 24 04          	mov    %eax,0x4(%esp)
80106109:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106110:	e8 d7 f6 ff ff       	call   801057ec <argstr>
80106115:	85 c0                	test   %eax,%eax
80106117:	78 17                	js     80106130 <sys_open+0x34>
80106119:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010611c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106120:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106127:	e8 30 f6 ff ff       	call   8010575c <argint>
8010612c:	85 c0                	test   %eax,%eax
8010612e:	79 0a                	jns    8010613a <sys_open+0x3e>
    return -1;
80106130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106135:	e9 5c 01 00 00       	jmp    80106296 <sys_open+0x19a>

  begin_op();
8010613a:	e8 89 d3 ff ff       	call   801034c8 <begin_op>

  if(omode & O_CREATE){
8010613f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106142:	25 00 02 00 00       	and    $0x200,%eax
80106147:	85 c0                	test   %eax,%eax
80106149:	74 3b                	je     80106186 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010614b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010614e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106155:	00 
80106156:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010615d:	00 
8010615e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106165:	00 
80106166:	89 04 24             	mov    %eax,(%esp)
80106169:	e8 ce fd ff ff       	call   80105f3c <create>
8010616e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106171:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106175:	75 6b                	jne    801061e2 <sys_open+0xe6>
      end_op();
80106177:	e8 d0 d3 ff ff       	call   8010354c <end_op>
      return -1;
8010617c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106181:	e9 10 01 00 00       	jmp    80106296 <sys_open+0x19a>
    }
  } else {
    if((ip = namei(path)) == 0){
80106186:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106189:	89 04 24             	mov    %eax,(%esp)
8010618c:	e8 f8 c2 ff ff       	call   80102489 <namei>
80106191:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106194:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106198:	75 0f                	jne    801061a9 <sys_open+0xad>
      end_op();
8010619a:	e8 ad d3 ff ff       	call   8010354c <end_op>
      return -1;
8010619f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a4:	e9 ed 00 00 00       	jmp    80106296 <sys_open+0x19a>
    }
    ilock(ip);
801061a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ac:	89 04 24             	mov    %eax,(%esp)
801061af:	e8 24 b7 ff ff       	call   801018d8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801061b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061bb:	66 83 f8 01          	cmp    $0x1,%ax
801061bf:	75 21                	jne    801061e2 <sys_open+0xe6>
801061c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061c4:	85 c0                	test   %eax,%eax
801061c6:	74 1a                	je     801061e2 <sys_open+0xe6>
      iunlockput(ip);
801061c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cb:	89 04 24             	mov    %eax,(%esp)
801061ce:	e8 8f b9 ff ff       	call   80101b62 <iunlockput>
      end_op();
801061d3:	e8 74 d3 ff ff       	call   8010354c <end_op>
      return -1;
801061d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061dd:	e9 b4 00 00 00       	jmp    80106296 <sys_open+0x19a>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801061e2:	e8 5d ad ff ff       	call   80100f44 <filealloc>
801061e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061ee:	74 14                	je     80106204 <sys_open+0x108>
801061f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f3:	89 04 24             	mov    %eax,(%esp)
801061f6:	e8 2e f7 ff ff       	call   80105929 <fdalloc>
801061fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801061fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106202:	79 28                	jns    8010622c <sys_open+0x130>
    if(f)
80106204:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106208:	74 0b                	je     80106215 <sys_open+0x119>
      fileclose(f);
8010620a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620d:	89 04 24             	mov    %eax,(%esp)
80106210:	e8 d7 ad ff ff       	call   80100fec <fileclose>
    iunlockput(ip);
80106215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106218:	89 04 24             	mov    %eax,(%esp)
8010621b:	e8 42 b9 ff ff       	call   80101b62 <iunlockput>
    end_op();
80106220:	e8 27 d3 ff ff       	call   8010354c <end_op>
    return -1;
80106225:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622a:	eb 6a                	jmp    80106296 <sys_open+0x19a>
  }
  iunlock(ip);
8010622c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622f:	89 04 24             	mov    %eax,(%esp)
80106232:	e8 f5 b7 ff ff       	call   80101a2c <iunlock>
  end_op();
80106237:	e8 10 d3 ff ff       	call   8010354c <end_op>

  f->type = FD_INODE;
8010623c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106245:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106248:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010624b:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010624e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106251:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010625b:	83 e0 01             	and    $0x1,%eax
8010625e:	85 c0                	test   %eax,%eax
80106260:	0f 94 c0             	sete   %al
80106263:	89 c2                	mov    %eax,%edx
80106265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106268:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010626b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010626e:	83 e0 01             	and    $0x1,%eax
80106271:	85 c0                	test   %eax,%eax
80106273:	75 0a                	jne    8010627f <sys_open+0x183>
80106275:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106278:	83 e0 02             	and    $0x2,%eax
8010627b:	85 c0                	test   %eax,%eax
8010627d:	74 07                	je     80106286 <sys_open+0x18a>
8010627f:	b8 01 00 00 00       	mov    $0x1,%eax
80106284:	eb 05                	jmp    8010628b <sys_open+0x18f>
80106286:	b8 00 00 00 00       	mov    $0x0,%eax
8010628b:	89 c2                	mov    %eax,%edx
8010628d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106290:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106293:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106296:	c9                   	leave  
80106297:	c3                   	ret    

80106298 <sys_mkdir>:

int
sys_mkdir(void)
{
80106298:	55                   	push   %ebp
80106299:	89 e5                	mov    %esp,%ebp
8010629b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010629e:	e8 25 d2 ff ff       	call   801034c8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801062a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801062aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062b1:	e8 36 f5 ff ff       	call   801057ec <argstr>
801062b6:	85 c0                	test   %eax,%eax
801062b8:	78 2c                	js     801062e6 <sys_mkdir+0x4e>
801062ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062c4:	00 
801062c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062cc:	00 
801062cd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801062d4:	00 
801062d5:	89 04 24             	mov    %eax,(%esp)
801062d8:	e8 5f fc ff ff       	call   80105f3c <create>
801062dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062e4:	75 0c                	jne    801062f2 <sys_mkdir+0x5a>
    end_op();
801062e6:	e8 61 d2 ff ff       	call   8010354c <end_op>
    return -1;
801062eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f0:	eb 15                	jmp    80106307 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801062f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f5:	89 04 24             	mov    %eax,(%esp)
801062f8:	e8 65 b8 ff ff       	call   80101b62 <iunlockput>
  end_op();
801062fd:	e8 4a d2 ff ff       	call   8010354c <end_op>
  return 0;
80106302:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106307:	c9                   	leave  
80106308:	c3                   	ret    

80106309 <sys_mknod>:

int
sys_mknod(void)
{
80106309:	55                   	push   %ebp
8010630a:	89 e5                	mov    %esp,%ebp
8010630c:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010630f:	e8 b4 d1 ff ff       	call   801034c8 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106314:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106317:	89 44 24 04          	mov    %eax,0x4(%esp)
8010631b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106322:	e8 c5 f4 ff ff       	call   801057ec <argstr>
80106327:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010632a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010632e:	78 5e                	js     8010638e <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106330:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106333:	89 44 24 04          	mov    %eax,0x4(%esp)
80106337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010633e:	e8 19 f4 ff ff       	call   8010575c <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106343:	85 c0                	test   %eax,%eax
80106345:	78 47                	js     8010638e <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106347:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010634a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010634e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106355:	e8 02 f4 ff ff       	call   8010575c <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010635a:	85 c0                	test   %eax,%eax
8010635c:	78 30                	js     8010638e <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010635e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106361:	0f bf c8             	movswl %ax,%ecx
80106364:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106367:	0f bf d0             	movswl %ax,%edx
8010636a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010636d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106371:	89 54 24 08          	mov    %edx,0x8(%esp)
80106375:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010637c:	00 
8010637d:	89 04 24             	mov    %eax,(%esp)
80106380:	e8 b7 fb ff ff       	call   80105f3c <create>
80106385:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106388:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010638c:	75 0c                	jne    8010639a <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010638e:	e8 b9 d1 ff ff       	call   8010354c <end_op>
    return -1;
80106393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106398:	eb 15                	jmp    801063af <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010639a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639d:	89 04 24             	mov    %eax,(%esp)
801063a0:	e8 bd b7 ff ff       	call   80101b62 <iunlockput>
  end_op();
801063a5:	e8 a2 d1 ff ff       	call   8010354c <end_op>
  return 0;
801063aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063af:	c9                   	leave  
801063b0:	c3                   	ret    

801063b1 <sys_chdir>:

int
sys_chdir(void)
{
801063b1:	55                   	push   %ebp
801063b2:	89 e5                	mov    %esp,%ebp
801063b4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063b7:	e8 0c d1 ff ff       	call   801034c8 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801063bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801063c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063ca:	e8 1d f4 ff ff       	call   801057ec <argstr>
801063cf:	85 c0                	test   %eax,%eax
801063d1:	78 14                	js     801063e7 <sys_chdir+0x36>
801063d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d6:	89 04 24             	mov    %eax,(%esp)
801063d9:	e8 ab c0 ff ff       	call   80102489 <namei>
801063de:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063e5:	75 0c                	jne    801063f3 <sys_chdir+0x42>
    end_op();
801063e7:	e8 60 d1 ff ff       	call   8010354c <end_op>
    return -1;
801063ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f1:	eb 61                	jmp    80106454 <sys_chdir+0xa3>
  }
  ilock(ip);
801063f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f6:	89 04 24             	mov    %eax,(%esp)
801063f9:	e8 da b4 ff ff       	call   801018d8 <ilock>
  if(ip->type != T_DIR){
801063fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106401:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106405:	66 83 f8 01          	cmp    $0x1,%ax
80106409:	74 17                	je     80106422 <sys_chdir+0x71>
    iunlockput(ip);
8010640b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640e:	89 04 24             	mov    %eax,(%esp)
80106411:	e8 4c b7 ff ff       	call   80101b62 <iunlockput>
    end_op();
80106416:	e8 31 d1 ff ff       	call   8010354c <end_op>
    return -1;
8010641b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106420:	eb 32                	jmp    80106454 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106425:	89 04 24             	mov    %eax,(%esp)
80106428:	e8 ff b5 ff ff       	call   80101a2c <iunlock>
  iput(proc->cwd);
8010642d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106433:	8b 40 68             	mov    0x68(%eax),%eax
80106436:	89 04 24             	mov    %eax,(%esp)
80106439:	e8 53 b6 ff ff       	call   80101a91 <iput>
  end_op();
8010643e:	e8 09 d1 ff ff       	call   8010354c <end_op>
  proc->cwd = ip;
80106443:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106449:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010644c:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010644f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106454:	c9                   	leave  
80106455:	c3                   	ret    

80106456 <sys_exec>:

int
sys_exec(void)
{
80106456:	55                   	push   %ebp
80106457:	89 e5                	mov    %esp,%ebp
80106459:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010645f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106462:	89 44 24 04          	mov    %eax,0x4(%esp)
80106466:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010646d:	e8 7a f3 ff ff       	call   801057ec <argstr>
80106472:	85 c0                	test   %eax,%eax
80106474:	78 1a                	js     80106490 <sys_exec+0x3a>
80106476:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010647c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106480:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106487:	e8 d0 f2 ff ff       	call   8010575c <argint>
8010648c:	85 c0                	test   %eax,%eax
8010648e:	79 0a                	jns    8010649a <sys_exec+0x44>
    return -1;
80106490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106495:	e9 c8 00 00 00       	jmp    80106562 <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
8010649a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801064a1:	00 
801064a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801064a9:	00 
801064aa:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064b0:	89 04 24             	mov    %eax,(%esp)
801064b3:	e8 5e ef ff ff       	call   80105416 <memset>
  for(i=0;; i++){
801064b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801064bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c2:	83 f8 1f             	cmp    $0x1f,%eax
801064c5:	76 0a                	jbe    801064d1 <sys_exec+0x7b>
      return -1;
801064c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cc:	e9 91 00 00 00       	jmp    80106562 <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801064d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d4:	c1 e0 02             	shl    $0x2,%eax
801064d7:	89 c2                	mov    %eax,%edx
801064d9:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064df:	01 c2                	add    %eax,%edx
801064e1:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801064e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801064eb:	89 14 24             	mov    %edx,(%esp)
801064ee:	e8 cd f1 ff ff       	call   801056c0 <fetchint>
801064f3:	85 c0                	test   %eax,%eax
801064f5:	79 07                	jns    801064fe <sys_exec+0xa8>
      return -1;
801064f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fc:	eb 64                	jmp    80106562 <sys_exec+0x10c>
    if(uarg == 0){
801064fe:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106504:	85 c0                	test   %eax,%eax
80106506:	75 26                	jne    8010652e <sys_exec+0xd8>
      argv[i] = 0;
80106508:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106512:	00 00 00 00 
      break;
80106516:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651a:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106520:	89 54 24 04          	mov    %edx,0x4(%esp)
80106524:	89 04 24             	mov    %eax,(%esp)
80106527:	e8 e0 a5 ff ff       	call   80100b0c <exec>
8010652c:	eb 34                	jmp    80106562 <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010652e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106534:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106537:	c1 e2 02             	shl    $0x2,%edx
8010653a:	01 c2                	add    %eax,%edx
8010653c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106542:	89 54 24 04          	mov    %edx,0x4(%esp)
80106546:	89 04 24             	mov    %eax,(%esp)
80106549:	e8 ac f1 ff ff       	call   801056fa <fetchstr>
8010654e:	85 c0                	test   %eax,%eax
80106550:	79 07                	jns    80106559 <sys_exec+0x103>
      return -1;
80106552:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106557:	eb 09                	jmp    80106562 <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106559:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010655d:	e9 5d ff ff ff       	jmp    801064bf <sys_exec+0x69>
  return exec(path, argv);
}
80106562:	c9                   	leave  
80106563:	c3                   	ret    

80106564 <sys_pipe>:

int
sys_pipe(void)
{
80106564:	55                   	push   %ebp
80106565:	89 e5                	mov    %esp,%ebp
80106567:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010656a:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106571:	00 
80106572:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106575:	89 44 24 04          	mov    %eax,0x4(%esp)
80106579:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106580:	e8 05 f2 ff ff       	call   8010578a <argptr>
80106585:	85 c0                	test   %eax,%eax
80106587:	79 0a                	jns    80106593 <sys_pipe+0x2f>
    return -1;
80106589:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658e:	e9 9b 00 00 00       	jmp    8010662e <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106593:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106596:	89 44 24 04          	mov    %eax,0x4(%esp)
8010659a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010659d:	89 04 24             	mov    %eax,(%esp)
801065a0:	e8 37 da ff ff       	call   80103fdc <pipealloc>
801065a5:	85 c0                	test   %eax,%eax
801065a7:	79 07                	jns    801065b0 <sys_pipe+0x4c>
    return -1;
801065a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ae:	eb 7e                	jmp    8010662e <sys_pipe+0xca>
  fd0 = -1;
801065b0:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801065b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065ba:	89 04 24             	mov    %eax,(%esp)
801065bd:	e8 67 f3 ff ff       	call   80105929 <fdalloc>
801065c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065c9:	78 14                	js     801065df <sys_pipe+0x7b>
801065cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ce:	89 04 24             	mov    %eax,(%esp)
801065d1:	e8 53 f3 ff ff       	call   80105929 <fdalloc>
801065d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065dd:	79 37                	jns    80106616 <sys_pipe+0xb2>
    if(fd0 >= 0)
801065df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065e3:	78 14                	js     801065f9 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801065e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065ee:	83 c2 08             	add    $0x8,%edx
801065f1:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801065f8:	00 
    fileclose(rf);
801065f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065fc:	89 04 24             	mov    %eax,(%esp)
801065ff:	e8 e8 a9 ff ff       	call   80100fec <fileclose>
    fileclose(wf);
80106604:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106607:	89 04 24             	mov    %eax,(%esp)
8010660a:	e8 dd a9 ff ff       	call   80100fec <fileclose>
    return -1;
8010660f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106614:	eb 18                	jmp    8010662e <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106616:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106619:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010661c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010661e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106621:	8d 50 04             	lea    0x4(%eax),%edx
80106624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106627:	89 02                	mov    %eax,(%edx)
  return 0;
80106629:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010662e:	c9                   	leave  
8010662f:	c3                   	ret    

80106630 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106630:	55                   	push   %ebp
80106631:	89 e5                	mov    %esp,%ebp
80106633:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106636:	e8 4f e0 ff ff       	call   8010468a <fork>
}
8010663b:	c9                   	leave  
8010663c:	c3                   	ret    

8010663d <sys_exit>:

int
sys_exit(void)
{
8010663d:	55                   	push   %ebp
8010663e:	89 e5                	mov    %esp,%ebp
80106640:	83 ec 08             	sub    $0x8,%esp
  exit();
80106643:	e8 bd e1 ff ff       	call   80104805 <exit>
  return 0;  // not reached
80106648:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010664d:	c9                   	leave  
8010664e:	c3                   	ret    

8010664f <sys_wait>:

int
sys_wait(void)
{
8010664f:	55                   	push   %ebp
80106650:	89 e5                	mov    %esp,%ebp
80106652:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106655:	e8 cd e2 ff ff       	call   80104927 <wait>
}
8010665a:	c9                   	leave  
8010665b:	c3                   	ret    

8010665c <sys_kill>:

int
sys_kill(void)
{
8010665c:	55                   	push   %ebp
8010665d:	89 e5                	mov    %esp,%ebp
8010665f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106662:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106665:	89 44 24 04          	mov    %eax,0x4(%esp)
80106669:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106670:	e8 e7 f0 ff ff       	call   8010575c <argint>
80106675:	85 c0                	test   %eax,%eax
80106677:	79 07                	jns    80106680 <sys_kill+0x24>
    return -1;
80106679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010667e:	eb 0b                	jmp    8010668b <sys_kill+0x2f>
  return kill(pid);
80106680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106683:	89 04 24             	mov    %eax,(%esp)
80106686:	e8 b2 e7 ff ff       	call   80104e3d <kill>
}
8010668b:	c9                   	leave  
8010668c:	c3                   	ret    

8010668d <sys_getpid>:

int
sys_getpid(void)
{
8010668d:	55                   	push   %ebp
8010668e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106690:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106696:	8b 40 10             	mov    0x10(%eax),%eax
}
80106699:	5d                   	pop    %ebp
8010669a:	c3                   	ret    

8010669b <sys_sbrk>:

int
sys_sbrk(void)
{
8010669b:	55                   	push   %ebp
8010669c:	89 e5                	mov    %esp,%ebp
8010669e:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801066a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801066a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066af:	e8 a8 f0 ff ff       	call   8010575c <argint>
801066b4:	85 c0                	test   %eax,%eax
801066b6:	79 07                	jns    801066bf <sys_sbrk+0x24>
    return -1;
801066b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066bd:	eb 24                	jmp    801066e3 <sys_sbrk+0x48>
  addr = proc->sz;
801066bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066c5:	8b 00                	mov    (%eax),%eax
801066c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801066ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066cd:	89 04 24             	mov    %eax,(%esp)
801066d0:	e8 10 df ff ff       	call   801045e5 <growproc>
801066d5:	85 c0                	test   %eax,%eax
801066d7:	79 07                	jns    801066e0 <sys_sbrk+0x45>
    return -1;
801066d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066de:	eb 03                	jmp    801066e3 <sys_sbrk+0x48>
  return addr;
801066e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066e3:	c9                   	leave  
801066e4:	c3                   	ret    

801066e5 <sys_sleep>:

int
sys_sleep(void)
{
801066e5:	55                   	push   %ebp
801066e6:	89 e5                	mov    %esp,%ebp
801066e8:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801066eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801066f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066f9:	e8 5e f0 ff ff       	call   8010575c <argint>
801066fe:	85 c0                	test   %eax,%eax
80106700:	79 07                	jns    80106709 <sys_sleep+0x24>
    return -1;
80106702:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106707:	eb 6c                	jmp    80106775 <sys_sleep+0x90>
  acquire(&tickslock);
80106709:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106710:	e8 aa ea ff ff       	call   801051bf <acquire>
  ticks0 = ticks;
80106715:	a1 e0 50 11 80       	mov    0x801150e0,%eax
8010671a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010671d:	eb 34                	jmp    80106753 <sys_sleep+0x6e>
    if(proc->killed){
8010671f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106725:	8b 40 24             	mov    0x24(%eax),%eax
80106728:	85 c0                	test   %eax,%eax
8010672a:	74 13                	je     8010673f <sys_sleep+0x5a>
      release(&tickslock);
8010672c:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106733:	e8 e9 ea ff ff       	call   80105221 <release>
      return -1;
80106738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010673d:	eb 36                	jmp    80106775 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010673f:	c7 44 24 04 a0 48 11 	movl   $0x801148a0,0x4(%esp)
80106746:	80 
80106747:	c7 04 24 e0 50 11 80 	movl   $0x801150e0,(%esp)
8010674e:	e8 9e e4 ff ff       	call   80104bf1 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106753:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106758:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010675b:	89 c2                	mov    %eax,%edx
8010675d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106760:	39 c2                	cmp    %eax,%edx
80106762:	72 bb                	jb     8010671f <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106764:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
8010676b:	e8 b1 ea ff ff       	call   80105221 <release>
  return 0;
80106770:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106775:	c9                   	leave  
80106776:	c3                   	ret    

80106777 <sys_join>:


int
sys_join(void)
{
80106777:	55                   	push   %ebp
80106778:	89 e5                	mov    %esp,%ebp
8010677a:	83 ec 28             	sub    $0x28,%esp
  void **stack;
  int stackArg;
  stackArg = argint(0, &stackArg);
8010677d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106780:	89 44 24 04          	mov    %eax,0x4(%esp)
80106784:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010678b:	e8 cc ef ff ff       	call   8010575c <argint>
80106790:	89 45 f0             	mov    %eax,-0x10(%ebp)
  stack = (void**) stackArg;
80106793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106796:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return join(stack);
80106799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679c:	89 04 24             	mov    %eax,(%esp)
8010679f:	e8 51 e5 ff ff       	call   80104cf5 <join>
}
801067a4:	c9                   	leave  
801067a5:	c3                   	ret    

801067a6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801067a6:	55                   	push   %ebp
801067a7:	89 e5                	mov    %esp,%ebp
801067a9:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801067ac:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
801067b3:	e8 07 ea ff ff       	call   801051bf <acquire>
  xticks = ticks;
801067b8:	a1 e0 50 11 80       	mov    0x801150e0,%eax
801067bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801067c0:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
801067c7:	e8 55 ea ff ff       	call   80105221 <release>
  return xticks;
801067cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067cf:	c9                   	leave  
801067d0:	c3                   	ret    

801067d1 <sys_clone>:

int
sys_clone(void)
{
801067d1:	55                   	push   %ebp
801067d2:	89 e5                	mov    %esp,%ebp
801067d4:	83 ec 28             	sub    $0x28,%esp
  void * fcn,* arg,* stack;
  if(argptr(0, (void *)&fcn, sizeof(void *)) < 0)
801067d7:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801067de:	00 
801067df:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801067e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067ed:	e8 98 ef ff ff       	call   8010578a <argptr>
801067f2:	85 c0                	test   %eax,%eax
801067f4:	79 07                	jns    801067fd <sys_clone+0x2c>
    return -1;
801067f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067fb:	eb 65                	jmp    80106862 <sys_clone+0x91>

  if(argptr(1, (void *)&arg, sizeof(void *)) < 0)
801067fd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106804:	00 
80106805:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106808:	89 44 24 04          	mov    %eax,0x4(%esp)
8010680c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106813:	e8 72 ef ff ff       	call   8010578a <argptr>
80106818:	85 c0                	test   %eax,%eax
8010681a:	79 07                	jns    80106823 <sys_clone+0x52>
    return -1;
8010681c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106821:	eb 3f                	jmp    80106862 <sys_clone+0x91>

  if(argptr(2, (void *)&stack, sizeof(void *)) < 0)
80106823:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010682a:	00 
8010682b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010682e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106832:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106839:	e8 4c ef ff ff       	call   8010578a <argptr>
8010683e:	85 c0                	test   %eax,%eax
80106840:	79 07                	jns    80106849 <sys_clone+0x78>
    return -1;
80106842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106847:	eb 19                	jmp    80106862 <sys_clone+0x91>
  return clone(fcn, arg, stack);
80106849:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010684c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010684f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106852:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106856:	89 54 24 04          	mov    %edx,0x4(%esp)
8010685a:	89 04 24             	mov    %eax,(%esp)
8010685d:	e8 4a e7 ff ff       	call   80104fac <clone>
80106862:	c9                   	leave  
80106863:	c3                   	ret    

80106864 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106864:	55                   	push   %ebp
80106865:	89 e5                	mov    %esp,%ebp
80106867:	83 ec 08             	sub    $0x8,%esp
8010686a:	8b 55 08             	mov    0x8(%ebp),%edx
8010686d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106870:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106874:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106877:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010687b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010687f:	ee                   	out    %al,(%dx)
}
80106880:	c9                   	leave  
80106881:	c3                   	ret    

80106882 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106882:	55                   	push   %ebp
80106883:	89 e5                	mov    %esp,%ebp
80106885:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106888:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010688f:	00 
80106890:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106897:	e8 c8 ff ff ff       	call   80106864 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010689c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801068a3:	00 
801068a4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068ab:	e8 b4 ff ff ff       	call   80106864 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801068b0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801068b7:	00 
801068b8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068bf:	e8 a0 ff ff ff       	call   80106864 <outb>
  picenable(IRQ_TIMER);
801068c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068cb:	e8 9d d5 ff ff       	call   80103e6d <picenable>
}
801068d0:	c9                   	leave  
801068d1:	c3                   	ret    
801068d2:	66 90                	xchg   %ax,%ax

801068d4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801068d4:	1e                   	push   %ds
  pushl %es
801068d5:	06                   	push   %es
  pushl %fs
801068d6:	0f a0                	push   %fs
  pushl %gs
801068d8:	0f a8                	push   %gs
  pushal
801068da:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801068db:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801068df:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068e1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068e3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068e7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068e9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801068eb:	54                   	push   %esp
  call trap
801068ec:	e8 d9 01 00 00       	call   80106aca <trap>
  addl $4, %esp
801068f1:	83 c4 04             	add    $0x4,%esp

801068f4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801068f4:	61                   	popa   
  popl %gs
801068f5:	0f a9                	pop    %gs
  popl %fs
801068f7:	0f a1                	pop    %fs
  popl %es
801068f9:	07                   	pop    %es
  popl %ds
801068fa:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801068fb:	83 c4 08             	add    $0x8,%esp
  iret
801068fe:	cf                   	iret   
801068ff:	90                   	nop

80106900 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106900:	55                   	push   %ebp
80106901:	89 e5                	mov    %esp,%ebp
80106903:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106906:	8b 45 0c             	mov    0xc(%ebp),%eax
80106909:	83 e8 01             	sub    $0x1,%eax
8010690c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106910:	8b 45 08             	mov    0x8(%ebp),%eax
80106913:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106917:	8b 45 08             	mov    0x8(%ebp),%eax
8010691a:	c1 e8 10             	shr    $0x10,%eax
8010691d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106921:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106924:	0f 01 18             	lidtl  (%eax)
}
80106927:	c9                   	leave  
80106928:	c3                   	ret    

80106929 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106929:	55                   	push   %ebp
8010692a:	89 e5                	mov    %esp,%ebp
8010692c:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010692f:	0f 20 d0             	mov    %cr2,%eax
80106932:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106935:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106938:	c9                   	leave  
80106939:	c3                   	ret    

8010693a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010693a:	55                   	push   %ebp
8010693b:	89 e5                	mov    %esp,%ebp
8010693d:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106940:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106947:	e9 c3 00 00 00       	jmp    80106a0f <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010694c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694f:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106956:	89 c2                	mov    %eax,%edx
80106958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010695b:	66 89 14 c5 e0 48 11 	mov    %dx,-0x7feeb720(,%eax,8)
80106962:	80 
80106963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106966:	66 c7 04 c5 e2 48 11 	movw   $0x8,-0x7feeb71e(,%eax,8)
8010696d:	80 08 00 
80106970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106973:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
8010697a:	80 
8010697b:	83 e2 e0             	and    $0xffffffe0,%edx
8010697e:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
80106985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106988:	0f b6 14 c5 e4 48 11 	movzbl -0x7feeb71c(,%eax,8),%edx
8010698f:	80 
80106990:	83 e2 1f             	and    $0x1f,%edx
80106993:	88 14 c5 e4 48 11 80 	mov    %dl,-0x7feeb71c(,%eax,8)
8010699a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010699d:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801069a4:	80 
801069a5:	83 e2 f0             	and    $0xfffffff0,%edx
801069a8:	83 ca 0e             	or     $0xe,%edx
801069ab:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801069b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b5:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801069bc:	80 
801069bd:	83 e2 ef             	and    $0xffffffef,%edx
801069c0:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801069c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ca:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801069d1:	80 
801069d2:	83 e2 9f             	and    $0xffffff9f,%edx
801069d5:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801069dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069df:	0f b6 14 c5 e5 48 11 	movzbl -0x7feeb71b(,%eax,8),%edx
801069e6:	80 
801069e7:	83 ca 80             	or     $0xffffff80,%edx
801069ea:	88 14 c5 e5 48 11 80 	mov    %dl,-0x7feeb71b(,%eax,8)
801069f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f4:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801069fb:	c1 e8 10             	shr    $0x10,%eax
801069fe:	89 c2                	mov    %eax,%edx
80106a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a03:	66 89 14 c5 e6 48 11 	mov    %dx,-0x7feeb71a(,%eax,8)
80106a0a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106a0b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106a0f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a16:	0f 8e 30 ff ff ff    	jle    8010694c <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a1c:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a21:	66 a3 e0 4a 11 80    	mov    %ax,0x80114ae0
80106a27:	66 c7 05 e2 4a 11 80 	movw   $0x8,0x80114ae2
80106a2e:	08 00 
80106a30:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
80106a37:	83 e0 e0             	and    $0xffffffe0,%eax
80106a3a:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106a3f:	0f b6 05 e4 4a 11 80 	movzbl 0x80114ae4,%eax
80106a46:	83 e0 1f             	and    $0x1f,%eax
80106a49:	a2 e4 4a 11 80       	mov    %al,0x80114ae4
80106a4e:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106a55:	83 c8 0f             	or     $0xf,%eax
80106a58:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106a5d:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106a64:	83 e0 ef             	and    $0xffffffef,%eax
80106a67:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106a6c:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106a73:	83 c8 60             	or     $0x60,%eax
80106a76:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106a7b:	0f b6 05 e5 4a 11 80 	movzbl 0x80114ae5,%eax
80106a82:	83 c8 80             	or     $0xffffff80,%eax
80106a85:	a2 e5 4a 11 80       	mov    %al,0x80114ae5
80106a8a:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a8f:	c1 e8 10             	shr    $0x10,%eax
80106a92:	66 a3 e6 4a 11 80    	mov    %ax,0x80114ae6
  
  initlock(&tickslock, "time");
80106a98:	c7 44 24 04 30 8d 10 	movl   $0x80108d30,0x4(%esp)
80106a9f:	80 
80106aa0:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106aa7:	e8 f2 e6 ff ff       	call   8010519e <initlock>
}
80106aac:	c9                   	leave  
80106aad:	c3                   	ret    

80106aae <idtinit>:

void
idtinit(void)
{
80106aae:	55                   	push   %ebp
80106aaf:	89 e5                	mov    %esp,%ebp
80106ab1:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106ab4:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106abb:	00 
80106abc:	c7 04 24 e0 48 11 80 	movl   $0x801148e0,(%esp)
80106ac3:	e8 38 fe ff ff       	call   80106900 <lidt>
}
80106ac8:	c9                   	leave  
80106ac9:	c3                   	ret    

80106aca <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106aca:	55                   	push   %ebp
80106acb:	89 e5                	mov    %esp,%ebp
80106acd:	57                   	push   %edi
80106ace:	56                   	push   %esi
80106acf:	53                   	push   %ebx
80106ad0:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ad6:	8b 40 30             	mov    0x30(%eax),%eax
80106ad9:	83 f8 40             	cmp    $0x40,%eax
80106adc:	75 3f                	jne    80106b1d <trap+0x53>
    if(proc->killed)
80106ade:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ae4:	8b 40 24             	mov    0x24(%eax),%eax
80106ae7:	85 c0                	test   %eax,%eax
80106ae9:	74 05                	je     80106af0 <trap+0x26>
      exit();
80106aeb:	e8 15 dd ff ff       	call   80104805 <exit>
    proc->tf = tf;
80106af0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af6:	8b 55 08             	mov    0x8(%ebp),%edx
80106af9:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106afc:	e8 22 ed ff ff       	call   80105823 <syscall>
    if(proc->killed)
80106b01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b07:	8b 40 24             	mov    0x24(%eax),%eax
80106b0a:	85 c0                	test   %eax,%eax
80106b0c:	74 0a                	je     80106b18 <trap+0x4e>
      exit();
80106b0e:	e8 f2 dc ff ff       	call   80104805 <exit>
    return;
80106b13:	e9 2d 02 00 00       	jmp    80106d45 <trap+0x27b>
80106b18:	e9 28 02 00 00       	jmp    80106d45 <trap+0x27b>
  }

  switch(tf->trapno){
80106b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b20:	8b 40 30             	mov    0x30(%eax),%eax
80106b23:	83 e8 20             	sub    $0x20,%eax
80106b26:	83 f8 1f             	cmp    $0x1f,%eax
80106b29:	0f 87 bc 00 00 00    	ja     80106beb <trap+0x121>
80106b2f:	8b 04 85 d8 8d 10 80 	mov    -0x7fef7228(,%eax,4),%eax
80106b36:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b38:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b3e:	0f b6 00             	movzbl (%eax),%eax
80106b41:	84 c0                	test   %al,%al
80106b43:	75 31                	jne    80106b76 <trap+0xac>
      acquire(&tickslock);
80106b45:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106b4c:	e8 6e e6 ff ff       	call   801051bf <acquire>
      ticks++;
80106b51:	a1 e0 50 11 80       	mov    0x801150e0,%eax
80106b56:	83 c0 01             	add    $0x1,%eax
80106b59:	a3 e0 50 11 80       	mov    %eax,0x801150e0
      wakeup(&ticks);
80106b5e:	c7 04 24 e0 50 11 80 	movl   $0x801150e0,(%esp)
80106b65:	e8 60 e1 ff ff       	call   80104cca <wakeup>
      release(&tickslock);
80106b6a:	c7 04 24 a0 48 11 80 	movl   $0x801148a0,(%esp)
80106b71:	e8 ab e6 ff ff       	call   80105221 <release>
    }
    lapiceoi();
80106b76:	e8 16 c4 ff ff       	call   80102f91 <lapiceoi>
    break;
80106b7b:	e9 41 01 00 00       	jmp    80106cc1 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b80:	e8 16 bc ff ff       	call   8010279b <ideintr>
    lapiceoi();
80106b85:	e8 07 c4 ff ff       	call   80102f91 <lapiceoi>
    break;
80106b8a:	e9 32 01 00 00       	jmp    80106cc1 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b8f:	e8 cc c1 ff ff       	call   80102d60 <kbdintr>
    lapiceoi();
80106b94:	e8 f8 c3 ff ff       	call   80102f91 <lapiceoi>
    break;
80106b99:	e9 23 01 00 00       	jmp    80106cc1 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b9e:	e8 9a 03 00 00       	call   80106f3d <uartintr>
    lapiceoi();
80106ba3:	e8 e9 c3 ff ff       	call   80102f91 <lapiceoi>
    break;
80106ba8:	e9 14 01 00 00       	jmp    80106cc1 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bad:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb0:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bba:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bc3:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bc6:	0f b6 c0             	movzbl %al,%eax
80106bc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106bcd:	89 54 24 08          	mov    %edx,0x8(%esp)
80106bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd5:	c7 04 24 38 8d 10 80 	movl   $0x80108d38,(%esp)
80106bdc:	e8 bf 97 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106be1:	e8 ab c3 ff ff       	call   80102f91 <lapiceoi>
    break;
80106be6:	e9 d6 00 00 00       	jmp    80106cc1 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106beb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf1:	85 c0                	test   %eax,%eax
80106bf3:	74 11                	je     80106c06 <trap+0x13c>
80106bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bfc:	0f b7 c0             	movzwl %ax,%eax
80106bff:	83 e0 03             	and    $0x3,%eax
80106c02:	85 c0                	test   %eax,%eax
80106c04:	75 46                	jne    80106c4c <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c06:	e8 1e fd ff ff       	call   80106929 <rcr2>
80106c0b:	8b 55 08             	mov    0x8(%ebp),%edx
80106c0e:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c11:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c18:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c1b:	0f b6 ca             	movzbl %dl,%ecx
80106c1e:	8b 55 08             	mov    0x8(%ebp),%edx
80106c21:	8b 52 30             	mov    0x30(%edx),%edx
80106c24:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c28:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c2c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c30:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c34:	c7 04 24 5c 8d 10 80 	movl   $0x80108d5c,(%esp)
80106c3b:	e8 60 97 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c40:	c7 04 24 8e 8d 10 80 	movl   $0x80108d8e,(%esp)
80106c47:	e8 ee 98 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c4c:	e8 d8 fc ff ff       	call   80106929 <rcr2>
80106c51:	89 c2                	mov    %eax,%edx
80106c53:	8b 45 08             	mov    0x8(%ebp),%eax
80106c56:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c59:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c5f:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c62:	0f b6 f0             	movzbl %al,%esi
80106c65:	8b 45 08             	mov    0x8(%ebp),%eax
80106c68:	8b 58 34             	mov    0x34(%eax),%ebx
80106c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c6e:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c77:	83 c0 6c             	add    $0x6c,%eax
80106c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c83:	8b 40 10             	mov    0x10(%eax),%eax
80106c86:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106c8a:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106c8e:	89 74 24 14          	mov    %esi,0x14(%esp)
80106c92:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106c96:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c9a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106c9d:	89 74 24 08          	mov    %esi,0x8(%esp)
80106ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ca5:	c7 04 24 94 8d 10 80 	movl   $0x80108d94,(%esp)
80106cac:	e8 ef 96 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106cb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cb7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cbe:	eb 01                	jmp    80106cc1 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cc0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc7:	85 c0                	test   %eax,%eax
80106cc9:	74 24                	je     80106cef <trap+0x225>
80106ccb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cd1:	8b 40 24             	mov    0x24(%eax),%eax
80106cd4:	85 c0                	test   %eax,%eax
80106cd6:	74 17                	je     80106cef <trap+0x225>
80106cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80106cdb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cdf:	0f b7 c0             	movzwl %ax,%eax
80106ce2:	83 e0 03             	and    $0x3,%eax
80106ce5:	83 f8 03             	cmp    $0x3,%eax
80106ce8:	75 05                	jne    80106cef <trap+0x225>
    exit();
80106cea:	e8 16 db ff ff       	call   80104805 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106cef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf5:	85 c0                	test   %eax,%eax
80106cf7:	74 1e                	je     80106d17 <trap+0x24d>
80106cf9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cff:	8b 40 0c             	mov    0xc(%eax),%eax
80106d02:	83 f8 04             	cmp    $0x4,%eax
80106d05:	75 10                	jne    80106d17 <trap+0x24d>
80106d07:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0a:	8b 40 30             	mov    0x30(%eax),%eax
80106d0d:	83 f8 20             	cmp    $0x20,%eax
80106d10:	75 05                	jne    80106d17 <trap+0x24d>
    yield();
80106d12:	e8 69 de ff ff       	call   80104b80 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d1d:	85 c0                	test   %eax,%eax
80106d1f:	74 24                	je     80106d45 <trap+0x27b>
80106d21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d27:	8b 40 24             	mov    0x24(%eax),%eax
80106d2a:	85 c0                	test   %eax,%eax
80106d2c:	74 17                	je     80106d45 <trap+0x27b>
80106d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d31:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d35:	0f b7 c0             	movzwl %ax,%eax
80106d38:	83 e0 03             	and    $0x3,%eax
80106d3b:	83 f8 03             	cmp    $0x3,%eax
80106d3e:	75 05                	jne    80106d45 <trap+0x27b>
    exit();
80106d40:	e8 c0 da ff ff       	call   80104805 <exit>
}
80106d45:	83 c4 3c             	add    $0x3c,%esp
80106d48:	5b                   	pop    %ebx
80106d49:	5e                   	pop    %esi
80106d4a:	5f                   	pop    %edi
80106d4b:	5d                   	pop    %ebp
80106d4c:	c3                   	ret    
80106d4d:	66 90                	xchg   %ax,%ax
80106d4f:	90                   	nop

80106d50 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d50:	55                   	push   %ebp
80106d51:	89 e5                	mov    %esp,%ebp
80106d53:	83 ec 14             	sub    $0x14,%esp
80106d56:	8b 45 08             	mov    0x8(%ebp),%eax
80106d59:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d5d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d61:	89 c2                	mov    %eax,%edx
80106d63:	ec                   	in     (%dx),%al
80106d64:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d67:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d6b:	c9                   	leave  
80106d6c:	c3                   	ret    

80106d6d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106d6d:	55                   	push   %ebp
80106d6e:	89 e5                	mov    %esp,%ebp
80106d70:	83 ec 08             	sub    $0x8,%esp
80106d73:	8b 55 08             	mov    0x8(%ebp),%edx
80106d76:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d79:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d7d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d80:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d84:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d88:	ee                   	out    %al,(%dx)
}
80106d89:	c9                   	leave  
80106d8a:	c3                   	ret    

80106d8b <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d8b:	55                   	push   %ebp
80106d8c:	89 e5                	mov    %esp,%ebp
80106d8e:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d98:	00 
80106d99:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106da0:	e8 c8 ff ff ff       	call   80106d6d <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106da5:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106dac:	00 
80106dad:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106db4:	e8 b4 ff ff ff       	call   80106d6d <outb>
  outb(COM1+0, 115200/9600);
80106db9:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106dc0:	00 
80106dc1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106dc8:	e8 a0 ff ff ff       	call   80106d6d <outb>
  outb(COM1+1, 0);
80106dcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dd4:	00 
80106dd5:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106ddc:	e8 8c ff ff ff       	call   80106d6d <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106de1:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106de8:	00 
80106de9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106df0:	e8 78 ff ff ff       	call   80106d6d <outb>
  outb(COM1+4, 0);
80106df5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dfc:	00 
80106dfd:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e04:	e8 64 ff ff ff       	call   80106d6d <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e09:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e10:	00 
80106e11:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e18:	e8 50 ff ff ff       	call   80106d6d <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e1d:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e24:	e8 27 ff ff ff       	call   80106d50 <inb>
80106e29:	3c ff                	cmp    $0xff,%al
80106e2b:	75 02                	jne    80106e2f <uartinit+0xa4>
    return;
80106e2d:	eb 6a                	jmp    80106e99 <uartinit+0x10e>
  uart = 1;
80106e2f:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e36:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e39:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e40:	e8 0b ff ff ff       	call   80106d50 <inb>
  inb(COM1+0);
80106e45:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e4c:	e8 ff fe ff ff       	call   80106d50 <inb>
  picenable(IRQ_COM1);
80106e51:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e58:	e8 10 d0 ff ff       	call   80103e6d <picenable>
  ioapicenable(IRQ_COM1, 0);
80106e5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e64:	00 
80106e65:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e6c:	e8 ab bb ff ff       	call   80102a1c <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e71:	c7 45 f4 58 8e 10 80 	movl   $0x80108e58,-0xc(%ebp)
80106e78:	eb 15                	jmp    80106e8f <uartinit+0x104>
    uartputc(*p);
80106e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7d:	0f b6 00             	movzbl (%eax),%eax
80106e80:	0f be c0             	movsbl %al,%eax
80106e83:	89 04 24             	mov    %eax,(%esp)
80106e86:	e8 10 00 00 00       	call   80106e9b <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e8b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e92:	0f b6 00             	movzbl (%eax),%eax
80106e95:	84 c0                	test   %al,%al
80106e97:	75 e1                	jne    80106e7a <uartinit+0xef>
    uartputc(*p);
}
80106e99:	c9                   	leave  
80106e9a:	c3                   	ret    

80106e9b <uartputc>:

void
uartputc(int c)
{
80106e9b:	55                   	push   %ebp
80106e9c:	89 e5                	mov    %esp,%ebp
80106e9e:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106ea1:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106ea6:	85 c0                	test   %eax,%eax
80106ea8:	75 02                	jne    80106eac <uartputc+0x11>
    return;
80106eaa:	eb 4b                	jmp    80106ef7 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106eac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106eb3:	eb 10                	jmp    80106ec5 <uartputc+0x2a>
    microdelay(10);
80106eb5:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106ebc:	e8 f5 c0 ff ff       	call   80102fb6 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ec1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ec5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ec9:	7f 16                	jg     80106ee1 <uartputc+0x46>
80106ecb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106ed2:	e8 79 fe ff ff       	call   80106d50 <inb>
80106ed7:	0f b6 c0             	movzbl %al,%eax
80106eda:	83 e0 20             	and    $0x20,%eax
80106edd:	85 c0                	test   %eax,%eax
80106edf:	74 d4                	je     80106eb5 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee4:	0f b6 c0             	movzbl %al,%eax
80106ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106eeb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106ef2:	e8 76 fe ff ff       	call   80106d6d <outb>
}
80106ef7:	c9                   	leave  
80106ef8:	c3                   	ret    

80106ef9 <uartgetc>:

static int
uartgetc(void)
{
80106ef9:	55                   	push   %ebp
80106efa:	89 e5                	mov    %esp,%ebp
80106efc:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106eff:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f04:	85 c0                	test   %eax,%eax
80106f06:	75 07                	jne    80106f0f <uartgetc+0x16>
    return -1;
80106f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f0d:	eb 2c                	jmp    80106f3b <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f0f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f16:	e8 35 fe ff ff       	call   80106d50 <inb>
80106f1b:	0f b6 c0             	movzbl %al,%eax
80106f1e:	83 e0 01             	and    $0x1,%eax
80106f21:	85 c0                	test   %eax,%eax
80106f23:	75 07                	jne    80106f2c <uartgetc+0x33>
    return -1;
80106f25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f2a:	eb 0f                	jmp    80106f3b <uartgetc+0x42>
  return inb(COM1+0);
80106f2c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f33:	e8 18 fe ff ff       	call   80106d50 <inb>
80106f38:	0f b6 c0             	movzbl %al,%eax
}
80106f3b:	c9                   	leave  
80106f3c:	c3                   	ret    

80106f3d <uartintr>:

void
uartintr(void)
{
80106f3d:	55                   	push   %ebp
80106f3e:	89 e5                	mov    %esp,%ebp
80106f40:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f43:	c7 04 24 f9 6e 10 80 	movl   $0x80106ef9,(%esp)
80106f4a:	e8 79 98 ff ff       	call   801007c8 <consoleintr>
}
80106f4f:	c9                   	leave  
80106f50:	c3                   	ret    
80106f51:	66 90                	xchg   %ax,%ax
80106f53:	90                   	nop

80106f54 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $0
80106f56:	6a 00                	push   $0x0
  jmp alltraps
80106f58:	e9 77 f9 ff ff       	jmp    801068d4 <alltraps>

80106f5d <vector1>:
.globl vector1
vector1:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $1
80106f5f:	6a 01                	push   $0x1
  jmp alltraps
80106f61:	e9 6e f9 ff ff       	jmp    801068d4 <alltraps>

80106f66 <vector2>:
.globl vector2
vector2:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $2
80106f68:	6a 02                	push   $0x2
  jmp alltraps
80106f6a:	e9 65 f9 ff ff       	jmp    801068d4 <alltraps>

80106f6f <vector3>:
.globl vector3
vector3:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $3
80106f71:	6a 03                	push   $0x3
  jmp alltraps
80106f73:	e9 5c f9 ff ff       	jmp    801068d4 <alltraps>

80106f78 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $4
80106f7a:	6a 04                	push   $0x4
  jmp alltraps
80106f7c:	e9 53 f9 ff ff       	jmp    801068d4 <alltraps>

80106f81 <vector5>:
.globl vector5
vector5:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $5
80106f83:	6a 05                	push   $0x5
  jmp alltraps
80106f85:	e9 4a f9 ff ff       	jmp    801068d4 <alltraps>

80106f8a <vector6>:
.globl vector6
vector6:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $6
80106f8c:	6a 06                	push   $0x6
  jmp alltraps
80106f8e:	e9 41 f9 ff ff       	jmp    801068d4 <alltraps>

80106f93 <vector7>:
.globl vector7
vector7:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $7
80106f95:	6a 07                	push   $0x7
  jmp alltraps
80106f97:	e9 38 f9 ff ff       	jmp    801068d4 <alltraps>

80106f9c <vector8>:
.globl vector8
vector8:
  pushl $8
80106f9c:	6a 08                	push   $0x8
  jmp alltraps
80106f9e:	e9 31 f9 ff ff       	jmp    801068d4 <alltraps>

80106fa3 <vector9>:
.globl vector9
vector9:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $9
80106fa5:	6a 09                	push   $0x9
  jmp alltraps
80106fa7:	e9 28 f9 ff ff       	jmp    801068d4 <alltraps>

80106fac <vector10>:
.globl vector10
vector10:
  pushl $10
80106fac:	6a 0a                	push   $0xa
  jmp alltraps
80106fae:	e9 21 f9 ff ff       	jmp    801068d4 <alltraps>

80106fb3 <vector11>:
.globl vector11
vector11:
  pushl $11
80106fb3:	6a 0b                	push   $0xb
  jmp alltraps
80106fb5:	e9 1a f9 ff ff       	jmp    801068d4 <alltraps>

80106fba <vector12>:
.globl vector12
vector12:
  pushl $12
80106fba:	6a 0c                	push   $0xc
  jmp alltraps
80106fbc:	e9 13 f9 ff ff       	jmp    801068d4 <alltraps>

80106fc1 <vector13>:
.globl vector13
vector13:
  pushl $13
80106fc1:	6a 0d                	push   $0xd
  jmp alltraps
80106fc3:	e9 0c f9 ff ff       	jmp    801068d4 <alltraps>

80106fc8 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fc8:	6a 0e                	push   $0xe
  jmp alltraps
80106fca:	e9 05 f9 ff ff       	jmp    801068d4 <alltraps>

80106fcf <vector15>:
.globl vector15
vector15:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $15
80106fd1:	6a 0f                	push   $0xf
  jmp alltraps
80106fd3:	e9 fc f8 ff ff       	jmp    801068d4 <alltraps>

80106fd8 <vector16>:
.globl vector16
vector16:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $16
80106fda:	6a 10                	push   $0x10
  jmp alltraps
80106fdc:	e9 f3 f8 ff ff       	jmp    801068d4 <alltraps>

80106fe1 <vector17>:
.globl vector17
vector17:
  pushl $17
80106fe1:	6a 11                	push   $0x11
  jmp alltraps
80106fe3:	e9 ec f8 ff ff       	jmp    801068d4 <alltraps>

80106fe8 <vector18>:
.globl vector18
vector18:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $18
80106fea:	6a 12                	push   $0x12
  jmp alltraps
80106fec:	e9 e3 f8 ff ff       	jmp    801068d4 <alltraps>

80106ff1 <vector19>:
.globl vector19
vector19:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $19
80106ff3:	6a 13                	push   $0x13
  jmp alltraps
80106ff5:	e9 da f8 ff ff       	jmp    801068d4 <alltraps>

80106ffa <vector20>:
.globl vector20
vector20:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $20
80106ffc:	6a 14                	push   $0x14
  jmp alltraps
80106ffe:	e9 d1 f8 ff ff       	jmp    801068d4 <alltraps>

80107003 <vector21>:
.globl vector21
vector21:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $21
80107005:	6a 15                	push   $0x15
  jmp alltraps
80107007:	e9 c8 f8 ff ff       	jmp    801068d4 <alltraps>

8010700c <vector22>:
.globl vector22
vector22:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $22
8010700e:	6a 16                	push   $0x16
  jmp alltraps
80107010:	e9 bf f8 ff ff       	jmp    801068d4 <alltraps>

80107015 <vector23>:
.globl vector23
vector23:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $23
80107017:	6a 17                	push   $0x17
  jmp alltraps
80107019:	e9 b6 f8 ff ff       	jmp    801068d4 <alltraps>

8010701e <vector24>:
.globl vector24
vector24:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $24
80107020:	6a 18                	push   $0x18
  jmp alltraps
80107022:	e9 ad f8 ff ff       	jmp    801068d4 <alltraps>

80107027 <vector25>:
.globl vector25
vector25:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $25
80107029:	6a 19                	push   $0x19
  jmp alltraps
8010702b:	e9 a4 f8 ff ff       	jmp    801068d4 <alltraps>

80107030 <vector26>:
.globl vector26
vector26:
  pushl $0
80107030:	6a 00                	push   $0x0
  pushl $26
80107032:	6a 1a                	push   $0x1a
  jmp alltraps
80107034:	e9 9b f8 ff ff       	jmp    801068d4 <alltraps>

80107039 <vector27>:
.globl vector27
vector27:
  pushl $0
80107039:	6a 00                	push   $0x0
  pushl $27
8010703b:	6a 1b                	push   $0x1b
  jmp alltraps
8010703d:	e9 92 f8 ff ff       	jmp    801068d4 <alltraps>

80107042 <vector28>:
.globl vector28
vector28:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $28
80107044:	6a 1c                	push   $0x1c
  jmp alltraps
80107046:	e9 89 f8 ff ff       	jmp    801068d4 <alltraps>

8010704b <vector29>:
.globl vector29
vector29:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $29
8010704d:	6a 1d                	push   $0x1d
  jmp alltraps
8010704f:	e9 80 f8 ff ff       	jmp    801068d4 <alltraps>

80107054 <vector30>:
.globl vector30
vector30:
  pushl $0
80107054:	6a 00                	push   $0x0
  pushl $30
80107056:	6a 1e                	push   $0x1e
  jmp alltraps
80107058:	e9 77 f8 ff ff       	jmp    801068d4 <alltraps>

8010705d <vector31>:
.globl vector31
vector31:
  pushl $0
8010705d:	6a 00                	push   $0x0
  pushl $31
8010705f:	6a 1f                	push   $0x1f
  jmp alltraps
80107061:	e9 6e f8 ff ff       	jmp    801068d4 <alltraps>

80107066 <vector32>:
.globl vector32
vector32:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $32
80107068:	6a 20                	push   $0x20
  jmp alltraps
8010706a:	e9 65 f8 ff ff       	jmp    801068d4 <alltraps>

8010706f <vector33>:
.globl vector33
vector33:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $33
80107071:	6a 21                	push   $0x21
  jmp alltraps
80107073:	e9 5c f8 ff ff       	jmp    801068d4 <alltraps>

80107078 <vector34>:
.globl vector34
vector34:
  pushl $0
80107078:	6a 00                	push   $0x0
  pushl $34
8010707a:	6a 22                	push   $0x22
  jmp alltraps
8010707c:	e9 53 f8 ff ff       	jmp    801068d4 <alltraps>

80107081 <vector35>:
.globl vector35
vector35:
  pushl $0
80107081:	6a 00                	push   $0x0
  pushl $35
80107083:	6a 23                	push   $0x23
  jmp alltraps
80107085:	e9 4a f8 ff ff       	jmp    801068d4 <alltraps>

8010708a <vector36>:
.globl vector36
vector36:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $36
8010708c:	6a 24                	push   $0x24
  jmp alltraps
8010708e:	e9 41 f8 ff ff       	jmp    801068d4 <alltraps>

80107093 <vector37>:
.globl vector37
vector37:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $37
80107095:	6a 25                	push   $0x25
  jmp alltraps
80107097:	e9 38 f8 ff ff       	jmp    801068d4 <alltraps>

8010709c <vector38>:
.globl vector38
vector38:
  pushl $0
8010709c:	6a 00                	push   $0x0
  pushl $38
8010709e:	6a 26                	push   $0x26
  jmp alltraps
801070a0:	e9 2f f8 ff ff       	jmp    801068d4 <alltraps>

801070a5 <vector39>:
.globl vector39
vector39:
  pushl $0
801070a5:	6a 00                	push   $0x0
  pushl $39
801070a7:	6a 27                	push   $0x27
  jmp alltraps
801070a9:	e9 26 f8 ff ff       	jmp    801068d4 <alltraps>

801070ae <vector40>:
.globl vector40
vector40:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $40
801070b0:	6a 28                	push   $0x28
  jmp alltraps
801070b2:	e9 1d f8 ff ff       	jmp    801068d4 <alltraps>

801070b7 <vector41>:
.globl vector41
vector41:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $41
801070b9:	6a 29                	push   $0x29
  jmp alltraps
801070bb:	e9 14 f8 ff ff       	jmp    801068d4 <alltraps>

801070c0 <vector42>:
.globl vector42
vector42:
  pushl $0
801070c0:	6a 00                	push   $0x0
  pushl $42
801070c2:	6a 2a                	push   $0x2a
  jmp alltraps
801070c4:	e9 0b f8 ff ff       	jmp    801068d4 <alltraps>

801070c9 <vector43>:
.globl vector43
vector43:
  pushl $0
801070c9:	6a 00                	push   $0x0
  pushl $43
801070cb:	6a 2b                	push   $0x2b
  jmp alltraps
801070cd:	e9 02 f8 ff ff       	jmp    801068d4 <alltraps>

801070d2 <vector44>:
.globl vector44
vector44:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $44
801070d4:	6a 2c                	push   $0x2c
  jmp alltraps
801070d6:	e9 f9 f7 ff ff       	jmp    801068d4 <alltraps>

801070db <vector45>:
.globl vector45
vector45:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $45
801070dd:	6a 2d                	push   $0x2d
  jmp alltraps
801070df:	e9 f0 f7 ff ff       	jmp    801068d4 <alltraps>

801070e4 <vector46>:
.globl vector46
vector46:
  pushl $0
801070e4:	6a 00                	push   $0x0
  pushl $46
801070e6:	6a 2e                	push   $0x2e
  jmp alltraps
801070e8:	e9 e7 f7 ff ff       	jmp    801068d4 <alltraps>

801070ed <vector47>:
.globl vector47
vector47:
  pushl $0
801070ed:	6a 00                	push   $0x0
  pushl $47
801070ef:	6a 2f                	push   $0x2f
  jmp alltraps
801070f1:	e9 de f7 ff ff       	jmp    801068d4 <alltraps>

801070f6 <vector48>:
.globl vector48
vector48:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $48
801070f8:	6a 30                	push   $0x30
  jmp alltraps
801070fa:	e9 d5 f7 ff ff       	jmp    801068d4 <alltraps>

801070ff <vector49>:
.globl vector49
vector49:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $49
80107101:	6a 31                	push   $0x31
  jmp alltraps
80107103:	e9 cc f7 ff ff       	jmp    801068d4 <alltraps>

80107108 <vector50>:
.globl vector50
vector50:
  pushl $0
80107108:	6a 00                	push   $0x0
  pushl $50
8010710a:	6a 32                	push   $0x32
  jmp alltraps
8010710c:	e9 c3 f7 ff ff       	jmp    801068d4 <alltraps>

80107111 <vector51>:
.globl vector51
vector51:
  pushl $0
80107111:	6a 00                	push   $0x0
  pushl $51
80107113:	6a 33                	push   $0x33
  jmp alltraps
80107115:	e9 ba f7 ff ff       	jmp    801068d4 <alltraps>

8010711a <vector52>:
.globl vector52
vector52:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $52
8010711c:	6a 34                	push   $0x34
  jmp alltraps
8010711e:	e9 b1 f7 ff ff       	jmp    801068d4 <alltraps>

80107123 <vector53>:
.globl vector53
vector53:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $53
80107125:	6a 35                	push   $0x35
  jmp alltraps
80107127:	e9 a8 f7 ff ff       	jmp    801068d4 <alltraps>

8010712c <vector54>:
.globl vector54
vector54:
  pushl $0
8010712c:	6a 00                	push   $0x0
  pushl $54
8010712e:	6a 36                	push   $0x36
  jmp alltraps
80107130:	e9 9f f7 ff ff       	jmp    801068d4 <alltraps>

80107135 <vector55>:
.globl vector55
vector55:
  pushl $0
80107135:	6a 00                	push   $0x0
  pushl $55
80107137:	6a 37                	push   $0x37
  jmp alltraps
80107139:	e9 96 f7 ff ff       	jmp    801068d4 <alltraps>

8010713e <vector56>:
.globl vector56
vector56:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $56
80107140:	6a 38                	push   $0x38
  jmp alltraps
80107142:	e9 8d f7 ff ff       	jmp    801068d4 <alltraps>

80107147 <vector57>:
.globl vector57
vector57:
  pushl $0
80107147:	6a 00                	push   $0x0
  pushl $57
80107149:	6a 39                	push   $0x39
  jmp alltraps
8010714b:	e9 84 f7 ff ff       	jmp    801068d4 <alltraps>

80107150 <vector58>:
.globl vector58
vector58:
  pushl $0
80107150:	6a 00                	push   $0x0
  pushl $58
80107152:	6a 3a                	push   $0x3a
  jmp alltraps
80107154:	e9 7b f7 ff ff       	jmp    801068d4 <alltraps>

80107159 <vector59>:
.globl vector59
vector59:
  pushl $0
80107159:	6a 00                	push   $0x0
  pushl $59
8010715b:	6a 3b                	push   $0x3b
  jmp alltraps
8010715d:	e9 72 f7 ff ff       	jmp    801068d4 <alltraps>

80107162 <vector60>:
.globl vector60
vector60:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $60
80107164:	6a 3c                	push   $0x3c
  jmp alltraps
80107166:	e9 69 f7 ff ff       	jmp    801068d4 <alltraps>

8010716b <vector61>:
.globl vector61
vector61:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $61
8010716d:	6a 3d                	push   $0x3d
  jmp alltraps
8010716f:	e9 60 f7 ff ff       	jmp    801068d4 <alltraps>

80107174 <vector62>:
.globl vector62
vector62:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $62
80107176:	6a 3e                	push   $0x3e
  jmp alltraps
80107178:	e9 57 f7 ff ff       	jmp    801068d4 <alltraps>

8010717d <vector63>:
.globl vector63
vector63:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $63
8010717f:	6a 3f                	push   $0x3f
  jmp alltraps
80107181:	e9 4e f7 ff ff       	jmp    801068d4 <alltraps>

80107186 <vector64>:
.globl vector64
vector64:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $64
80107188:	6a 40                	push   $0x40
  jmp alltraps
8010718a:	e9 45 f7 ff ff       	jmp    801068d4 <alltraps>

8010718f <vector65>:
.globl vector65
vector65:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $65
80107191:	6a 41                	push   $0x41
  jmp alltraps
80107193:	e9 3c f7 ff ff       	jmp    801068d4 <alltraps>

80107198 <vector66>:
.globl vector66
vector66:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $66
8010719a:	6a 42                	push   $0x42
  jmp alltraps
8010719c:	e9 33 f7 ff ff       	jmp    801068d4 <alltraps>

801071a1 <vector67>:
.globl vector67
vector67:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $67
801071a3:	6a 43                	push   $0x43
  jmp alltraps
801071a5:	e9 2a f7 ff ff       	jmp    801068d4 <alltraps>

801071aa <vector68>:
.globl vector68
vector68:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $68
801071ac:	6a 44                	push   $0x44
  jmp alltraps
801071ae:	e9 21 f7 ff ff       	jmp    801068d4 <alltraps>

801071b3 <vector69>:
.globl vector69
vector69:
  pushl $0
801071b3:	6a 00                	push   $0x0
  pushl $69
801071b5:	6a 45                	push   $0x45
  jmp alltraps
801071b7:	e9 18 f7 ff ff       	jmp    801068d4 <alltraps>

801071bc <vector70>:
.globl vector70
vector70:
  pushl $0
801071bc:	6a 00                	push   $0x0
  pushl $70
801071be:	6a 46                	push   $0x46
  jmp alltraps
801071c0:	e9 0f f7 ff ff       	jmp    801068d4 <alltraps>

801071c5 <vector71>:
.globl vector71
vector71:
  pushl $0
801071c5:	6a 00                	push   $0x0
  pushl $71
801071c7:	6a 47                	push   $0x47
  jmp alltraps
801071c9:	e9 06 f7 ff ff       	jmp    801068d4 <alltraps>

801071ce <vector72>:
.globl vector72
vector72:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $72
801071d0:	6a 48                	push   $0x48
  jmp alltraps
801071d2:	e9 fd f6 ff ff       	jmp    801068d4 <alltraps>

801071d7 <vector73>:
.globl vector73
vector73:
  pushl $0
801071d7:	6a 00                	push   $0x0
  pushl $73
801071d9:	6a 49                	push   $0x49
  jmp alltraps
801071db:	e9 f4 f6 ff ff       	jmp    801068d4 <alltraps>

801071e0 <vector74>:
.globl vector74
vector74:
  pushl $0
801071e0:	6a 00                	push   $0x0
  pushl $74
801071e2:	6a 4a                	push   $0x4a
  jmp alltraps
801071e4:	e9 eb f6 ff ff       	jmp    801068d4 <alltraps>

801071e9 <vector75>:
.globl vector75
vector75:
  pushl $0
801071e9:	6a 00                	push   $0x0
  pushl $75
801071eb:	6a 4b                	push   $0x4b
  jmp alltraps
801071ed:	e9 e2 f6 ff ff       	jmp    801068d4 <alltraps>

801071f2 <vector76>:
.globl vector76
vector76:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $76
801071f4:	6a 4c                	push   $0x4c
  jmp alltraps
801071f6:	e9 d9 f6 ff ff       	jmp    801068d4 <alltraps>

801071fb <vector77>:
.globl vector77
vector77:
  pushl $0
801071fb:	6a 00                	push   $0x0
  pushl $77
801071fd:	6a 4d                	push   $0x4d
  jmp alltraps
801071ff:	e9 d0 f6 ff ff       	jmp    801068d4 <alltraps>

80107204 <vector78>:
.globl vector78
vector78:
  pushl $0
80107204:	6a 00                	push   $0x0
  pushl $78
80107206:	6a 4e                	push   $0x4e
  jmp alltraps
80107208:	e9 c7 f6 ff ff       	jmp    801068d4 <alltraps>

8010720d <vector79>:
.globl vector79
vector79:
  pushl $0
8010720d:	6a 00                	push   $0x0
  pushl $79
8010720f:	6a 4f                	push   $0x4f
  jmp alltraps
80107211:	e9 be f6 ff ff       	jmp    801068d4 <alltraps>

80107216 <vector80>:
.globl vector80
vector80:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $80
80107218:	6a 50                	push   $0x50
  jmp alltraps
8010721a:	e9 b5 f6 ff ff       	jmp    801068d4 <alltraps>

8010721f <vector81>:
.globl vector81
vector81:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $81
80107221:	6a 51                	push   $0x51
  jmp alltraps
80107223:	e9 ac f6 ff ff       	jmp    801068d4 <alltraps>

80107228 <vector82>:
.globl vector82
vector82:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $82
8010722a:	6a 52                	push   $0x52
  jmp alltraps
8010722c:	e9 a3 f6 ff ff       	jmp    801068d4 <alltraps>

80107231 <vector83>:
.globl vector83
vector83:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $83
80107233:	6a 53                	push   $0x53
  jmp alltraps
80107235:	e9 9a f6 ff ff       	jmp    801068d4 <alltraps>

8010723a <vector84>:
.globl vector84
vector84:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $84
8010723c:	6a 54                	push   $0x54
  jmp alltraps
8010723e:	e9 91 f6 ff ff       	jmp    801068d4 <alltraps>

80107243 <vector85>:
.globl vector85
vector85:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $85
80107245:	6a 55                	push   $0x55
  jmp alltraps
80107247:	e9 88 f6 ff ff       	jmp    801068d4 <alltraps>

8010724c <vector86>:
.globl vector86
vector86:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $86
8010724e:	6a 56                	push   $0x56
  jmp alltraps
80107250:	e9 7f f6 ff ff       	jmp    801068d4 <alltraps>

80107255 <vector87>:
.globl vector87
vector87:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $87
80107257:	6a 57                	push   $0x57
  jmp alltraps
80107259:	e9 76 f6 ff ff       	jmp    801068d4 <alltraps>

8010725e <vector88>:
.globl vector88
vector88:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $88
80107260:	6a 58                	push   $0x58
  jmp alltraps
80107262:	e9 6d f6 ff ff       	jmp    801068d4 <alltraps>

80107267 <vector89>:
.globl vector89
vector89:
  pushl $0
80107267:	6a 00                	push   $0x0
  pushl $89
80107269:	6a 59                	push   $0x59
  jmp alltraps
8010726b:	e9 64 f6 ff ff       	jmp    801068d4 <alltraps>

80107270 <vector90>:
.globl vector90
vector90:
  pushl $0
80107270:	6a 00                	push   $0x0
  pushl $90
80107272:	6a 5a                	push   $0x5a
  jmp alltraps
80107274:	e9 5b f6 ff ff       	jmp    801068d4 <alltraps>

80107279 <vector91>:
.globl vector91
vector91:
  pushl $0
80107279:	6a 00                	push   $0x0
  pushl $91
8010727b:	6a 5b                	push   $0x5b
  jmp alltraps
8010727d:	e9 52 f6 ff ff       	jmp    801068d4 <alltraps>

80107282 <vector92>:
.globl vector92
vector92:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $92
80107284:	6a 5c                	push   $0x5c
  jmp alltraps
80107286:	e9 49 f6 ff ff       	jmp    801068d4 <alltraps>

8010728b <vector93>:
.globl vector93
vector93:
  pushl $0
8010728b:	6a 00                	push   $0x0
  pushl $93
8010728d:	6a 5d                	push   $0x5d
  jmp alltraps
8010728f:	e9 40 f6 ff ff       	jmp    801068d4 <alltraps>

80107294 <vector94>:
.globl vector94
vector94:
  pushl $0
80107294:	6a 00                	push   $0x0
  pushl $94
80107296:	6a 5e                	push   $0x5e
  jmp alltraps
80107298:	e9 37 f6 ff ff       	jmp    801068d4 <alltraps>

8010729d <vector95>:
.globl vector95
vector95:
  pushl $0
8010729d:	6a 00                	push   $0x0
  pushl $95
8010729f:	6a 5f                	push   $0x5f
  jmp alltraps
801072a1:	e9 2e f6 ff ff       	jmp    801068d4 <alltraps>

801072a6 <vector96>:
.globl vector96
vector96:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $96
801072a8:	6a 60                	push   $0x60
  jmp alltraps
801072aa:	e9 25 f6 ff ff       	jmp    801068d4 <alltraps>

801072af <vector97>:
.globl vector97
vector97:
  pushl $0
801072af:	6a 00                	push   $0x0
  pushl $97
801072b1:	6a 61                	push   $0x61
  jmp alltraps
801072b3:	e9 1c f6 ff ff       	jmp    801068d4 <alltraps>

801072b8 <vector98>:
.globl vector98
vector98:
  pushl $0
801072b8:	6a 00                	push   $0x0
  pushl $98
801072ba:	6a 62                	push   $0x62
  jmp alltraps
801072bc:	e9 13 f6 ff ff       	jmp    801068d4 <alltraps>

801072c1 <vector99>:
.globl vector99
vector99:
  pushl $0
801072c1:	6a 00                	push   $0x0
  pushl $99
801072c3:	6a 63                	push   $0x63
  jmp alltraps
801072c5:	e9 0a f6 ff ff       	jmp    801068d4 <alltraps>

801072ca <vector100>:
.globl vector100
vector100:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $100
801072cc:	6a 64                	push   $0x64
  jmp alltraps
801072ce:	e9 01 f6 ff ff       	jmp    801068d4 <alltraps>

801072d3 <vector101>:
.globl vector101
vector101:
  pushl $0
801072d3:	6a 00                	push   $0x0
  pushl $101
801072d5:	6a 65                	push   $0x65
  jmp alltraps
801072d7:	e9 f8 f5 ff ff       	jmp    801068d4 <alltraps>

801072dc <vector102>:
.globl vector102
vector102:
  pushl $0
801072dc:	6a 00                	push   $0x0
  pushl $102
801072de:	6a 66                	push   $0x66
  jmp alltraps
801072e0:	e9 ef f5 ff ff       	jmp    801068d4 <alltraps>

801072e5 <vector103>:
.globl vector103
vector103:
  pushl $0
801072e5:	6a 00                	push   $0x0
  pushl $103
801072e7:	6a 67                	push   $0x67
  jmp alltraps
801072e9:	e9 e6 f5 ff ff       	jmp    801068d4 <alltraps>

801072ee <vector104>:
.globl vector104
vector104:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $104
801072f0:	6a 68                	push   $0x68
  jmp alltraps
801072f2:	e9 dd f5 ff ff       	jmp    801068d4 <alltraps>

801072f7 <vector105>:
.globl vector105
vector105:
  pushl $0
801072f7:	6a 00                	push   $0x0
  pushl $105
801072f9:	6a 69                	push   $0x69
  jmp alltraps
801072fb:	e9 d4 f5 ff ff       	jmp    801068d4 <alltraps>

80107300 <vector106>:
.globl vector106
vector106:
  pushl $0
80107300:	6a 00                	push   $0x0
  pushl $106
80107302:	6a 6a                	push   $0x6a
  jmp alltraps
80107304:	e9 cb f5 ff ff       	jmp    801068d4 <alltraps>

80107309 <vector107>:
.globl vector107
vector107:
  pushl $0
80107309:	6a 00                	push   $0x0
  pushl $107
8010730b:	6a 6b                	push   $0x6b
  jmp alltraps
8010730d:	e9 c2 f5 ff ff       	jmp    801068d4 <alltraps>

80107312 <vector108>:
.globl vector108
vector108:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $108
80107314:	6a 6c                	push   $0x6c
  jmp alltraps
80107316:	e9 b9 f5 ff ff       	jmp    801068d4 <alltraps>

8010731b <vector109>:
.globl vector109
vector109:
  pushl $0
8010731b:	6a 00                	push   $0x0
  pushl $109
8010731d:	6a 6d                	push   $0x6d
  jmp alltraps
8010731f:	e9 b0 f5 ff ff       	jmp    801068d4 <alltraps>

80107324 <vector110>:
.globl vector110
vector110:
  pushl $0
80107324:	6a 00                	push   $0x0
  pushl $110
80107326:	6a 6e                	push   $0x6e
  jmp alltraps
80107328:	e9 a7 f5 ff ff       	jmp    801068d4 <alltraps>

8010732d <vector111>:
.globl vector111
vector111:
  pushl $0
8010732d:	6a 00                	push   $0x0
  pushl $111
8010732f:	6a 6f                	push   $0x6f
  jmp alltraps
80107331:	e9 9e f5 ff ff       	jmp    801068d4 <alltraps>

80107336 <vector112>:
.globl vector112
vector112:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $112
80107338:	6a 70                	push   $0x70
  jmp alltraps
8010733a:	e9 95 f5 ff ff       	jmp    801068d4 <alltraps>

8010733f <vector113>:
.globl vector113
vector113:
  pushl $0
8010733f:	6a 00                	push   $0x0
  pushl $113
80107341:	6a 71                	push   $0x71
  jmp alltraps
80107343:	e9 8c f5 ff ff       	jmp    801068d4 <alltraps>

80107348 <vector114>:
.globl vector114
vector114:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $114
8010734a:	6a 72                	push   $0x72
  jmp alltraps
8010734c:	e9 83 f5 ff ff       	jmp    801068d4 <alltraps>

80107351 <vector115>:
.globl vector115
vector115:
  pushl $0
80107351:	6a 00                	push   $0x0
  pushl $115
80107353:	6a 73                	push   $0x73
  jmp alltraps
80107355:	e9 7a f5 ff ff       	jmp    801068d4 <alltraps>

8010735a <vector116>:
.globl vector116
vector116:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $116
8010735c:	6a 74                	push   $0x74
  jmp alltraps
8010735e:	e9 71 f5 ff ff       	jmp    801068d4 <alltraps>

80107363 <vector117>:
.globl vector117
vector117:
  pushl $0
80107363:	6a 00                	push   $0x0
  pushl $117
80107365:	6a 75                	push   $0x75
  jmp alltraps
80107367:	e9 68 f5 ff ff       	jmp    801068d4 <alltraps>

8010736c <vector118>:
.globl vector118
vector118:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $118
8010736e:	6a 76                	push   $0x76
  jmp alltraps
80107370:	e9 5f f5 ff ff       	jmp    801068d4 <alltraps>

80107375 <vector119>:
.globl vector119
vector119:
  pushl $0
80107375:	6a 00                	push   $0x0
  pushl $119
80107377:	6a 77                	push   $0x77
  jmp alltraps
80107379:	e9 56 f5 ff ff       	jmp    801068d4 <alltraps>

8010737e <vector120>:
.globl vector120
vector120:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $120
80107380:	6a 78                	push   $0x78
  jmp alltraps
80107382:	e9 4d f5 ff ff       	jmp    801068d4 <alltraps>

80107387 <vector121>:
.globl vector121
vector121:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $121
80107389:	6a 79                	push   $0x79
  jmp alltraps
8010738b:	e9 44 f5 ff ff       	jmp    801068d4 <alltraps>

80107390 <vector122>:
.globl vector122
vector122:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $122
80107392:	6a 7a                	push   $0x7a
  jmp alltraps
80107394:	e9 3b f5 ff ff       	jmp    801068d4 <alltraps>

80107399 <vector123>:
.globl vector123
vector123:
  pushl $0
80107399:	6a 00                	push   $0x0
  pushl $123
8010739b:	6a 7b                	push   $0x7b
  jmp alltraps
8010739d:	e9 32 f5 ff ff       	jmp    801068d4 <alltraps>

801073a2 <vector124>:
.globl vector124
vector124:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $124
801073a4:	6a 7c                	push   $0x7c
  jmp alltraps
801073a6:	e9 29 f5 ff ff       	jmp    801068d4 <alltraps>

801073ab <vector125>:
.globl vector125
vector125:
  pushl $0
801073ab:	6a 00                	push   $0x0
  pushl $125
801073ad:	6a 7d                	push   $0x7d
  jmp alltraps
801073af:	e9 20 f5 ff ff       	jmp    801068d4 <alltraps>

801073b4 <vector126>:
.globl vector126
vector126:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $126
801073b6:	6a 7e                	push   $0x7e
  jmp alltraps
801073b8:	e9 17 f5 ff ff       	jmp    801068d4 <alltraps>

801073bd <vector127>:
.globl vector127
vector127:
  pushl $0
801073bd:	6a 00                	push   $0x0
  pushl $127
801073bf:	6a 7f                	push   $0x7f
  jmp alltraps
801073c1:	e9 0e f5 ff ff       	jmp    801068d4 <alltraps>

801073c6 <vector128>:
.globl vector128
vector128:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $128
801073c8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073cd:	e9 02 f5 ff ff       	jmp    801068d4 <alltraps>

801073d2 <vector129>:
.globl vector129
vector129:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $129
801073d4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073d9:	e9 f6 f4 ff ff       	jmp    801068d4 <alltraps>

801073de <vector130>:
.globl vector130
vector130:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $130
801073e0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073e5:	e9 ea f4 ff ff       	jmp    801068d4 <alltraps>

801073ea <vector131>:
.globl vector131
vector131:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $131
801073ec:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073f1:	e9 de f4 ff ff       	jmp    801068d4 <alltraps>

801073f6 <vector132>:
.globl vector132
vector132:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $132
801073f8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073fd:	e9 d2 f4 ff ff       	jmp    801068d4 <alltraps>

80107402 <vector133>:
.globl vector133
vector133:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $133
80107404:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107409:	e9 c6 f4 ff ff       	jmp    801068d4 <alltraps>

8010740e <vector134>:
.globl vector134
vector134:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $134
80107410:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107415:	e9 ba f4 ff ff       	jmp    801068d4 <alltraps>

8010741a <vector135>:
.globl vector135
vector135:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $135
8010741c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107421:	e9 ae f4 ff ff       	jmp    801068d4 <alltraps>

80107426 <vector136>:
.globl vector136
vector136:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $136
80107428:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010742d:	e9 a2 f4 ff ff       	jmp    801068d4 <alltraps>

80107432 <vector137>:
.globl vector137
vector137:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $137
80107434:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107439:	e9 96 f4 ff ff       	jmp    801068d4 <alltraps>

8010743e <vector138>:
.globl vector138
vector138:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $138
80107440:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107445:	e9 8a f4 ff ff       	jmp    801068d4 <alltraps>

8010744a <vector139>:
.globl vector139
vector139:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $139
8010744c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107451:	e9 7e f4 ff ff       	jmp    801068d4 <alltraps>

80107456 <vector140>:
.globl vector140
vector140:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $140
80107458:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010745d:	e9 72 f4 ff ff       	jmp    801068d4 <alltraps>

80107462 <vector141>:
.globl vector141
vector141:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $141
80107464:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107469:	e9 66 f4 ff ff       	jmp    801068d4 <alltraps>

8010746e <vector142>:
.globl vector142
vector142:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $142
80107470:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107475:	e9 5a f4 ff ff       	jmp    801068d4 <alltraps>

8010747a <vector143>:
.globl vector143
vector143:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $143
8010747c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107481:	e9 4e f4 ff ff       	jmp    801068d4 <alltraps>

80107486 <vector144>:
.globl vector144
vector144:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $144
80107488:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010748d:	e9 42 f4 ff ff       	jmp    801068d4 <alltraps>

80107492 <vector145>:
.globl vector145
vector145:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $145
80107494:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107499:	e9 36 f4 ff ff       	jmp    801068d4 <alltraps>

8010749e <vector146>:
.globl vector146
vector146:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $146
801074a0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074a5:	e9 2a f4 ff ff       	jmp    801068d4 <alltraps>

801074aa <vector147>:
.globl vector147
vector147:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $147
801074ac:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074b1:	e9 1e f4 ff ff       	jmp    801068d4 <alltraps>

801074b6 <vector148>:
.globl vector148
vector148:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $148
801074b8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074bd:	e9 12 f4 ff ff       	jmp    801068d4 <alltraps>

801074c2 <vector149>:
.globl vector149
vector149:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $149
801074c4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074c9:	e9 06 f4 ff ff       	jmp    801068d4 <alltraps>

801074ce <vector150>:
.globl vector150
vector150:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $150
801074d0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074d5:	e9 fa f3 ff ff       	jmp    801068d4 <alltraps>

801074da <vector151>:
.globl vector151
vector151:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $151
801074dc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074e1:	e9 ee f3 ff ff       	jmp    801068d4 <alltraps>

801074e6 <vector152>:
.globl vector152
vector152:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $152
801074e8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074ed:	e9 e2 f3 ff ff       	jmp    801068d4 <alltraps>

801074f2 <vector153>:
.globl vector153
vector153:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $153
801074f4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074f9:	e9 d6 f3 ff ff       	jmp    801068d4 <alltraps>

801074fe <vector154>:
.globl vector154
vector154:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $154
80107500:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107505:	e9 ca f3 ff ff       	jmp    801068d4 <alltraps>

8010750a <vector155>:
.globl vector155
vector155:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $155
8010750c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107511:	e9 be f3 ff ff       	jmp    801068d4 <alltraps>

80107516 <vector156>:
.globl vector156
vector156:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $156
80107518:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010751d:	e9 b2 f3 ff ff       	jmp    801068d4 <alltraps>

80107522 <vector157>:
.globl vector157
vector157:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $157
80107524:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107529:	e9 a6 f3 ff ff       	jmp    801068d4 <alltraps>

8010752e <vector158>:
.globl vector158
vector158:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $158
80107530:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107535:	e9 9a f3 ff ff       	jmp    801068d4 <alltraps>

8010753a <vector159>:
.globl vector159
vector159:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $159
8010753c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107541:	e9 8e f3 ff ff       	jmp    801068d4 <alltraps>

80107546 <vector160>:
.globl vector160
vector160:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $160
80107548:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010754d:	e9 82 f3 ff ff       	jmp    801068d4 <alltraps>

80107552 <vector161>:
.globl vector161
vector161:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $161
80107554:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107559:	e9 76 f3 ff ff       	jmp    801068d4 <alltraps>

8010755e <vector162>:
.globl vector162
vector162:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $162
80107560:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107565:	e9 6a f3 ff ff       	jmp    801068d4 <alltraps>

8010756a <vector163>:
.globl vector163
vector163:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $163
8010756c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107571:	e9 5e f3 ff ff       	jmp    801068d4 <alltraps>

80107576 <vector164>:
.globl vector164
vector164:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $164
80107578:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010757d:	e9 52 f3 ff ff       	jmp    801068d4 <alltraps>

80107582 <vector165>:
.globl vector165
vector165:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $165
80107584:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107589:	e9 46 f3 ff ff       	jmp    801068d4 <alltraps>

8010758e <vector166>:
.globl vector166
vector166:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $166
80107590:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107595:	e9 3a f3 ff ff       	jmp    801068d4 <alltraps>

8010759a <vector167>:
.globl vector167
vector167:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $167
8010759c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075a1:	e9 2e f3 ff ff       	jmp    801068d4 <alltraps>

801075a6 <vector168>:
.globl vector168
vector168:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $168
801075a8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075ad:	e9 22 f3 ff ff       	jmp    801068d4 <alltraps>

801075b2 <vector169>:
.globl vector169
vector169:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $169
801075b4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075b9:	e9 16 f3 ff ff       	jmp    801068d4 <alltraps>

801075be <vector170>:
.globl vector170
vector170:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $170
801075c0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075c5:	e9 0a f3 ff ff       	jmp    801068d4 <alltraps>

801075ca <vector171>:
.globl vector171
vector171:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $171
801075cc:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075d1:	e9 fe f2 ff ff       	jmp    801068d4 <alltraps>

801075d6 <vector172>:
.globl vector172
vector172:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $172
801075d8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075dd:	e9 f2 f2 ff ff       	jmp    801068d4 <alltraps>

801075e2 <vector173>:
.globl vector173
vector173:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $173
801075e4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075e9:	e9 e6 f2 ff ff       	jmp    801068d4 <alltraps>

801075ee <vector174>:
.globl vector174
vector174:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $174
801075f0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075f5:	e9 da f2 ff ff       	jmp    801068d4 <alltraps>

801075fa <vector175>:
.globl vector175
vector175:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $175
801075fc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107601:	e9 ce f2 ff ff       	jmp    801068d4 <alltraps>

80107606 <vector176>:
.globl vector176
vector176:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $176
80107608:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010760d:	e9 c2 f2 ff ff       	jmp    801068d4 <alltraps>

80107612 <vector177>:
.globl vector177
vector177:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $177
80107614:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107619:	e9 b6 f2 ff ff       	jmp    801068d4 <alltraps>

8010761e <vector178>:
.globl vector178
vector178:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $178
80107620:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107625:	e9 aa f2 ff ff       	jmp    801068d4 <alltraps>

8010762a <vector179>:
.globl vector179
vector179:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $179
8010762c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107631:	e9 9e f2 ff ff       	jmp    801068d4 <alltraps>

80107636 <vector180>:
.globl vector180
vector180:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $180
80107638:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010763d:	e9 92 f2 ff ff       	jmp    801068d4 <alltraps>

80107642 <vector181>:
.globl vector181
vector181:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $181
80107644:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107649:	e9 86 f2 ff ff       	jmp    801068d4 <alltraps>

8010764e <vector182>:
.globl vector182
vector182:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $182
80107650:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107655:	e9 7a f2 ff ff       	jmp    801068d4 <alltraps>

8010765a <vector183>:
.globl vector183
vector183:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $183
8010765c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107661:	e9 6e f2 ff ff       	jmp    801068d4 <alltraps>

80107666 <vector184>:
.globl vector184
vector184:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $184
80107668:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010766d:	e9 62 f2 ff ff       	jmp    801068d4 <alltraps>

80107672 <vector185>:
.globl vector185
vector185:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $185
80107674:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107679:	e9 56 f2 ff ff       	jmp    801068d4 <alltraps>

8010767e <vector186>:
.globl vector186
vector186:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $186
80107680:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107685:	e9 4a f2 ff ff       	jmp    801068d4 <alltraps>

8010768a <vector187>:
.globl vector187
vector187:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $187
8010768c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107691:	e9 3e f2 ff ff       	jmp    801068d4 <alltraps>

80107696 <vector188>:
.globl vector188
vector188:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $188
80107698:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010769d:	e9 32 f2 ff ff       	jmp    801068d4 <alltraps>

801076a2 <vector189>:
.globl vector189
vector189:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $189
801076a4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076a9:	e9 26 f2 ff ff       	jmp    801068d4 <alltraps>

801076ae <vector190>:
.globl vector190
vector190:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $190
801076b0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076b5:	e9 1a f2 ff ff       	jmp    801068d4 <alltraps>

801076ba <vector191>:
.globl vector191
vector191:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $191
801076bc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076c1:	e9 0e f2 ff ff       	jmp    801068d4 <alltraps>

801076c6 <vector192>:
.globl vector192
vector192:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $192
801076c8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076cd:	e9 02 f2 ff ff       	jmp    801068d4 <alltraps>

801076d2 <vector193>:
.globl vector193
vector193:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $193
801076d4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076d9:	e9 f6 f1 ff ff       	jmp    801068d4 <alltraps>

801076de <vector194>:
.globl vector194
vector194:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $194
801076e0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076e5:	e9 ea f1 ff ff       	jmp    801068d4 <alltraps>

801076ea <vector195>:
.globl vector195
vector195:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $195
801076ec:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076f1:	e9 de f1 ff ff       	jmp    801068d4 <alltraps>

801076f6 <vector196>:
.globl vector196
vector196:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $196
801076f8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076fd:	e9 d2 f1 ff ff       	jmp    801068d4 <alltraps>

80107702 <vector197>:
.globl vector197
vector197:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $197
80107704:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107709:	e9 c6 f1 ff ff       	jmp    801068d4 <alltraps>

8010770e <vector198>:
.globl vector198
vector198:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $198
80107710:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107715:	e9 ba f1 ff ff       	jmp    801068d4 <alltraps>

8010771a <vector199>:
.globl vector199
vector199:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $199
8010771c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107721:	e9 ae f1 ff ff       	jmp    801068d4 <alltraps>

80107726 <vector200>:
.globl vector200
vector200:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $200
80107728:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010772d:	e9 a2 f1 ff ff       	jmp    801068d4 <alltraps>

80107732 <vector201>:
.globl vector201
vector201:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $201
80107734:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107739:	e9 96 f1 ff ff       	jmp    801068d4 <alltraps>

8010773e <vector202>:
.globl vector202
vector202:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $202
80107740:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107745:	e9 8a f1 ff ff       	jmp    801068d4 <alltraps>

8010774a <vector203>:
.globl vector203
vector203:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $203
8010774c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107751:	e9 7e f1 ff ff       	jmp    801068d4 <alltraps>

80107756 <vector204>:
.globl vector204
vector204:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $204
80107758:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010775d:	e9 72 f1 ff ff       	jmp    801068d4 <alltraps>

80107762 <vector205>:
.globl vector205
vector205:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $205
80107764:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107769:	e9 66 f1 ff ff       	jmp    801068d4 <alltraps>

8010776e <vector206>:
.globl vector206
vector206:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $206
80107770:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107775:	e9 5a f1 ff ff       	jmp    801068d4 <alltraps>

8010777a <vector207>:
.globl vector207
vector207:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $207
8010777c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107781:	e9 4e f1 ff ff       	jmp    801068d4 <alltraps>

80107786 <vector208>:
.globl vector208
vector208:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $208
80107788:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010778d:	e9 42 f1 ff ff       	jmp    801068d4 <alltraps>

80107792 <vector209>:
.globl vector209
vector209:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $209
80107794:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107799:	e9 36 f1 ff ff       	jmp    801068d4 <alltraps>

8010779e <vector210>:
.globl vector210
vector210:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $210
801077a0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077a5:	e9 2a f1 ff ff       	jmp    801068d4 <alltraps>

801077aa <vector211>:
.globl vector211
vector211:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $211
801077ac:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077b1:	e9 1e f1 ff ff       	jmp    801068d4 <alltraps>

801077b6 <vector212>:
.globl vector212
vector212:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $212
801077b8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077bd:	e9 12 f1 ff ff       	jmp    801068d4 <alltraps>

801077c2 <vector213>:
.globl vector213
vector213:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $213
801077c4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077c9:	e9 06 f1 ff ff       	jmp    801068d4 <alltraps>

801077ce <vector214>:
.globl vector214
vector214:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $214
801077d0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077d5:	e9 fa f0 ff ff       	jmp    801068d4 <alltraps>

801077da <vector215>:
.globl vector215
vector215:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $215
801077dc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077e1:	e9 ee f0 ff ff       	jmp    801068d4 <alltraps>

801077e6 <vector216>:
.globl vector216
vector216:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $216
801077e8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077ed:	e9 e2 f0 ff ff       	jmp    801068d4 <alltraps>

801077f2 <vector217>:
.globl vector217
vector217:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $217
801077f4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077f9:	e9 d6 f0 ff ff       	jmp    801068d4 <alltraps>

801077fe <vector218>:
.globl vector218
vector218:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $218
80107800:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107805:	e9 ca f0 ff ff       	jmp    801068d4 <alltraps>

8010780a <vector219>:
.globl vector219
vector219:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $219
8010780c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107811:	e9 be f0 ff ff       	jmp    801068d4 <alltraps>

80107816 <vector220>:
.globl vector220
vector220:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $220
80107818:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010781d:	e9 b2 f0 ff ff       	jmp    801068d4 <alltraps>

80107822 <vector221>:
.globl vector221
vector221:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $221
80107824:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107829:	e9 a6 f0 ff ff       	jmp    801068d4 <alltraps>

8010782e <vector222>:
.globl vector222
vector222:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $222
80107830:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107835:	e9 9a f0 ff ff       	jmp    801068d4 <alltraps>

8010783a <vector223>:
.globl vector223
vector223:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $223
8010783c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107841:	e9 8e f0 ff ff       	jmp    801068d4 <alltraps>

80107846 <vector224>:
.globl vector224
vector224:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $224
80107848:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010784d:	e9 82 f0 ff ff       	jmp    801068d4 <alltraps>

80107852 <vector225>:
.globl vector225
vector225:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $225
80107854:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107859:	e9 76 f0 ff ff       	jmp    801068d4 <alltraps>

8010785e <vector226>:
.globl vector226
vector226:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $226
80107860:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107865:	e9 6a f0 ff ff       	jmp    801068d4 <alltraps>

8010786a <vector227>:
.globl vector227
vector227:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $227
8010786c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107871:	e9 5e f0 ff ff       	jmp    801068d4 <alltraps>

80107876 <vector228>:
.globl vector228
vector228:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $228
80107878:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010787d:	e9 52 f0 ff ff       	jmp    801068d4 <alltraps>

80107882 <vector229>:
.globl vector229
vector229:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $229
80107884:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107889:	e9 46 f0 ff ff       	jmp    801068d4 <alltraps>

8010788e <vector230>:
.globl vector230
vector230:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $230
80107890:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107895:	e9 3a f0 ff ff       	jmp    801068d4 <alltraps>

8010789a <vector231>:
.globl vector231
vector231:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $231
8010789c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078a1:	e9 2e f0 ff ff       	jmp    801068d4 <alltraps>

801078a6 <vector232>:
.globl vector232
vector232:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $232
801078a8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078ad:	e9 22 f0 ff ff       	jmp    801068d4 <alltraps>

801078b2 <vector233>:
.globl vector233
vector233:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $233
801078b4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078b9:	e9 16 f0 ff ff       	jmp    801068d4 <alltraps>

801078be <vector234>:
.globl vector234
vector234:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $234
801078c0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078c5:	e9 0a f0 ff ff       	jmp    801068d4 <alltraps>

801078ca <vector235>:
.globl vector235
vector235:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $235
801078cc:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078d1:	e9 fe ef ff ff       	jmp    801068d4 <alltraps>

801078d6 <vector236>:
.globl vector236
vector236:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $236
801078d8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078dd:	e9 f2 ef ff ff       	jmp    801068d4 <alltraps>

801078e2 <vector237>:
.globl vector237
vector237:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $237
801078e4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078e9:	e9 e6 ef ff ff       	jmp    801068d4 <alltraps>

801078ee <vector238>:
.globl vector238
vector238:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $238
801078f0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078f5:	e9 da ef ff ff       	jmp    801068d4 <alltraps>

801078fa <vector239>:
.globl vector239
vector239:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $239
801078fc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107901:	e9 ce ef ff ff       	jmp    801068d4 <alltraps>

80107906 <vector240>:
.globl vector240
vector240:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $240
80107908:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010790d:	e9 c2 ef ff ff       	jmp    801068d4 <alltraps>

80107912 <vector241>:
.globl vector241
vector241:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $241
80107914:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107919:	e9 b6 ef ff ff       	jmp    801068d4 <alltraps>

8010791e <vector242>:
.globl vector242
vector242:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $242
80107920:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107925:	e9 aa ef ff ff       	jmp    801068d4 <alltraps>

8010792a <vector243>:
.globl vector243
vector243:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $243
8010792c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107931:	e9 9e ef ff ff       	jmp    801068d4 <alltraps>

80107936 <vector244>:
.globl vector244
vector244:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $244
80107938:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010793d:	e9 92 ef ff ff       	jmp    801068d4 <alltraps>

80107942 <vector245>:
.globl vector245
vector245:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $245
80107944:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107949:	e9 86 ef ff ff       	jmp    801068d4 <alltraps>

8010794e <vector246>:
.globl vector246
vector246:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $246
80107950:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107955:	e9 7a ef ff ff       	jmp    801068d4 <alltraps>

8010795a <vector247>:
.globl vector247
vector247:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $247
8010795c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107961:	e9 6e ef ff ff       	jmp    801068d4 <alltraps>

80107966 <vector248>:
.globl vector248
vector248:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $248
80107968:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010796d:	e9 62 ef ff ff       	jmp    801068d4 <alltraps>

80107972 <vector249>:
.globl vector249
vector249:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $249
80107974:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107979:	e9 56 ef ff ff       	jmp    801068d4 <alltraps>

8010797e <vector250>:
.globl vector250
vector250:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $250
80107980:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107985:	e9 4a ef ff ff       	jmp    801068d4 <alltraps>

8010798a <vector251>:
.globl vector251
vector251:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $251
8010798c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107991:	e9 3e ef ff ff       	jmp    801068d4 <alltraps>

80107996 <vector252>:
.globl vector252
vector252:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $252
80107998:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010799d:	e9 32 ef ff ff       	jmp    801068d4 <alltraps>

801079a2 <vector253>:
.globl vector253
vector253:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $253
801079a4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079a9:	e9 26 ef ff ff       	jmp    801068d4 <alltraps>

801079ae <vector254>:
.globl vector254
vector254:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $254
801079b0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079b5:	e9 1a ef ff ff       	jmp    801068d4 <alltraps>

801079ba <vector255>:
.globl vector255
vector255:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $255
801079bc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079c1:	e9 0e ef ff ff       	jmp    801068d4 <alltraps>
801079c6:	66 90                	xchg   %ax,%ax

801079c8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079c8:	55                   	push   %ebp
801079c9:	89 e5                	mov    %esp,%ebp
801079cb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801079ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801079d1:	83 e8 01             	sub    $0x1,%eax
801079d4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079d8:	8b 45 08             	mov    0x8(%ebp),%eax
801079db:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079df:	8b 45 08             	mov    0x8(%ebp),%eax
801079e2:	c1 e8 10             	shr    $0x10,%eax
801079e5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801079e9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079ec:	0f 01 10             	lgdtl  (%eax)
}
801079ef:	c9                   	leave  
801079f0:	c3                   	ret    

801079f1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801079f1:	55                   	push   %ebp
801079f2:	89 e5                	mov    %esp,%ebp
801079f4:	83 ec 04             	sub    $0x4,%esp
801079f7:	8b 45 08             	mov    0x8(%ebp),%eax
801079fa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079fe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a02:	0f 00 d8             	ltr    %ax
}
80107a05:	c9                   	leave  
80107a06:	c3                   	ret    

80107a07 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a07:	55                   	push   %ebp
80107a08:	89 e5                	mov    %esp,%ebp
80107a0a:	83 ec 04             	sub    $0x4,%esp
80107a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a10:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a14:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a18:	8e e8                	mov    %eax,%gs
}
80107a1a:	c9                   	leave  
80107a1b:	c3                   	ret    

80107a1c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a1c:	55                   	push   %ebp
80107a1d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a22:	0f 22 d8             	mov    %eax,%cr3
}
80107a25:	5d                   	pop    %ebp
80107a26:	c3                   	ret    

80107a27 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a27:	55                   	push   %ebp
80107a28:	89 e5                	mov    %esp,%ebp
80107a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2d:	05 00 00 00 80       	add    $0x80000000,%eax
80107a32:	5d                   	pop    %ebp
80107a33:	c3                   	ret    

80107a34 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a34:	55                   	push   %ebp
80107a35:	89 e5                	mov    %esp,%ebp
80107a37:	8b 45 08             	mov    0x8(%ebp),%eax
80107a3a:	05 00 00 00 80       	add    $0x80000000,%eax
80107a3f:	5d                   	pop    %ebp
80107a40:	c3                   	ret    

80107a41 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a41:	55                   	push   %ebp
80107a42:	89 e5                	mov    %esp,%ebp
80107a44:	53                   	push   %ebx
80107a45:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a48:	e8 ec b4 ff ff       	call   80102f39 <cpunum>
80107a4d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a53:	05 60 23 11 80       	add    $0x80112360,%eax
80107a58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a67:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a70:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a77:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a7b:	83 e2 f0             	and    $0xfffffff0,%edx
80107a7e:	83 ca 0a             	or     $0xa,%edx
80107a81:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a87:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a8b:	83 ca 10             	or     $0x10,%edx
80107a8e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a98:	83 e2 9f             	and    $0xffffff9f,%edx
80107a9b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aa5:	83 ca 80             	or     $0xffffff80,%edx
80107aa8:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aae:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ab2:	83 ca 0f             	or     $0xf,%edx
80107ab5:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107abf:	83 e2 ef             	and    $0xffffffef,%edx
80107ac2:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107acc:	83 e2 df             	and    $0xffffffdf,%edx
80107acf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ad9:	83 ca 40             	or     $0x40,%edx
80107adc:	88 50 7e             	mov    %dl,0x7e(%eax)
80107adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae6:	83 ca 80             	or     $0xffffff80,%edx
80107ae9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107afd:	ff ff 
80107aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b02:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b09:	00 00 
80107b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b18:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b1f:	83 e2 f0             	and    $0xfffffff0,%edx
80107b22:	83 ca 02             	or     $0x2,%edx
80107b25:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b35:	83 ca 10             	or     $0x10,%edx
80107b38:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b41:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b48:	83 e2 9f             	and    $0xffffff9f,%edx
80107b4b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b54:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b5b:	83 ca 80             	or     $0xffffff80,%edx
80107b5e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b67:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b6e:	83 ca 0f             	or     $0xf,%edx
80107b71:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b81:	83 e2 ef             	and    $0xffffffef,%edx
80107b84:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b94:	83 e2 df             	and    $0xffffffdf,%edx
80107b97:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ba7:	83 ca 40             	or     $0x40,%edx
80107baa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bba:	83 ca 80             	or     $0xffffff80,%edx
80107bbd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107bd7:	ff ff 
80107bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107be3:	00 00 
80107be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bf9:	83 e2 f0             	and    $0xfffffff0,%edx
80107bfc:	83 ca 0a             	or     $0xa,%edx
80107bff:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c08:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c0f:	83 ca 10             	or     $0x10,%edx
80107c12:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c22:	83 ca 60             	or     $0x60,%edx
80107c25:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c35:	83 ca 80             	or     $0xffffff80,%edx
80107c38:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c41:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c48:	83 ca 0f             	or     $0xf,%edx
80107c4b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c54:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c5b:	83 e2 ef             	and    $0xffffffef,%edx
80107c5e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c67:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c6e:	83 e2 df             	and    $0xffffffdf,%edx
80107c71:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c81:	83 ca 40             	or     $0x40,%edx
80107c84:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c94:	83 ca 80             	or     $0xffffff80,%edx
80107c97:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107cb1:	ff ff 
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107cbd:	00 00 
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ccc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cd3:	83 e2 f0             	and    $0xfffffff0,%edx
80107cd6:	83 ca 02             	or     $0x2,%edx
80107cd9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ce9:	83 ca 10             	or     $0x10,%edx
80107cec:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cfc:	83 ca 60             	or     $0x60,%edx
80107cff:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d08:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d0f:	83 ca 80             	or     $0xffffff80,%edx
80107d12:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d22:	83 ca 0f             	or     $0xf,%edx
80107d25:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d35:	83 e2 ef             	and    $0xffffffef,%edx
80107d38:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d41:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d48:	83 e2 df             	and    $0xffffffdf,%edx
80107d4b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d54:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d5b:	83 ca 40             	or     $0x40,%edx
80107d5e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d67:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d6e:	83 ca 80             	or     $0xffffff80,%edx
80107d71:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d84:	05 b4 00 00 00       	add    $0xb4,%eax
80107d89:	89 c3                	mov    %eax,%ebx
80107d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8e:	05 b4 00 00 00       	add    $0xb4,%eax
80107d93:	c1 e8 10             	shr    $0x10,%eax
80107d96:	89 c1                	mov    %eax,%ecx
80107d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9b:	05 b4 00 00 00       	add    $0xb4,%eax
80107da0:	c1 e8 18             	shr    $0x18,%eax
80107da3:	89 c2                	mov    %eax,%edx
80107da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da8:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107daf:	00 00 
80107db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db4:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbe:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107dce:	83 e1 f0             	and    $0xfffffff0,%ecx
80107dd1:	83 c9 02             	or     $0x2,%ecx
80107dd4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddd:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107de4:	83 c9 10             	or     $0x10,%ecx
80107de7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107df7:	83 e1 9f             	and    $0xffffff9f,%ecx
80107dfa:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e03:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e0a:	83 c9 80             	or     $0xffffff80,%ecx
80107e0d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e16:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e1d:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e20:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e29:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e30:	83 e1 ef             	and    $0xffffffef,%ecx
80107e33:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e43:	83 e1 df             	and    $0xffffffdf,%ecx
80107e46:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e56:	83 c9 40             	or     $0x40,%ecx
80107e59:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e62:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e69:	83 c9 80             	or     $0xffffff80,%ecx
80107e6c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	83 c0 70             	add    $0x70,%eax
80107e81:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107e88:	00 
80107e89:	89 04 24             	mov    %eax,(%esp)
80107e8c:	e8 37 fb ff ff       	call   801079c8 <lgdt>
  loadgs(SEG_KCPU << 3);
80107e91:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107e98:	e8 6a fb ff ff       	call   80107a07 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107ea6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ead:	00 00 00 00 
}
80107eb1:	83 c4 24             	add    $0x24,%esp
80107eb4:	5b                   	pop    %ebx
80107eb5:	5d                   	pop    %ebp
80107eb6:	c3                   	ret    

80107eb7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107eb7:	55                   	push   %ebp
80107eb8:	89 e5                	mov    %esp,%ebp
80107eba:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ec0:	c1 e8 16             	shr    $0x16,%eax
80107ec3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107eca:	8b 45 08             	mov    0x8(%ebp),%eax
80107ecd:	01 d0                	add    %edx,%eax
80107ecf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ed5:	8b 00                	mov    (%eax),%eax
80107ed7:	83 e0 01             	and    $0x1,%eax
80107eda:	85 c0                	test   %eax,%eax
80107edc:	74 17                	je     80107ef5 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee1:	8b 00                	mov    (%eax),%eax
80107ee3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee8:	89 04 24             	mov    %eax,(%esp)
80107eeb:	e8 44 fb ff ff       	call   80107a34 <p2v>
80107ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ef3:	eb 4b                	jmp    80107f40 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107ef5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ef9:	74 0e                	je     80107f09 <walkpgdir+0x52>
80107efb:	e8 a3 ac ff ff       	call   80102ba3 <kalloc>
80107f00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f07:	75 07                	jne    80107f10 <walkpgdir+0x59>
      return 0;
80107f09:	b8 00 00 00 00       	mov    $0x0,%eax
80107f0e:	eb 47                	jmp    80107f57 <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f10:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f17:	00 
80107f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f1f:	00 
80107f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f23:	89 04 24             	mov    %eax,(%esp)
80107f26:	e8 eb d4 ff ff       	call   80105416 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2e:	89 04 24             	mov    %eax,(%esp)
80107f31:	e8 f1 fa ff ff       	call   80107a27 <v2p>
80107f36:	83 c8 07             	or     $0x7,%eax
80107f39:	89 c2                	mov    %eax,%edx
80107f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f3e:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f40:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f43:	c1 e8 0c             	shr    $0xc,%eax
80107f46:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f4b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f55:	01 d0                	add    %edx,%eax
}
80107f57:	c9                   	leave  
80107f58:	c3                   	ret    

80107f59 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f59:	55                   	push   %ebp
80107f5a:	89 e5                	mov    %esp,%ebp
80107f5c:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f6d:	8b 45 10             	mov    0x10(%ebp),%eax
80107f70:	01 d0                	add    %edx,%eax
80107f72:	83 e8 01             	sub    $0x1,%eax
80107f75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f7d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107f84:	00 
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80107f8f:	89 04 24             	mov    %eax,(%esp)
80107f92:	e8 20 ff ff ff       	call   80107eb7 <walkpgdir>
80107f97:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f9a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f9e:	75 07                	jne    80107fa7 <mappages+0x4e>
      return -1;
80107fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fa5:	eb 48                	jmp    80107fef <mappages+0x96>
    if(*pte & PTE_P)
80107fa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107faa:	8b 00                	mov    (%eax),%eax
80107fac:	83 e0 01             	and    $0x1,%eax
80107faf:	85 c0                	test   %eax,%eax
80107fb1:	74 0c                	je     80107fbf <mappages+0x66>
      panic("remap");
80107fb3:	c7 04 24 60 8e 10 80 	movl   $0x80108e60,(%esp)
80107fba:	e8 7b 85 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107fbf:	8b 45 18             	mov    0x18(%ebp),%eax
80107fc2:	0b 45 14             	or     0x14(%ebp),%eax
80107fc5:	83 c8 01             	or     $0x1,%eax
80107fc8:	89 c2                	mov    %eax,%edx
80107fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fcd:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fd5:	75 08                	jne    80107fdf <mappages+0x86>
      break;
80107fd7:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107fd8:	b8 00 00 00 00       	mov    $0x0,%eax
80107fdd:	eb 10                	jmp    80107fef <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107fdf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fe6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107fed:	eb 8e                	jmp    80107f7d <mappages+0x24>
  return 0;
}
80107fef:	c9                   	leave  
80107ff0:	c3                   	ret    

80107ff1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107ff1:	55                   	push   %ebp
80107ff2:	89 e5                	mov    %esp,%ebp
80107ff4:	53                   	push   %ebx
80107ff5:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ff8:	e8 a6 ab ff ff       	call   80102ba3 <kalloc>
80107ffd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108000:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108004:	75 0a                	jne    80108010 <setupkvm+0x1f>
    return 0;
80108006:	b8 00 00 00 00       	mov    $0x0,%eax
8010800b:	e9 98 00 00 00       	jmp    801080a8 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108010:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108017:	00 
80108018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010801f:	00 
80108020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108023:	89 04 24             	mov    %eax,(%esp)
80108026:	e8 eb d3 ff ff       	call   80105416 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010802b:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108032:	e8 fd f9 ff ff       	call   80107a34 <p2v>
80108037:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010803c:	76 0c                	jbe    8010804a <setupkvm+0x59>
    panic("PHYSTOP too high");
8010803e:	c7 04 24 66 8e 10 80 	movl   $0x80108e66,(%esp)
80108045:	e8 f0 84 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010804a:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80108051:	eb 49                	jmp    8010809c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108056:	8b 48 0c             	mov    0xc(%eax),%ecx
80108059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805c:	8b 50 04             	mov    0x4(%eax),%edx
8010805f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108062:	8b 58 08             	mov    0x8(%eax),%ebx
80108065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108068:	8b 40 04             	mov    0x4(%eax),%eax
8010806b:	29 c3                	sub    %eax,%ebx
8010806d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108070:	8b 00                	mov    (%eax),%eax
80108072:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108076:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010807a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010807e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108082:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108085:	89 04 24             	mov    %eax,(%esp)
80108088:	e8 cc fe ff ff       	call   80107f59 <mappages>
8010808d:	85 c0                	test   %eax,%eax
8010808f:	79 07                	jns    80108098 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108091:	b8 00 00 00 00       	mov    $0x0,%eax
80108096:	eb 10                	jmp    801080a8 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108098:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010809c:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
801080a3:	72 ae                	jb     80108053 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801080a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080a8:	83 c4 34             	add    $0x34,%esp
801080ab:	5b                   	pop    %ebx
801080ac:	5d                   	pop    %ebp
801080ad:	c3                   	ret    

801080ae <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080ae:	55                   	push   %ebp
801080af:	89 e5                	mov    %esp,%ebp
801080b1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080b4:	e8 38 ff ff ff       	call   80107ff1 <setupkvm>
801080b9:	a3 38 51 11 80       	mov    %eax,0x80115138
  switchkvm();
801080be:	e8 02 00 00 00       	call   801080c5 <switchkvm>
}
801080c3:	c9                   	leave  
801080c4:	c3                   	ret    

801080c5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080c5:	55                   	push   %ebp
801080c6:	89 e5                	mov    %esp,%ebp
801080c8:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080cb:	a1 38 51 11 80       	mov    0x80115138,%eax
801080d0:	89 04 24             	mov    %eax,(%esp)
801080d3:	e8 4f f9 ff ff       	call   80107a27 <v2p>
801080d8:	89 04 24             	mov    %eax,(%esp)
801080db:	e8 3c f9 ff ff       	call   80107a1c <lcr3>
}
801080e0:	c9                   	leave  
801080e1:	c3                   	ret    

801080e2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080e2:	55                   	push   %ebp
801080e3:	89 e5                	mov    %esp,%ebp
801080e5:	53                   	push   %ebx
801080e6:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801080e9:	e8 25 d2 ff ff       	call   80105313 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080f4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080fb:	83 c2 08             	add    $0x8,%edx
801080fe:	89 d3                	mov    %edx,%ebx
80108100:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108107:	83 c2 08             	add    $0x8,%edx
8010810a:	c1 ea 10             	shr    $0x10,%edx
8010810d:	89 d1                	mov    %edx,%ecx
8010810f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108116:	83 c2 08             	add    $0x8,%edx
80108119:	c1 ea 18             	shr    $0x18,%edx
8010811c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108123:	67 00 
80108125:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010812c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108132:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108139:	83 e1 f0             	and    $0xfffffff0,%ecx
8010813c:	83 c9 09             	or     $0x9,%ecx
8010813f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108145:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010814c:	83 c9 10             	or     $0x10,%ecx
8010814f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108155:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010815c:	83 e1 9f             	and    $0xffffff9f,%ecx
8010815f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108165:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010816c:	83 c9 80             	or     $0xffffff80,%ecx
8010816f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108175:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010817c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010817f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108185:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010818c:	83 e1 ef             	and    $0xffffffef,%ecx
8010818f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108195:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010819c:	83 e1 df             	and    $0xffffffdf,%ecx
8010819f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081a5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081ac:	83 c9 40             	or     $0x40,%ecx
801081af:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081b5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081bc:	83 e1 7f             	and    $0x7f,%ecx
801081bf:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081c5:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081cb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081d1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081d8:	83 e2 ef             	and    $0xffffffef,%edx
801081db:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081e1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081e7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081f3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801081fa:	8b 52 08             	mov    0x8(%edx),%edx
801081fd:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108203:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108206:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
8010820d:	e8 df f7 ff ff       	call   801079f1 <ltr>
  if(p->pgdir == 0)
80108212:	8b 45 08             	mov    0x8(%ebp),%eax
80108215:	8b 40 04             	mov    0x4(%eax),%eax
80108218:	85 c0                	test   %eax,%eax
8010821a:	75 0c                	jne    80108228 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010821c:	c7 04 24 77 8e 10 80 	movl   $0x80108e77,(%esp)
80108223:	e8 12 83 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108228:	8b 45 08             	mov    0x8(%ebp),%eax
8010822b:	8b 40 04             	mov    0x4(%eax),%eax
8010822e:	89 04 24             	mov    %eax,(%esp)
80108231:	e8 f1 f7 ff ff       	call   80107a27 <v2p>
80108236:	89 04 24             	mov    %eax,(%esp)
80108239:	e8 de f7 ff ff       	call   80107a1c <lcr3>
  popcli();
8010823e:	e8 14 d1 ff ff       	call   80105357 <popcli>
}
80108243:	83 c4 14             	add    $0x14,%esp
80108246:	5b                   	pop    %ebx
80108247:	5d                   	pop    %ebp
80108248:	c3                   	ret    

80108249 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108249:	55                   	push   %ebp
8010824a:	89 e5                	mov    %esp,%ebp
8010824c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010824f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108256:	76 0c                	jbe    80108264 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108258:	c7 04 24 8b 8e 10 80 	movl   $0x80108e8b,(%esp)
8010825f:	e8 d6 82 ff ff       	call   8010053a <panic>
  mem = kalloc();
80108264:	e8 3a a9 ff ff       	call   80102ba3 <kalloc>
80108269:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010826c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108273:	00 
80108274:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010827b:	00 
8010827c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827f:	89 04 24             	mov    %eax,(%esp)
80108282:	e8 8f d1 ff ff       	call   80105416 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828a:	89 04 24             	mov    %eax,(%esp)
8010828d:	e8 95 f7 ff ff       	call   80107a27 <v2p>
80108292:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108299:	00 
8010829a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010829e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082a5:	00 
801082a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082ad:	00 
801082ae:	8b 45 08             	mov    0x8(%ebp),%eax
801082b1:	89 04 24             	mov    %eax,(%esp)
801082b4:	e8 a0 fc ff ff       	call   80107f59 <mappages>
  memmove(mem, init, sz);
801082b9:	8b 45 10             	mov    0x10(%ebp),%eax
801082bc:	89 44 24 08          	mov    %eax,0x8(%esp)
801082c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801082c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801082c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ca:	89 04 24             	mov    %eax,(%esp)
801082cd:	e8 13 d2 ff ff       	call   801054e5 <memmove>
}
801082d2:	c9                   	leave  
801082d3:	c3                   	ret    

801082d4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082d4:	55                   	push   %ebp
801082d5:	89 e5                	mov    %esp,%ebp
801082d7:	53                   	push   %ebx
801082d8:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082db:	8b 45 0c             	mov    0xc(%ebp),%eax
801082de:	25 ff 0f 00 00       	and    $0xfff,%eax
801082e3:	85 c0                	test   %eax,%eax
801082e5:	74 0c                	je     801082f3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801082e7:	c7 04 24 a8 8e 10 80 	movl   $0x80108ea8,(%esp)
801082ee:	e8 47 82 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082fa:	e9 a9 00 00 00       	jmp    801083a8 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801082ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108302:	8b 55 0c             	mov    0xc(%ebp),%edx
80108305:	01 d0                	add    %edx,%eax
80108307:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010830e:	00 
8010830f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108313:	8b 45 08             	mov    0x8(%ebp),%eax
80108316:	89 04 24             	mov    %eax,(%esp)
80108319:	e8 99 fb ff ff       	call   80107eb7 <walkpgdir>
8010831e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108321:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108325:	75 0c                	jne    80108333 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108327:	c7 04 24 cb 8e 10 80 	movl   $0x80108ecb,(%esp)
8010832e:	e8 07 82 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
80108333:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108336:	8b 00                	mov    (%eax),%eax
80108338:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010833d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108343:	8b 55 18             	mov    0x18(%ebp),%edx
80108346:	29 c2                	sub    %eax,%edx
80108348:	89 d0                	mov    %edx,%eax
8010834a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010834f:	77 0f                	ja     80108360 <loaduvm+0x8c>
      n = sz - i;
80108351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108354:	8b 55 18             	mov    0x18(%ebp),%edx
80108357:	29 c2                	sub    %eax,%edx
80108359:	89 d0                	mov    %edx,%eax
8010835b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010835e:	eb 07                	jmp    80108367 <loaduvm+0x93>
    else
      n = PGSIZE;
80108360:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836a:	8b 55 14             	mov    0x14(%ebp),%edx
8010836d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108370:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108373:	89 04 24             	mov    %eax,(%esp)
80108376:	e8 b9 f6 ff ff       	call   80107a34 <p2v>
8010837b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010837e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108382:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108386:	89 44 24 04          	mov    %eax,0x4(%esp)
8010838a:	8b 45 10             	mov    0x10(%ebp),%eax
8010838d:	89 04 24             	mov    %eax,(%esp)
80108390:	e8 56 9a ff ff       	call   80101deb <readi>
80108395:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108398:	74 07                	je     801083a1 <loaduvm+0xcd>
      return -1;
8010839a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010839f:	eb 18                	jmp    801083b9 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801083a1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ab:	3b 45 18             	cmp    0x18(%ebp),%eax
801083ae:	0f 82 4b ff ff ff    	jb     801082ff <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801083b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083b9:	83 c4 24             	add    $0x24,%esp
801083bc:	5b                   	pop    %ebx
801083bd:	5d                   	pop    %ebp
801083be:	c3                   	ret    

801083bf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083bf:	55                   	push   %ebp
801083c0:	89 e5                	mov    %esp,%ebp
801083c2:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083c5:	8b 45 10             	mov    0x10(%ebp),%eax
801083c8:	85 c0                	test   %eax,%eax
801083ca:	79 0a                	jns    801083d6 <allocuvm+0x17>
    return 0;
801083cc:	b8 00 00 00 00       	mov    $0x0,%eax
801083d1:	e9 c1 00 00 00       	jmp    80108497 <allocuvm+0xd8>
  if(newsz < oldsz)
801083d6:	8b 45 10             	mov    0x10(%ebp),%eax
801083d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083dc:	73 08                	jae    801083e6 <allocuvm+0x27>
    return oldsz;
801083de:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e1:	e9 b1 00 00 00       	jmp    80108497 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801083e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e9:	05 ff 0f 00 00       	add    $0xfff,%eax
801083ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083f6:	e9 8d 00 00 00       	jmp    80108488 <allocuvm+0xc9>
    mem = kalloc();
801083fb:	e8 a3 a7 ff ff       	call   80102ba3 <kalloc>
80108400:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108403:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108407:	75 2c                	jne    80108435 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108409:	c7 04 24 e9 8e 10 80 	movl   $0x80108ee9,(%esp)
80108410:	e8 8b 7f ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108415:	8b 45 0c             	mov    0xc(%ebp),%eax
80108418:	89 44 24 08          	mov    %eax,0x8(%esp)
8010841c:	8b 45 10             	mov    0x10(%ebp),%eax
8010841f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108423:	8b 45 08             	mov    0x8(%ebp),%eax
80108426:	89 04 24             	mov    %eax,(%esp)
80108429:	e8 6b 00 00 00       	call   80108499 <deallocuvm>
      return 0;
8010842e:	b8 00 00 00 00       	mov    $0x0,%eax
80108433:	eb 62                	jmp    80108497 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108435:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010843c:	00 
8010843d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108444:	00 
80108445:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108448:	89 04 24             	mov    %eax,(%esp)
8010844b:	e8 c6 cf ff ff       	call   80105416 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108453:	89 04 24             	mov    %eax,(%esp)
80108456:	e8 cc f5 ff ff       	call   80107a27 <v2p>
8010845b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010845e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108465:	00 
80108466:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010846a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108471:	00 
80108472:	89 54 24 04          	mov    %edx,0x4(%esp)
80108476:	8b 45 08             	mov    0x8(%ebp),%eax
80108479:	89 04 24             	mov    %eax,(%esp)
8010847c:	e8 d8 fa ff ff       	call   80107f59 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108481:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010848b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010848e:	0f 82 67 ff ff ff    	jb     801083fb <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108494:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108497:	c9                   	leave  
80108498:	c3                   	ret    

80108499 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108499:	55                   	push   %ebp
8010849a:	89 e5                	mov    %esp,%ebp
8010849c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010849f:	8b 45 10             	mov    0x10(%ebp),%eax
801084a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084a5:	72 08                	jb     801084af <deallocuvm+0x16>
    return oldsz;
801084a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801084aa:	e9 a4 00 00 00       	jmp    80108553 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801084af:	8b 45 10             	mov    0x10(%ebp),%eax
801084b2:	05 ff 0f 00 00       	add    $0xfff,%eax
801084b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084bf:	e9 80 00 00 00       	jmp    80108544 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084ce:	00 
801084cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801084d3:	8b 45 08             	mov    0x8(%ebp),%eax
801084d6:	89 04 24             	mov    %eax,(%esp)
801084d9:	e8 d9 f9 ff ff       	call   80107eb7 <walkpgdir>
801084de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801084e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084e5:	75 09                	jne    801084f0 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801084e7:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801084ee:	eb 4d                	jmp    8010853d <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801084f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f3:	8b 00                	mov    (%eax),%eax
801084f5:	83 e0 01             	and    $0x1,%eax
801084f8:	85 c0                	test   %eax,%eax
801084fa:	74 41                	je     8010853d <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801084fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084ff:	8b 00                	mov    (%eax),%eax
80108501:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108506:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108509:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010850d:	75 0c                	jne    8010851b <deallocuvm+0x82>
        panic("kfree");
8010850f:	c7 04 24 01 8f 10 80 	movl   $0x80108f01,(%esp)
80108516:	e8 1f 80 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
8010851b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010851e:	89 04 24             	mov    %eax,(%esp)
80108521:	e8 0e f5 ff ff       	call   80107a34 <p2v>
80108526:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108529:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010852c:	89 04 24             	mov    %eax,(%esp)
8010852f:	e8 d6 a5 ff ff       	call   80102b0a <kfree>
      *pte = 0;
80108534:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108537:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010853d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108544:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108547:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010854a:	0f 82 74 ff ff ff    	jb     801084c4 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108550:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108553:	c9                   	leave  
80108554:	c3                   	ret    

80108555 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108555:	55                   	push   %ebp
80108556:	89 e5                	mov    %esp,%ebp
80108558:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010855b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010855f:	75 0c                	jne    8010856d <freevm+0x18>
    panic("freevm: no pgdir");
80108561:	c7 04 24 07 8f 10 80 	movl   $0x80108f07,(%esp)
80108568:	e8 cd 7f ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010856d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108574:	00 
80108575:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010857c:	80 
8010857d:	8b 45 08             	mov    0x8(%ebp),%eax
80108580:	89 04 24             	mov    %eax,(%esp)
80108583:	e8 11 ff ff ff       	call   80108499 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108588:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010858f:	eb 48                	jmp    801085d9 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108594:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010859b:	8b 45 08             	mov    0x8(%ebp),%eax
8010859e:	01 d0                	add    %edx,%eax
801085a0:	8b 00                	mov    (%eax),%eax
801085a2:	83 e0 01             	and    $0x1,%eax
801085a5:	85 c0                	test   %eax,%eax
801085a7:	74 2c                	je     801085d5 <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801085a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085b3:	8b 45 08             	mov    0x8(%ebp),%eax
801085b6:	01 d0                	add    %edx,%eax
801085b8:	8b 00                	mov    (%eax),%eax
801085ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085bf:	89 04 24             	mov    %eax,(%esp)
801085c2:	e8 6d f4 ff ff       	call   80107a34 <p2v>
801085c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801085ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085cd:	89 04 24             	mov    %eax,(%esp)
801085d0:	e8 35 a5 ff ff       	call   80102b0a <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801085d5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085d9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085e0:	76 af                	jbe    80108591 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801085e2:	8b 45 08             	mov    0x8(%ebp),%eax
801085e5:	89 04 24             	mov    %eax,(%esp)
801085e8:	e8 1d a5 ff ff       	call   80102b0a <kfree>
}
801085ed:	c9                   	leave  
801085ee:	c3                   	ret    

801085ef <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801085ef:	55                   	push   %ebp
801085f0:	89 e5                	mov    %esp,%ebp
801085f2:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085fc:	00 
801085fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108600:	89 44 24 04          	mov    %eax,0x4(%esp)
80108604:	8b 45 08             	mov    0x8(%ebp),%eax
80108607:	89 04 24             	mov    %eax,(%esp)
8010860a:	e8 a8 f8 ff ff       	call   80107eb7 <walkpgdir>
8010860f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108612:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108616:	75 0c                	jne    80108624 <clearpteu+0x35>
    panic("clearpteu");
80108618:	c7 04 24 18 8f 10 80 	movl   $0x80108f18,(%esp)
8010861f:	e8 16 7f ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
80108624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108627:	8b 00                	mov    (%eax),%eax
80108629:	83 e0 fb             	and    $0xfffffffb,%eax
8010862c:	89 c2                	mov    %eax,%edx
8010862e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108631:	89 10                	mov    %edx,(%eax)
}
80108633:	c9                   	leave  
80108634:	c3                   	ret    

80108635 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108635:	55                   	push   %ebp
80108636:	89 e5                	mov    %esp,%ebp
80108638:	53                   	push   %ebx
80108639:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010863c:	e8 b0 f9 ff ff       	call   80107ff1 <setupkvm>
80108641:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108644:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108648:	75 0a                	jne    80108654 <copyuvm+0x1f>
    return 0;
8010864a:	b8 00 00 00 00       	mov    $0x0,%eax
8010864f:	e9 fd 00 00 00       	jmp    80108751 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108654:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010865b:	e9 d0 00 00 00       	jmp    80108730 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108663:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010866a:	00 
8010866b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010866f:	8b 45 08             	mov    0x8(%ebp),%eax
80108672:	89 04 24             	mov    %eax,(%esp)
80108675:	e8 3d f8 ff ff       	call   80107eb7 <walkpgdir>
8010867a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010867d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108681:	75 0c                	jne    8010868f <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108683:	c7 04 24 22 8f 10 80 	movl   $0x80108f22,(%esp)
8010868a:	e8 ab 7e ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
8010868f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108692:	8b 00                	mov    (%eax),%eax
80108694:	83 e0 01             	and    $0x1,%eax
80108697:	85 c0                	test   %eax,%eax
80108699:	75 0c                	jne    801086a7 <copyuvm+0x72>
      panic("copyuvm: page not present");
8010869b:	c7 04 24 3c 8f 10 80 	movl   $0x80108f3c,(%esp)
801086a2:	e8 93 7e ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
801086a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086aa:	8b 00                	mov    (%eax),%eax
801086ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801086b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086b7:	8b 00                	mov    (%eax),%eax
801086b9:	25 ff 0f 00 00       	and    $0xfff,%eax
801086be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801086c1:	e8 dd a4 ff ff       	call   80102ba3 <kalloc>
801086c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
801086c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801086cd:	75 02                	jne    801086d1 <copyuvm+0x9c>
      goto bad;
801086cf:	eb 70                	jmp    80108741 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801086d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086d4:	89 04 24             	mov    %eax,(%esp)
801086d7:	e8 58 f3 ff ff       	call   80107a34 <p2v>
801086dc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086e3:	00 
801086e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801086e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086eb:	89 04 24             	mov    %eax,(%esp)
801086ee:	e8 f2 cd ff ff       	call   801054e5 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801086f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801086f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086f9:	89 04 24             	mov    %eax,(%esp)
801086fc:	e8 26 f3 ff ff       	call   80107a27 <v2p>
80108701:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108704:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108708:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010870c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108713:	00 
80108714:	89 54 24 04          	mov    %edx,0x4(%esp)
80108718:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871b:	89 04 24             	mov    %eax,(%esp)
8010871e:	e8 36 f8 ff ff       	call   80107f59 <mappages>
80108723:	85 c0                	test   %eax,%eax
80108725:	79 02                	jns    80108729 <copyuvm+0xf4>
      goto bad;
80108727:	eb 18                	jmp    80108741 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108729:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108733:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108736:	0f 82 24 ff ff ff    	jb     80108660 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010873c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010873f:	eb 10                	jmp    80108751 <copyuvm+0x11c>

bad:
  freevm(d);
80108741:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108744:	89 04 24             	mov    %eax,(%esp)
80108747:	e8 09 fe ff ff       	call   80108555 <freevm>
  return 0;
8010874c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108751:	83 c4 44             	add    $0x44,%esp
80108754:	5b                   	pop    %ebx
80108755:	5d                   	pop    %ebp
80108756:	c3                   	ret    

80108757 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108757:	55                   	push   %ebp
80108758:	89 e5                	mov    %esp,%ebp
8010875a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010875d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108764:	00 
80108765:	8b 45 0c             	mov    0xc(%ebp),%eax
80108768:	89 44 24 04          	mov    %eax,0x4(%esp)
8010876c:	8b 45 08             	mov    0x8(%ebp),%eax
8010876f:	89 04 24             	mov    %eax,(%esp)
80108772:	e8 40 f7 ff ff       	call   80107eb7 <walkpgdir>
80108777:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010877a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877d:	8b 00                	mov    (%eax),%eax
8010877f:	83 e0 01             	and    $0x1,%eax
80108782:	85 c0                	test   %eax,%eax
80108784:	75 07                	jne    8010878d <uva2ka+0x36>
    return 0;
80108786:	b8 00 00 00 00       	mov    $0x0,%eax
8010878b:	eb 25                	jmp    801087b2 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
8010878d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108790:	8b 00                	mov    (%eax),%eax
80108792:	83 e0 04             	and    $0x4,%eax
80108795:	85 c0                	test   %eax,%eax
80108797:	75 07                	jne    801087a0 <uva2ka+0x49>
    return 0;
80108799:	b8 00 00 00 00       	mov    $0x0,%eax
8010879e:	eb 12                	jmp    801087b2 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801087a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a3:	8b 00                	mov    (%eax),%eax
801087a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087aa:	89 04 24             	mov    %eax,(%esp)
801087ad:	e8 82 f2 ff ff       	call   80107a34 <p2v>
}
801087b2:	c9                   	leave  
801087b3:	c3                   	ret    

801087b4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087b4:	55                   	push   %ebp
801087b5:	89 e5                	mov    %esp,%ebp
801087b7:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087ba:	8b 45 10             	mov    0x10(%ebp),%eax
801087bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087c0:	e9 87 00 00 00       	jmp    8010884c <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801087c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801087c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801087d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801087d7:	8b 45 08             	mov    0x8(%ebp),%eax
801087da:	89 04 24             	mov    %eax,(%esp)
801087dd:	e8 75 ff ff ff       	call   80108757 <uva2ka>
801087e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087e9:	75 07                	jne    801087f2 <copyout+0x3e>
      return -1;
801087eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087f0:	eb 69                	jmp    8010885b <copyout+0xa7>
    n = PGSIZE - (va - va0);
801087f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801087f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801087f8:	29 c2                	sub    %eax,%edx
801087fa:	89 d0                	mov    %edx,%eax
801087fc:	05 00 10 00 00       	add    $0x1000,%eax
80108801:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108807:	3b 45 14             	cmp    0x14(%ebp),%eax
8010880a:	76 06                	jbe    80108812 <copyout+0x5e>
      n = len;
8010880c:	8b 45 14             	mov    0x14(%ebp),%eax
8010880f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108812:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108815:	8b 55 0c             	mov    0xc(%ebp),%edx
80108818:	29 c2                	sub    %eax,%edx
8010881a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010881d:	01 c2                	add    %eax,%edx
8010881f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108822:	89 44 24 08          	mov    %eax,0x8(%esp)
80108826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108829:	89 44 24 04          	mov    %eax,0x4(%esp)
8010882d:	89 14 24             	mov    %edx,(%esp)
80108830:	e8 b0 cc ff ff       	call   801054e5 <memmove>
    len -= n;
80108835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108838:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010883b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010883e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108841:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108844:	05 00 10 00 00       	add    $0x1000,%eax
80108849:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010884c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108850:	0f 85 6f ff ff ff    	jne    801087c5 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108856:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010885b:	c9                   	leave  
8010885c:	c3                   	ret    
