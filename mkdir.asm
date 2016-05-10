
_mkdir:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "Usage: mkdir files...\n");
   f:	c7 44 24 04 fe 08 00 	movl   $0x8fe,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 65 04 00 00       	call   488 <printf>
    exit();
  23:	e8 d0 02 00 00       	call   2f8 <exit>
  }

  for(i = 1; i < argc; i++){
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 4f                	jmp    81 <main+0x81>
    if(mkdir(argv[i]) < 0){
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 14 03 00 00       	call   360 <mkdir>
  4c:	85 c0                	test   %eax,%eax
  4e:	79 2c                	jns    7c <main+0x7c>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  50:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  5e:	01 d0                	add    %edx,%eax
  60:	8b 00                	mov    (%eax),%eax
  62:	89 44 24 08          	mov    %eax,0x8(%esp)
  66:	c7 44 24 04 15 09 00 	movl   $0x915,0x4(%esp)
  6d:	00 
  6e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  75:	e8 0e 04 00 00       	call   488 <printf>
      break;
  7a:	eb 0e                	jmp    8a <main+0x8a>
  if(argc < 2){
    printf(2, "Usage: mkdir files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  7c:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  81:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  85:	3b 45 08             	cmp    0x8(%ebp),%eax
  88:	7c a8                	jl     32 <main+0x32>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit();
  8a:	e8 69 02 00 00       	call   2f8 <exit>
  8f:	90                   	nop

00000090 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	57                   	push   %edi
  94:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  98:	8b 55 10             	mov    0x10(%ebp),%edx
  9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  9e:	89 cb                	mov    %ecx,%ebx
  a0:	89 df                	mov    %ebx,%edi
  a2:	89 d1                	mov    %edx,%ecx
  a4:	fc                   	cld    
  a5:	f3 aa                	rep stos %al,%es:(%edi)
  a7:	89 ca                	mov    %ecx,%edx
  a9:	89 fb                	mov    %edi,%ebx
  ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b1:	5b                   	pop    %ebx
  b2:	5f                   	pop    %edi
  b3:	5d                   	pop    %ebp
  b4:	c3                   	ret    

000000b5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b5:	55                   	push   %ebp
  b6:	89 e5                	mov    %esp,%ebp
  b8:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  bb:	8b 45 08             	mov    0x8(%ebp),%eax
  be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c1:	90                   	nop
  c2:	8b 45 08             	mov    0x8(%ebp),%eax
  c5:	8d 50 01             	lea    0x1(%eax),%edx
  c8:	89 55 08             	mov    %edx,0x8(%ebp)
  cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  d1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  d4:	0f b6 12             	movzbl (%edx),%edx
  d7:	88 10                	mov    %dl,(%eax)
  d9:	0f b6 00             	movzbl (%eax),%eax
  dc:	84 c0                	test   %al,%al
  de:	75 e2                	jne    c2 <strcpy+0xd>
    ;
  return os;
  e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e3:	c9                   	leave  
  e4:	c3                   	ret    

000000e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e5:	55                   	push   %ebp
  e6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e8:	eb 08                	jmp    f2 <strcmp+0xd>
    p++, q++;
  ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  f2:	8b 45 08             	mov    0x8(%ebp),%eax
  f5:	0f b6 00             	movzbl (%eax),%eax
  f8:	84 c0                	test   %al,%al
  fa:	74 10                	je     10c <strcmp+0x27>
  fc:	8b 45 08             	mov    0x8(%ebp),%eax
  ff:	0f b6 10             	movzbl (%eax),%edx
 102:	8b 45 0c             	mov    0xc(%ebp),%eax
 105:	0f b6 00             	movzbl (%eax),%eax
 108:	38 c2                	cmp    %al,%dl
 10a:	74 de                	je     ea <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	0f b6 00             	movzbl (%eax),%eax
 112:	0f b6 d0             	movzbl %al,%edx
 115:	8b 45 0c             	mov    0xc(%ebp),%eax
 118:	0f b6 00             	movzbl (%eax),%eax
 11b:	0f b6 c0             	movzbl %al,%eax
 11e:	29 c2                	sub    %eax,%edx
 120:	89 d0                	mov    %edx,%eax
}
 122:	5d                   	pop    %ebp
 123:	c3                   	ret    

00000124 <strlen>:

uint
strlen(char *s)
{
 124:	55                   	push   %ebp
 125:	89 e5                	mov    %esp,%ebp
 127:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 12a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 131:	eb 04                	jmp    137 <strlen+0x13>
 133:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 137:	8b 55 fc             	mov    -0x4(%ebp),%edx
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	01 d0                	add    %edx,%eax
 13f:	0f b6 00             	movzbl (%eax),%eax
 142:	84 c0                	test   %al,%al
 144:	75 ed                	jne    133 <strlen+0xf>
    ;
  return n;
 146:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 149:	c9                   	leave  
 14a:	c3                   	ret    

0000014b <memset>:

void*
memset(void *dst, int c, uint n)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 151:	8b 45 10             	mov    0x10(%ebp),%eax
 154:	89 44 24 08          	mov    %eax,0x8(%esp)
 158:	8b 45 0c             	mov    0xc(%ebp),%eax
 15b:	89 44 24 04          	mov    %eax,0x4(%esp)
 15f:	8b 45 08             	mov    0x8(%ebp),%eax
 162:	89 04 24             	mov    %eax,(%esp)
 165:	e8 26 ff ff ff       	call   90 <stosb>
  return dst;
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 16d:	c9                   	leave  
 16e:	c3                   	ret    

0000016f <strchr>:

char*
strchr(const char *s, char c)
{
 16f:	55                   	push   %ebp
 170:	89 e5                	mov    %esp,%ebp
 172:	83 ec 04             	sub    $0x4,%esp
 175:	8b 45 0c             	mov    0xc(%ebp),%eax
 178:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 17b:	eb 14                	jmp    191 <strchr+0x22>
    if(*s == c)
 17d:	8b 45 08             	mov    0x8(%ebp),%eax
 180:	0f b6 00             	movzbl (%eax),%eax
 183:	3a 45 fc             	cmp    -0x4(%ebp),%al
 186:	75 05                	jne    18d <strchr+0x1e>
      return (char*)s;
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	eb 13                	jmp    1a0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 18d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 191:	8b 45 08             	mov    0x8(%ebp),%eax
 194:	0f b6 00             	movzbl (%eax),%eax
 197:	84 c0                	test   %al,%al
 199:	75 e2                	jne    17d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 19b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a0:	c9                   	leave  
 1a1:	c3                   	ret    

000001a2 <gets>:

char*
gets(char *buf, int max)
{
 1a2:	55                   	push   %ebp
 1a3:	89 e5                	mov    %esp,%ebp
 1a5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1af:	eb 4c                	jmp    1fd <gets+0x5b>
    cc = read(0, &c, 1);
 1b1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1b8:	00 
 1b9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1c7:	e8 44 01 00 00       	call   310 <read>
 1cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d3:	7f 02                	jg     1d7 <gets+0x35>
      break;
 1d5:	eb 31                	jmp    208 <gets+0x66>
    buf[i++] = c;
 1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1da:	8d 50 01             	lea    0x1(%eax),%edx
 1dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1e0:	89 c2                	mov    %eax,%edx
 1e2:	8b 45 08             	mov    0x8(%ebp),%eax
 1e5:	01 c2                	add    %eax,%edx
 1e7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1eb:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ed:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f1:	3c 0a                	cmp    $0xa,%al
 1f3:	74 13                	je     208 <gets+0x66>
 1f5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f9:	3c 0d                	cmp    $0xd,%al
 1fb:	74 0b                	je     208 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 200:	83 c0 01             	add    $0x1,%eax
 203:	3b 45 0c             	cmp    0xc(%ebp),%eax
 206:	7c a9                	jl     1b1 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 208:	8b 55 f4             	mov    -0xc(%ebp),%edx
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	01 d0                	add    %edx,%eax
 210:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 213:	8b 45 08             	mov    0x8(%ebp),%eax
}
 216:	c9                   	leave  
 217:	c3                   	ret    

00000218 <stat>:

int
stat(char *n, struct stat *st)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 225:	00 
 226:	8b 45 08             	mov    0x8(%ebp),%eax
 229:	89 04 24             	mov    %eax,(%esp)
 22c:	e8 07 01 00 00       	call   338 <open>
 231:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 234:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 238:	79 07                	jns    241 <stat+0x29>
    return -1;
 23a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 23f:	eb 23                	jmp    264 <stat+0x4c>
  r = fstat(fd, st);
 241:	8b 45 0c             	mov    0xc(%ebp),%eax
 244:	89 44 24 04          	mov    %eax,0x4(%esp)
 248:	8b 45 f4             	mov    -0xc(%ebp),%eax
 24b:	89 04 24             	mov    %eax,(%esp)
 24e:	e8 fd 00 00 00       	call   350 <fstat>
 253:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 256:	8b 45 f4             	mov    -0xc(%ebp),%eax
 259:	89 04 24             	mov    %eax,(%esp)
 25c:	e8 bf 00 00 00       	call   320 <close>
  return r;
 261:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 264:	c9                   	leave  
 265:	c3                   	ret    

00000266 <atoi>:

int
atoi(const char *s)
{
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 26c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 273:	eb 25                	jmp    29a <atoi+0x34>
    n = n*10 + *s++ - '0';
 275:	8b 55 fc             	mov    -0x4(%ebp),%edx
 278:	89 d0                	mov    %edx,%eax
 27a:	c1 e0 02             	shl    $0x2,%eax
 27d:	01 d0                	add    %edx,%eax
 27f:	01 c0                	add    %eax,%eax
 281:	89 c1                	mov    %eax,%ecx
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	8d 50 01             	lea    0x1(%eax),%edx
 289:	89 55 08             	mov    %edx,0x8(%ebp)
 28c:	0f b6 00             	movzbl (%eax),%eax
 28f:	0f be c0             	movsbl %al,%eax
 292:	01 c8                	add    %ecx,%eax
 294:	83 e8 30             	sub    $0x30,%eax
 297:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	0f b6 00             	movzbl (%eax),%eax
 2a0:	3c 2f                	cmp    $0x2f,%al
 2a2:	7e 0a                	jle    2ae <atoi+0x48>
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	0f b6 00             	movzbl (%eax),%eax
 2aa:	3c 39                	cmp    $0x39,%al
 2ac:	7e c7                	jle    275 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b1:	c9                   	leave  
 2b2:	c3                   	ret    

000002b3 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c5:	eb 17                	jmp    2de <memmove+0x2b>
    *dst++ = *src++;
 2c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2ca:	8d 50 01             	lea    0x1(%eax),%edx
 2cd:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2d0:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2d3:	8d 4a 01             	lea    0x1(%edx),%ecx
 2d6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2d9:	0f b6 12             	movzbl (%edx),%edx
 2dc:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2de:	8b 45 10             	mov    0x10(%ebp),%eax
 2e1:	8d 50 ff             	lea    -0x1(%eax),%edx
 2e4:	89 55 10             	mov    %edx,0x10(%ebp)
 2e7:	85 c0                	test   %eax,%eax
 2e9:	7f dc                	jg     2c7 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ee:	c9                   	leave  
 2ef:	c3                   	ret    

000002f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2f0:	b8 01 00 00 00       	mov    $0x1,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <exit>:
SYSCALL(exit)
 2f8:	b8 02 00 00 00       	mov    $0x2,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <wait>:
SYSCALL(wait)
 300:	b8 03 00 00 00       	mov    $0x3,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <pipe>:
SYSCALL(pipe)
 308:	b8 04 00 00 00       	mov    $0x4,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <read>:
SYSCALL(read)
 310:	b8 05 00 00 00       	mov    $0x5,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <write>:
SYSCALL(write)
 318:	b8 10 00 00 00       	mov    $0x10,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <close>:
SYSCALL(close)
 320:	b8 15 00 00 00       	mov    $0x15,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <kill>:
SYSCALL(kill)
 328:	b8 06 00 00 00       	mov    $0x6,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <exec>:
SYSCALL(exec)
 330:	b8 07 00 00 00       	mov    $0x7,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <open>:
SYSCALL(open)
 338:	b8 0f 00 00 00       	mov    $0xf,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <mknod>:
SYSCALL(mknod)
 340:	b8 11 00 00 00       	mov    $0x11,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <unlink>:
SYSCALL(unlink)
 348:	b8 12 00 00 00       	mov    $0x12,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <fstat>:
SYSCALL(fstat)
 350:	b8 08 00 00 00       	mov    $0x8,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <link>:
SYSCALL(link)
 358:	b8 13 00 00 00       	mov    $0x13,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <mkdir>:
SYSCALL(mkdir)
 360:	b8 14 00 00 00       	mov    $0x14,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <chdir>:
SYSCALL(chdir)
 368:	b8 09 00 00 00       	mov    $0x9,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <dup>:
SYSCALL(dup)
 370:	b8 0a 00 00 00       	mov    $0xa,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <getpid>:
SYSCALL(getpid)
 378:	b8 0b 00 00 00       	mov    $0xb,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <sbrk>:
SYSCALL(sbrk)
 380:	b8 0c 00 00 00       	mov    $0xc,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <sleep>:
SYSCALL(sleep)
 388:	b8 0d 00 00 00       	mov    $0xd,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <uptime>:
SYSCALL(uptime)
 390:	b8 0e 00 00 00       	mov    $0xe,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <clone>:
SYSCALL(clone)
 398:	b8 16 00 00 00       	mov    $0x16,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <join>:
 3a0:	b8 17 00 00 00       	mov    $0x17,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	83 ec 18             	sub    $0x18,%esp
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3bb:	00 
 3bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	89 04 24             	mov    %eax,(%esp)
 3c9:	e8 4a ff ff ff       	call   318 <write>
}
 3ce:	c9                   	leave  
 3cf:	c3                   	ret    

000003d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	56                   	push   %esi
 3d4:	53                   	push   %ebx
 3d5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3df:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e3:	74 17                	je     3fc <printint+0x2c>
 3e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3e9:	79 11                	jns    3fc <printint+0x2c>
    neg = 1;
 3eb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f5:	f7 d8                	neg    %eax
 3f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3fa:	eb 06                	jmp    402 <printint+0x32>
  } else {
    x = xx;
 3fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 402:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 409:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 40c:	8d 41 01             	lea    0x1(%ecx),%eax
 40f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 412:	8b 5d 10             	mov    0x10(%ebp),%ebx
 415:	8b 45 ec             	mov    -0x14(%ebp),%eax
 418:	ba 00 00 00 00       	mov    $0x0,%edx
 41d:	f7 f3                	div    %ebx
 41f:	89 d0                	mov    %edx,%eax
 421:	0f b6 80 3c 0c 00 00 	movzbl 0xc3c(%eax),%eax
 428:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 42c:	8b 75 10             	mov    0x10(%ebp),%esi
 42f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 432:	ba 00 00 00 00       	mov    $0x0,%edx
 437:	f7 f6                	div    %esi
 439:	89 45 ec             	mov    %eax,-0x14(%ebp)
 43c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 440:	75 c7                	jne    409 <printint+0x39>
  if(neg)
 442:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 446:	74 10                	je     458 <printint+0x88>
    buf[i++] = '-';
 448:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44b:	8d 50 01             	lea    0x1(%eax),%edx
 44e:	89 55 f4             	mov    %edx,-0xc(%ebp)
 451:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 456:	eb 1f                	jmp    477 <printint+0xa7>
 458:	eb 1d                	jmp    477 <printint+0xa7>
    putc(fd, buf[i]);
 45a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 45d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 460:	01 d0                	add    %edx,%eax
 462:	0f b6 00             	movzbl (%eax),%eax
 465:	0f be c0             	movsbl %al,%eax
 468:	89 44 24 04          	mov    %eax,0x4(%esp)
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
 46f:	89 04 24             	mov    %eax,(%esp)
 472:	e8 31 ff ff ff       	call   3a8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 477:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 47b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 47f:	79 d9                	jns    45a <printint+0x8a>
    putc(fd, buf[i]);
}
 481:	83 c4 30             	add    $0x30,%esp
 484:	5b                   	pop    %ebx
 485:	5e                   	pop    %esi
 486:	5d                   	pop    %ebp
 487:	c3                   	ret    

00000488 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 488:	55                   	push   %ebp
 489:	89 e5                	mov    %esp,%ebp
 48b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 48e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 495:	8d 45 0c             	lea    0xc(%ebp),%eax
 498:	83 c0 04             	add    $0x4,%eax
 49b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 49e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a5:	e9 7c 01 00 00       	jmp    626 <printf+0x19e>
    c = fmt[i] & 0xff;
 4aa:	8b 55 0c             	mov    0xc(%ebp),%edx
 4ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b0:	01 d0                	add    %edx,%eax
 4b2:	0f b6 00             	movzbl (%eax),%eax
 4b5:	0f be c0             	movsbl %al,%eax
 4b8:	25 ff 00 00 00       	and    $0xff,%eax
 4bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c4:	75 2c                	jne    4f2 <printf+0x6a>
      if(c == '%'){
 4c6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4ca:	75 0c                	jne    4d8 <printf+0x50>
        state = '%';
 4cc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4d3:	e9 4a 01 00 00       	jmp    622 <printf+0x19a>
      } else {
        putc(fd, c);
 4d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4db:	0f be c0             	movsbl %al,%eax
 4de:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e2:	8b 45 08             	mov    0x8(%ebp),%eax
 4e5:	89 04 24             	mov    %eax,(%esp)
 4e8:	e8 bb fe ff ff       	call   3a8 <putc>
 4ed:	e9 30 01 00 00       	jmp    622 <printf+0x19a>
      }
    } else if(state == '%'){
 4f2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f6:	0f 85 26 01 00 00    	jne    622 <printf+0x19a>
      if(c == 'd'){
 4fc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 500:	75 2d                	jne    52f <printf+0xa7>
        printint(fd, *ap, 10, 1);
 502:	8b 45 e8             	mov    -0x18(%ebp),%eax
 505:	8b 00                	mov    (%eax),%eax
 507:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 50e:	00 
 50f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 516:	00 
 517:	89 44 24 04          	mov    %eax,0x4(%esp)
 51b:	8b 45 08             	mov    0x8(%ebp),%eax
 51e:	89 04 24             	mov    %eax,(%esp)
 521:	e8 aa fe ff ff       	call   3d0 <printint>
        ap++;
 526:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52a:	e9 ec 00 00 00       	jmp    61b <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 52f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 533:	74 06                	je     53b <printf+0xb3>
 535:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 539:	75 2d                	jne    568 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 53b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53e:	8b 00                	mov    (%eax),%eax
 540:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 547:	00 
 548:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 54f:	00 
 550:	89 44 24 04          	mov    %eax,0x4(%esp)
 554:	8b 45 08             	mov    0x8(%ebp),%eax
 557:	89 04 24             	mov    %eax,(%esp)
 55a:	e8 71 fe ff ff       	call   3d0 <printint>
        ap++;
 55f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 563:	e9 b3 00 00 00       	jmp    61b <printf+0x193>
      } else if(c == 's'){
 568:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 56c:	75 45                	jne    5b3 <printf+0x12b>
        s = (char*)*ap;
 56e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 571:	8b 00                	mov    (%eax),%eax
 573:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 576:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 57a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 57e:	75 09                	jne    589 <printf+0x101>
          s = "(null)";
 580:	c7 45 f4 31 09 00 00 	movl   $0x931,-0xc(%ebp)
        while(*s != 0){
 587:	eb 1e                	jmp    5a7 <printf+0x11f>
 589:	eb 1c                	jmp    5a7 <printf+0x11f>
          putc(fd, *s);
 58b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58e:	0f b6 00             	movzbl (%eax),%eax
 591:	0f be c0             	movsbl %al,%eax
 594:	89 44 24 04          	mov    %eax,0x4(%esp)
 598:	8b 45 08             	mov    0x8(%ebp),%eax
 59b:	89 04 24             	mov    %eax,(%esp)
 59e:	e8 05 fe ff ff       	call   3a8 <putc>
          s++;
 5a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	84 c0                	test   %al,%al
 5af:	75 da                	jne    58b <printf+0x103>
 5b1:	eb 68                	jmp    61b <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5b7:	75 1d                	jne    5d6 <printf+0x14e>
        putc(fd, *ap);
 5b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bc:	8b 00                	mov    (%eax),%eax
 5be:	0f be c0             	movsbl %al,%eax
 5c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c5:	8b 45 08             	mov    0x8(%ebp),%eax
 5c8:	89 04 24             	mov    %eax,(%esp)
 5cb:	e8 d8 fd ff ff       	call   3a8 <putc>
        ap++;
 5d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d4:	eb 45                	jmp    61b <printf+0x193>
      } else if(c == '%'){
 5d6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5da:	75 17                	jne    5f3 <printf+0x16b>
        putc(fd, c);
 5dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5df:	0f be c0             	movsbl %al,%eax
 5e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e6:	8b 45 08             	mov    0x8(%ebp),%eax
 5e9:	89 04 24             	mov    %eax,(%esp)
 5ec:	e8 b7 fd ff ff       	call   3a8 <putc>
 5f1:	eb 28                	jmp    61b <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5fa:	00 
 5fb:	8b 45 08             	mov    0x8(%ebp),%eax
 5fe:	89 04 24             	mov    %eax,(%esp)
 601:	e8 a2 fd ff ff       	call   3a8 <putc>
        putc(fd, c);
 606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 609:	0f be c0             	movsbl %al,%eax
 60c:	89 44 24 04          	mov    %eax,0x4(%esp)
 610:	8b 45 08             	mov    0x8(%ebp),%eax
 613:	89 04 24             	mov    %eax,(%esp)
 616:	e8 8d fd ff ff       	call   3a8 <putc>
      }
      state = 0;
 61b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 622:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 626:	8b 55 0c             	mov    0xc(%ebp),%edx
 629:	8b 45 f0             	mov    -0x10(%ebp),%eax
 62c:	01 d0                	add    %edx,%eax
 62e:	0f b6 00             	movzbl (%eax),%eax
 631:	84 c0                	test   %al,%al
 633:	0f 85 71 fe ff ff    	jne    4aa <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 639:	c9                   	leave  
 63a:	c3                   	ret    
 63b:	90                   	nop

0000063c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 63c:	55                   	push   %ebp
 63d:	89 e5                	mov    %esp,%ebp
 63f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	83 e8 08             	sub    $0x8,%eax
 648:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64b:	a1 58 0c 00 00       	mov    0xc58,%eax
 650:	89 45 fc             	mov    %eax,-0x4(%ebp)
 653:	eb 24                	jmp    679 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 00                	mov    (%eax),%eax
 65a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65d:	77 12                	ja     671 <free+0x35>
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 665:	77 24                	ja     68b <free+0x4f>
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 00                	mov    (%eax),%eax
 66c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 66f:	77 1a                	ja     68b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	8b 00                	mov    (%eax),%eax
 676:	89 45 fc             	mov    %eax,-0x4(%ebp)
 679:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67f:	76 d4                	jbe    655 <free+0x19>
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 689:	76 ca                	jbe    655 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 68b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68e:	8b 40 04             	mov    0x4(%eax),%eax
 691:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 698:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69b:	01 c2                	add    %eax,%edx
 69d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a0:	8b 00                	mov    (%eax),%eax
 6a2:	39 c2                	cmp    %eax,%edx
 6a4:	75 24                	jne    6ca <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a9:	8b 50 04             	mov    0x4(%eax),%edx
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	8b 00                	mov    (%eax),%eax
 6b1:	8b 40 04             	mov    0x4(%eax),%eax
 6b4:	01 c2                	add    %eax,%edx
 6b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	8b 00                	mov    (%eax),%eax
 6c1:	8b 10                	mov    (%eax),%edx
 6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c6:	89 10                	mov    %edx,(%eax)
 6c8:	eb 0a                	jmp    6d4 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cd:	8b 10                	mov    (%eax),%edx
 6cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d7:	8b 40 04             	mov    0x4(%eax),%eax
 6da:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	01 d0                	add    %edx,%eax
 6e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e9:	75 20                	jne    70b <free+0xcf>
    p->s.size += bp->s.size;
 6eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ee:	8b 50 04             	mov    0x4(%eax),%edx
 6f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f4:	8b 40 04             	mov    0x4(%eax),%eax
 6f7:	01 c2                	add    %eax,%edx
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 702:	8b 10                	mov    (%eax),%edx
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	89 10                	mov    %edx,(%eax)
 709:	eb 08                	jmp    713 <free+0xd7>
  } else
    p->s.ptr = bp;
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 711:	89 10                	mov    %edx,(%eax)
  freep = p;
 713:	8b 45 fc             	mov    -0x4(%ebp),%eax
 716:	a3 58 0c 00 00       	mov    %eax,0xc58
}
 71b:	c9                   	leave  
 71c:	c3                   	ret    

0000071d <morecore>:

static Header*
morecore(uint nu)
{
 71d:	55                   	push   %ebp
 71e:	89 e5                	mov    %esp,%ebp
 720:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 723:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 72a:	77 07                	ja     733 <morecore+0x16>
    nu = 4096;
 72c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 733:	8b 45 08             	mov    0x8(%ebp),%eax
 736:	c1 e0 03             	shl    $0x3,%eax
 739:	89 04 24             	mov    %eax,(%esp)
 73c:	e8 3f fc ff ff       	call   380 <sbrk>
 741:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 744:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 748:	75 07                	jne    751 <morecore+0x34>
    return 0;
 74a:	b8 00 00 00 00       	mov    $0x0,%eax
 74f:	eb 22                	jmp    773 <morecore+0x56>
  hp = (Header*)p;
 751:	8b 45 f4             	mov    -0xc(%ebp),%eax
 754:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 757:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75a:	8b 55 08             	mov    0x8(%ebp),%edx
 75d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 760:	8b 45 f0             	mov    -0x10(%ebp),%eax
 763:	83 c0 08             	add    $0x8,%eax
 766:	89 04 24             	mov    %eax,(%esp)
 769:	e8 ce fe ff ff       	call   63c <free>
  return freep;
 76e:	a1 58 0c 00 00       	mov    0xc58,%eax
}
 773:	c9                   	leave  
 774:	c3                   	ret    

00000775 <malloc>:

void*
malloc(uint nbytes)
{
 775:	55                   	push   %ebp
 776:	89 e5                	mov    %esp,%ebp
 778:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 77b:	8b 45 08             	mov    0x8(%ebp),%eax
 77e:	83 c0 07             	add    $0x7,%eax
 781:	c1 e8 03             	shr    $0x3,%eax
 784:	83 c0 01             	add    $0x1,%eax
 787:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 78a:	a1 58 0c 00 00       	mov    0xc58,%eax
 78f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 792:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 796:	75 23                	jne    7bb <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 798:	c7 45 f0 50 0c 00 00 	movl   $0xc50,-0x10(%ebp)
 79f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a2:	a3 58 0c 00 00       	mov    %eax,0xc58
 7a7:	a1 58 0c 00 00       	mov    0xc58,%eax
 7ac:	a3 50 0c 00 00       	mov    %eax,0xc50
    base.s.size = 0;
 7b1:	c7 05 54 0c 00 00 00 	movl   $0x0,0xc54
 7b8:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7be:	8b 00                	mov    (%eax),%eax
 7c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c6:	8b 40 04             	mov    0x4(%eax),%eax
 7c9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7cc:	72 4d                	jb     81b <malloc+0xa6>
      if(p->s.size == nunits)
 7ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d1:	8b 40 04             	mov    0x4(%eax),%eax
 7d4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7d7:	75 0c                	jne    7e5 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dc:	8b 10                	mov    (%eax),%edx
 7de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e1:	89 10                	mov    %edx,(%eax)
 7e3:	eb 26                	jmp    80b <malloc+0x96>
      else {
        p->s.size -= nunits;
 7e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e8:	8b 40 04             	mov    0x4(%eax),%eax
 7eb:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7ee:	89 c2                	mov    %eax,%edx
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f9:	8b 40 04             	mov    0x4(%eax),%eax
 7fc:	c1 e0 03             	shl    $0x3,%eax
 7ff:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	8b 55 ec             	mov    -0x14(%ebp),%edx
 808:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 80b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80e:	a3 58 0c 00 00       	mov    %eax,0xc58
      return (void*)(p + 1);
 813:	8b 45 f4             	mov    -0xc(%ebp),%eax
 816:	83 c0 08             	add    $0x8,%eax
 819:	eb 38                	jmp    853 <malloc+0xde>
    }
    if(p == freep)
 81b:	a1 58 0c 00 00       	mov    0xc58,%eax
 820:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 823:	75 1b                	jne    840 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 825:	8b 45 ec             	mov    -0x14(%ebp),%eax
 828:	89 04 24             	mov    %eax,(%esp)
 82b:	e8 ed fe ff ff       	call   71d <morecore>
 830:	89 45 f4             	mov    %eax,-0xc(%ebp)
 833:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 837:	75 07                	jne    840 <malloc+0xcb>
        return 0;
 839:	b8 00 00 00 00       	mov    $0x0,%eax
 83e:	eb 13                	jmp    853 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 840:	8b 45 f4             	mov    -0xc(%ebp),%eax
 843:	89 45 f0             	mov    %eax,-0x10(%ebp)
 846:	8b 45 f4             	mov    -0xc(%ebp),%eax
 849:	8b 00                	mov    (%eax),%eax
 84b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 84e:	e9 70 ff ff ff       	jmp    7c3 <malloc+0x4e>
}
 853:	c9                   	leave  
 854:	c3                   	ret    
 855:	66 90                	xchg   %ax,%ax
 857:	90                   	nop

00000858 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
 858:	55                   	push   %ebp
 859:	89 e5                	mov    %esp,%ebp
 85b:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 85e:	8b 55 08             	mov    0x8(%ebp),%edx
 861:	8b 45 0c             	mov    0xc(%ebp),%eax
 864:	8b 4d 08             	mov    0x8(%ebp),%ecx
 867:	f0 87 02             	lock xchg %eax,(%edx)
 86a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
 86d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 870:	c9                   	leave  
 871:	c3                   	ret    

00000872 <mutex_init>:
#include "types.h"
#include "user.h"
#include "x86.h"
#include "threadlib.h"

void mutex_init(mutex_t *m) {
 872:	55                   	push   %ebp
 873:	89 e5                	mov    %esp,%ebp
  // 0 indicates that lock is available, 1 that it is held by a thread
  m->flag = 0;
 875:	8b 45 08             	mov    0x8(%ebp),%eax
 878:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 87e:	5d                   	pop    %ebp
 87f:	c3                   	ret    

00000880 <mutex_lock>:

void mutex_lock(mutex_t *m)
{
 880:	55                   	push   %ebp
 881:	89 e5                	mov    %esp,%ebp
 883:	83 ec 08             	sub    $0x8,%esp
  while (xchg(&m->flag, 1) == 1); // spin-wait (do nothing)
 886:	90                   	nop
 887:	8b 45 08             	mov    0x8(%ebp),%eax
 88a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 891:	00 
 892:	89 04 24             	mov    %eax,(%esp)
 895:	e8 be ff ff ff       	call   858 <xchg>
 89a:	83 f8 01             	cmp    $0x1,%eax
 89d:	74 e8                	je     887 <mutex_lock+0x7>
}
 89f:	c9                   	leave  
 8a0:	c3                   	ret    

000008a1 <mutex_unlock>:

void mutex_unlock(mutex_t *m)
{
 8a1:	55                   	push   %ebp
 8a2:	89 e5                	mov    %esp,%ebp
  m->flag = 0;
 8a4:	8b 45 08             	mov    0x8(%ebp),%eax
 8a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
} 
 8ad:	5d                   	pop    %ebp
 8ae:	c3                   	ret    

000008af <thread_create>:
  if(!pid) (*start_routine)(arg);
  else return pid;
}*/

int thread_create(void(*child)(void*), void *arg_ptr)
{
 8af:	55                   	push   %ebp
 8b0:	89 e5                	mov    %esp,%ebp
 8b2:	83 ec 28             	sub    $0x28,%esp
	void *stack = malloc(4096);
 8b5:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 8bc:	e8 b4 fe ff ff       	call   775 <malloc>
 8c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int clone_pid = clone(child, arg_ptr, stack);
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	89 44 24 08          	mov    %eax,0x8(%esp)
 8cb:	8b 45 0c             	mov    0xc(%ebp),%eax
 8ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d2:	8b 45 08             	mov    0x8(%ebp),%eax
 8d5:	89 04 24             	mov    %eax,(%esp)
 8d8:	e8 bb fa ff ff       	call   398 <clone>
 8dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return clone_pid;
 8e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 8e3:	c9                   	leave  
 8e4:	c3                   	ret    

000008e5 <thread_join>:

int thread_join(void)
{
 8e5:	55                   	push   %ebp
 8e6:	89 e5                	mov    %esp,%ebp
 8e8:	83 ec 28             	sub    $0x28,%esp
    void *join_s;
    int join_pid = join(&join_s);
 8eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
 8ee:	89 04 24             	mov    %eax,(%esp)
 8f1:	e8 aa fa ff ff       	call   3a0 <join>
 8f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return join_pid;
 8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fc:	c9                   	leave  
 8fd:	c3                   	ret    
