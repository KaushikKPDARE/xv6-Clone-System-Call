
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
   9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 d6 08 00 	movl   $0x8d6,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 3d 04 00 00       	call   460 <printf>
    exit();
  23:	e8 a8 02 00 00       	call   2d0 <exit>
  }
  for(i=1; i<argc; i++)
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 27                	jmp    59 <main+0x59>
    kill(atoi(argv[i]));
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  40:	01 d0                	add    %edx,%eax
  42:	8b 00                	mov    (%eax),%eax
  44:	89 04 24             	mov    %eax,(%esp)
  47:	e8 f2 01 00 00       	call   23e <atoi>
  4c:	89 04 24             	mov    %eax,(%esp)
  4f:	e8 ac 02 00 00       	call   300 <kill>

  if(argc < 2){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  54:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  5d:	3b 45 08             	cmp    0x8(%ebp),%eax
  60:	7c d0                	jl     32 <main+0x32>
    kill(atoi(argv[i]));
  exit();
  62:	e8 69 02 00 00       	call   2d0 <exit>
  67:	90                   	nop

00000068 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	57                   	push   %edi
  6c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  70:	8b 55 10             	mov    0x10(%ebp),%edx
  73:	8b 45 0c             	mov    0xc(%ebp),%eax
  76:	89 cb                	mov    %ecx,%ebx
  78:	89 df                	mov    %ebx,%edi
  7a:	89 d1                	mov    %edx,%ecx
  7c:	fc                   	cld    
  7d:	f3 aa                	rep stos %al,%es:(%edi)
  7f:	89 ca                	mov    %ecx,%edx
  81:	89 fb                	mov    %edi,%ebx
  83:	89 5d 08             	mov    %ebx,0x8(%ebp)
  86:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  89:	5b                   	pop    %ebx
  8a:	5f                   	pop    %edi
  8b:	5d                   	pop    %ebp
  8c:	c3                   	ret    

0000008d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  93:	8b 45 08             	mov    0x8(%ebp),%eax
  96:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  99:	90                   	nop
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	8d 50 01             	lea    0x1(%eax),%edx
  a0:	89 55 08             	mov    %edx,0x8(%ebp)
  a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  a6:	8d 4a 01             	lea    0x1(%edx),%ecx
  a9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  ac:	0f b6 12             	movzbl (%edx),%edx
  af:	88 10                	mov    %dl,(%eax)
  b1:	0f b6 00             	movzbl (%eax),%eax
  b4:	84 c0                	test   %al,%al
  b6:	75 e2                	jne    9a <strcpy+0xd>
    ;
  return os;
  b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bb:	c9                   	leave  
  bc:	c3                   	ret    

000000bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c0:	eb 08                	jmp    ca <strcmp+0xd>
    p++, q++;
  c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	0f b6 00             	movzbl (%eax),%eax
  d0:	84 c0                	test   %al,%al
  d2:	74 10                	je     e4 <strcmp+0x27>
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 10             	movzbl (%eax),%edx
  da:	8b 45 0c             	mov    0xc(%ebp),%eax
  dd:	0f b6 00             	movzbl (%eax),%eax
  e0:	38 c2                	cmp    %al,%dl
  e2:	74 de                	je     c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e4:	8b 45 08             	mov    0x8(%ebp),%eax
  e7:	0f b6 00             	movzbl (%eax),%eax
  ea:	0f b6 d0             	movzbl %al,%edx
  ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  f0:	0f b6 00             	movzbl (%eax),%eax
  f3:	0f b6 c0             	movzbl %al,%eax
  f6:	29 c2                	sub    %eax,%edx
  f8:	89 d0                	mov    %edx,%eax
}
  fa:	5d                   	pop    %ebp
  fb:	c3                   	ret    

000000fc <strlen>:

uint
strlen(char *s)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 102:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 109:	eb 04                	jmp    10f <strlen+0x13>
 10b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 10f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	01 d0                	add    %edx,%eax
 117:	0f b6 00             	movzbl (%eax),%eax
 11a:	84 c0                	test   %al,%al
 11c:	75 ed                	jne    10b <strlen+0xf>
    ;
  return n;
 11e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 121:	c9                   	leave  
 122:	c3                   	ret    

00000123 <memset>:

void*
memset(void *dst, int c, uint n)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 129:	8b 45 10             	mov    0x10(%ebp),%eax
 12c:	89 44 24 08          	mov    %eax,0x8(%esp)
 130:	8b 45 0c             	mov    0xc(%ebp),%eax
 133:	89 44 24 04          	mov    %eax,0x4(%esp)
 137:	8b 45 08             	mov    0x8(%ebp),%eax
 13a:	89 04 24             	mov    %eax,(%esp)
 13d:	e8 26 ff ff ff       	call   68 <stosb>
  return dst;
 142:	8b 45 08             	mov    0x8(%ebp),%eax
}
 145:	c9                   	leave  
 146:	c3                   	ret    

00000147 <strchr>:

char*
strchr(const char *s, char c)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
 14a:	83 ec 04             	sub    $0x4,%esp
 14d:	8b 45 0c             	mov    0xc(%ebp),%eax
 150:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 153:	eb 14                	jmp    169 <strchr+0x22>
    if(*s == c)
 155:	8b 45 08             	mov    0x8(%ebp),%eax
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 15e:	75 05                	jne    165 <strchr+0x1e>
      return (char*)s;
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	eb 13                	jmp    178 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 165:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 169:	8b 45 08             	mov    0x8(%ebp),%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	84 c0                	test   %al,%al
 171:	75 e2                	jne    155 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 173:	b8 00 00 00 00       	mov    $0x0,%eax
}
 178:	c9                   	leave  
 179:	c3                   	ret    

0000017a <gets>:

char*
gets(char *buf, int max)
{
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 187:	eb 4c                	jmp    1d5 <gets+0x5b>
    cc = read(0, &c, 1);
 189:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 190:	00 
 191:	8d 45 ef             	lea    -0x11(%ebp),%eax
 194:	89 44 24 04          	mov    %eax,0x4(%esp)
 198:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 19f:	e8 44 01 00 00       	call   2e8 <read>
 1a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ab:	7f 02                	jg     1af <gets+0x35>
      break;
 1ad:	eb 31                	jmp    1e0 <gets+0x66>
    buf[i++] = c;
 1af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b2:	8d 50 01             	lea    0x1(%eax),%edx
 1b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1b8:	89 c2                	mov    %eax,%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 c2                	add    %eax,%edx
 1bf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c3:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c9:	3c 0a                	cmp    $0xa,%al
 1cb:	74 13                	je     1e0 <gets+0x66>
 1cd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d1:	3c 0d                	cmp    $0xd,%al
 1d3:	74 0b                	je     1e0 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d8:	83 c0 01             	add    $0x1,%eax
 1db:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1de:	7c a9                	jl     189 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
 1e6:	01 d0                	add    %edx,%eax
 1e8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ee:	c9                   	leave  
 1ef:	c3                   	ret    

000001f0 <stat>:

int
stat(char *n, struct stat *st)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1fd:	00 
 1fe:	8b 45 08             	mov    0x8(%ebp),%eax
 201:	89 04 24             	mov    %eax,(%esp)
 204:	e8 07 01 00 00       	call   310 <open>
 209:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 20c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 210:	79 07                	jns    219 <stat+0x29>
    return -1;
 212:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 217:	eb 23                	jmp    23c <stat+0x4c>
  r = fstat(fd, st);
 219:	8b 45 0c             	mov    0xc(%ebp),%eax
 21c:	89 44 24 04          	mov    %eax,0x4(%esp)
 220:	8b 45 f4             	mov    -0xc(%ebp),%eax
 223:	89 04 24             	mov    %eax,(%esp)
 226:	e8 fd 00 00 00       	call   328 <fstat>
 22b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 22e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 231:	89 04 24             	mov    %eax,(%esp)
 234:	e8 bf 00 00 00       	call   2f8 <close>
  return r;
 239:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 23c:	c9                   	leave  
 23d:	c3                   	ret    

0000023e <atoi>:

int
atoi(const char *s)
{
 23e:	55                   	push   %ebp
 23f:	89 e5                	mov    %esp,%ebp
 241:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 244:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 24b:	eb 25                	jmp    272 <atoi+0x34>
    n = n*10 + *s++ - '0';
 24d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 250:	89 d0                	mov    %edx,%eax
 252:	c1 e0 02             	shl    $0x2,%eax
 255:	01 d0                	add    %edx,%eax
 257:	01 c0                	add    %eax,%eax
 259:	89 c1                	mov    %eax,%ecx
 25b:	8b 45 08             	mov    0x8(%ebp),%eax
 25e:	8d 50 01             	lea    0x1(%eax),%edx
 261:	89 55 08             	mov    %edx,0x8(%ebp)
 264:	0f b6 00             	movzbl (%eax),%eax
 267:	0f be c0             	movsbl %al,%eax
 26a:	01 c8                	add    %ecx,%eax
 26c:	83 e8 30             	sub    $0x30,%eax
 26f:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	0f b6 00             	movzbl (%eax),%eax
 278:	3c 2f                	cmp    $0x2f,%al
 27a:	7e 0a                	jle    286 <atoi+0x48>
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	0f b6 00             	movzbl (%eax),%eax
 282:	3c 39                	cmp    $0x39,%al
 284:	7e c7                	jle    24d <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 286:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 289:	c9                   	leave  
 28a:	c3                   	ret    

0000028b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 28b:	55                   	push   %ebp
 28c:	89 e5                	mov    %esp,%ebp
 28e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 297:	8b 45 0c             	mov    0xc(%ebp),%eax
 29a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 29d:	eb 17                	jmp    2b6 <memmove+0x2b>
    *dst++ = *src++;
 29f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2a2:	8d 50 01             	lea    0x1(%eax),%edx
 2a5:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2a8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ab:	8d 4a 01             	lea    0x1(%edx),%ecx
 2ae:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2b1:	0f b6 12             	movzbl (%edx),%edx
 2b4:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b6:	8b 45 10             	mov    0x10(%ebp),%eax
 2b9:	8d 50 ff             	lea    -0x1(%eax),%edx
 2bc:	89 55 10             	mov    %edx,0x10(%ebp)
 2bf:	85 c0                	test   %eax,%eax
 2c1:	7f dc                	jg     29f <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c6:	c9                   	leave  
 2c7:	c3                   	ret    

000002c8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c8:	b8 01 00 00 00       	mov    $0x1,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <exit>:
SYSCALL(exit)
 2d0:	b8 02 00 00 00       	mov    $0x2,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <wait>:
SYSCALL(wait)
 2d8:	b8 03 00 00 00       	mov    $0x3,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <pipe>:
SYSCALL(pipe)
 2e0:	b8 04 00 00 00       	mov    $0x4,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <read>:
SYSCALL(read)
 2e8:	b8 05 00 00 00       	mov    $0x5,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <write>:
SYSCALL(write)
 2f0:	b8 10 00 00 00       	mov    $0x10,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <close>:
SYSCALL(close)
 2f8:	b8 15 00 00 00       	mov    $0x15,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <kill>:
SYSCALL(kill)
 300:	b8 06 00 00 00       	mov    $0x6,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <exec>:
SYSCALL(exec)
 308:	b8 07 00 00 00       	mov    $0x7,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <open>:
SYSCALL(open)
 310:	b8 0f 00 00 00       	mov    $0xf,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <mknod>:
SYSCALL(mknod)
 318:	b8 11 00 00 00       	mov    $0x11,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <unlink>:
SYSCALL(unlink)
 320:	b8 12 00 00 00       	mov    $0x12,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <fstat>:
SYSCALL(fstat)
 328:	b8 08 00 00 00       	mov    $0x8,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <link>:
SYSCALL(link)
 330:	b8 13 00 00 00       	mov    $0x13,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <mkdir>:
SYSCALL(mkdir)
 338:	b8 14 00 00 00       	mov    $0x14,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <chdir>:
SYSCALL(chdir)
 340:	b8 09 00 00 00       	mov    $0x9,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <dup>:
SYSCALL(dup)
 348:	b8 0a 00 00 00       	mov    $0xa,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <getpid>:
SYSCALL(getpid)
 350:	b8 0b 00 00 00       	mov    $0xb,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <sbrk>:
SYSCALL(sbrk)
 358:	b8 0c 00 00 00       	mov    $0xc,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <sleep>:
SYSCALL(sleep)
 360:	b8 0d 00 00 00       	mov    $0xd,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <uptime>:
SYSCALL(uptime)
 368:	b8 0e 00 00 00       	mov    $0xe,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <clone>:
SYSCALL(clone)
 370:	b8 16 00 00 00       	mov    $0x16,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <join>:
 378:	b8 17 00 00 00       	mov    $0x17,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 380:	55                   	push   %ebp
 381:	89 e5                	mov    %esp,%ebp
 383:	83 ec 18             	sub    $0x18,%esp
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 38c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 393:	00 
 394:	8d 45 f4             	lea    -0xc(%ebp),%eax
 397:	89 44 24 04          	mov    %eax,0x4(%esp)
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
 39e:	89 04 24             	mov    %eax,(%esp)
 3a1:	e8 4a ff ff ff       	call   2f0 <write>
}
 3a6:	c9                   	leave  
 3a7:	c3                   	ret    

000003a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	56                   	push   %esi
 3ac:	53                   	push   %ebx
 3ad:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3b7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3bb:	74 17                	je     3d4 <printint+0x2c>
 3bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3c1:	79 11                	jns    3d4 <printint+0x2c>
    neg = 1;
 3c3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cd:	f7 d8                	neg    %eax
 3cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3d2:	eb 06                	jmp    3da <printint+0x32>
  } else {
    x = xx;
 3d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3e1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3e4:	8d 41 01             	lea    0x1(%ecx),%eax
 3e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f0:	ba 00 00 00 00       	mov    $0x0,%edx
 3f5:	f7 f3                	div    %ebx
 3f7:	89 d0                	mov    %edx,%eax
 3f9:	0f b6 80 f8 0b 00 00 	movzbl 0xbf8(%eax),%eax
 400:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 404:	8b 75 10             	mov    0x10(%ebp),%esi
 407:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40a:	ba 00 00 00 00       	mov    $0x0,%edx
 40f:	f7 f6                	div    %esi
 411:	89 45 ec             	mov    %eax,-0x14(%ebp)
 414:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 418:	75 c7                	jne    3e1 <printint+0x39>
  if(neg)
 41a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 41e:	74 10                	je     430 <printint+0x88>
    buf[i++] = '-';
 420:	8b 45 f4             	mov    -0xc(%ebp),%eax
 423:	8d 50 01             	lea    0x1(%eax),%edx
 426:	89 55 f4             	mov    %edx,-0xc(%ebp)
 429:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 42e:	eb 1f                	jmp    44f <printint+0xa7>
 430:	eb 1d                	jmp    44f <printint+0xa7>
    putc(fd, buf[i]);
 432:	8d 55 dc             	lea    -0x24(%ebp),%edx
 435:	8b 45 f4             	mov    -0xc(%ebp),%eax
 438:	01 d0                	add    %edx,%eax
 43a:	0f b6 00             	movzbl (%eax),%eax
 43d:	0f be c0             	movsbl %al,%eax
 440:	89 44 24 04          	mov    %eax,0x4(%esp)
 444:	8b 45 08             	mov    0x8(%ebp),%eax
 447:	89 04 24             	mov    %eax,(%esp)
 44a:	e8 31 ff ff ff       	call   380 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 44f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 453:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 457:	79 d9                	jns    432 <printint+0x8a>
    putc(fd, buf[i]);
}
 459:	83 c4 30             	add    $0x30,%esp
 45c:	5b                   	pop    %ebx
 45d:	5e                   	pop    %esi
 45e:	5d                   	pop    %ebp
 45f:	c3                   	ret    

00000460 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 460:	55                   	push   %ebp
 461:	89 e5                	mov    %esp,%ebp
 463:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 466:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 46d:	8d 45 0c             	lea    0xc(%ebp),%eax
 470:	83 c0 04             	add    $0x4,%eax
 473:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 476:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 47d:	e9 7c 01 00 00       	jmp    5fe <printf+0x19e>
    c = fmt[i] & 0xff;
 482:	8b 55 0c             	mov    0xc(%ebp),%edx
 485:	8b 45 f0             	mov    -0x10(%ebp),%eax
 488:	01 d0                	add    %edx,%eax
 48a:	0f b6 00             	movzbl (%eax),%eax
 48d:	0f be c0             	movsbl %al,%eax
 490:	25 ff 00 00 00       	and    $0xff,%eax
 495:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 498:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 49c:	75 2c                	jne    4ca <printf+0x6a>
      if(c == '%'){
 49e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4a2:	75 0c                	jne    4b0 <printf+0x50>
        state = '%';
 4a4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ab:	e9 4a 01 00 00       	jmp    5fa <printf+0x19a>
      } else {
        putc(fd, c);
 4b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b3:	0f be c0             	movsbl %al,%eax
 4b6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ba:	8b 45 08             	mov    0x8(%ebp),%eax
 4bd:	89 04 24             	mov    %eax,(%esp)
 4c0:	e8 bb fe ff ff       	call   380 <putc>
 4c5:	e9 30 01 00 00       	jmp    5fa <printf+0x19a>
      }
    } else if(state == '%'){
 4ca:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ce:	0f 85 26 01 00 00    	jne    5fa <printf+0x19a>
      if(c == 'd'){
 4d4:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4d8:	75 2d                	jne    507 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4da:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4dd:	8b 00                	mov    (%eax),%eax
 4df:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4e6:	00 
 4e7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4ee:	00 
 4ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	89 04 24             	mov    %eax,(%esp)
 4f9:	e8 aa fe ff ff       	call   3a8 <printint>
        ap++;
 4fe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 502:	e9 ec 00 00 00       	jmp    5f3 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 507:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 50b:	74 06                	je     513 <printf+0xb3>
 50d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 511:	75 2d                	jne    540 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 513:	8b 45 e8             	mov    -0x18(%ebp),%eax
 516:	8b 00                	mov    (%eax),%eax
 518:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 51f:	00 
 520:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 527:	00 
 528:	89 44 24 04          	mov    %eax,0x4(%esp)
 52c:	8b 45 08             	mov    0x8(%ebp),%eax
 52f:	89 04 24             	mov    %eax,(%esp)
 532:	e8 71 fe ff ff       	call   3a8 <printint>
        ap++;
 537:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 53b:	e9 b3 00 00 00       	jmp    5f3 <printf+0x193>
      } else if(c == 's'){
 540:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 544:	75 45                	jne    58b <printf+0x12b>
        s = (char*)*ap;
 546:	8b 45 e8             	mov    -0x18(%ebp),%eax
 549:	8b 00                	mov    (%eax),%eax
 54b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 54e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 556:	75 09                	jne    561 <printf+0x101>
          s = "(null)";
 558:	c7 45 f4 ea 08 00 00 	movl   $0x8ea,-0xc(%ebp)
        while(*s != 0){
 55f:	eb 1e                	jmp    57f <printf+0x11f>
 561:	eb 1c                	jmp    57f <printf+0x11f>
          putc(fd, *s);
 563:	8b 45 f4             	mov    -0xc(%ebp),%eax
 566:	0f b6 00             	movzbl (%eax),%eax
 569:	0f be c0             	movsbl %al,%eax
 56c:	89 44 24 04          	mov    %eax,0x4(%esp)
 570:	8b 45 08             	mov    0x8(%ebp),%eax
 573:	89 04 24             	mov    %eax,(%esp)
 576:	e8 05 fe ff ff       	call   380 <putc>
          s++;
 57b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 57f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 582:	0f b6 00             	movzbl (%eax),%eax
 585:	84 c0                	test   %al,%al
 587:	75 da                	jne    563 <printf+0x103>
 589:	eb 68                	jmp    5f3 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 58b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 58f:	75 1d                	jne    5ae <printf+0x14e>
        putc(fd, *ap);
 591:	8b 45 e8             	mov    -0x18(%ebp),%eax
 594:	8b 00                	mov    (%eax),%eax
 596:	0f be c0             	movsbl %al,%eax
 599:	89 44 24 04          	mov    %eax,0x4(%esp)
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	89 04 24             	mov    %eax,(%esp)
 5a3:	e8 d8 fd ff ff       	call   380 <putc>
        ap++;
 5a8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ac:	eb 45                	jmp    5f3 <printf+0x193>
      } else if(c == '%'){
 5ae:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5b2:	75 17                	jne    5cb <printf+0x16b>
        putc(fd, c);
 5b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b7:	0f be c0             	movsbl %al,%eax
 5ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 5be:	8b 45 08             	mov    0x8(%ebp),%eax
 5c1:	89 04 24             	mov    %eax,(%esp)
 5c4:	e8 b7 fd ff ff       	call   380 <putc>
 5c9:	eb 28                	jmp    5f3 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5cb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5d2:	00 
 5d3:	8b 45 08             	mov    0x8(%ebp),%eax
 5d6:	89 04 24             	mov    %eax,(%esp)
 5d9:	e8 a2 fd ff ff       	call   380 <putc>
        putc(fd, c);
 5de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e1:	0f be c0             	movsbl %al,%eax
 5e4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e8:	8b 45 08             	mov    0x8(%ebp),%eax
 5eb:	89 04 24             	mov    %eax,(%esp)
 5ee:	e8 8d fd ff ff       	call   380 <putc>
      }
      state = 0;
 5f3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5fa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5fe:	8b 55 0c             	mov    0xc(%ebp),%edx
 601:	8b 45 f0             	mov    -0x10(%ebp),%eax
 604:	01 d0                	add    %edx,%eax
 606:	0f b6 00             	movzbl (%eax),%eax
 609:	84 c0                	test   %al,%al
 60b:	0f 85 71 fe ff ff    	jne    482 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 611:	c9                   	leave  
 612:	c3                   	ret    
 613:	90                   	nop

00000614 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 614:	55                   	push   %ebp
 615:	89 e5                	mov    %esp,%ebp
 617:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 61a:	8b 45 08             	mov    0x8(%ebp),%eax
 61d:	83 e8 08             	sub    $0x8,%eax
 620:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 623:	a1 14 0c 00 00       	mov    0xc14,%eax
 628:	89 45 fc             	mov    %eax,-0x4(%ebp)
 62b:	eb 24                	jmp    651 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 62d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 630:	8b 00                	mov    (%eax),%eax
 632:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 635:	77 12                	ja     649 <free+0x35>
 637:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63d:	77 24                	ja     663 <free+0x4f>
 63f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 647:	77 1a                	ja     663 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 649:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 651:	8b 45 f8             	mov    -0x8(%ebp),%eax
 654:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 657:	76 d4                	jbe    62d <free+0x19>
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 661:	76 ca                	jbe    62d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 663:	8b 45 f8             	mov    -0x8(%ebp),%eax
 666:	8b 40 04             	mov    0x4(%eax),%eax
 669:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 670:	8b 45 f8             	mov    -0x8(%ebp),%eax
 673:	01 c2                	add    %eax,%edx
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	8b 00                	mov    (%eax),%eax
 67a:	39 c2                	cmp    %eax,%edx
 67c:	75 24                	jne    6a2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	8b 50 04             	mov    0x4(%eax),%edx
 684:	8b 45 fc             	mov    -0x4(%ebp),%eax
 687:	8b 00                	mov    (%eax),%eax
 689:	8b 40 04             	mov    0x4(%eax),%eax
 68c:	01 c2                	add    %eax,%edx
 68e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 691:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 694:	8b 45 fc             	mov    -0x4(%ebp),%eax
 697:	8b 00                	mov    (%eax),%eax
 699:	8b 10                	mov    (%eax),%edx
 69b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69e:	89 10                	mov    %edx,(%eax)
 6a0:	eb 0a                	jmp    6ac <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a5:	8b 10                	mov    (%eax),%edx
 6a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6aa:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6af:	8b 40 04             	mov    0x4(%eax),%eax
 6b2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	01 d0                	add    %edx,%eax
 6be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c1:	75 20                	jne    6e3 <free+0xcf>
    p->s.size += bp->s.size;
 6c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c6:	8b 50 04             	mov    0x4(%eax),%edx
 6c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cc:	8b 40 04             	mov    0x4(%eax),%eax
 6cf:	01 c2                	add    %eax,%edx
 6d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	8b 10                	mov    (%eax),%edx
 6dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6df:	89 10                	mov    %edx,(%eax)
 6e1:	eb 08                	jmp    6eb <free+0xd7>
  } else
    p->s.ptr = bp;
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6e9:	89 10                	mov    %edx,(%eax)
  freep = p;
 6eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ee:	a3 14 0c 00 00       	mov    %eax,0xc14
}
 6f3:	c9                   	leave  
 6f4:	c3                   	ret    

000006f5 <morecore>:

static Header*
morecore(uint nu)
{
 6f5:	55                   	push   %ebp
 6f6:	89 e5                	mov    %esp,%ebp
 6f8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6fb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 702:	77 07                	ja     70b <morecore+0x16>
    nu = 4096;
 704:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	c1 e0 03             	shl    $0x3,%eax
 711:	89 04 24             	mov    %eax,(%esp)
 714:	e8 3f fc ff ff       	call   358 <sbrk>
 719:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 71c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 720:	75 07                	jne    729 <morecore+0x34>
    return 0;
 722:	b8 00 00 00 00       	mov    $0x0,%eax
 727:	eb 22                	jmp    74b <morecore+0x56>
  hp = (Header*)p;
 729:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 72f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 732:	8b 55 08             	mov    0x8(%ebp),%edx
 735:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 738:	8b 45 f0             	mov    -0x10(%ebp),%eax
 73b:	83 c0 08             	add    $0x8,%eax
 73e:	89 04 24             	mov    %eax,(%esp)
 741:	e8 ce fe ff ff       	call   614 <free>
  return freep;
 746:	a1 14 0c 00 00       	mov    0xc14,%eax
}
 74b:	c9                   	leave  
 74c:	c3                   	ret    

0000074d <malloc>:

void*
malloc(uint nbytes)
{
 74d:	55                   	push   %ebp
 74e:	89 e5                	mov    %esp,%ebp
 750:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 753:	8b 45 08             	mov    0x8(%ebp),%eax
 756:	83 c0 07             	add    $0x7,%eax
 759:	c1 e8 03             	shr    $0x3,%eax
 75c:	83 c0 01             	add    $0x1,%eax
 75f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 762:	a1 14 0c 00 00       	mov    0xc14,%eax
 767:	89 45 f0             	mov    %eax,-0x10(%ebp)
 76a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 76e:	75 23                	jne    793 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 770:	c7 45 f0 0c 0c 00 00 	movl   $0xc0c,-0x10(%ebp)
 777:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77a:	a3 14 0c 00 00       	mov    %eax,0xc14
 77f:	a1 14 0c 00 00       	mov    0xc14,%eax
 784:	a3 0c 0c 00 00       	mov    %eax,0xc0c
    base.s.size = 0;
 789:	c7 05 10 0c 00 00 00 	movl   $0x0,0xc10
 790:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 793:	8b 45 f0             	mov    -0x10(%ebp),%eax
 796:	8b 00                	mov    (%eax),%eax
 798:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 79b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79e:	8b 40 04             	mov    0x4(%eax),%eax
 7a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7a4:	72 4d                	jb     7f3 <malloc+0xa6>
      if(p->s.size == nunits)
 7a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a9:	8b 40 04             	mov    0x4(%eax),%eax
 7ac:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7af:	75 0c                	jne    7bd <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	8b 10                	mov    (%eax),%edx
 7b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b9:	89 10                	mov    %edx,(%eax)
 7bb:	eb 26                	jmp    7e3 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c0:	8b 40 04             	mov    0x4(%eax),%eax
 7c3:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7c6:	89 c2                	mov    %eax,%edx
 7c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cb:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d1:	8b 40 04             	mov    0x4(%eax),%eax
 7d4:	c1 e0 03             	shl    $0x3,%eax
 7d7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7e0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e6:	a3 14 0c 00 00       	mov    %eax,0xc14
      return (void*)(p + 1);
 7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ee:	83 c0 08             	add    $0x8,%eax
 7f1:	eb 38                	jmp    82b <malloc+0xde>
    }
    if(p == freep)
 7f3:	a1 14 0c 00 00       	mov    0xc14,%eax
 7f8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7fb:	75 1b                	jne    818 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 7fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
 800:	89 04 24             	mov    %eax,(%esp)
 803:	e8 ed fe ff ff       	call   6f5 <morecore>
 808:	89 45 f4             	mov    %eax,-0xc(%ebp)
 80b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 80f:	75 07                	jne    818 <malloc+0xcb>
        return 0;
 811:	b8 00 00 00 00       	mov    $0x0,%eax
 816:	eb 13                	jmp    82b <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 81e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 821:	8b 00                	mov    (%eax),%eax
 823:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 826:	e9 70 ff ff ff       	jmp    79b <malloc+0x4e>
}
 82b:	c9                   	leave  
 82c:	c3                   	ret    
 82d:	66 90                	xchg   %ax,%ax
 82f:	90                   	nop

00000830 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
 830:	55                   	push   %ebp
 831:	89 e5                	mov    %esp,%ebp
 833:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 836:	8b 55 08             	mov    0x8(%ebp),%edx
 839:	8b 45 0c             	mov    0xc(%ebp),%eax
 83c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 83f:	f0 87 02             	lock xchg %eax,(%edx)
 842:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 848:	c9                   	leave  
 849:	c3                   	ret    

0000084a <mutex_init>:
#include "types.h"
#include "user.h"
#include "x86.h"
#include "threadlib.h"

void mutex_init(mutex_t *m) {
 84a:	55                   	push   %ebp
 84b:	89 e5                	mov    %esp,%ebp
  // 0 indicates that lock is available, 1 that it is held by a thread
  m->flag = 0;
 84d:	8b 45 08             	mov    0x8(%ebp),%eax
 850:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 856:	5d                   	pop    %ebp
 857:	c3                   	ret    

00000858 <mutex_lock>:

void mutex_lock(mutex_t *m)
{
 858:	55                   	push   %ebp
 859:	89 e5                	mov    %esp,%ebp
 85b:	83 ec 08             	sub    $0x8,%esp
  while (xchg(&m->flag, 1) == 1); // spin-wait (do nothing)
 85e:	90                   	nop
 85f:	8b 45 08             	mov    0x8(%ebp),%eax
 862:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 869:	00 
 86a:	89 04 24             	mov    %eax,(%esp)
 86d:	e8 be ff ff ff       	call   830 <xchg>
 872:	83 f8 01             	cmp    $0x1,%eax
 875:	74 e8                	je     85f <mutex_lock+0x7>
}
 877:	c9                   	leave  
 878:	c3                   	ret    

00000879 <mutex_unlock>:

void mutex_unlock(mutex_t *m)
{
 879:	55                   	push   %ebp
 87a:	89 e5                	mov    %esp,%ebp
  m->flag = 0;
 87c:	8b 45 08             	mov    0x8(%ebp),%eax
 87f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
} 
 885:	5d                   	pop    %ebp
 886:	c3                   	ret    

00000887 <thread_create>:
  if(!pid) (*start_routine)(arg);
  else return pid;
}*/

int thread_create(void(*child)(void*), void *arg_ptr)
{
 887:	55                   	push   %ebp
 888:	89 e5                	mov    %esp,%ebp
 88a:	83 ec 28             	sub    $0x28,%esp
	void *stack = malloc(4096);
 88d:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 894:	e8 b4 fe ff ff       	call   74d <malloc>
 899:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int clone_pid = clone(child, arg_ptr, stack);
 89c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89f:	89 44 24 08          	mov    %eax,0x8(%esp)
 8a3:	8b 45 0c             	mov    0xc(%ebp),%eax
 8a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 8aa:	8b 45 08             	mov    0x8(%ebp),%eax
 8ad:	89 04 24             	mov    %eax,(%esp)
 8b0:	e8 bb fa ff ff       	call   370 <clone>
 8b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return clone_pid;
 8b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 8bb:	c9                   	leave  
 8bc:	c3                   	ret    

000008bd <thread_join>:

int thread_join(void)
{
 8bd:	55                   	push   %ebp
 8be:	89 e5                	mov    %esp,%ebp
 8c0:	83 ec 28             	sub    $0x28,%esp
    void *join_s;
    int join_pid = join(&join_s);
 8c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
 8c6:	89 04 24             	mov    %eax,(%esp)
 8c9:	e8 aa fa ff ff       	call   378 <join>
 8ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return join_pid;
 8d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d4:	c9                   	leave  
 8d5:	c3                   	ret    
