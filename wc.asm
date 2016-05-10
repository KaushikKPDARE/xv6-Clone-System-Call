
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 48             	sub    $0x48,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
   d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
  19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  20:	eb 68                	jmp    8a <wc+0x8a>
    for(i=0; i<n; i++){
  22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  29:	eb 57                	jmp    82 <wc+0x82>
      c++;
  2b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
      if(buf[i] == '\n')
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	05 00 0e 00 00       	add    $0xe00,%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 0a                	cmp    $0xa,%al
  3c:	75 04                	jne    42 <wc+0x42>
        l++;
  3e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  45:	05 00 0e 00 00       	add    $0xe00,%eax
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	0f be c0             	movsbl %al,%eax
  50:	89 44 24 04          	mov    %eax,0x4(%esp)
  54:	c7 04 24 4a 0a 00 00 	movl   $0xa4a,(%esp)
  5b:	e8 5b 02 00 00       	call   2bb <strchr>
  60:	85 c0                	test   %eax,%eax
  62:	74 09                	je     6d <wc+0x6d>
        inword = 0;
  64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  6b:	eb 11                	jmp    7e <wc+0x7e>
      else if(!inword){
  6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  71:	75 0b                	jne    7e <wc+0x7e>
        w++;
  73:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
        inword = 1;
  77:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
  7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  88:	7c a1                	jl     2b <wc+0x2b>
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
  8a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  91:	00 
  92:	c7 44 24 04 00 0e 00 	movl   $0xe00,0x4(%esp)
  99:	00 
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 b7 03 00 00       	call   45c <read>
  a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  ac:	0f 8f 70 ff ff ff    	jg     22 <wc+0x22>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
  b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  b6:	79 19                	jns    d1 <wc+0xd1>
    printf(1, "wc: read error\n");
  b8:	c7 44 24 04 50 0a 00 	movl   $0xa50,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 08 05 00 00       	call   5d4 <printf>
    exit();
  cc:	e8 73 03 00 00       	call   444 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  d4:	89 44 24 14          	mov    %eax,0x14(%esp)
  d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  db:	89 44 24 10          	mov    %eax,0x10(%esp)
  df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ed:	c7 44 24 04 60 0a 00 	movl   $0xa60,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fc:	e8 d3 04 00 00       	call   5d4 <printf>
}
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <main>:

int
main(int argc, char *argv[])
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 e4 f0             	and    $0xfffffff0,%esp
 109:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
 10c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 110:	7f 19                	jg     12b <main+0x28>
    wc(0, "");
 112:	c7 44 24 04 6d 0a 00 	movl   $0xa6d,0x4(%esp)
 119:	00 
 11a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 121:	e8 da fe ff ff       	call   0 <wc>
    exit();
 126:	e8 19 03 00 00       	call   444 <exit>
  }

  for(i = 1; i < argc; i++){
 12b:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 132:	00 
 133:	e9 8f 00 00 00       	jmp    1c7 <main+0xc4>
    if((fd = open(argv[i], 0)) < 0){
 138:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 13c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 143:	8b 45 0c             	mov    0xc(%ebp),%eax
 146:	01 d0                	add    %edx,%eax
 148:	8b 00                	mov    (%eax),%eax
 14a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 151:	00 
 152:	89 04 24             	mov    %eax,(%esp)
 155:	e8 2a 03 00 00       	call   484 <open>
 15a:	89 44 24 18          	mov    %eax,0x18(%esp)
 15e:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 163:	79 2f                	jns    194 <main+0x91>
      printf(1, "wc: cannot open %s\n", argv[i]);
 165:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 169:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 170:	8b 45 0c             	mov    0xc(%ebp),%eax
 173:	01 d0                	add    %edx,%eax
 175:	8b 00                	mov    (%eax),%eax
 177:	89 44 24 08          	mov    %eax,0x8(%esp)
 17b:	c7 44 24 04 6e 0a 00 	movl   $0xa6e,0x4(%esp)
 182:	00 
 183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18a:	e8 45 04 00 00       	call   5d4 <printf>
      exit();
 18f:	e8 b0 02 00 00       	call   444 <exit>
    }
    wc(fd, argv[i]);
 194:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 198:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 19f:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a2:	01 d0                	add    %edx,%eax
 1a4:	8b 00                	mov    (%eax),%eax
 1a6:	89 44 24 04          	mov    %eax,0x4(%esp)
 1aa:	8b 44 24 18          	mov    0x18(%esp),%eax
 1ae:	89 04 24             	mov    %eax,(%esp)
 1b1:	e8 4a fe ff ff       	call   0 <wc>
    close(fd);
 1b6:	8b 44 24 18          	mov    0x18(%esp),%eax
 1ba:	89 04 24             	mov    %eax,(%esp)
 1bd:	e8 aa 02 00 00       	call   46c <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
 1c2:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1cb:	3b 45 08             	cmp    0x8(%ebp),%eax
 1ce:	0f 8c 64 ff ff ff    	jl     138 <main+0x35>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
 1d4:	e8 6b 02 00 00       	call   444 <exit>
 1d9:	66 90                	xchg   %ax,%ax
 1db:	90                   	nop

000001dc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1dc:	55                   	push   %ebp
 1dd:	89 e5                	mov    %esp,%ebp
 1df:	57                   	push   %edi
 1e0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1e4:	8b 55 10             	mov    0x10(%ebp),%edx
 1e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ea:	89 cb                	mov    %ecx,%ebx
 1ec:	89 df                	mov    %ebx,%edi
 1ee:	89 d1                	mov    %edx,%ecx
 1f0:	fc                   	cld    
 1f1:	f3 aa                	rep stos %al,%es:(%edi)
 1f3:	89 ca                	mov    %ecx,%edx
 1f5:	89 fb                	mov    %edi,%ebx
 1f7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1fa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1fd:	5b                   	pop    %ebx
 1fe:	5f                   	pop    %edi
 1ff:	5d                   	pop    %ebp
 200:	c3                   	ret    

00000201 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
 204:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 20d:	90                   	nop
 20e:	8b 45 08             	mov    0x8(%ebp),%eax
 211:	8d 50 01             	lea    0x1(%eax),%edx
 214:	89 55 08             	mov    %edx,0x8(%ebp)
 217:	8b 55 0c             	mov    0xc(%ebp),%edx
 21a:	8d 4a 01             	lea    0x1(%edx),%ecx
 21d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 220:	0f b6 12             	movzbl (%edx),%edx
 223:	88 10                	mov    %dl,(%eax)
 225:	0f b6 00             	movzbl (%eax),%eax
 228:	84 c0                	test   %al,%al
 22a:	75 e2                	jne    20e <strcpy+0xd>
    ;
  return os;
 22c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22f:	c9                   	leave  
 230:	c3                   	ret    

00000231 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 231:	55                   	push   %ebp
 232:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 234:	eb 08                	jmp    23e <strcmp+0xd>
    p++, q++;
 236:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	0f b6 00             	movzbl (%eax),%eax
 244:	84 c0                	test   %al,%al
 246:	74 10                	je     258 <strcmp+0x27>
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	0f b6 10             	movzbl (%eax),%edx
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	0f b6 00             	movzbl (%eax),%eax
 254:	38 c2                	cmp    %al,%dl
 256:	74 de                	je     236 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	0f b6 00             	movzbl (%eax),%eax
 25e:	0f b6 d0             	movzbl %al,%edx
 261:	8b 45 0c             	mov    0xc(%ebp),%eax
 264:	0f b6 00             	movzbl (%eax),%eax
 267:	0f b6 c0             	movzbl %al,%eax
 26a:	29 c2                	sub    %eax,%edx
 26c:	89 d0                	mov    %edx,%eax
}
 26e:	5d                   	pop    %ebp
 26f:	c3                   	ret    

00000270 <strlen>:

uint
strlen(char *s)
{
 270:	55                   	push   %ebp
 271:	89 e5                	mov    %esp,%ebp
 273:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 276:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 27d:	eb 04                	jmp    283 <strlen+0x13>
 27f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 283:	8b 55 fc             	mov    -0x4(%ebp),%edx
 286:	8b 45 08             	mov    0x8(%ebp),%eax
 289:	01 d0                	add    %edx,%eax
 28b:	0f b6 00             	movzbl (%eax),%eax
 28e:	84 c0                	test   %al,%al
 290:	75 ed                	jne    27f <strlen+0xf>
    ;
  return n;
 292:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 295:	c9                   	leave  
 296:	c3                   	ret    

00000297 <memset>:

void*
memset(void *dst, int c, uint n)
{
 297:	55                   	push   %ebp
 298:	89 e5                	mov    %esp,%ebp
 29a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 29d:	8b 45 10             	mov    0x10(%ebp),%eax
 2a0:	89 44 24 08          	mov    %eax,0x8(%esp)
 2a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	89 04 24             	mov    %eax,(%esp)
 2b1:	e8 26 ff ff ff       	call   1dc <stosb>
  return dst;
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b9:	c9                   	leave  
 2ba:	c3                   	ret    

000002bb <strchr>:

char*
strchr(const char *s, char c)
{
 2bb:	55                   	push   %ebp
 2bc:	89 e5                	mov    %esp,%ebp
 2be:	83 ec 04             	sub    $0x4,%esp
 2c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c4:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2c7:	eb 14                	jmp    2dd <strchr+0x22>
    if(*s == c)
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	0f b6 00             	movzbl (%eax),%eax
 2cf:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2d2:	75 05                	jne    2d9 <strchr+0x1e>
      return (char*)s;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	eb 13                	jmp    2ec <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
 2e0:	0f b6 00             	movzbl (%eax),%eax
 2e3:	84 c0                	test   %al,%al
 2e5:	75 e2                	jne    2c9 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2ec:	c9                   	leave  
 2ed:	c3                   	ret    

000002ee <gets>:

char*
gets(char *buf, int max)
{
 2ee:	55                   	push   %ebp
 2ef:	89 e5                	mov    %esp,%ebp
 2f1:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2fb:	eb 4c                	jmp    349 <gets+0x5b>
    cc = read(0, &c, 1);
 2fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 304:	00 
 305:	8d 45 ef             	lea    -0x11(%ebp),%eax
 308:	89 44 24 04          	mov    %eax,0x4(%esp)
 30c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 313:	e8 44 01 00 00       	call   45c <read>
 318:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 31b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 31f:	7f 02                	jg     323 <gets+0x35>
      break;
 321:	eb 31                	jmp    354 <gets+0x66>
    buf[i++] = c;
 323:	8b 45 f4             	mov    -0xc(%ebp),%eax
 326:	8d 50 01             	lea    0x1(%eax),%edx
 329:	89 55 f4             	mov    %edx,-0xc(%ebp)
 32c:	89 c2                	mov    %eax,%edx
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	01 c2                	add    %eax,%edx
 333:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 337:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 339:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 33d:	3c 0a                	cmp    $0xa,%al
 33f:	74 13                	je     354 <gets+0x66>
 341:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 345:	3c 0d                	cmp    $0xd,%al
 347:	74 0b                	je     354 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 349:	8b 45 f4             	mov    -0xc(%ebp),%eax
 34c:	83 c0 01             	add    $0x1,%eax
 34f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 352:	7c a9                	jl     2fd <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 354:	8b 55 f4             	mov    -0xc(%ebp),%edx
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	01 d0                	add    %edx,%eax
 35c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 362:	c9                   	leave  
 363:	c3                   	ret    

00000364 <stat>:

int
stat(char *n, struct stat *st)
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
 367:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 36a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 371:	00 
 372:	8b 45 08             	mov    0x8(%ebp),%eax
 375:	89 04 24             	mov    %eax,(%esp)
 378:	e8 07 01 00 00       	call   484 <open>
 37d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 380:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 384:	79 07                	jns    38d <stat+0x29>
    return -1;
 386:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 38b:	eb 23                	jmp    3b0 <stat+0x4c>
  r = fstat(fd, st);
 38d:	8b 45 0c             	mov    0xc(%ebp),%eax
 390:	89 44 24 04          	mov    %eax,0x4(%esp)
 394:	8b 45 f4             	mov    -0xc(%ebp),%eax
 397:	89 04 24             	mov    %eax,(%esp)
 39a:	e8 fd 00 00 00       	call   49c <fstat>
 39f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a5:	89 04 24             	mov    %eax,(%esp)
 3a8:	e8 bf 00 00 00       	call   46c <close>
  return r;
 3ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3b0:	c9                   	leave  
 3b1:	c3                   	ret    

000003b2 <atoi>:

int
atoi(const char *s)
{
 3b2:	55                   	push   %ebp
 3b3:	89 e5                	mov    %esp,%ebp
 3b5:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3bf:	eb 25                	jmp    3e6 <atoi+0x34>
    n = n*10 + *s++ - '0';
 3c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3c4:	89 d0                	mov    %edx,%eax
 3c6:	c1 e0 02             	shl    $0x2,%eax
 3c9:	01 d0                	add    %edx,%eax
 3cb:	01 c0                	add    %eax,%eax
 3cd:	89 c1                	mov    %eax,%ecx
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	8d 50 01             	lea    0x1(%eax),%edx
 3d5:	89 55 08             	mov    %edx,0x8(%ebp)
 3d8:	0f b6 00             	movzbl (%eax),%eax
 3db:	0f be c0             	movsbl %al,%eax
 3de:	01 c8                	add    %ecx,%eax
 3e0:	83 e8 30             	sub    $0x30,%eax
 3e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	0f b6 00             	movzbl (%eax),%eax
 3ec:	3c 2f                	cmp    $0x2f,%al
 3ee:	7e 0a                	jle    3fa <atoi+0x48>
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	0f b6 00             	movzbl (%eax),%eax
 3f6:	3c 39                	cmp    $0x39,%al
 3f8:	7e c7                	jle    3c1 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3fd:	c9                   	leave  
 3fe:	c3                   	ret    

000003ff <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3ff:	55                   	push   %ebp
 400:	89 e5                	mov    %esp,%ebp
 402:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 405:	8b 45 08             	mov    0x8(%ebp),%eax
 408:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 40b:	8b 45 0c             	mov    0xc(%ebp),%eax
 40e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 411:	eb 17                	jmp    42a <memmove+0x2b>
    *dst++ = *src++;
 413:	8b 45 fc             	mov    -0x4(%ebp),%eax
 416:	8d 50 01             	lea    0x1(%eax),%edx
 419:	89 55 fc             	mov    %edx,-0x4(%ebp)
 41c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 41f:	8d 4a 01             	lea    0x1(%edx),%ecx
 422:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 425:	0f b6 12             	movzbl (%edx),%edx
 428:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 42a:	8b 45 10             	mov    0x10(%ebp),%eax
 42d:	8d 50 ff             	lea    -0x1(%eax),%edx
 430:	89 55 10             	mov    %edx,0x10(%ebp)
 433:	85 c0                	test   %eax,%eax
 435:	7f dc                	jg     413 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 437:	8b 45 08             	mov    0x8(%ebp),%eax
}
 43a:	c9                   	leave  
 43b:	c3                   	ret    

0000043c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 43c:	b8 01 00 00 00       	mov    $0x1,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <exit>:
SYSCALL(exit)
 444:	b8 02 00 00 00       	mov    $0x2,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <wait>:
SYSCALL(wait)
 44c:	b8 03 00 00 00       	mov    $0x3,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <pipe>:
SYSCALL(pipe)
 454:	b8 04 00 00 00       	mov    $0x4,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <read>:
SYSCALL(read)
 45c:	b8 05 00 00 00       	mov    $0x5,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <write>:
SYSCALL(write)
 464:	b8 10 00 00 00       	mov    $0x10,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <close>:
SYSCALL(close)
 46c:	b8 15 00 00 00       	mov    $0x15,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <kill>:
SYSCALL(kill)
 474:	b8 06 00 00 00       	mov    $0x6,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <exec>:
SYSCALL(exec)
 47c:	b8 07 00 00 00       	mov    $0x7,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <open>:
SYSCALL(open)
 484:	b8 0f 00 00 00       	mov    $0xf,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <mknod>:
SYSCALL(mknod)
 48c:	b8 11 00 00 00       	mov    $0x11,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <unlink>:
SYSCALL(unlink)
 494:	b8 12 00 00 00       	mov    $0x12,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <fstat>:
SYSCALL(fstat)
 49c:	b8 08 00 00 00       	mov    $0x8,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <link>:
SYSCALL(link)
 4a4:	b8 13 00 00 00       	mov    $0x13,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <mkdir>:
SYSCALL(mkdir)
 4ac:	b8 14 00 00 00       	mov    $0x14,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <chdir>:
SYSCALL(chdir)
 4b4:	b8 09 00 00 00       	mov    $0x9,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <dup>:
SYSCALL(dup)
 4bc:	b8 0a 00 00 00       	mov    $0xa,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <getpid>:
SYSCALL(getpid)
 4c4:	b8 0b 00 00 00       	mov    $0xb,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <sbrk>:
SYSCALL(sbrk)
 4cc:	b8 0c 00 00 00       	mov    $0xc,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <sleep>:
SYSCALL(sleep)
 4d4:	b8 0d 00 00 00       	mov    $0xd,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <uptime>:
SYSCALL(uptime)
 4dc:	b8 0e 00 00 00       	mov    $0xe,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <clone>:
SYSCALL(clone)
 4e4:	b8 16 00 00 00       	mov    $0x16,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <join>:
 4ec:	b8 17 00 00 00       	mov    $0x17,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f4:	55                   	push   %ebp
 4f5:	89 e5                	mov    %esp,%ebp
 4f7:	83 ec 18             	sub    $0x18,%esp
 4fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 500:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 507:	00 
 508:	8d 45 f4             	lea    -0xc(%ebp),%eax
 50b:	89 44 24 04          	mov    %eax,0x4(%esp)
 50f:	8b 45 08             	mov    0x8(%ebp),%eax
 512:	89 04 24             	mov    %eax,(%esp)
 515:	e8 4a ff ff ff       	call   464 <write>
}
 51a:	c9                   	leave  
 51b:	c3                   	ret    

0000051c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 51c:	55                   	push   %ebp
 51d:	89 e5                	mov    %esp,%ebp
 51f:	56                   	push   %esi
 520:	53                   	push   %ebx
 521:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 524:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 52b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 52f:	74 17                	je     548 <printint+0x2c>
 531:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 535:	79 11                	jns    548 <printint+0x2c>
    neg = 1;
 537:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 53e:	8b 45 0c             	mov    0xc(%ebp),%eax
 541:	f7 d8                	neg    %eax
 543:	89 45 ec             	mov    %eax,-0x14(%ebp)
 546:	eb 06                	jmp    54e <printint+0x32>
  } else {
    x = xx;
 548:	8b 45 0c             	mov    0xc(%ebp),%eax
 54b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 54e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 555:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 558:	8d 41 01             	lea    0x1(%ecx),%eax
 55b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 55e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 561:	8b 45 ec             	mov    -0x14(%ebp),%eax
 564:	ba 00 00 00 00       	mov    $0x0,%edx
 569:	f7 f3                	div    %ebx
 56b:	89 d0                	mov    %edx,%eax
 56d:	0f b6 80 b0 0d 00 00 	movzbl 0xdb0(%eax),%eax
 574:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 578:	8b 75 10             	mov    0x10(%ebp),%esi
 57b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 57e:	ba 00 00 00 00       	mov    $0x0,%edx
 583:	f7 f6                	div    %esi
 585:	89 45 ec             	mov    %eax,-0x14(%ebp)
 588:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 58c:	75 c7                	jne    555 <printint+0x39>
  if(neg)
 58e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 592:	74 10                	je     5a4 <printint+0x88>
    buf[i++] = '-';
 594:	8b 45 f4             	mov    -0xc(%ebp),%eax
 597:	8d 50 01             	lea    0x1(%eax),%edx
 59a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 59d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5a2:	eb 1f                	jmp    5c3 <printint+0xa7>
 5a4:	eb 1d                	jmp    5c3 <printint+0xa7>
    putc(fd, buf[i]);
 5a6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ac:	01 d0                	add    %edx,%eax
 5ae:	0f b6 00             	movzbl (%eax),%eax
 5b1:	0f be c0             	movsbl %al,%eax
 5b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	89 04 24             	mov    %eax,(%esp)
 5be:	e8 31 ff ff ff       	call   4f4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5c3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5cb:	79 d9                	jns    5a6 <printint+0x8a>
    putc(fd, buf[i]);
}
 5cd:	83 c4 30             	add    $0x30,%esp
 5d0:	5b                   	pop    %ebx
 5d1:	5e                   	pop    %esi
 5d2:	5d                   	pop    %ebp
 5d3:	c3                   	ret    

000005d4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5d4:	55                   	push   %ebp
 5d5:	89 e5                	mov    %esp,%ebp
 5d7:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5da:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5e1:	8d 45 0c             	lea    0xc(%ebp),%eax
 5e4:	83 c0 04             	add    $0x4,%eax
 5e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5f1:	e9 7c 01 00 00       	jmp    772 <printf+0x19e>
    c = fmt[i] & 0xff;
 5f6:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5fc:	01 d0                	add    %edx,%eax
 5fe:	0f b6 00             	movzbl (%eax),%eax
 601:	0f be c0             	movsbl %al,%eax
 604:	25 ff 00 00 00       	and    $0xff,%eax
 609:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 60c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 610:	75 2c                	jne    63e <printf+0x6a>
      if(c == '%'){
 612:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 616:	75 0c                	jne    624 <printf+0x50>
        state = '%';
 618:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 61f:	e9 4a 01 00 00       	jmp    76e <printf+0x19a>
      } else {
        putc(fd, c);
 624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 627:	0f be c0             	movsbl %al,%eax
 62a:	89 44 24 04          	mov    %eax,0x4(%esp)
 62e:	8b 45 08             	mov    0x8(%ebp),%eax
 631:	89 04 24             	mov    %eax,(%esp)
 634:	e8 bb fe ff ff       	call   4f4 <putc>
 639:	e9 30 01 00 00       	jmp    76e <printf+0x19a>
      }
    } else if(state == '%'){
 63e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 642:	0f 85 26 01 00 00    	jne    76e <printf+0x19a>
      if(c == 'd'){
 648:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 64c:	75 2d                	jne    67b <printf+0xa7>
        printint(fd, *ap, 10, 1);
 64e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 651:	8b 00                	mov    (%eax),%eax
 653:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 65a:	00 
 65b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 662:	00 
 663:	89 44 24 04          	mov    %eax,0x4(%esp)
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	89 04 24             	mov    %eax,(%esp)
 66d:	e8 aa fe ff ff       	call   51c <printint>
        ap++;
 672:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 676:	e9 ec 00 00 00       	jmp    767 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 67b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 67f:	74 06                	je     687 <printf+0xb3>
 681:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 685:	75 2d                	jne    6b4 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 687:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68a:	8b 00                	mov    (%eax),%eax
 68c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 693:	00 
 694:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 69b:	00 
 69c:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a0:	8b 45 08             	mov    0x8(%ebp),%eax
 6a3:	89 04 24             	mov    %eax,(%esp)
 6a6:	e8 71 fe ff ff       	call   51c <printint>
        ap++;
 6ab:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6af:	e9 b3 00 00 00       	jmp    767 <printf+0x193>
      } else if(c == 's'){
 6b4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6b8:	75 45                	jne    6ff <printf+0x12b>
        s = (char*)*ap;
 6ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6bd:	8b 00                	mov    (%eax),%eax
 6bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6c2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6ca:	75 09                	jne    6d5 <printf+0x101>
          s = "(null)";
 6cc:	c7 45 f4 82 0a 00 00 	movl   $0xa82,-0xc(%ebp)
        while(*s != 0){
 6d3:	eb 1e                	jmp    6f3 <printf+0x11f>
 6d5:	eb 1c                	jmp    6f3 <printf+0x11f>
          putc(fd, *s);
 6d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6da:	0f b6 00             	movzbl (%eax),%eax
 6dd:	0f be c0             	movsbl %al,%eax
 6e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	89 04 24             	mov    %eax,(%esp)
 6ea:	e8 05 fe ff ff       	call   4f4 <putc>
          s++;
 6ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f6:	0f b6 00             	movzbl (%eax),%eax
 6f9:	84 c0                	test   %al,%al
 6fb:	75 da                	jne    6d7 <printf+0x103>
 6fd:	eb 68                	jmp    767 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ff:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 703:	75 1d                	jne    722 <printf+0x14e>
        putc(fd, *ap);
 705:	8b 45 e8             	mov    -0x18(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	0f be c0             	movsbl %al,%eax
 70d:	89 44 24 04          	mov    %eax,0x4(%esp)
 711:	8b 45 08             	mov    0x8(%ebp),%eax
 714:	89 04 24             	mov    %eax,(%esp)
 717:	e8 d8 fd ff ff       	call   4f4 <putc>
        ap++;
 71c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 720:	eb 45                	jmp    767 <printf+0x193>
      } else if(c == '%'){
 722:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 726:	75 17                	jne    73f <printf+0x16b>
        putc(fd, c);
 728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72b:	0f be c0             	movsbl %al,%eax
 72e:	89 44 24 04          	mov    %eax,0x4(%esp)
 732:	8b 45 08             	mov    0x8(%ebp),%eax
 735:	89 04 24             	mov    %eax,(%esp)
 738:	e8 b7 fd ff ff       	call   4f4 <putc>
 73d:	eb 28                	jmp    767 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 73f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 746:	00 
 747:	8b 45 08             	mov    0x8(%ebp),%eax
 74a:	89 04 24             	mov    %eax,(%esp)
 74d:	e8 a2 fd ff ff       	call   4f4 <putc>
        putc(fd, c);
 752:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 755:	0f be c0             	movsbl %al,%eax
 758:	89 44 24 04          	mov    %eax,0x4(%esp)
 75c:	8b 45 08             	mov    0x8(%ebp),%eax
 75f:	89 04 24             	mov    %eax,(%esp)
 762:	e8 8d fd ff ff       	call   4f4 <putc>
      }
      state = 0;
 767:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 76e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 772:	8b 55 0c             	mov    0xc(%ebp),%edx
 775:	8b 45 f0             	mov    -0x10(%ebp),%eax
 778:	01 d0                	add    %edx,%eax
 77a:	0f b6 00             	movzbl (%eax),%eax
 77d:	84 c0                	test   %al,%al
 77f:	0f 85 71 fe ff ff    	jne    5f6 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 785:	c9                   	leave  
 786:	c3                   	ret    
 787:	90                   	nop

00000788 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 788:	55                   	push   %ebp
 789:	89 e5                	mov    %esp,%ebp
 78b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78e:	8b 45 08             	mov    0x8(%ebp),%eax
 791:	83 e8 08             	sub    $0x8,%eax
 794:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 797:	a1 e8 0d 00 00       	mov    0xde8,%eax
 79c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79f:	eb 24                	jmp    7c5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a4:	8b 00                	mov    (%eax),%eax
 7a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a9:	77 12                	ja     7bd <free+0x35>
 7ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b1:	77 24                	ja     7d7 <free+0x4f>
 7b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b6:	8b 00                	mov    (%eax),%eax
 7b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bb:	77 1a                	ja     7d7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c0:	8b 00                	mov    (%eax),%eax
 7c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7cb:	76 d4                	jbe    7a1 <free+0x19>
 7cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d5:	76 ca                	jbe    7a1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7da:	8b 40 04             	mov    0x4(%eax),%eax
 7dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e7:	01 c2                	add    %eax,%edx
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	8b 00                	mov    (%eax),%eax
 7ee:	39 c2                	cmp    %eax,%edx
 7f0:	75 24                	jne    816 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f5:	8b 50 04             	mov    0x4(%eax),%edx
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	8b 00                	mov    (%eax),%eax
 7fd:	8b 40 04             	mov    0x4(%eax),%eax
 800:	01 c2                	add    %eax,%edx
 802:	8b 45 f8             	mov    -0x8(%ebp),%eax
 805:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80b:	8b 00                	mov    (%eax),%eax
 80d:	8b 10                	mov    (%eax),%edx
 80f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 812:	89 10                	mov    %edx,(%eax)
 814:	eb 0a                	jmp    820 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 816:	8b 45 fc             	mov    -0x4(%ebp),%eax
 819:	8b 10                	mov    (%eax),%edx
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	8b 40 04             	mov    0x4(%eax),%eax
 826:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 82d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 830:	01 d0                	add    %edx,%eax
 832:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 835:	75 20                	jne    857 <free+0xcf>
    p->s.size += bp->s.size;
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	8b 50 04             	mov    0x4(%eax),%edx
 83d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	01 c2                	add    %eax,%edx
 845:	8b 45 fc             	mov    -0x4(%ebp),%eax
 848:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 84b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84e:	8b 10                	mov    (%eax),%edx
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	89 10                	mov    %edx,(%eax)
 855:	eb 08                	jmp    85f <free+0xd7>
  } else
    p->s.ptr = bp;
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 85d:	89 10                	mov    %edx,(%eax)
  freep = p;
 85f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 862:	a3 e8 0d 00 00       	mov    %eax,0xde8
}
 867:	c9                   	leave  
 868:	c3                   	ret    

00000869 <morecore>:

static Header*
morecore(uint nu)
{
 869:	55                   	push   %ebp
 86a:	89 e5                	mov    %esp,%ebp
 86c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 86f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 876:	77 07                	ja     87f <morecore+0x16>
    nu = 4096;
 878:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 87f:	8b 45 08             	mov    0x8(%ebp),%eax
 882:	c1 e0 03             	shl    $0x3,%eax
 885:	89 04 24             	mov    %eax,(%esp)
 888:	e8 3f fc ff ff       	call   4cc <sbrk>
 88d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 890:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 894:	75 07                	jne    89d <morecore+0x34>
    return 0;
 896:	b8 00 00 00 00       	mov    $0x0,%eax
 89b:	eb 22                	jmp    8bf <morecore+0x56>
  hp = (Header*)p;
 89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a6:	8b 55 08             	mov    0x8(%ebp),%edx
 8a9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8af:	83 c0 08             	add    $0x8,%eax
 8b2:	89 04 24             	mov    %eax,(%esp)
 8b5:	e8 ce fe ff ff       	call   788 <free>
  return freep;
 8ba:	a1 e8 0d 00 00       	mov    0xde8,%eax
}
 8bf:	c9                   	leave  
 8c0:	c3                   	ret    

000008c1 <malloc>:

void*
malloc(uint nbytes)
{
 8c1:	55                   	push   %ebp
 8c2:	89 e5                	mov    %esp,%ebp
 8c4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ca:	83 c0 07             	add    $0x7,%eax
 8cd:	c1 e8 03             	shr    $0x3,%eax
 8d0:	83 c0 01             	add    $0x1,%eax
 8d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d6:	a1 e8 0d 00 00       	mov    0xde8,%eax
 8db:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8de:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e2:	75 23                	jne    907 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8e4:	c7 45 f0 e0 0d 00 00 	movl   $0xde0,-0x10(%ebp)
 8eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ee:	a3 e8 0d 00 00       	mov    %eax,0xde8
 8f3:	a1 e8 0d 00 00       	mov    0xde8,%eax
 8f8:	a3 e0 0d 00 00       	mov    %eax,0xde0
    base.s.size = 0;
 8fd:	c7 05 e4 0d 00 00 00 	movl   $0x0,0xde4
 904:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 907:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90a:	8b 00                	mov    (%eax),%eax
 90c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8b 40 04             	mov    0x4(%eax),%eax
 915:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 918:	72 4d                	jb     967 <malloc+0xa6>
      if(p->s.size == nunits)
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	8b 40 04             	mov    0x4(%eax),%eax
 920:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 923:	75 0c                	jne    931 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 925:	8b 45 f4             	mov    -0xc(%ebp),%eax
 928:	8b 10                	mov    (%eax),%edx
 92a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92d:	89 10                	mov    %edx,(%eax)
 92f:	eb 26                	jmp    957 <malloc+0x96>
      else {
        p->s.size -= nunits;
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	2b 45 ec             	sub    -0x14(%ebp),%eax
 93a:	89 c2                	mov    %eax,%edx
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 942:	8b 45 f4             	mov    -0xc(%ebp),%eax
 945:	8b 40 04             	mov    0x4(%eax),%eax
 948:	c1 e0 03             	shl    $0x3,%eax
 94b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 94e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 951:	8b 55 ec             	mov    -0x14(%ebp),%edx
 954:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 957:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95a:	a3 e8 0d 00 00       	mov    %eax,0xde8
      return (void*)(p + 1);
 95f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 962:	83 c0 08             	add    $0x8,%eax
 965:	eb 38                	jmp    99f <malloc+0xde>
    }
    if(p == freep)
 967:	a1 e8 0d 00 00       	mov    0xde8,%eax
 96c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 96f:	75 1b                	jne    98c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 971:	8b 45 ec             	mov    -0x14(%ebp),%eax
 974:	89 04 24             	mov    %eax,(%esp)
 977:	e8 ed fe ff ff       	call   869 <morecore>
 97c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 97f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 983:	75 07                	jne    98c <malloc+0xcb>
        return 0;
 985:	b8 00 00 00 00       	mov    $0x0,%eax
 98a:	eb 13                	jmp    99f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 992:	8b 45 f4             	mov    -0xc(%ebp),%eax
 995:	8b 00                	mov    (%eax),%eax
 997:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 99a:	e9 70 ff ff ff       	jmp    90f <malloc+0x4e>
}
 99f:	c9                   	leave  
 9a0:	c3                   	ret    
 9a1:	66 90                	xchg   %ax,%ax
 9a3:	90                   	nop

000009a4 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
 9a4:	55                   	push   %ebp
 9a5:	89 e5                	mov    %esp,%ebp
 9a7:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 9aa:	8b 55 08             	mov    0x8(%ebp),%edx
 9ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 9b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
 9b3:	f0 87 02             	lock xchg %eax,(%edx)
 9b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
 9b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 9bc:	c9                   	leave  
 9bd:	c3                   	ret    

000009be <mutex_init>:
#include "types.h"
#include "user.h"
#include "x86.h"
#include "threadlib.h"

void mutex_init(mutex_t *m) {
 9be:	55                   	push   %ebp
 9bf:	89 e5                	mov    %esp,%ebp
  // 0 indicates that lock is available, 1 that it is held by a thread
  m->flag = 0;
 9c1:	8b 45 08             	mov    0x8(%ebp),%eax
 9c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 9ca:	5d                   	pop    %ebp
 9cb:	c3                   	ret    

000009cc <mutex_lock>:

void mutex_lock(mutex_t *m)
{
 9cc:	55                   	push   %ebp
 9cd:	89 e5                	mov    %esp,%ebp
 9cf:	83 ec 08             	sub    $0x8,%esp
  while (xchg(&m->flag, 1) == 1); // spin-wait (do nothing)
 9d2:	90                   	nop
 9d3:	8b 45 08             	mov    0x8(%ebp),%eax
 9d6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 9dd:	00 
 9de:	89 04 24             	mov    %eax,(%esp)
 9e1:	e8 be ff ff ff       	call   9a4 <xchg>
 9e6:	83 f8 01             	cmp    $0x1,%eax
 9e9:	74 e8                	je     9d3 <mutex_lock+0x7>
}
 9eb:	c9                   	leave  
 9ec:	c3                   	ret    

000009ed <mutex_unlock>:

void mutex_unlock(mutex_t *m)
{
 9ed:	55                   	push   %ebp
 9ee:	89 e5                	mov    %esp,%ebp
  m->flag = 0;
 9f0:	8b 45 08             	mov    0x8(%ebp),%eax
 9f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
} 
 9f9:	5d                   	pop    %ebp
 9fa:	c3                   	ret    

000009fb <thread_create>:
  if(!pid) (*start_routine)(arg);
  else return pid;
}*/

int thread_create(void(*child)(void*), void *arg_ptr)
{
 9fb:	55                   	push   %ebp
 9fc:	89 e5                	mov    %esp,%ebp
 9fe:	83 ec 28             	sub    $0x28,%esp
	void *stack = malloc(4096);
 a01:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 a08:	e8 b4 fe ff ff       	call   8c1 <malloc>
 a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int clone_pid = clone(child, arg_ptr, stack);
 a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a13:	89 44 24 08          	mov    %eax,0x8(%esp)
 a17:	8b 45 0c             	mov    0xc(%ebp),%eax
 a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
 a1e:	8b 45 08             	mov    0x8(%ebp),%eax
 a21:	89 04 24             	mov    %eax,(%esp)
 a24:	e8 bb fa ff ff       	call   4e4 <clone>
 a29:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return clone_pid;
 a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 a2f:	c9                   	leave  
 a30:	c3                   	ret    

00000a31 <thread_join>:

int thread_join(void)
{
 a31:	55                   	push   %ebp
 a32:	89 e5                	mov    %esp,%ebp
 a34:	83 ec 28             	sub    $0x28,%esp
    void *join_s;
    int join_pid = join(&join_s);
 a37:	8d 45 f0             	lea    -0x10(%ebp),%eax
 a3a:	89 04 24             	mov    %eax,(%esp)
 a3d:	e8 aa fa ff ff       	call   4ec <join>
 a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return join_pid;
 a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a48:	c9                   	leave  
 a49:	c3                   	ret    
