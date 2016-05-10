
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  int fd, i;
  char path[] = "stressfs0";
   c:	c7 84 24 1e 02 00 00 	movl   $0x65727473,0x21e(%esp)
  13:	73 74 72 65 
  17:	c7 84 24 22 02 00 00 	movl   $0x73667373,0x222(%esp)
  1e:	73 73 66 73 
  22:	66 c7 84 24 26 02 00 	movw   $0x30,0x226(%esp)
  29:	00 30 00 
  char data[512];

  printf(1, "stressfs starting\n");
  2c:	c7 44 24 04 22 0a 00 	movl   $0xa22,0x4(%esp)
  33:	00 
  34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3b:	e8 6c 05 00 00       	call   5ac <printf>
  memset(data, 'a', sizeof(data));
  40:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  47:	00 
  48:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  4f:	00 
  50:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  54:	89 04 24             	mov    %eax,(%esp)
  57:	e8 13 02 00 00       	call   26f <memset>

  for(i = 0; i < 4; i++)
  5c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  63:	00 00 00 00 
  67:	eb 13                	jmp    7c <main+0x7c>
    if(fork() > 0)
  69:	e8 a6 03 00 00       	call   414 <fork>
  6e:	85 c0                	test   %eax,%eax
  70:	7e 02                	jle    74 <main+0x74>
      break;
  72:	eb 12                	jmp    86 <main+0x86>
  char data[512];

  printf(1, "stressfs starting\n");
  memset(data, 'a', sizeof(data));

  for(i = 0; i < 4; i++)
  74:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
  7b:	01 
  7c:	83 bc 24 2c 02 00 00 	cmpl   $0x3,0x22c(%esp)
  83:	03 
  84:	7e e3                	jle    69 <main+0x69>
    if(fork() > 0)
      break;

  printf(1, "write %d\n", i);
  86:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  91:	c7 44 24 04 35 0a 00 	movl   $0xa35,0x4(%esp)
  98:	00 
  99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a0:	e8 07 05 00 00       	call   5ac <printf>

  path[8] += i;
  a5:	0f b6 84 24 26 02 00 	movzbl 0x226(%esp),%eax
  ac:	00 
  ad:	89 c2                	mov    %eax,%edx
  af:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
  b6:	01 d0                	add    %edx,%eax
  b8:	88 84 24 26 02 00 00 	mov    %al,0x226(%esp)
  fd = open(path, O_CREATE | O_RDWR);
  bf:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  c6:	00 
  c7:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
  ce:	89 04 24             	mov    %eax,(%esp)
  d1:	e8 86 03 00 00       	call   45c <open>
  d6:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for(i = 0; i < 20; i++)
  dd:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
  e4:	00 00 00 00 
  e8:	eb 27                	jmp    111 <main+0x111>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  ea:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  f1:	00 
  f2:	8d 44 24 1e          	lea    0x1e(%esp),%eax
  f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  fa:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 101:	89 04 24             	mov    %eax,(%esp)
 104:	e8 33 03 00 00       	call   43c <write>

  printf(1, "write %d\n", i);

  path[8] += i;
  fd = open(path, O_CREATE | O_RDWR);
  for(i = 0; i < 20; i++)
 109:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 110:	01 
 111:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 118:	13 
 119:	7e cf                	jle    ea <main+0xea>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  close(fd);
 11b:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 122:	89 04 24             	mov    %eax,(%esp)
 125:	e8 1a 03 00 00       	call   444 <close>

  printf(1, "read\n");
 12a:	c7 44 24 04 3f 0a 00 	movl   $0xa3f,0x4(%esp)
 131:	00 
 132:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 139:	e8 6e 04 00 00       	call   5ac <printf>

  fd = open(path, O_RDONLY);
 13e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 145:	00 
 146:	8d 84 24 1e 02 00 00 	lea    0x21e(%esp),%eax
 14d:	89 04 24             	mov    %eax,(%esp)
 150:	e8 07 03 00 00       	call   45c <open>
 155:	89 84 24 28 02 00 00 	mov    %eax,0x228(%esp)
  for (i = 0; i < 20; i++)
 15c:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 163:	00 00 00 00 
 167:	eb 27                	jmp    190 <main+0x190>
    read(fd, data, sizeof(data));
 169:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 170:	00 
 171:	8d 44 24 1e          	lea    0x1e(%esp),%eax
 175:	89 44 24 04          	mov    %eax,0x4(%esp)
 179:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 180:	89 04 24             	mov    %eax,(%esp)
 183:	e8 ac 02 00 00       	call   434 <read>
  close(fd);

  printf(1, "read\n");

  fd = open(path, O_RDONLY);
  for (i = 0; i < 20; i++)
 188:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 18f:	01 
 190:	83 bc 24 2c 02 00 00 	cmpl   $0x13,0x22c(%esp)
 197:	13 
 198:	7e cf                	jle    169 <main+0x169>
    read(fd, data, sizeof(data));
  close(fd);
 19a:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
 1a1:	89 04 24             	mov    %eax,(%esp)
 1a4:	e8 9b 02 00 00       	call   444 <close>

  wait();
 1a9:	e8 76 02 00 00       	call   424 <wait>
  
  exit();
 1ae:	e8 69 02 00 00       	call   41c <exit>
 1b3:	90                   	nop

000001b4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	57                   	push   %edi
 1b8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1bc:	8b 55 10             	mov    0x10(%ebp),%edx
 1bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c2:	89 cb                	mov    %ecx,%ebx
 1c4:	89 df                	mov    %ebx,%edi
 1c6:	89 d1                	mov    %edx,%ecx
 1c8:	fc                   	cld    
 1c9:	f3 aa                	rep stos %al,%es:(%edi)
 1cb:	89 ca                	mov    %ecx,%edx
 1cd:	89 fb                	mov    %edi,%ebx
 1cf:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1d2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1d5:	5b                   	pop    %ebx
 1d6:	5f                   	pop    %edi
 1d7:	5d                   	pop    %ebp
 1d8:	c3                   	ret    

000001d9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1d9:	55                   	push   %ebp
 1da:	89 e5                	mov    %esp,%ebp
 1dc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1e5:	90                   	nop
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	8d 50 01             	lea    0x1(%eax),%edx
 1ec:	89 55 08             	mov    %edx,0x8(%ebp)
 1ef:	8b 55 0c             	mov    0xc(%ebp),%edx
 1f2:	8d 4a 01             	lea    0x1(%edx),%ecx
 1f5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1f8:	0f b6 12             	movzbl (%edx),%edx
 1fb:	88 10                	mov    %dl,(%eax)
 1fd:	0f b6 00             	movzbl (%eax),%eax
 200:	84 c0                	test   %al,%al
 202:	75 e2                	jne    1e6 <strcpy+0xd>
    ;
  return os;
 204:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 207:	c9                   	leave  
 208:	c3                   	ret    

00000209 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 209:	55                   	push   %ebp
 20a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 20c:	eb 08                	jmp    216 <strcmp+0xd>
    p++, q++;
 20e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 212:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 216:	8b 45 08             	mov    0x8(%ebp),%eax
 219:	0f b6 00             	movzbl (%eax),%eax
 21c:	84 c0                	test   %al,%al
 21e:	74 10                	je     230 <strcmp+0x27>
 220:	8b 45 08             	mov    0x8(%ebp),%eax
 223:	0f b6 10             	movzbl (%eax),%edx
 226:	8b 45 0c             	mov    0xc(%ebp),%eax
 229:	0f b6 00             	movzbl (%eax),%eax
 22c:	38 c2                	cmp    %al,%dl
 22e:	74 de                	je     20e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	0f b6 00             	movzbl (%eax),%eax
 236:	0f b6 d0             	movzbl %al,%edx
 239:	8b 45 0c             	mov    0xc(%ebp),%eax
 23c:	0f b6 00             	movzbl (%eax),%eax
 23f:	0f b6 c0             	movzbl %al,%eax
 242:	29 c2                	sub    %eax,%edx
 244:	89 d0                	mov    %edx,%eax
}
 246:	5d                   	pop    %ebp
 247:	c3                   	ret    

00000248 <strlen>:

uint
strlen(char *s)
{
 248:	55                   	push   %ebp
 249:	89 e5                	mov    %esp,%ebp
 24b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 24e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 255:	eb 04                	jmp    25b <strlen+0x13>
 257:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 25b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 25e:	8b 45 08             	mov    0x8(%ebp),%eax
 261:	01 d0                	add    %edx,%eax
 263:	0f b6 00             	movzbl (%eax),%eax
 266:	84 c0                	test   %al,%al
 268:	75 ed                	jne    257 <strlen+0xf>
    ;
  return n;
 26a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 26d:	c9                   	leave  
 26e:	c3                   	ret    

0000026f <memset>:

void*
memset(void *dst, int c, uint n)
{
 26f:	55                   	push   %ebp
 270:	89 e5                	mov    %esp,%ebp
 272:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 275:	8b 45 10             	mov    0x10(%ebp),%eax
 278:	89 44 24 08          	mov    %eax,0x8(%esp)
 27c:	8b 45 0c             	mov    0xc(%ebp),%eax
 27f:	89 44 24 04          	mov    %eax,0x4(%esp)
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	89 04 24             	mov    %eax,(%esp)
 289:	e8 26 ff ff ff       	call   1b4 <stosb>
  return dst;
 28e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 291:	c9                   	leave  
 292:	c3                   	ret    

00000293 <strchr>:

char*
strchr(const char *s, char c)
{
 293:	55                   	push   %ebp
 294:	89 e5                	mov    %esp,%ebp
 296:	83 ec 04             	sub    $0x4,%esp
 299:	8b 45 0c             	mov    0xc(%ebp),%eax
 29c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 29f:	eb 14                	jmp    2b5 <strchr+0x22>
    if(*s == c)
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	0f b6 00             	movzbl (%eax),%eax
 2a7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2aa:	75 05                	jne    2b1 <strchr+0x1e>
      return (char*)s;
 2ac:	8b 45 08             	mov    0x8(%ebp),%eax
 2af:	eb 13                	jmp    2c4 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	84 c0                	test   %al,%al
 2bd:	75 e2                	jne    2a1 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2c4:	c9                   	leave  
 2c5:	c3                   	ret    

000002c6 <gets>:

char*
gets(char *buf, int max)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2d3:	eb 4c                	jmp    321 <gets+0x5b>
    cc = read(0, &c, 1);
 2d5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2dc:	00 
 2dd:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 2e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2eb:	e8 44 01 00 00       	call   434 <read>
 2f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2f7:	7f 02                	jg     2fb <gets+0x35>
      break;
 2f9:	eb 31                	jmp    32c <gets+0x66>
    buf[i++] = c;
 2fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fe:	8d 50 01             	lea    0x1(%eax),%edx
 301:	89 55 f4             	mov    %edx,-0xc(%ebp)
 304:	89 c2                	mov    %eax,%edx
 306:	8b 45 08             	mov    0x8(%ebp),%eax
 309:	01 c2                	add    %eax,%edx
 30b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 30f:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 311:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 315:	3c 0a                	cmp    $0xa,%al
 317:	74 13                	je     32c <gets+0x66>
 319:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 31d:	3c 0d                	cmp    $0xd,%al
 31f:	74 0b                	je     32c <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 321:	8b 45 f4             	mov    -0xc(%ebp),%eax
 324:	83 c0 01             	add    $0x1,%eax
 327:	3b 45 0c             	cmp    0xc(%ebp),%eax
 32a:	7c a9                	jl     2d5 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 32c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	01 d0                	add    %edx,%eax
 334:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 337:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33a:	c9                   	leave  
 33b:	c3                   	ret    

0000033c <stat>:

int
stat(char *n, struct stat *st)
{
 33c:	55                   	push   %ebp
 33d:	89 e5                	mov    %esp,%ebp
 33f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 342:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 349:	00 
 34a:	8b 45 08             	mov    0x8(%ebp),%eax
 34d:	89 04 24             	mov    %eax,(%esp)
 350:	e8 07 01 00 00       	call   45c <open>
 355:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 358:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 35c:	79 07                	jns    365 <stat+0x29>
    return -1;
 35e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 363:	eb 23                	jmp    388 <stat+0x4c>
  r = fstat(fd, st);
 365:	8b 45 0c             	mov    0xc(%ebp),%eax
 368:	89 44 24 04          	mov    %eax,0x4(%esp)
 36c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 36f:	89 04 24             	mov    %eax,(%esp)
 372:	e8 fd 00 00 00       	call   474 <fstat>
 377:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 37a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37d:	89 04 24             	mov    %eax,(%esp)
 380:	e8 bf 00 00 00       	call   444 <close>
  return r;
 385:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 388:	c9                   	leave  
 389:	c3                   	ret    

0000038a <atoi>:

int
atoi(const char *s)
{
 38a:	55                   	push   %ebp
 38b:	89 e5                	mov    %esp,%ebp
 38d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 390:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 397:	eb 25                	jmp    3be <atoi+0x34>
    n = n*10 + *s++ - '0';
 399:	8b 55 fc             	mov    -0x4(%ebp),%edx
 39c:	89 d0                	mov    %edx,%eax
 39e:	c1 e0 02             	shl    $0x2,%eax
 3a1:	01 d0                	add    %edx,%eax
 3a3:	01 c0                	add    %eax,%eax
 3a5:	89 c1                	mov    %eax,%ecx
 3a7:	8b 45 08             	mov    0x8(%ebp),%eax
 3aa:	8d 50 01             	lea    0x1(%eax),%edx
 3ad:	89 55 08             	mov    %edx,0x8(%ebp)
 3b0:	0f b6 00             	movzbl (%eax),%eax
 3b3:	0f be c0             	movsbl %al,%eax
 3b6:	01 c8                	add    %ecx,%eax
 3b8:	83 e8 30             	sub    $0x30,%eax
 3bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3be:	8b 45 08             	mov    0x8(%ebp),%eax
 3c1:	0f b6 00             	movzbl (%eax),%eax
 3c4:	3c 2f                	cmp    $0x2f,%al
 3c6:	7e 0a                	jle    3d2 <atoi+0x48>
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	0f b6 00             	movzbl (%eax),%eax
 3ce:	3c 39                	cmp    $0x39,%al
 3d0:	7e c7                	jle    399 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3d5:	c9                   	leave  
 3d6:	c3                   	ret    

000003d7 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3d7:	55                   	push   %ebp
 3d8:	89 e5                	mov    %esp,%ebp
 3da:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3e3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3e9:	eb 17                	jmp    402 <memmove+0x2b>
    *dst++ = *src++;
 3eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ee:	8d 50 01             	lea    0x1(%eax),%edx
 3f1:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3f4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3f7:	8d 4a 01             	lea    0x1(%edx),%ecx
 3fa:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3fd:	0f b6 12             	movzbl (%edx),%edx
 400:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 402:	8b 45 10             	mov    0x10(%ebp),%eax
 405:	8d 50 ff             	lea    -0x1(%eax),%edx
 408:	89 55 10             	mov    %edx,0x10(%ebp)
 40b:	85 c0                	test   %eax,%eax
 40d:	7f dc                	jg     3eb <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 40f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 412:	c9                   	leave  
 413:	c3                   	ret    

00000414 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 414:	b8 01 00 00 00       	mov    $0x1,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <exit>:
SYSCALL(exit)
 41c:	b8 02 00 00 00       	mov    $0x2,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <wait>:
SYSCALL(wait)
 424:	b8 03 00 00 00       	mov    $0x3,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <pipe>:
SYSCALL(pipe)
 42c:	b8 04 00 00 00       	mov    $0x4,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <read>:
SYSCALL(read)
 434:	b8 05 00 00 00       	mov    $0x5,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <write>:
SYSCALL(write)
 43c:	b8 10 00 00 00       	mov    $0x10,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <close>:
SYSCALL(close)
 444:	b8 15 00 00 00       	mov    $0x15,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <kill>:
SYSCALL(kill)
 44c:	b8 06 00 00 00       	mov    $0x6,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <exec>:
SYSCALL(exec)
 454:	b8 07 00 00 00       	mov    $0x7,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <open>:
SYSCALL(open)
 45c:	b8 0f 00 00 00       	mov    $0xf,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <mknod>:
SYSCALL(mknod)
 464:	b8 11 00 00 00       	mov    $0x11,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <unlink>:
SYSCALL(unlink)
 46c:	b8 12 00 00 00       	mov    $0x12,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <fstat>:
SYSCALL(fstat)
 474:	b8 08 00 00 00       	mov    $0x8,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <link>:
SYSCALL(link)
 47c:	b8 13 00 00 00       	mov    $0x13,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <mkdir>:
SYSCALL(mkdir)
 484:	b8 14 00 00 00       	mov    $0x14,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <chdir>:
SYSCALL(chdir)
 48c:	b8 09 00 00 00       	mov    $0x9,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <dup>:
SYSCALL(dup)
 494:	b8 0a 00 00 00       	mov    $0xa,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <getpid>:
SYSCALL(getpid)
 49c:	b8 0b 00 00 00       	mov    $0xb,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <sbrk>:
SYSCALL(sbrk)
 4a4:	b8 0c 00 00 00       	mov    $0xc,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <sleep>:
SYSCALL(sleep)
 4ac:	b8 0d 00 00 00       	mov    $0xd,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <uptime>:
SYSCALL(uptime)
 4b4:	b8 0e 00 00 00       	mov    $0xe,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <clone>:
SYSCALL(clone)
 4bc:	b8 16 00 00 00       	mov    $0x16,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <join>:
 4c4:	b8 17 00 00 00       	mov    $0x17,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4cc:	55                   	push   %ebp
 4cd:	89 e5                	mov    %esp,%ebp
 4cf:	83 ec 18             	sub    $0x18,%esp
 4d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4df:	00 
 4e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	89 04 24             	mov    %eax,(%esp)
 4ed:	e8 4a ff ff ff       	call   43c <write>
}
 4f2:	c9                   	leave  
 4f3:	c3                   	ret    

000004f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f4:	55                   	push   %ebp
 4f5:	89 e5                	mov    %esp,%ebp
 4f7:	56                   	push   %esi
 4f8:	53                   	push   %ebx
 4f9:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4fc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 503:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 507:	74 17                	je     520 <printint+0x2c>
 509:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 50d:	79 11                	jns    520 <printint+0x2c>
    neg = 1;
 50f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 516:	8b 45 0c             	mov    0xc(%ebp),%eax
 519:	f7 d8                	neg    %eax
 51b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 51e:	eb 06                	jmp    526 <printint+0x32>
  } else {
    x = xx;
 520:	8b 45 0c             	mov    0xc(%ebp),%eax
 523:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 526:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 52d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 530:	8d 41 01             	lea    0x1(%ecx),%eax
 533:	89 45 f4             	mov    %eax,-0xc(%ebp)
 536:	8b 5d 10             	mov    0x10(%ebp),%ebx
 539:	8b 45 ec             	mov    -0x14(%ebp),%eax
 53c:	ba 00 00 00 00       	mov    $0x0,%edx
 541:	f7 f3                	div    %ebx
 543:	89 d0                	mov    %edx,%eax
 545:	0f b6 80 50 0d 00 00 	movzbl 0xd50(%eax),%eax
 54c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 550:	8b 75 10             	mov    0x10(%ebp),%esi
 553:	8b 45 ec             	mov    -0x14(%ebp),%eax
 556:	ba 00 00 00 00       	mov    $0x0,%edx
 55b:	f7 f6                	div    %esi
 55d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 560:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 564:	75 c7                	jne    52d <printint+0x39>
  if(neg)
 566:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 56a:	74 10                	je     57c <printint+0x88>
    buf[i++] = '-';
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	8d 50 01             	lea    0x1(%eax),%edx
 572:	89 55 f4             	mov    %edx,-0xc(%ebp)
 575:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 57a:	eb 1f                	jmp    59b <printint+0xa7>
 57c:	eb 1d                	jmp    59b <printint+0xa7>
    putc(fd, buf[i]);
 57e:	8d 55 dc             	lea    -0x24(%ebp),%edx
 581:	8b 45 f4             	mov    -0xc(%ebp),%eax
 584:	01 d0                	add    %edx,%eax
 586:	0f b6 00             	movzbl (%eax),%eax
 589:	0f be c0             	movsbl %al,%eax
 58c:	89 44 24 04          	mov    %eax,0x4(%esp)
 590:	8b 45 08             	mov    0x8(%ebp),%eax
 593:	89 04 24             	mov    %eax,(%esp)
 596:	e8 31 ff ff ff       	call   4cc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 59b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 59f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a3:	79 d9                	jns    57e <printint+0x8a>
    putc(fd, buf[i]);
}
 5a5:	83 c4 30             	add    $0x30,%esp
 5a8:	5b                   	pop    %ebx
 5a9:	5e                   	pop    %esi
 5aa:	5d                   	pop    %ebp
 5ab:	c3                   	ret    

000005ac <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5ac:	55                   	push   %ebp
 5ad:	89 e5                	mov    %esp,%ebp
 5af:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5b9:	8d 45 0c             	lea    0xc(%ebp),%eax
 5bc:	83 c0 04             	add    $0x4,%eax
 5bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5c2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5c9:	e9 7c 01 00 00       	jmp    74a <printf+0x19e>
    c = fmt[i] & 0xff;
 5ce:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d4:	01 d0                	add    %edx,%eax
 5d6:	0f b6 00             	movzbl (%eax),%eax
 5d9:	0f be c0             	movsbl %al,%eax
 5dc:	25 ff 00 00 00       	and    $0xff,%eax
 5e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5e8:	75 2c                	jne    616 <printf+0x6a>
      if(c == '%'){
 5ea:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ee:	75 0c                	jne    5fc <printf+0x50>
        state = '%';
 5f0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5f7:	e9 4a 01 00 00       	jmp    746 <printf+0x19a>
      } else {
        putc(fd, c);
 5fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ff:	0f be c0             	movsbl %al,%eax
 602:	89 44 24 04          	mov    %eax,0x4(%esp)
 606:	8b 45 08             	mov    0x8(%ebp),%eax
 609:	89 04 24             	mov    %eax,(%esp)
 60c:	e8 bb fe ff ff       	call   4cc <putc>
 611:	e9 30 01 00 00       	jmp    746 <printf+0x19a>
      }
    } else if(state == '%'){
 616:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 61a:	0f 85 26 01 00 00    	jne    746 <printf+0x19a>
      if(c == 'd'){
 620:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 624:	75 2d                	jne    653 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 626:	8b 45 e8             	mov    -0x18(%ebp),%eax
 629:	8b 00                	mov    (%eax),%eax
 62b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 632:	00 
 633:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 63a:	00 
 63b:	89 44 24 04          	mov    %eax,0x4(%esp)
 63f:	8b 45 08             	mov    0x8(%ebp),%eax
 642:	89 04 24             	mov    %eax,(%esp)
 645:	e8 aa fe ff ff       	call   4f4 <printint>
        ap++;
 64a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64e:	e9 ec 00 00 00       	jmp    73f <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 653:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 657:	74 06                	je     65f <printf+0xb3>
 659:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 65d:	75 2d                	jne    68c <printf+0xe0>
        printint(fd, *ap, 16, 0);
 65f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 662:	8b 00                	mov    (%eax),%eax
 664:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 66b:	00 
 66c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 673:	00 
 674:	89 44 24 04          	mov    %eax,0x4(%esp)
 678:	8b 45 08             	mov    0x8(%ebp),%eax
 67b:	89 04 24             	mov    %eax,(%esp)
 67e:	e8 71 fe ff ff       	call   4f4 <printint>
        ap++;
 683:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 687:	e9 b3 00 00 00       	jmp    73f <printf+0x193>
      } else if(c == 's'){
 68c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 690:	75 45                	jne    6d7 <printf+0x12b>
        s = (char*)*ap;
 692:	8b 45 e8             	mov    -0x18(%ebp),%eax
 695:	8b 00                	mov    (%eax),%eax
 697:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 69a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 69e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a2:	75 09                	jne    6ad <printf+0x101>
          s = "(null)";
 6a4:	c7 45 f4 45 0a 00 00 	movl   $0xa45,-0xc(%ebp)
        while(*s != 0){
 6ab:	eb 1e                	jmp    6cb <printf+0x11f>
 6ad:	eb 1c                	jmp    6cb <printf+0x11f>
          putc(fd, *s);
 6af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b2:	0f b6 00             	movzbl (%eax),%eax
 6b5:	0f be c0             	movsbl %al,%eax
 6b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bc:	8b 45 08             	mov    0x8(%ebp),%eax
 6bf:	89 04 24             	mov    %eax,(%esp)
 6c2:	e8 05 fe ff ff       	call   4cc <putc>
          s++;
 6c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ce:	0f b6 00             	movzbl (%eax),%eax
 6d1:	84 c0                	test   %al,%al
 6d3:	75 da                	jne    6af <printf+0x103>
 6d5:	eb 68                	jmp    73f <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6db:	75 1d                	jne    6fa <printf+0x14e>
        putc(fd, *ap);
 6dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e0:	8b 00                	mov    (%eax),%eax
 6e2:	0f be c0             	movsbl %al,%eax
 6e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e9:	8b 45 08             	mov    0x8(%ebp),%eax
 6ec:	89 04 24             	mov    %eax,(%esp)
 6ef:	e8 d8 fd ff ff       	call   4cc <putc>
        ap++;
 6f4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f8:	eb 45                	jmp    73f <printf+0x193>
      } else if(c == '%'){
 6fa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6fe:	75 17                	jne    717 <printf+0x16b>
        putc(fd, c);
 700:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 703:	0f be c0             	movsbl %al,%eax
 706:	89 44 24 04          	mov    %eax,0x4(%esp)
 70a:	8b 45 08             	mov    0x8(%ebp),%eax
 70d:	89 04 24             	mov    %eax,(%esp)
 710:	e8 b7 fd ff ff       	call   4cc <putc>
 715:	eb 28                	jmp    73f <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 717:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 71e:	00 
 71f:	8b 45 08             	mov    0x8(%ebp),%eax
 722:	89 04 24             	mov    %eax,(%esp)
 725:	e8 a2 fd ff ff       	call   4cc <putc>
        putc(fd, c);
 72a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72d:	0f be c0             	movsbl %al,%eax
 730:	89 44 24 04          	mov    %eax,0x4(%esp)
 734:	8b 45 08             	mov    0x8(%ebp),%eax
 737:	89 04 24             	mov    %eax,(%esp)
 73a:	e8 8d fd ff ff       	call   4cc <putc>
      }
      state = 0;
 73f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 746:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 74a:	8b 55 0c             	mov    0xc(%ebp),%edx
 74d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 750:	01 d0                	add    %edx,%eax
 752:	0f b6 00             	movzbl (%eax),%eax
 755:	84 c0                	test   %al,%al
 757:	0f 85 71 fe ff ff    	jne    5ce <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 75d:	c9                   	leave  
 75e:	c3                   	ret    
 75f:	90                   	nop

00000760 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 760:	55                   	push   %ebp
 761:	89 e5                	mov    %esp,%ebp
 763:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 766:	8b 45 08             	mov    0x8(%ebp),%eax
 769:	83 e8 08             	sub    $0x8,%eax
 76c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76f:	a1 6c 0d 00 00       	mov    0xd6c,%eax
 774:	89 45 fc             	mov    %eax,-0x4(%ebp)
 777:	eb 24                	jmp    79d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 781:	77 12                	ja     795 <free+0x35>
 783:	8b 45 f8             	mov    -0x8(%ebp),%eax
 786:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 789:	77 24                	ja     7af <free+0x4f>
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 793:	77 1a                	ja     7af <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a3:	76 d4                	jbe    779 <free+0x19>
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ad:	76 ca                	jbe    779 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b2:	8b 40 04             	mov    0x4(%eax),%eax
 7b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bf:	01 c2                	add    %eax,%edx
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	39 c2                	cmp    %eax,%edx
 7c8:	75 24                	jne    7ee <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cd:	8b 50 04             	mov    0x4(%eax),%edx
 7d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d3:	8b 00                	mov    (%eax),%eax
 7d5:	8b 40 04             	mov    0x4(%eax),%eax
 7d8:	01 c2                	add    %eax,%edx
 7da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	8b 10                	mov    (%eax),%edx
 7e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ea:	89 10                	mov    %edx,(%eax)
 7ec:	eb 0a                	jmp    7f8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f1:	8b 10                	mov    (%eax),%edx
 7f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	8b 40 04             	mov    0x4(%eax),%eax
 7fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	01 d0                	add    %edx,%eax
 80a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 80d:	75 20                	jne    82f <free+0xcf>
    p->s.size += bp->s.size;
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	8b 50 04             	mov    0x4(%eax),%edx
 815:	8b 45 f8             	mov    -0x8(%ebp),%eax
 818:	8b 40 04             	mov    0x4(%eax),%eax
 81b:	01 c2                	add    %eax,%edx
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	8b 10                	mov    (%eax),%edx
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	89 10                	mov    %edx,(%eax)
 82d:	eb 08                	jmp    837 <free+0xd7>
  } else
    p->s.ptr = bp;
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	8b 55 f8             	mov    -0x8(%ebp),%edx
 835:	89 10                	mov    %edx,(%eax)
  freep = p;
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	a3 6c 0d 00 00       	mov    %eax,0xd6c
}
 83f:	c9                   	leave  
 840:	c3                   	ret    

00000841 <morecore>:

static Header*
morecore(uint nu)
{
 841:	55                   	push   %ebp
 842:	89 e5                	mov    %esp,%ebp
 844:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 847:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 84e:	77 07                	ja     857 <morecore+0x16>
    nu = 4096;
 850:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 857:	8b 45 08             	mov    0x8(%ebp),%eax
 85a:	c1 e0 03             	shl    $0x3,%eax
 85d:	89 04 24             	mov    %eax,(%esp)
 860:	e8 3f fc ff ff       	call   4a4 <sbrk>
 865:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 868:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 86c:	75 07                	jne    875 <morecore+0x34>
    return 0;
 86e:	b8 00 00 00 00       	mov    $0x0,%eax
 873:	eb 22                	jmp    897 <morecore+0x56>
  hp = (Header*)p;
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 87b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87e:	8b 55 08             	mov    0x8(%ebp),%edx
 881:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 884:	8b 45 f0             	mov    -0x10(%ebp),%eax
 887:	83 c0 08             	add    $0x8,%eax
 88a:	89 04 24             	mov    %eax,(%esp)
 88d:	e8 ce fe ff ff       	call   760 <free>
  return freep;
 892:	a1 6c 0d 00 00       	mov    0xd6c,%eax
}
 897:	c9                   	leave  
 898:	c3                   	ret    

00000899 <malloc>:

void*
malloc(uint nbytes)
{
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89f:	8b 45 08             	mov    0x8(%ebp),%eax
 8a2:	83 c0 07             	add    $0x7,%eax
 8a5:	c1 e8 03             	shr    $0x3,%eax
 8a8:	83 c0 01             	add    $0x1,%eax
 8ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8ae:	a1 6c 0d 00 00       	mov    0xd6c,%eax
 8b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ba:	75 23                	jne    8df <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8bc:	c7 45 f0 64 0d 00 00 	movl   $0xd64,-0x10(%ebp)
 8c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c6:	a3 6c 0d 00 00       	mov    %eax,0xd6c
 8cb:	a1 6c 0d 00 00       	mov    0xd6c,%eax
 8d0:	a3 64 0d 00 00       	mov    %eax,0xd64
    base.s.size = 0;
 8d5:	c7 05 68 0d 00 00 00 	movl   $0x0,0xd68
 8dc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e2:	8b 00                	mov    (%eax),%eax
 8e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ea:	8b 40 04             	mov    0x4(%eax),%eax
 8ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f0:	72 4d                	jb     93f <malloc+0xa6>
      if(p->s.size == nunits)
 8f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f5:	8b 40 04             	mov    0x4(%eax),%eax
 8f8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8fb:	75 0c                	jne    909 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 900:	8b 10                	mov    (%eax),%edx
 902:	8b 45 f0             	mov    -0x10(%ebp),%eax
 905:	89 10                	mov    %edx,(%eax)
 907:	eb 26                	jmp    92f <malloc+0x96>
      else {
        p->s.size -= nunits;
 909:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90c:	8b 40 04             	mov    0x4(%eax),%eax
 90f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 912:	89 c2                	mov    %eax,%edx
 914:	8b 45 f4             	mov    -0xc(%ebp),%eax
 917:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	8b 40 04             	mov    0x4(%eax),%eax
 920:	c1 e0 03             	shl    $0x3,%eax
 923:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	8b 55 ec             	mov    -0x14(%ebp),%edx
 92c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 92f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 932:	a3 6c 0d 00 00       	mov    %eax,0xd6c
      return (void*)(p + 1);
 937:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93a:	83 c0 08             	add    $0x8,%eax
 93d:	eb 38                	jmp    977 <malloc+0xde>
    }
    if(p == freep)
 93f:	a1 6c 0d 00 00       	mov    0xd6c,%eax
 944:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 947:	75 1b                	jne    964 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 949:	8b 45 ec             	mov    -0x14(%ebp),%eax
 94c:	89 04 24             	mov    %eax,(%esp)
 94f:	e8 ed fe ff ff       	call   841 <morecore>
 954:	89 45 f4             	mov    %eax,-0xc(%ebp)
 957:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 95b:	75 07                	jne    964 <malloc+0xcb>
        return 0;
 95d:	b8 00 00 00 00       	mov    $0x0,%eax
 962:	eb 13                	jmp    977 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 964:	8b 45 f4             	mov    -0xc(%ebp),%eax
 967:	89 45 f0             	mov    %eax,-0x10(%ebp)
 96a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96d:	8b 00                	mov    (%eax),%eax
 96f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 972:	e9 70 ff ff ff       	jmp    8e7 <malloc+0x4e>
}
 977:	c9                   	leave  
 978:	c3                   	ret    
 979:	66 90                	xchg   %ax,%ax
 97b:	90                   	nop

0000097c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
 97c:	55                   	push   %ebp
 97d:	89 e5                	mov    %esp,%ebp
 97f:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 982:	8b 55 08             	mov    0x8(%ebp),%edx
 985:	8b 45 0c             	mov    0xc(%ebp),%eax
 988:	8b 4d 08             	mov    0x8(%ebp),%ecx
 98b:	f0 87 02             	lock xchg %eax,(%edx)
 98e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
 991:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 994:	c9                   	leave  
 995:	c3                   	ret    

00000996 <mutex_init>:
#include "types.h"
#include "user.h"
#include "x86.h"
#include "threadlib.h"

void mutex_init(mutex_t *m) {
 996:	55                   	push   %ebp
 997:	89 e5                	mov    %esp,%ebp
  // 0 indicates that lock is available, 1 that it is held by a thread
  m->flag = 0;
 999:	8b 45 08             	mov    0x8(%ebp),%eax
 99c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 9a2:	5d                   	pop    %ebp
 9a3:	c3                   	ret    

000009a4 <mutex_lock>:

void mutex_lock(mutex_t *m)
{
 9a4:	55                   	push   %ebp
 9a5:	89 e5                	mov    %esp,%ebp
 9a7:	83 ec 08             	sub    $0x8,%esp
  while (xchg(&m->flag, 1) == 1); // spin-wait (do nothing)
 9aa:	90                   	nop
 9ab:	8b 45 08             	mov    0x8(%ebp),%eax
 9ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 9b5:	00 
 9b6:	89 04 24             	mov    %eax,(%esp)
 9b9:	e8 be ff ff ff       	call   97c <xchg>
 9be:	83 f8 01             	cmp    $0x1,%eax
 9c1:	74 e8                	je     9ab <mutex_lock+0x7>
}
 9c3:	c9                   	leave  
 9c4:	c3                   	ret    

000009c5 <mutex_unlock>:

void mutex_unlock(mutex_t *m)
{
 9c5:	55                   	push   %ebp
 9c6:	89 e5                	mov    %esp,%ebp
  m->flag = 0;
 9c8:	8b 45 08             	mov    0x8(%ebp),%eax
 9cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
} 
 9d1:	5d                   	pop    %ebp
 9d2:	c3                   	ret    

000009d3 <thread_create>:
  if(!pid) (*start_routine)(arg);
  else return pid;
}*/

int thread_create(void(*child)(void*), void *arg_ptr)
{
 9d3:	55                   	push   %ebp
 9d4:	89 e5                	mov    %esp,%ebp
 9d6:	83 ec 28             	sub    $0x28,%esp
	void *stack = malloc(4096);
 9d9:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 9e0:	e8 b4 fe ff ff       	call   899 <malloc>
 9e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int clone_pid = clone(child, arg_ptr, stack);
 9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9eb:	89 44 24 08          	mov    %eax,0x8(%esp)
 9ef:	8b 45 0c             	mov    0xc(%ebp),%eax
 9f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 9f6:	8b 45 08             	mov    0x8(%ebp),%eax
 9f9:	89 04 24             	mov    %eax,(%esp)
 9fc:	e8 bb fa ff ff       	call   4bc <clone>
 a01:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return clone_pid;
 a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 a07:	c9                   	leave  
 a08:	c3                   	ret    

00000a09 <thread_join>:

int thread_join(void)
{
 a09:	55                   	push   %ebp
 a0a:	89 e5                	mov    %esp,%ebp
 a0c:	83 ec 28             	sub    $0x28,%esp
    void *join_s;
    int join_pid = join(&join_s);
 a0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
 a12:	89 04 24             	mov    %eax,(%esp)
 a15:	e8 aa fa ff ff       	call   4c4 <join>
 a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return join_pid;
 a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a20:	c9                   	leave  
 a21:	c3                   	ret    
