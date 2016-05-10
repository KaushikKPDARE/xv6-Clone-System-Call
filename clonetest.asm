
_clonetest:     file format elf32-i386


Disassembly of section .text:

00000000 <child>:
int x = 0;
mutex_t lock;

void
child(void *arg_ptr) 
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
   int i;
   for(i=0;i<100000;i++)
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
   d:	eb 29                	jmp    38 <child+0x38>
 {
   mutex_lock(&lock);
   f:	c7 04 24 28 0d 00 00 	movl   $0xd28,(%esp)
  16:	e8 15 09 00 00       	call   930 <mutex_lock>
   x++;
  1b:	a1 18 0d 00 00       	mov    0xd18,%eax
  20:	83 c0 01             	add    $0x1,%eax
  23:	a3 18 0d 00 00       	mov    %eax,0xd18
   mutex_unlock(&lock);
  28:	c7 04 24 28 0d 00 00 	movl   $0xd28,(%esp)
  2f:	e8 1d 09 00 00       	call   951 <mutex_unlock>

void
child(void *arg_ptr) 
{
   int i;
   for(i=0;i<100000;i++)
  34:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  38:	81 7d f4 9f 86 01 00 	cmpl   $0x1869f,-0xc(%ebp)
  3f:	7e ce                	jle    f <child+0xf>
 {
   mutex_lock(&lock);
   x++;
   mutex_unlock(&lock);
 }
   exit();
  41:	e8 62 03 00 00       	call   3a8 <exit>

00000046 <main>:
}

int 
main(int argc, char *argv[])
{
  46:	55                   	push   %ebp
  47:	89 e5                	mov    %esp,%ebp
  49:	83 e4 f0             	and    $0xfffffff0,%esp
  4c:	83 ec 30             	sub    $0x30,%esp
   printf(1, "clone test\n");
  4f:	c7 44 24 04 ae 09 00 	movl   $0x9ae,0x4(%esp)
  56:	00 
  57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  5e:	e8 d5 04 00 00       	call   538 <printf>
   ppid = getpid();
  63:	e8 c0 03 00 00       	call   428 <getpid>
  68:	a3 2c 0d 00 00       	mov    %eax,0xd2c
   
   int arg1 = 10, arg2 =20;
  6d:	c7 44 24 14 0a 00 00 	movl   $0xa,0x14(%esp)
  74:	00 
  75:	c7 44 24 10 14 00 00 	movl   $0x14,0x10(%esp)
  7c:	00 
   //int thread_cnt = atoi(argv[1]);
   void *arg_ptr1  = &arg1;
  7d:	8d 44 24 14          	lea    0x14(%esp),%eax
  81:	89 44 24 2c          	mov    %eax,0x2c(%esp)
   void *arg_ptr2  = &arg2;
  85:	8d 44 24 10          	lea    0x10(%esp),%eax
  89:	89 44 24 28          	mov    %eax,0x28(%esp)
     int c_pid  = thread_create(child,arg_ptr1);
  8d:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  91:	89 44 24 04          	mov    %eax,0x4(%esp)
  95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  9c:	e8 be 08 00 00       	call   95f <thread_create>
  a1:	89 44 24 24          	mov    %eax,0x24(%esp)
     int c_pid1  = thread_create(child,arg_ptr2);
  a5:	8b 44 24 28          	mov    0x28(%esp),%eax
  a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  b4:	e8 a6 08 00 00       	call   95f <thread_create>
  b9:	89 44 24 20          	mov    %eax,0x20(%esp)
     int j_pid  = thread_join();
  bd:	e8 d3 08 00 00       	call   995 <thread_join>
  c2:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     int j_pid1  = thread_join();
  c6:	e8 ca 08 00 00       	call   995 <thread_join>
  cb:	89 44 24 18          	mov    %eax,0x18(%esp)
     if(j_pid == c_pid){} else{kill(ppid); exit();}
  cf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  d3:	3b 44 24 24          	cmp    0x24(%esp),%eax
  d7:	74 12                	je     eb <main+0xa5>
  d9:	a1 2c 0d 00 00       	mov    0xd2c,%eax
  de:	89 04 24             	mov    %eax,(%esp)
  e1:	e8 f2 02 00 00       	call   3d8 <kill>
  e6:	e8 bd 02 00 00       	call   3a8 <exit>
     if(j_pid1 == c_pid1){} else{kill(ppid); exit();}
  eb:	8b 44 24 18          	mov    0x18(%esp),%eax
  ef:	3b 44 24 20          	cmp    0x20(%esp),%eax
  f3:	74 12                	je     107 <main+0xc1>
  f5:	a1 2c 0d 00 00       	mov    0xd2c,%eax
  fa:	89 04 24             	mov    %eax,(%esp)
  fd:	e8 d6 02 00 00       	call   3d8 <kill>
 102:	e8 a1 02 00 00       	call   3a8 <exit>
   printf(1,"The counter: %d\n",x);
 107:	a1 18 0d 00 00       	mov    0xd18,%eax
 10c:	89 44 24 08          	mov    %eax,0x8(%esp)
 110:	c7 44 24 04 ba 09 00 	movl   $0x9ba,0x4(%esp)
 117:	00 
 118:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11f:	e8 14 04 00 00       	call   538 <printf>
   printf(1, "clone test OK\n");
 124:	c7 44 24 04 cb 09 00 	movl   $0x9cb,0x4(%esp)
 12b:	00 
 12c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 133:	e8 00 04 00 00       	call   538 <printf>
   exit();
 138:	e8 6b 02 00 00       	call   3a8 <exit>
 13d:	66 90                	xchg   %ax,%ax
 13f:	90                   	nop

00000140 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	57                   	push   %edi
 144:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 145:	8b 4d 08             	mov    0x8(%ebp),%ecx
 148:	8b 55 10             	mov    0x10(%ebp),%edx
 14b:	8b 45 0c             	mov    0xc(%ebp),%eax
 14e:	89 cb                	mov    %ecx,%ebx
 150:	89 df                	mov    %ebx,%edi
 152:	89 d1                	mov    %edx,%ecx
 154:	fc                   	cld    
 155:	f3 aa                	rep stos %al,%es:(%edi)
 157:	89 ca                	mov    %ecx,%edx
 159:	89 fb                	mov    %edi,%ebx
 15b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 15e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 161:	5b                   	pop    %ebx
 162:	5f                   	pop    %edi
 163:	5d                   	pop    %ebp
 164:	c3                   	ret    

00000165 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 165:	55                   	push   %ebp
 166:	89 e5                	mov    %esp,%ebp
 168:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 171:	90                   	nop
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	8d 50 01             	lea    0x1(%eax),%edx
 178:	89 55 08             	mov    %edx,0x8(%ebp)
 17b:	8b 55 0c             	mov    0xc(%ebp),%edx
 17e:	8d 4a 01             	lea    0x1(%edx),%ecx
 181:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 184:	0f b6 12             	movzbl (%edx),%edx
 187:	88 10                	mov    %dl,(%eax)
 189:	0f b6 00             	movzbl (%eax),%eax
 18c:	84 c0                	test   %al,%al
 18e:	75 e2                	jne    172 <strcpy+0xd>
    ;
  return os;
 190:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 193:	c9                   	leave  
 194:	c3                   	ret    

00000195 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 198:	eb 08                	jmp    1a2 <strcmp+0xd>
    p++, q++;
 19a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 19e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1a2:	8b 45 08             	mov    0x8(%ebp),%eax
 1a5:	0f b6 00             	movzbl (%eax),%eax
 1a8:	84 c0                	test   %al,%al
 1aa:	74 10                	je     1bc <strcmp+0x27>
 1ac:	8b 45 08             	mov    0x8(%ebp),%eax
 1af:	0f b6 10             	movzbl (%eax),%edx
 1b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b5:	0f b6 00             	movzbl (%eax),%eax
 1b8:	38 c2                	cmp    %al,%dl
 1ba:	74 de                	je     19a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	0f b6 00             	movzbl (%eax),%eax
 1c2:	0f b6 d0             	movzbl %al,%edx
 1c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c8:	0f b6 00             	movzbl (%eax),%eax
 1cb:	0f b6 c0             	movzbl %al,%eax
 1ce:	29 c2                	sub    %eax,%edx
 1d0:	89 d0                	mov    %edx,%eax
}
 1d2:	5d                   	pop    %ebp
 1d3:	c3                   	ret    

000001d4 <strlen>:

uint
strlen(char *s)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1e1:	eb 04                	jmp    1e7 <strlen+0x13>
 1e3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ea:	8b 45 08             	mov    0x8(%ebp),%eax
 1ed:	01 d0                	add    %edx,%eax
 1ef:	0f b6 00             	movzbl (%eax),%eax
 1f2:	84 c0                	test   %al,%al
 1f4:	75 ed                	jne    1e3 <strlen+0xf>
    ;
  return n;
 1f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1f9:	c9                   	leave  
 1fa:	c3                   	ret    

000001fb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1fb:	55                   	push   %ebp
 1fc:	89 e5                	mov    %esp,%ebp
 1fe:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 201:	8b 45 10             	mov    0x10(%ebp),%eax
 204:	89 44 24 08          	mov    %eax,0x8(%esp)
 208:	8b 45 0c             	mov    0xc(%ebp),%eax
 20b:	89 44 24 04          	mov    %eax,0x4(%esp)
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	89 04 24             	mov    %eax,(%esp)
 215:	e8 26 ff ff ff       	call   140 <stosb>
  return dst;
 21a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 21d:	c9                   	leave  
 21e:	c3                   	ret    

0000021f <strchr>:

char*
strchr(const char *s, char c)
{
 21f:	55                   	push   %ebp
 220:	89 e5                	mov    %esp,%ebp
 222:	83 ec 04             	sub    $0x4,%esp
 225:	8b 45 0c             	mov    0xc(%ebp),%eax
 228:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 22b:	eb 14                	jmp    241 <strchr+0x22>
    if(*s == c)
 22d:	8b 45 08             	mov    0x8(%ebp),%eax
 230:	0f b6 00             	movzbl (%eax),%eax
 233:	3a 45 fc             	cmp    -0x4(%ebp),%al
 236:	75 05                	jne    23d <strchr+0x1e>
      return (char*)s;
 238:	8b 45 08             	mov    0x8(%ebp),%eax
 23b:	eb 13                	jmp    250 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 23d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	0f b6 00             	movzbl (%eax),%eax
 247:	84 c0                	test   %al,%al
 249:	75 e2                	jne    22d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 24b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 250:	c9                   	leave  
 251:	c3                   	ret    

00000252 <gets>:

char*
gets(char *buf, int max)
{
 252:	55                   	push   %ebp
 253:	89 e5                	mov    %esp,%ebp
 255:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 258:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 25f:	eb 4c                	jmp    2ad <gets+0x5b>
    cc = read(0, &c, 1);
 261:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 268:	00 
 269:	8d 45 ef             	lea    -0x11(%ebp),%eax
 26c:	89 44 24 04          	mov    %eax,0x4(%esp)
 270:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 277:	e8 44 01 00 00       	call   3c0 <read>
 27c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 27f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 283:	7f 02                	jg     287 <gets+0x35>
      break;
 285:	eb 31                	jmp    2b8 <gets+0x66>
    buf[i++] = c;
 287:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28a:	8d 50 01             	lea    0x1(%eax),%edx
 28d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 290:	89 c2                	mov    %eax,%edx
 292:	8b 45 08             	mov    0x8(%ebp),%eax
 295:	01 c2                	add    %eax,%edx
 297:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 29d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a1:	3c 0a                	cmp    $0xa,%al
 2a3:	74 13                	je     2b8 <gets+0x66>
 2a5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a9:	3c 0d                	cmp    $0xd,%al
 2ab:	74 0b                	je     2b8 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b0:	83 c0 01             	add    $0x1,%eax
 2b3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2b6:	7c a9                	jl     261 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	01 d0                	add    %edx,%eax
 2c0:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2c3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c6:	c9                   	leave  
 2c7:	c3                   	ret    

000002c8 <stat>:

int
stat(char *n, struct stat *st)
{
 2c8:	55                   	push   %ebp
 2c9:	89 e5                	mov    %esp,%ebp
 2cb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2d5:	00 
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	89 04 24             	mov    %eax,(%esp)
 2dc:	e8 07 01 00 00       	call   3e8 <open>
 2e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e8:	79 07                	jns    2f1 <stat+0x29>
    return -1;
 2ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ef:	eb 23                	jmp    314 <stat+0x4c>
  r = fstat(fd, st);
 2f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2fb:	89 04 24             	mov    %eax,(%esp)
 2fe:	e8 fd 00 00 00       	call   400 <fstat>
 303:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 306:	8b 45 f4             	mov    -0xc(%ebp),%eax
 309:	89 04 24             	mov    %eax,(%esp)
 30c:	e8 bf 00 00 00       	call   3d0 <close>
  return r;
 311:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 314:	c9                   	leave  
 315:	c3                   	ret    

00000316 <atoi>:

int
atoi(const char *s)
{
 316:	55                   	push   %ebp
 317:	89 e5                	mov    %esp,%ebp
 319:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 31c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 323:	eb 25                	jmp    34a <atoi+0x34>
    n = n*10 + *s++ - '0';
 325:	8b 55 fc             	mov    -0x4(%ebp),%edx
 328:	89 d0                	mov    %edx,%eax
 32a:	c1 e0 02             	shl    $0x2,%eax
 32d:	01 d0                	add    %edx,%eax
 32f:	01 c0                	add    %eax,%eax
 331:	89 c1                	mov    %eax,%ecx
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	8d 50 01             	lea    0x1(%eax),%edx
 339:	89 55 08             	mov    %edx,0x8(%ebp)
 33c:	0f b6 00             	movzbl (%eax),%eax
 33f:	0f be c0             	movsbl %al,%eax
 342:	01 c8                	add    %ecx,%eax
 344:	83 e8 30             	sub    $0x30,%eax
 347:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34a:	8b 45 08             	mov    0x8(%ebp),%eax
 34d:	0f b6 00             	movzbl (%eax),%eax
 350:	3c 2f                	cmp    $0x2f,%al
 352:	7e 0a                	jle    35e <atoi+0x48>
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	0f b6 00             	movzbl (%eax),%eax
 35a:	3c 39                	cmp    $0x39,%al
 35c:	7e c7                	jle    325 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 35e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 361:	c9                   	leave  
 362:	c3                   	ret    

00000363 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 363:	55                   	push   %ebp
 364:	89 e5                	mov    %esp,%ebp
 366:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 36f:	8b 45 0c             	mov    0xc(%ebp),%eax
 372:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 375:	eb 17                	jmp    38e <memmove+0x2b>
    *dst++ = *src++;
 377:	8b 45 fc             	mov    -0x4(%ebp),%eax
 37a:	8d 50 01             	lea    0x1(%eax),%edx
 37d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 380:	8b 55 f8             	mov    -0x8(%ebp),%edx
 383:	8d 4a 01             	lea    0x1(%edx),%ecx
 386:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 389:	0f b6 12             	movzbl (%edx),%edx
 38c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 38e:	8b 45 10             	mov    0x10(%ebp),%eax
 391:	8d 50 ff             	lea    -0x1(%eax),%edx
 394:	89 55 10             	mov    %edx,0x10(%ebp)
 397:	85 c0                	test   %eax,%eax
 399:	7f dc                	jg     377 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 39b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 39e:	c9                   	leave  
 39f:	c3                   	ret    

000003a0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3a0:	b8 01 00 00 00       	mov    $0x1,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <exit>:
SYSCALL(exit)
 3a8:	b8 02 00 00 00       	mov    $0x2,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <wait>:
SYSCALL(wait)
 3b0:	b8 03 00 00 00       	mov    $0x3,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <pipe>:
SYSCALL(pipe)
 3b8:	b8 04 00 00 00       	mov    $0x4,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <read>:
SYSCALL(read)
 3c0:	b8 05 00 00 00       	mov    $0x5,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <write>:
SYSCALL(write)
 3c8:	b8 10 00 00 00       	mov    $0x10,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <close>:
SYSCALL(close)
 3d0:	b8 15 00 00 00       	mov    $0x15,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <kill>:
SYSCALL(kill)
 3d8:	b8 06 00 00 00       	mov    $0x6,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <exec>:
SYSCALL(exec)
 3e0:	b8 07 00 00 00       	mov    $0x7,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <open>:
SYSCALL(open)
 3e8:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <mknod>:
SYSCALL(mknod)
 3f0:	b8 11 00 00 00       	mov    $0x11,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <unlink>:
SYSCALL(unlink)
 3f8:	b8 12 00 00 00       	mov    $0x12,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <fstat>:
SYSCALL(fstat)
 400:	b8 08 00 00 00       	mov    $0x8,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <link>:
SYSCALL(link)
 408:	b8 13 00 00 00       	mov    $0x13,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <mkdir>:
SYSCALL(mkdir)
 410:	b8 14 00 00 00       	mov    $0x14,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <chdir>:
SYSCALL(chdir)
 418:	b8 09 00 00 00       	mov    $0x9,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <dup>:
SYSCALL(dup)
 420:	b8 0a 00 00 00       	mov    $0xa,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <getpid>:
SYSCALL(getpid)
 428:	b8 0b 00 00 00       	mov    $0xb,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <sbrk>:
SYSCALL(sbrk)
 430:	b8 0c 00 00 00       	mov    $0xc,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <sleep>:
SYSCALL(sleep)
 438:	b8 0d 00 00 00       	mov    $0xd,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <uptime>:
SYSCALL(uptime)
 440:	b8 0e 00 00 00       	mov    $0xe,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <clone>:
SYSCALL(clone)
 448:	b8 16 00 00 00       	mov    $0x16,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <join>:
 450:	b8 17 00 00 00       	mov    $0x17,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	83 ec 18             	sub    $0x18,%esp
 45e:	8b 45 0c             	mov    0xc(%ebp),%eax
 461:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 464:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 46b:	00 
 46c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 46f:	89 44 24 04          	mov    %eax,0x4(%esp)
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	89 04 24             	mov    %eax,(%esp)
 479:	e8 4a ff ff ff       	call   3c8 <write>
}
 47e:	c9                   	leave  
 47f:	c3                   	ret    

00000480 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 480:	55                   	push   %ebp
 481:	89 e5                	mov    %esp,%ebp
 483:	56                   	push   %esi
 484:	53                   	push   %ebx
 485:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 488:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 48f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 493:	74 17                	je     4ac <printint+0x2c>
 495:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 499:	79 11                	jns    4ac <printint+0x2c>
    neg = 1;
 49b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4a5:	f7 d8                	neg    %eax
 4a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4aa:	eb 06                	jmp    4b2 <printint+0x32>
  } else {
    x = xx;
 4ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 4af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4bc:	8d 41 01             	lea    0x1(%ecx),%eax
 4bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4c8:	ba 00 00 00 00       	mov    $0x0,%edx
 4cd:	f7 f3                	div    %ebx
 4cf:	89 d0                	mov    %edx,%eax
 4d1:	0f b6 80 04 0d 00 00 	movzbl 0xd04(%eax),%eax
 4d8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4dc:	8b 75 10             	mov    0x10(%ebp),%esi
 4df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4e2:	ba 00 00 00 00       	mov    $0x0,%edx
 4e7:	f7 f6                	div    %esi
 4e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4f0:	75 c7                	jne    4b9 <printint+0x39>
  if(neg)
 4f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4f6:	74 10                	je     508 <printint+0x88>
    buf[i++] = '-';
 4f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fb:	8d 50 01             	lea    0x1(%eax),%edx
 4fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
 501:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 506:	eb 1f                	jmp    527 <printint+0xa7>
 508:	eb 1d                	jmp    527 <printint+0xa7>
    putc(fd, buf[i]);
 50a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 50d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 510:	01 d0                	add    %edx,%eax
 512:	0f b6 00             	movzbl (%eax),%eax
 515:	0f be c0             	movsbl %al,%eax
 518:	89 44 24 04          	mov    %eax,0x4(%esp)
 51c:	8b 45 08             	mov    0x8(%ebp),%eax
 51f:	89 04 24             	mov    %eax,(%esp)
 522:	e8 31 ff ff ff       	call   458 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 527:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 52b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 52f:	79 d9                	jns    50a <printint+0x8a>
    putc(fd, buf[i]);
}
 531:	83 c4 30             	add    $0x30,%esp
 534:	5b                   	pop    %ebx
 535:	5e                   	pop    %esi
 536:	5d                   	pop    %ebp
 537:	c3                   	ret    

00000538 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 538:	55                   	push   %ebp
 539:	89 e5                	mov    %esp,%ebp
 53b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 53e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 545:	8d 45 0c             	lea    0xc(%ebp),%eax
 548:	83 c0 04             	add    $0x4,%eax
 54b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 54e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 555:	e9 7c 01 00 00       	jmp    6d6 <printf+0x19e>
    c = fmt[i] & 0xff;
 55a:	8b 55 0c             	mov    0xc(%ebp),%edx
 55d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 560:	01 d0                	add    %edx,%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	0f be c0             	movsbl %al,%eax
 568:	25 ff 00 00 00       	and    $0xff,%eax
 56d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 570:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 574:	75 2c                	jne    5a2 <printf+0x6a>
      if(c == '%'){
 576:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 57a:	75 0c                	jne    588 <printf+0x50>
        state = '%';
 57c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 583:	e9 4a 01 00 00       	jmp    6d2 <printf+0x19a>
      } else {
        putc(fd, c);
 588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 58b:	0f be c0             	movsbl %al,%eax
 58e:	89 44 24 04          	mov    %eax,0x4(%esp)
 592:	8b 45 08             	mov    0x8(%ebp),%eax
 595:	89 04 24             	mov    %eax,(%esp)
 598:	e8 bb fe ff ff       	call   458 <putc>
 59d:	e9 30 01 00 00       	jmp    6d2 <printf+0x19a>
      }
    } else if(state == '%'){
 5a2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5a6:	0f 85 26 01 00 00    	jne    6d2 <printf+0x19a>
      if(c == 'd'){
 5ac:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5b0:	75 2d                	jne    5df <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b5:	8b 00                	mov    (%eax),%eax
 5b7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5be:	00 
 5bf:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5c6:	00 
 5c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5cb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ce:	89 04 24             	mov    %eax,(%esp)
 5d1:	e8 aa fe ff ff       	call   480 <printint>
        ap++;
 5d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5da:	e9 ec 00 00 00       	jmp    6cb <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 5df:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5e3:	74 06                	je     5eb <printf+0xb3>
 5e5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5e9:	75 2d                	jne    618 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 5eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ee:	8b 00                	mov    (%eax),%eax
 5f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5f7:	00 
 5f8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5ff:	00 
 600:	89 44 24 04          	mov    %eax,0x4(%esp)
 604:	8b 45 08             	mov    0x8(%ebp),%eax
 607:	89 04 24             	mov    %eax,(%esp)
 60a:	e8 71 fe ff ff       	call   480 <printint>
        ap++;
 60f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 613:	e9 b3 00 00 00       	jmp    6cb <printf+0x193>
      } else if(c == 's'){
 618:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 61c:	75 45                	jne    663 <printf+0x12b>
        s = (char*)*ap;
 61e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 621:	8b 00                	mov    (%eax),%eax
 623:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 626:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 62a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62e:	75 09                	jne    639 <printf+0x101>
          s = "(null)";
 630:	c7 45 f4 da 09 00 00 	movl   $0x9da,-0xc(%ebp)
        while(*s != 0){
 637:	eb 1e                	jmp    657 <printf+0x11f>
 639:	eb 1c                	jmp    657 <printf+0x11f>
          putc(fd, *s);
 63b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63e:	0f b6 00             	movzbl (%eax),%eax
 641:	0f be c0             	movsbl %al,%eax
 644:	89 44 24 04          	mov    %eax,0x4(%esp)
 648:	8b 45 08             	mov    0x8(%ebp),%eax
 64b:	89 04 24             	mov    %eax,(%esp)
 64e:	e8 05 fe ff ff       	call   458 <putc>
          s++;
 653:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 657:	8b 45 f4             	mov    -0xc(%ebp),%eax
 65a:	0f b6 00             	movzbl (%eax),%eax
 65d:	84 c0                	test   %al,%al
 65f:	75 da                	jne    63b <printf+0x103>
 661:	eb 68                	jmp    6cb <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 663:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 667:	75 1d                	jne    686 <printf+0x14e>
        putc(fd, *ap);
 669:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	0f be c0             	movsbl %al,%eax
 671:	89 44 24 04          	mov    %eax,0x4(%esp)
 675:	8b 45 08             	mov    0x8(%ebp),%eax
 678:	89 04 24             	mov    %eax,(%esp)
 67b:	e8 d8 fd ff ff       	call   458 <putc>
        ap++;
 680:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 684:	eb 45                	jmp    6cb <printf+0x193>
      } else if(c == '%'){
 686:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 68a:	75 17                	jne    6a3 <printf+0x16b>
        putc(fd, c);
 68c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68f:	0f be c0             	movsbl %al,%eax
 692:	89 44 24 04          	mov    %eax,0x4(%esp)
 696:	8b 45 08             	mov    0x8(%ebp),%eax
 699:	89 04 24             	mov    %eax,(%esp)
 69c:	e8 b7 fd ff ff       	call   458 <putc>
 6a1:	eb 28                	jmp    6cb <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6aa:	00 
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	89 04 24             	mov    %eax,(%esp)
 6b1:	e8 a2 fd ff ff       	call   458 <putc>
        putc(fd, c);
 6b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b9:	0f be c0             	movsbl %al,%eax
 6bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c0:	8b 45 08             	mov    0x8(%ebp),%eax
 6c3:	89 04 24             	mov    %eax,(%esp)
 6c6:	e8 8d fd ff ff       	call   458 <putc>
      }
      state = 0;
 6cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6d2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 6d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6dc:	01 d0                	add    %edx,%eax
 6de:	0f b6 00             	movzbl (%eax),%eax
 6e1:	84 c0                	test   %al,%al
 6e3:	0f 85 71 fe ff ff    	jne    55a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6e9:	c9                   	leave  
 6ea:	c3                   	ret    
 6eb:	90                   	nop

000006ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ec:	55                   	push   %ebp
 6ed:	89 e5                	mov    %esp,%ebp
 6ef:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f2:	8b 45 08             	mov    0x8(%ebp),%eax
 6f5:	83 e8 08             	sub    $0x8,%eax
 6f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fb:	a1 24 0d 00 00       	mov    0xd24,%eax
 700:	89 45 fc             	mov    %eax,-0x4(%ebp)
 703:	eb 24                	jmp    729 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 70d:	77 12                	ja     721 <free+0x35>
 70f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 712:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 715:	77 24                	ja     73b <free+0x4f>
 717:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71a:	8b 00                	mov    (%eax),%eax
 71c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 71f:	77 1a                	ja     73b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 721:	8b 45 fc             	mov    -0x4(%ebp),%eax
 724:	8b 00                	mov    (%eax),%eax
 726:	89 45 fc             	mov    %eax,-0x4(%ebp)
 729:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 72f:	76 d4                	jbe    705 <free+0x19>
 731:	8b 45 fc             	mov    -0x4(%ebp),%eax
 734:	8b 00                	mov    (%eax),%eax
 736:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 739:	76 ca                	jbe    705 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	8b 40 04             	mov    0x4(%eax),%eax
 741:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 748:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74b:	01 c2                	add    %eax,%edx
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	8b 00                	mov    (%eax),%eax
 752:	39 c2                	cmp    %eax,%edx
 754:	75 24                	jne    77a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 756:	8b 45 f8             	mov    -0x8(%ebp),%eax
 759:	8b 50 04             	mov    0x4(%eax),%edx
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 00                	mov    (%eax),%eax
 761:	8b 40 04             	mov    0x4(%eax),%eax
 764:	01 c2                	add    %eax,%edx
 766:	8b 45 f8             	mov    -0x8(%ebp),%eax
 769:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	8b 00                	mov    (%eax),%eax
 771:	8b 10                	mov    (%eax),%edx
 773:	8b 45 f8             	mov    -0x8(%ebp),%eax
 776:	89 10                	mov    %edx,(%eax)
 778:	eb 0a                	jmp    784 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 77a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77d:	8b 10                	mov    (%eax),%edx
 77f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 782:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 784:	8b 45 fc             	mov    -0x4(%ebp),%eax
 787:	8b 40 04             	mov    0x4(%eax),%eax
 78a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 791:	8b 45 fc             	mov    -0x4(%ebp),%eax
 794:	01 d0                	add    %edx,%eax
 796:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 799:	75 20                	jne    7bb <free+0xcf>
    p->s.size += bp->s.size;
 79b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79e:	8b 50 04             	mov    0x4(%eax),%edx
 7a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a4:	8b 40 04             	mov    0x4(%eax),%eax
 7a7:	01 c2                	add    %eax,%edx
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b2:	8b 10                	mov    (%eax),%edx
 7b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b7:	89 10                	mov    %edx,(%eax)
 7b9:	eb 08                	jmp    7c3 <free+0xd7>
  } else
    p->s.ptr = bp;
 7bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7be:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7c1:	89 10                	mov    %edx,(%eax)
  freep = p;
 7c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c6:	a3 24 0d 00 00       	mov    %eax,0xd24
}
 7cb:	c9                   	leave  
 7cc:	c3                   	ret    

000007cd <morecore>:

static Header*
morecore(uint nu)
{
 7cd:	55                   	push   %ebp
 7ce:	89 e5                	mov    %esp,%ebp
 7d0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7d3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7da:	77 07                	ja     7e3 <morecore+0x16>
    nu = 4096;
 7dc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7e3:	8b 45 08             	mov    0x8(%ebp),%eax
 7e6:	c1 e0 03             	shl    $0x3,%eax
 7e9:	89 04 24             	mov    %eax,(%esp)
 7ec:	e8 3f fc ff ff       	call   430 <sbrk>
 7f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7f4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7f8:	75 07                	jne    801 <morecore+0x34>
    return 0;
 7fa:	b8 00 00 00 00       	mov    $0x0,%eax
 7ff:	eb 22                	jmp    823 <morecore+0x56>
  hp = (Header*)p;
 801:	8b 45 f4             	mov    -0xc(%ebp),%eax
 804:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 807:	8b 45 f0             	mov    -0x10(%ebp),%eax
 80a:	8b 55 08             	mov    0x8(%ebp),%edx
 80d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 810:	8b 45 f0             	mov    -0x10(%ebp),%eax
 813:	83 c0 08             	add    $0x8,%eax
 816:	89 04 24             	mov    %eax,(%esp)
 819:	e8 ce fe ff ff       	call   6ec <free>
  return freep;
 81e:	a1 24 0d 00 00       	mov    0xd24,%eax
}
 823:	c9                   	leave  
 824:	c3                   	ret    

00000825 <malloc>:

void*
malloc(uint nbytes)
{
 825:	55                   	push   %ebp
 826:	89 e5                	mov    %esp,%ebp
 828:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82b:	8b 45 08             	mov    0x8(%ebp),%eax
 82e:	83 c0 07             	add    $0x7,%eax
 831:	c1 e8 03             	shr    $0x3,%eax
 834:	83 c0 01             	add    $0x1,%eax
 837:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 83a:	a1 24 0d 00 00       	mov    0xd24,%eax
 83f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 842:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 846:	75 23                	jne    86b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 848:	c7 45 f0 1c 0d 00 00 	movl   $0xd1c,-0x10(%ebp)
 84f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 852:	a3 24 0d 00 00       	mov    %eax,0xd24
 857:	a1 24 0d 00 00       	mov    0xd24,%eax
 85c:	a3 1c 0d 00 00       	mov    %eax,0xd1c
    base.s.size = 0;
 861:	c7 05 20 0d 00 00 00 	movl   $0x0,0xd20
 868:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 86e:	8b 00                	mov    (%eax),%eax
 870:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	8b 40 04             	mov    0x4(%eax),%eax
 879:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 87c:	72 4d                	jb     8cb <malloc+0xa6>
      if(p->s.size == nunits)
 87e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 881:	8b 40 04             	mov    0x4(%eax),%eax
 884:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 887:	75 0c                	jne    895 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 889:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88c:	8b 10                	mov    (%eax),%edx
 88e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 891:	89 10                	mov    %edx,(%eax)
 893:	eb 26                	jmp    8bb <malloc+0x96>
      else {
        p->s.size -= nunits;
 895:	8b 45 f4             	mov    -0xc(%ebp),%eax
 898:	8b 40 04             	mov    0x4(%eax),%eax
 89b:	2b 45 ec             	sub    -0x14(%ebp),%eax
 89e:	89 c2                	mov    %eax,%edx
 8a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a9:	8b 40 04             	mov    0x4(%eax),%eax
 8ac:	c1 e0 03             	shl    $0x3,%eax
 8af:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8b8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8be:	a3 24 0d 00 00       	mov    %eax,0xd24
      return (void*)(p + 1);
 8c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c6:	83 c0 08             	add    $0x8,%eax
 8c9:	eb 38                	jmp    903 <malloc+0xde>
    }
    if(p == freep)
 8cb:	a1 24 0d 00 00       	mov    0xd24,%eax
 8d0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8d3:	75 1b                	jne    8f0 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8d8:	89 04 24             	mov    %eax,(%esp)
 8db:	e8 ed fe ff ff       	call   7cd <morecore>
 8e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8e7:	75 07                	jne    8f0 <malloc+0xcb>
        return 0;
 8e9:	b8 00 00 00 00       	mov    $0x0,%eax
 8ee:	eb 13                	jmp    903 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f9:	8b 00                	mov    (%eax),%eax
 8fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8fe:	e9 70 ff ff ff       	jmp    873 <malloc+0x4e>
}
 903:	c9                   	leave  
 904:	c3                   	ret    
 905:	66 90                	xchg   %ax,%ax
 907:	90                   	nop

00000908 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
 908:	55                   	push   %ebp
 909:	89 e5                	mov    %esp,%ebp
 90b:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 90e:	8b 55 08             	mov    0x8(%ebp),%edx
 911:	8b 45 0c             	mov    0xc(%ebp),%eax
 914:	8b 4d 08             	mov    0x8(%ebp),%ecx
 917:	f0 87 02             	lock xchg %eax,(%edx)
 91a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 920:	c9                   	leave  
 921:	c3                   	ret    

00000922 <mutex_init>:
#include "types.h"
#include "user.h"
#include "x86.h"
#include "threadlib.h"

void mutex_init(mutex_t *m) {
 922:	55                   	push   %ebp
 923:	89 e5                	mov    %esp,%ebp
  // 0 indicates that lock is available, 1 that it is held by a thread
  m->flag = 0;
 925:	8b 45 08             	mov    0x8(%ebp),%eax
 928:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 92e:	5d                   	pop    %ebp
 92f:	c3                   	ret    

00000930 <mutex_lock>:

void mutex_lock(mutex_t *m)
{
 930:	55                   	push   %ebp
 931:	89 e5                	mov    %esp,%ebp
 933:	83 ec 08             	sub    $0x8,%esp
  while (xchg(&m->flag, 1) == 1); // spin-wait (do nothing)
 936:	90                   	nop
 937:	8b 45 08             	mov    0x8(%ebp),%eax
 93a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 941:	00 
 942:	89 04 24             	mov    %eax,(%esp)
 945:	e8 be ff ff ff       	call   908 <xchg>
 94a:	83 f8 01             	cmp    $0x1,%eax
 94d:	74 e8                	je     937 <mutex_lock+0x7>
}
 94f:	c9                   	leave  
 950:	c3                   	ret    

00000951 <mutex_unlock>:

void mutex_unlock(mutex_t *m)
{
 951:	55                   	push   %ebp
 952:	89 e5                	mov    %esp,%ebp
  m->flag = 0;
 954:	8b 45 08             	mov    0x8(%ebp),%eax
 957:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
} 
 95d:	5d                   	pop    %ebp
 95e:	c3                   	ret    

0000095f <thread_create>:
  if(!pid) (*start_routine)(arg);
  else return pid;
}*/

int thread_create(void(*child)(void*), void *arg_ptr)
{
 95f:	55                   	push   %ebp
 960:	89 e5                	mov    %esp,%ebp
 962:	83 ec 28             	sub    $0x28,%esp
	void *stack = malloc(4096);
 965:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 96c:	e8 b4 fe ff ff       	call   825 <malloc>
 971:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int clone_pid = clone(child, arg_ptr, stack);
 974:	8b 45 f4             	mov    -0xc(%ebp),%eax
 977:	89 44 24 08          	mov    %eax,0x8(%esp)
 97b:	8b 45 0c             	mov    0xc(%ebp),%eax
 97e:	89 44 24 04          	mov    %eax,0x4(%esp)
 982:	8b 45 08             	mov    0x8(%ebp),%eax
 985:	89 04 24             	mov    %eax,(%esp)
 988:	e8 bb fa ff ff       	call   448 <clone>
 98d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return clone_pid;
 990:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 993:	c9                   	leave  
 994:	c3                   	ret    

00000995 <thread_join>:

int thread_join(void)
{
 995:	55                   	push   %ebp
 996:	89 e5                	mov    %esp,%ebp
 998:	83 ec 28             	sub    $0x28,%esp
    void *join_s;
    int join_pid = join(&join_s);
 99b:	8d 45 f0             	lea    -0x10(%ebp),%eax
 99e:	89 04 24             	mov    %eax,(%esp)
 9a1:	e8 aa fa ff ff       	call   450 <join>
 9a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return join_pid;
 9a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ac:	c9                   	leave  
 9ad:	c3                   	ret    
