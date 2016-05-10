
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 de 03 00 00       	call   3f0 <strlen>
  12:	8b 55 08             	mov    0x8(%ebp),%edx
  15:	01 d0                	add    %edx,%eax
  17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1a:	eb 04                	jmp    20 <fmtname+0x20>
  1c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  23:	3b 45 08             	cmp    0x8(%ebp),%eax
  26:	72 0a                	jb     32 <fmtname+0x32>
  28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2b:	0f b6 00             	movzbl (%eax),%eax
  2e:	3c 2f                	cmp    $0x2f,%al
  30:	75 ea                	jne    1c <fmtname+0x1c>
    ;
  p++;
  32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  39:	89 04 24             	mov    %eax,(%esp)
  3c:	e8 af 03 00 00       	call   3f0 <strlen>
  41:	83 f8 0d             	cmp    $0xd,%eax
  44:	76 05                	jbe    4b <fmtname+0x4b>
    return p;
  46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  49:	eb 5f                	jmp    aa <fmtname+0xaa>
  memmove(buf, p, strlen(p));
  4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4e:	89 04 24             	mov    %eax,(%esp)
  51:	e8 9a 03 00 00       	call   3f0 <strlen>
  56:	89 44 24 08          	mov    %eax,0x8(%esp)
  5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  61:	c7 04 24 88 0f 00 00 	movl   $0xf88,(%esp)
  68:	e8 12 05 00 00       	call   57f <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  70:	89 04 24             	mov    %eax,(%esp)
  73:	e8 78 03 00 00       	call   3f0 <strlen>
  78:	ba 0e 00 00 00       	mov    $0xe,%edx
  7d:	89 d3                	mov    %edx,%ebx
  7f:	29 c3                	sub    %eax,%ebx
  81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  84:	89 04 24             	mov    %eax,(%esp)
  87:	e8 64 03 00 00       	call   3f0 <strlen>
  8c:	05 88 0f 00 00       	add    $0xf88,%eax
  91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  95:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  9c:	00 
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 72 03 00 00       	call   417 <memset>
  return buf;
  a5:	b8 88 0f 00 00       	mov    $0xf88,%eax
}
  aa:	83 c4 24             	add    $0x24,%esp
  ad:	5b                   	pop    %ebx
  ae:	5d                   	pop    %ebp
  af:	c3                   	ret    

000000b0 <ls>:

void
ls(char *path)
{
  b0:	55                   	push   %ebp
  b1:	89 e5                	mov    %esp,%ebp
  b3:	57                   	push   %edi
  b4:	56                   	push   %esi
  b5:	53                   	push   %ebx
  b6:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c3:	00 
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	89 04 24             	mov    %eax,(%esp)
  ca:	e8 35 05 00 00       	call   604 <open>
  cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d6:	79 20                	jns    f8 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d8:	8b 45 08             	mov    0x8(%ebp),%eax
  db:	89 44 24 08          	mov    %eax,0x8(%esp)
  df:	c7 44 24 04 ca 0b 00 	movl   $0xbca,0x4(%esp)
  e6:	00 
  e7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ee:	e8 61 06 00 00       	call   754 <printf>
    return;
  f3:	e9 01 02 00 00       	jmp    2f9 <ls+0x249>
  }
  
  if(fstat(fd, &st) < 0){
  f8:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 105:	89 04 24             	mov    %eax,(%esp)
 108:	e8 0f 05 00 00       	call   61c <fstat>
 10d:	85 c0                	test   %eax,%eax
 10f:	79 2b                	jns    13c <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	89 44 24 08          	mov    %eax,0x8(%esp)
 118:	c7 44 24 04 de 0b 00 	movl   $0xbde,0x4(%esp)
 11f:	00 
 120:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 127:	e8 28 06 00 00       	call   754 <printf>
    close(fd);
 12c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 b5 04 00 00       	call   5ec <close>
    return;
 137:	e9 bd 01 00 00       	jmp    2f9 <ls+0x249>
  }
  
  switch(st.type){
 13c:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 143:	98                   	cwtl   
 144:	83 f8 01             	cmp    $0x1,%eax
 147:	74 53                	je     19c <ls+0xec>
 149:	83 f8 02             	cmp    $0x2,%eax
 14c:	0f 85 9c 01 00 00    	jne    2ee <ls+0x23e>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 152:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 158:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15e:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 165:	0f bf d8             	movswl %ax,%ebx
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	89 04 24             	mov    %eax,(%esp)
 16e:	e8 8d fe ff ff       	call   0 <fmtname>
 173:	89 7c 24 14          	mov    %edi,0x14(%esp)
 177:	89 74 24 10          	mov    %esi,0x10(%esp)
 17b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 17f:	89 44 24 08          	mov    %eax,0x8(%esp)
 183:	c7 44 24 04 f2 0b 00 	movl   $0xbf2,0x4(%esp)
 18a:	00 
 18b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 192:	e8 bd 05 00 00       	call   754 <printf>
    break;
 197:	e9 52 01 00 00       	jmp    2ee <ls+0x23e>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	89 04 24             	mov    %eax,(%esp)
 1a2:	e8 49 02 00 00       	call   3f0 <strlen>
 1a7:	83 c0 10             	add    $0x10,%eax
 1aa:	3d 00 02 00 00       	cmp    $0x200,%eax
 1af:	76 19                	jbe    1ca <ls+0x11a>
      printf(1, "ls: path too long\n");
 1b1:	c7 44 24 04 ff 0b 00 	movl   $0xbff,0x4(%esp)
 1b8:	00 
 1b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1c0:	e8 8f 05 00 00       	call   754 <printf>
      break;
 1c5:	e9 24 01 00 00       	jmp    2ee <ls+0x23e>
    }
    strcpy(buf, path);
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d1:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d7:	89 04 24             	mov    %eax,(%esp)
 1da:	e8 a2 01 00 00       	call   381 <strcpy>
    p = buf+strlen(buf);
 1df:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e5:	89 04 24             	mov    %eax,(%esp)
 1e8:	e8 03 02 00 00       	call   3f0 <strlen>
 1ed:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1f3:	01 d0                	add    %edx,%eax
 1f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1fb:	8d 50 01             	lea    0x1(%eax),%edx
 1fe:	89 55 e0             	mov    %edx,-0x20(%ebp)
 201:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 204:	e9 be 00 00 00       	jmp    2c7 <ls+0x217>
      if(de.inum == 0)
 209:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 210:	66 85 c0             	test   %ax,%ax
 213:	75 05                	jne    21a <ls+0x16a>
        continue;
 215:	e9 ad 00 00 00       	jmp    2c7 <ls+0x217>
      memmove(p, de.name, DIRSIZ);
 21a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 221:	00 
 222:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 228:	83 c0 02             	add    $0x2,%eax
 22b:	89 44 24 04          	mov    %eax,0x4(%esp)
 22f:	8b 45 e0             	mov    -0x20(%ebp),%eax
 232:	89 04 24             	mov    %eax,(%esp)
 235:	e8 45 03 00 00       	call   57f <memmove>
      p[DIRSIZ] = 0;
 23a:	8b 45 e0             	mov    -0x20(%ebp),%eax
 23d:	83 c0 0e             	add    $0xe,%eax
 240:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 243:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 249:	89 44 24 04          	mov    %eax,0x4(%esp)
 24d:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 253:	89 04 24             	mov    %eax,(%esp)
 256:	e8 89 02 00 00       	call   4e4 <stat>
 25b:	85 c0                	test   %eax,%eax
 25d:	79 20                	jns    27f <ls+0x1cf>
        printf(1, "ls: cannot stat %s\n", buf);
 25f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 265:	89 44 24 08          	mov    %eax,0x8(%esp)
 269:	c7 44 24 04 de 0b 00 	movl   $0xbde,0x4(%esp)
 270:	00 
 271:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 278:	e8 d7 04 00 00       	call   754 <printf>
        continue;
 27d:	eb 48                	jmp    2c7 <ls+0x217>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 27f:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 285:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 28b:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 292:	0f bf d8             	movswl %ax,%ebx
 295:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 29b:	89 04 24             	mov    %eax,(%esp)
 29e:	e8 5d fd ff ff       	call   0 <fmtname>
 2a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2a7:	89 74 24 10          	mov    %esi,0x10(%esp)
 2ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2af:	89 44 24 08          	mov    %eax,0x8(%esp)
 2b3:	c7 44 24 04 f2 0b 00 	movl   $0xbf2,0x4(%esp)
 2ba:	00 
 2bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2c2:	e8 8d 04 00 00       	call   754 <printf>
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2ce:	00 
 2cf:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2dc:	89 04 24             	mov    %eax,(%esp)
 2df:	e8 f8 02 00 00       	call   5dc <read>
 2e4:	83 f8 10             	cmp    $0x10,%eax
 2e7:	0f 84 1c ff ff ff    	je     209 <ls+0x159>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2ed:	90                   	nop
  }
  close(fd);
 2ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2f1:	89 04 24             	mov    %eax,(%esp)
 2f4:	e8 f3 02 00 00       	call   5ec <close>
}
 2f9:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 2ff:	5b                   	pop    %ebx
 300:	5e                   	pop    %esi
 301:	5f                   	pop    %edi
 302:	5d                   	pop    %ebp
 303:	c3                   	ret    

00000304 <main>:

int
main(int argc, char *argv[])
{
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
 307:	83 e4 f0             	and    $0xfffffff0,%esp
 30a:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 30d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 311:	7f 11                	jg     324 <main+0x20>
    ls(".");
 313:	c7 04 24 12 0c 00 00 	movl   $0xc12,(%esp)
 31a:	e8 91 fd ff ff       	call   b0 <ls>
    exit();
 31f:	e8 a0 02 00 00       	call   5c4 <exit>
  }
  for(i=1; i<argc; i++)
 324:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 32b:	00 
 32c:	eb 1f                	jmp    34d <main+0x49>
    ls(argv[i]);
 32e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 332:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 339:	8b 45 0c             	mov    0xc(%ebp),%eax
 33c:	01 d0                	add    %edx,%eax
 33e:	8b 00                	mov    (%eax),%eax
 340:	89 04 24             	mov    %eax,(%esp)
 343:	e8 68 fd ff ff       	call   b0 <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 348:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 34d:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 351:	3b 45 08             	cmp    0x8(%ebp),%eax
 354:	7c d8                	jl     32e <main+0x2a>
    ls(argv[i]);
  exit();
 356:	e8 69 02 00 00       	call   5c4 <exit>
 35b:	90                   	nop

0000035c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	57                   	push   %edi
 360:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 361:	8b 4d 08             	mov    0x8(%ebp),%ecx
 364:	8b 55 10             	mov    0x10(%ebp),%edx
 367:	8b 45 0c             	mov    0xc(%ebp),%eax
 36a:	89 cb                	mov    %ecx,%ebx
 36c:	89 df                	mov    %ebx,%edi
 36e:	89 d1                	mov    %edx,%ecx
 370:	fc                   	cld    
 371:	f3 aa                	rep stos %al,%es:(%edi)
 373:	89 ca                	mov    %ecx,%edx
 375:	89 fb                	mov    %edi,%ebx
 377:	89 5d 08             	mov    %ebx,0x8(%ebp)
 37a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 37d:	5b                   	pop    %ebx
 37e:	5f                   	pop    %edi
 37f:	5d                   	pop    %ebp
 380:	c3                   	ret    

00000381 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 381:	55                   	push   %ebp
 382:	89 e5                	mov    %esp,%ebp
 384:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 38d:	90                   	nop
 38e:	8b 45 08             	mov    0x8(%ebp),%eax
 391:	8d 50 01             	lea    0x1(%eax),%edx
 394:	89 55 08             	mov    %edx,0x8(%ebp)
 397:	8b 55 0c             	mov    0xc(%ebp),%edx
 39a:	8d 4a 01             	lea    0x1(%edx),%ecx
 39d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 3a0:	0f b6 12             	movzbl (%edx),%edx
 3a3:	88 10                	mov    %dl,(%eax)
 3a5:	0f b6 00             	movzbl (%eax),%eax
 3a8:	84 c0                	test   %al,%al
 3aa:	75 e2                	jne    38e <strcpy+0xd>
    ;
  return os;
 3ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3af:	c9                   	leave  
 3b0:	c3                   	ret    

000003b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3b4:	eb 08                	jmp    3be <strcmp+0xd>
    p++, q++;
 3b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3ba:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3be:	8b 45 08             	mov    0x8(%ebp),%eax
 3c1:	0f b6 00             	movzbl (%eax),%eax
 3c4:	84 c0                	test   %al,%al
 3c6:	74 10                	je     3d8 <strcmp+0x27>
 3c8:	8b 45 08             	mov    0x8(%ebp),%eax
 3cb:	0f b6 10             	movzbl (%eax),%edx
 3ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d1:	0f b6 00             	movzbl (%eax),%eax
 3d4:	38 c2                	cmp    %al,%dl
 3d6:	74 de                	je     3b6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	0f b6 00             	movzbl (%eax),%eax
 3de:	0f b6 d0             	movzbl %al,%edx
 3e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	0f b6 c0             	movzbl %al,%eax
 3ea:	29 c2                	sub    %eax,%edx
 3ec:	89 d0                	mov    %edx,%eax
}
 3ee:	5d                   	pop    %ebp
 3ef:	c3                   	ret    

000003f0 <strlen>:

uint
strlen(char *s)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3fd:	eb 04                	jmp    403 <strlen+0x13>
 3ff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 403:	8b 55 fc             	mov    -0x4(%ebp),%edx
 406:	8b 45 08             	mov    0x8(%ebp),%eax
 409:	01 d0                	add    %edx,%eax
 40b:	0f b6 00             	movzbl (%eax),%eax
 40e:	84 c0                	test   %al,%al
 410:	75 ed                	jne    3ff <strlen+0xf>
    ;
  return n;
 412:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 415:	c9                   	leave  
 416:	c3                   	ret    

00000417 <memset>:

void*
memset(void *dst, int c, uint n)
{
 417:	55                   	push   %ebp
 418:	89 e5                	mov    %esp,%ebp
 41a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 41d:	8b 45 10             	mov    0x10(%ebp),%eax
 420:	89 44 24 08          	mov    %eax,0x8(%esp)
 424:	8b 45 0c             	mov    0xc(%ebp),%eax
 427:	89 44 24 04          	mov    %eax,0x4(%esp)
 42b:	8b 45 08             	mov    0x8(%ebp),%eax
 42e:	89 04 24             	mov    %eax,(%esp)
 431:	e8 26 ff ff ff       	call   35c <stosb>
  return dst;
 436:	8b 45 08             	mov    0x8(%ebp),%eax
}
 439:	c9                   	leave  
 43a:	c3                   	ret    

0000043b <strchr>:

char*
strchr(const char *s, char c)
{
 43b:	55                   	push   %ebp
 43c:	89 e5                	mov    %esp,%ebp
 43e:	83 ec 04             	sub    $0x4,%esp
 441:	8b 45 0c             	mov    0xc(%ebp),%eax
 444:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 447:	eb 14                	jmp    45d <strchr+0x22>
    if(*s == c)
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 452:	75 05                	jne    459 <strchr+0x1e>
      return (char*)s;
 454:	8b 45 08             	mov    0x8(%ebp),%eax
 457:	eb 13                	jmp    46c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 459:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45d:	8b 45 08             	mov    0x8(%ebp),%eax
 460:	0f b6 00             	movzbl (%eax),%eax
 463:	84 c0                	test   %al,%al
 465:	75 e2                	jne    449 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 467:	b8 00 00 00 00       	mov    $0x0,%eax
}
 46c:	c9                   	leave  
 46d:	c3                   	ret    

0000046e <gets>:

char*
gets(char *buf, int max)
{
 46e:	55                   	push   %ebp
 46f:	89 e5                	mov    %esp,%ebp
 471:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 474:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 47b:	eb 4c                	jmp    4c9 <gets+0x5b>
    cc = read(0, &c, 1);
 47d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 484:	00 
 485:	8d 45 ef             	lea    -0x11(%ebp),%eax
 488:	89 44 24 04          	mov    %eax,0x4(%esp)
 48c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 493:	e8 44 01 00 00       	call   5dc <read>
 498:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 49b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 49f:	7f 02                	jg     4a3 <gets+0x35>
      break;
 4a1:	eb 31                	jmp    4d4 <gets+0x66>
    buf[i++] = c;
 4a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a6:	8d 50 01             	lea    0x1(%eax),%edx
 4a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4ac:	89 c2                	mov    %eax,%edx
 4ae:	8b 45 08             	mov    0x8(%ebp),%eax
 4b1:	01 c2                	add    %eax,%edx
 4b3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b7:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4b9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4bd:	3c 0a                	cmp    $0xa,%al
 4bf:	74 13                	je     4d4 <gets+0x66>
 4c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c5:	3c 0d                	cmp    $0xd,%al
 4c7:	74 0b                	je     4d4 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4cc:	83 c0 01             	add    $0x1,%eax
 4cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4d2:	7c a9                	jl     47d <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
 4da:	01 d0                	add    %edx,%eax
 4dc:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4df:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4e2:	c9                   	leave  
 4e3:	c3                   	ret    

000004e4 <stat>:

int
stat(char *n, struct stat *st)
{
 4e4:	55                   	push   %ebp
 4e5:	89 e5                	mov    %esp,%ebp
 4e7:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4f1:	00 
 4f2:	8b 45 08             	mov    0x8(%ebp),%eax
 4f5:	89 04 24             	mov    %eax,(%esp)
 4f8:	e8 07 01 00 00       	call   604 <open>
 4fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 504:	79 07                	jns    50d <stat+0x29>
    return -1;
 506:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 50b:	eb 23                	jmp    530 <stat+0x4c>
  r = fstat(fd, st);
 50d:	8b 45 0c             	mov    0xc(%ebp),%eax
 510:	89 44 24 04          	mov    %eax,0x4(%esp)
 514:	8b 45 f4             	mov    -0xc(%ebp),%eax
 517:	89 04 24             	mov    %eax,(%esp)
 51a:	e8 fd 00 00 00       	call   61c <fstat>
 51f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 522:	8b 45 f4             	mov    -0xc(%ebp),%eax
 525:	89 04 24             	mov    %eax,(%esp)
 528:	e8 bf 00 00 00       	call   5ec <close>
  return r;
 52d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 530:	c9                   	leave  
 531:	c3                   	ret    

00000532 <atoi>:

int
atoi(const char *s)
{
 532:	55                   	push   %ebp
 533:	89 e5                	mov    %esp,%ebp
 535:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 538:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 53f:	eb 25                	jmp    566 <atoi+0x34>
    n = n*10 + *s++ - '0';
 541:	8b 55 fc             	mov    -0x4(%ebp),%edx
 544:	89 d0                	mov    %edx,%eax
 546:	c1 e0 02             	shl    $0x2,%eax
 549:	01 d0                	add    %edx,%eax
 54b:	01 c0                	add    %eax,%eax
 54d:	89 c1                	mov    %eax,%ecx
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	8d 50 01             	lea    0x1(%eax),%edx
 555:	89 55 08             	mov    %edx,0x8(%ebp)
 558:	0f b6 00             	movzbl (%eax),%eax
 55b:	0f be c0             	movsbl %al,%eax
 55e:	01 c8                	add    %ecx,%eax
 560:	83 e8 30             	sub    $0x30,%eax
 563:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 566:	8b 45 08             	mov    0x8(%ebp),%eax
 569:	0f b6 00             	movzbl (%eax),%eax
 56c:	3c 2f                	cmp    $0x2f,%al
 56e:	7e 0a                	jle    57a <atoi+0x48>
 570:	8b 45 08             	mov    0x8(%ebp),%eax
 573:	0f b6 00             	movzbl (%eax),%eax
 576:	3c 39                	cmp    $0x39,%al
 578:	7e c7                	jle    541 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 57a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 57d:	c9                   	leave  
 57e:	c3                   	ret    

0000057f <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 57f:	55                   	push   %ebp
 580:	89 e5                	mov    %esp,%ebp
 582:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 58b:	8b 45 0c             	mov    0xc(%ebp),%eax
 58e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 591:	eb 17                	jmp    5aa <memmove+0x2b>
    *dst++ = *src++;
 593:	8b 45 fc             	mov    -0x4(%ebp),%eax
 596:	8d 50 01             	lea    0x1(%eax),%edx
 599:	89 55 fc             	mov    %edx,-0x4(%ebp)
 59c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 59f:	8d 4a 01             	lea    0x1(%edx),%ecx
 5a2:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 5a5:	0f b6 12             	movzbl (%edx),%edx
 5a8:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5aa:	8b 45 10             	mov    0x10(%ebp),%eax
 5ad:	8d 50 ff             	lea    -0x1(%eax),%edx
 5b0:	89 55 10             	mov    %edx,0x10(%ebp)
 5b3:	85 c0                	test   %eax,%eax
 5b5:	7f dc                	jg     593 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5ba:	c9                   	leave  
 5bb:	c3                   	ret    

000005bc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5bc:	b8 01 00 00 00       	mov    $0x1,%eax
 5c1:	cd 40                	int    $0x40
 5c3:	c3                   	ret    

000005c4 <exit>:
SYSCALL(exit)
 5c4:	b8 02 00 00 00       	mov    $0x2,%eax
 5c9:	cd 40                	int    $0x40
 5cb:	c3                   	ret    

000005cc <wait>:
SYSCALL(wait)
 5cc:	b8 03 00 00 00       	mov    $0x3,%eax
 5d1:	cd 40                	int    $0x40
 5d3:	c3                   	ret    

000005d4 <pipe>:
SYSCALL(pipe)
 5d4:	b8 04 00 00 00       	mov    $0x4,%eax
 5d9:	cd 40                	int    $0x40
 5db:	c3                   	ret    

000005dc <read>:
SYSCALL(read)
 5dc:	b8 05 00 00 00       	mov    $0x5,%eax
 5e1:	cd 40                	int    $0x40
 5e3:	c3                   	ret    

000005e4 <write>:
SYSCALL(write)
 5e4:	b8 10 00 00 00       	mov    $0x10,%eax
 5e9:	cd 40                	int    $0x40
 5eb:	c3                   	ret    

000005ec <close>:
SYSCALL(close)
 5ec:	b8 15 00 00 00       	mov    $0x15,%eax
 5f1:	cd 40                	int    $0x40
 5f3:	c3                   	ret    

000005f4 <kill>:
SYSCALL(kill)
 5f4:	b8 06 00 00 00       	mov    $0x6,%eax
 5f9:	cd 40                	int    $0x40
 5fb:	c3                   	ret    

000005fc <exec>:
SYSCALL(exec)
 5fc:	b8 07 00 00 00       	mov    $0x7,%eax
 601:	cd 40                	int    $0x40
 603:	c3                   	ret    

00000604 <open>:
SYSCALL(open)
 604:	b8 0f 00 00 00       	mov    $0xf,%eax
 609:	cd 40                	int    $0x40
 60b:	c3                   	ret    

0000060c <mknod>:
SYSCALL(mknod)
 60c:	b8 11 00 00 00       	mov    $0x11,%eax
 611:	cd 40                	int    $0x40
 613:	c3                   	ret    

00000614 <unlink>:
SYSCALL(unlink)
 614:	b8 12 00 00 00       	mov    $0x12,%eax
 619:	cd 40                	int    $0x40
 61b:	c3                   	ret    

0000061c <fstat>:
SYSCALL(fstat)
 61c:	b8 08 00 00 00       	mov    $0x8,%eax
 621:	cd 40                	int    $0x40
 623:	c3                   	ret    

00000624 <link>:
SYSCALL(link)
 624:	b8 13 00 00 00       	mov    $0x13,%eax
 629:	cd 40                	int    $0x40
 62b:	c3                   	ret    

0000062c <mkdir>:
SYSCALL(mkdir)
 62c:	b8 14 00 00 00       	mov    $0x14,%eax
 631:	cd 40                	int    $0x40
 633:	c3                   	ret    

00000634 <chdir>:
SYSCALL(chdir)
 634:	b8 09 00 00 00       	mov    $0x9,%eax
 639:	cd 40                	int    $0x40
 63b:	c3                   	ret    

0000063c <dup>:
SYSCALL(dup)
 63c:	b8 0a 00 00 00       	mov    $0xa,%eax
 641:	cd 40                	int    $0x40
 643:	c3                   	ret    

00000644 <getpid>:
SYSCALL(getpid)
 644:	b8 0b 00 00 00       	mov    $0xb,%eax
 649:	cd 40                	int    $0x40
 64b:	c3                   	ret    

0000064c <sbrk>:
SYSCALL(sbrk)
 64c:	b8 0c 00 00 00       	mov    $0xc,%eax
 651:	cd 40                	int    $0x40
 653:	c3                   	ret    

00000654 <sleep>:
SYSCALL(sleep)
 654:	b8 0d 00 00 00       	mov    $0xd,%eax
 659:	cd 40                	int    $0x40
 65b:	c3                   	ret    

0000065c <uptime>:
SYSCALL(uptime)
 65c:	b8 0e 00 00 00       	mov    $0xe,%eax
 661:	cd 40                	int    $0x40
 663:	c3                   	ret    

00000664 <clone>:
SYSCALL(clone)
 664:	b8 16 00 00 00       	mov    $0x16,%eax
 669:	cd 40                	int    $0x40
 66b:	c3                   	ret    

0000066c <join>:
 66c:	b8 17 00 00 00       	mov    $0x17,%eax
 671:	cd 40                	int    $0x40
 673:	c3                   	ret    

00000674 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 674:	55                   	push   %ebp
 675:	89 e5                	mov    %esp,%ebp
 677:	83 ec 18             	sub    $0x18,%esp
 67a:	8b 45 0c             	mov    0xc(%ebp),%eax
 67d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 680:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 687:	00 
 688:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68b:	89 44 24 04          	mov    %eax,0x4(%esp)
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	89 04 24             	mov    %eax,(%esp)
 695:	e8 4a ff ff ff       	call   5e4 <write>
}
 69a:	c9                   	leave  
 69b:	c3                   	ret    

0000069c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69c:	55                   	push   %ebp
 69d:	89 e5                	mov    %esp,%ebp
 69f:	56                   	push   %esi
 6a0:	53                   	push   %ebx
 6a1:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6ab:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6af:	74 17                	je     6c8 <printint+0x2c>
 6b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b5:	79 11                	jns    6c8 <printint+0x2c>
    neg = 1;
 6b7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6be:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c1:	f7 d8                	neg    %eax
 6c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c6:	eb 06                	jmp    6ce <printint+0x32>
  } else {
    x = xx;
 6c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6d8:	8d 41 01             	lea    0x1(%ecx),%eax
 6db:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6de:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e4:	ba 00 00 00 00       	mov    $0x0,%edx
 6e9:	f7 f3                	div    %ebx
 6eb:	89 d0                	mov    %edx,%eax
 6ed:	0f b6 80 74 0f 00 00 	movzbl 0xf74(%eax),%eax
 6f4:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6f8:	8b 75 10             	mov    0x10(%ebp),%esi
 6fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6fe:	ba 00 00 00 00       	mov    $0x0,%edx
 703:	f7 f6                	div    %esi
 705:	89 45 ec             	mov    %eax,-0x14(%ebp)
 708:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70c:	75 c7                	jne    6d5 <printint+0x39>
  if(neg)
 70e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 712:	74 10                	je     724 <printint+0x88>
    buf[i++] = '-';
 714:	8b 45 f4             	mov    -0xc(%ebp),%eax
 717:	8d 50 01             	lea    0x1(%eax),%edx
 71a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 722:	eb 1f                	jmp    743 <printint+0xa7>
 724:	eb 1d                	jmp    743 <printint+0xa7>
    putc(fd, buf[i]);
 726:	8d 55 dc             	lea    -0x24(%ebp),%edx
 729:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72c:	01 d0                	add    %edx,%eax
 72e:	0f b6 00             	movzbl (%eax),%eax
 731:	0f be c0             	movsbl %al,%eax
 734:	89 44 24 04          	mov    %eax,0x4(%esp)
 738:	8b 45 08             	mov    0x8(%ebp),%eax
 73b:	89 04 24             	mov    %eax,(%esp)
 73e:	e8 31 ff ff ff       	call   674 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 743:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 747:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74b:	79 d9                	jns    726 <printint+0x8a>
    putc(fd, buf[i]);
}
 74d:	83 c4 30             	add    $0x30,%esp
 750:	5b                   	pop    %ebx
 751:	5e                   	pop    %esi
 752:	5d                   	pop    %ebp
 753:	c3                   	ret    

00000754 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 754:	55                   	push   %ebp
 755:	89 e5                	mov    %esp,%ebp
 757:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 75a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 761:	8d 45 0c             	lea    0xc(%ebp),%eax
 764:	83 c0 04             	add    $0x4,%eax
 767:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 76a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 771:	e9 7c 01 00 00       	jmp    8f2 <printf+0x19e>
    c = fmt[i] & 0xff;
 776:	8b 55 0c             	mov    0xc(%ebp),%edx
 779:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77c:	01 d0                	add    %edx,%eax
 77e:	0f b6 00             	movzbl (%eax),%eax
 781:	0f be c0             	movsbl %al,%eax
 784:	25 ff 00 00 00       	and    $0xff,%eax
 789:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 78c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 790:	75 2c                	jne    7be <printf+0x6a>
      if(c == '%'){
 792:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 796:	75 0c                	jne    7a4 <printf+0x50>
        state = '%';
 798:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 79f:	e9 4a 01 00 00       	jmp    8ee <printf+0x19a>
      } else {
        putc(fd, c);
 7a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a7:	0f be c0             	movsbl %al,%eax
 7aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ae:	8b 45 08             	mov    0x8(%ebp),%eax
 7b1:	89 04 24             	mov    %eax,(%esp)
 7b4:	e8 bb fe ff ff       	call   674 <putc>
 7b9:	e9 30 01 00 00       	jmp    8ee <printf+0x19a>
      }
    } else if(state == '%'){
 7be:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7c2:	0f 85 26 01 00 00    	jne    8ee <printf+0x19a>
      if(c == 'd'){
 7c8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7cc:	75 2d                	jne    7fb <printf+0xa7>
        printint(fd, *ap, 10, 1);
 7ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7da:	00 
 7db:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7e2:	00 
 7e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ea:	89 04 24             	mov    %eax,(%esp)
 7ed:	e8 aa fe ff ff       	call   69c <printint>
        ap++;
 7f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f6:	e9 ec 00 00 00       	jmp    8e7 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 7fb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ff:	74 06                	je     807 <printf+0xb3>
 801:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 805:	75 2d                	jne    834 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 807:	8b 45 e8             	mov    -0x18(%ebp),%eax
 80a:	8b 00                	mov    (%eax),%eax
 80c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 813:	00 
 814:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 81b:	00 
 81c:	89 44 24 04          	mov    %eax,0x4(%esp)
 820:	8b 45 08             	mov    0x8(%ebp),%eax
 823:	89 04 24             	mov    %eax,(%esp)
 826:	e8 71 fe ff ff       	call   69c <printint>
        ap++;
 82b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82f:	e9 b3 00 00 00       	jmp    8e7 <printf+0x193>
      } else if(c == 's'){
 834:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 838:	75 45                	jne    87f <printf+0x12b>
        s = (char*)*ap;
 83a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83d:	8b 00                	mov    (%eax),%eax
 83f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 842:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 846:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 84a:	75 09                	jne    855 <printf+0x101>
          s = "(null)";
 84c:	c7 45 f4 14 0c 00 00 	movl   $0xc14,-0xc(%ebp)
        while(*s != 0){
 853:	eb 1e                	jmp    873 <printf+0x11f>
 855:	eb 1c                	jmp    873 <printf+0x11f>
          putc(fd, *s);
 857:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85a:	0f b6 00             	movzbl (%eax),%eax
 85d:	0f be c0             	movsbl %al,%eax
 860:	89 44 24 04          	mov    %eax,0x4(%esp)
 864:	8b 45 08             	mov    0x8(%ebp),%eax
 867:	89 04 24             	mov    %eax,(%esp)
 86a:	e8 05 fe ff ff       	call   674 <putc>
          s++;
 86f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 873:	8b 45 f4             	mov    -0xc(%ebp),%eax
 876:	0f b6 00             	movzbl (%eax),%eax
 879:	84 c0                	test   %al,%al
 87b:	75 da                	jne    857 <printf+0x103>
 87d:	eb 68                	jmp    8e7 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 87f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 883:	75 1d                	jne    8a2 <printf+0x14e>
        putc(fd, *ap);
 885:	8b 45 e8             	mov    -0x18(%ebp),%eax
 888:	8b 00                	mov    (%eax),%eax
 88a:	0f be c0             	movsbl %al,%eax
 88d:	89 44 24 04          	mov    %eax,0x4(%esp)
 891:	8b 45 08             	mov    0x8(%ebp),%eax
 894:	89 04 24             	mov    %eax,(%esp)
 897:	e8 d8 fd ff ff       	call   674 <putc>
        ap++;
 89c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8a0:	eb 45                	jmp    8e7 <printf+0x193>
      } else if(c == '%'){
 8a2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8a6:	75 17                	jne    8bf <printf+0x16b>
        putc(fd, c);
 8a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ab:	0f be c0             	movsbl %al,%eax
 8ae:	89 44 24 04          	mov    %eax,0x4(%esp)
 8b2:	8b 45 08             	mov    0x8(%ebp),%eax
 8b5:	89 04 24             	mov    %eax,(%esp)
 8b8:	e8 b7 fd ff ff       	call   674 <putc>
 8bd:	eb 28                	jmp    8e7 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8bf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8c6:	00 
 8c7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ca:	89 04 24             	mov    %eax,(%esp)
 8cd:	e8 a2 fd ff ff       	call   674 <putc>
        putc(fd, c);
 8d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8d5:	0f be c0             	movsbl %al,%eax
 8d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 8dc:	8b 45 08             	mov    0x8(%ebp),%eax
 8df:	89 04 24             	mov    %eax,(%esp)
 8e2:	e8 8d fd ff ff       	call   674 <putc>
      }
      state = 0;
 8e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8ee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8f2:	8b 55 0c             	mov    0xc(%ebp),%edx
 8f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f8:	01 d0                	add    %edx,%eax
 8fa:	0f b6 00             	movzbl (%eax),%eax
 8fd:	84 c0                	test   %al,%al
 8ff:	0f 85 71 fe ff ff    	jne    776 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 905:	c9                   	leave  
 906:	c3                   	ret    
 907:	90                   	nop

00000908 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 908:	55                   	push   %ebp
 909:	89 e5                	mov    %esp,%ebp
 90b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 90e:	8b 45 08             	mov    0x8(%ebp),%eax
 911:	83 e8 08             	sub    $0x8,%eax
 914:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 917:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 91c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91f:	eb 24                	jmp    945 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 921:	8b 45 fc             	mov    -0x4(%ebp),%eax
 924:	8b 00                	mov    (%eax),%eax
 926:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 929:	77 12                	ja     93d <free+0x35>
 92b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 931:	77 24                	ja     957 <free+0x4f>
 933:	8b 45 fc             	mov    -0x4(%ebp),%eax
 936:	8b 00                	mov    (%eax),%eax
 938:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 93b:	77 1a                	ja     957 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 940:	8b 00                	mov    (%eax),%eax
 942:	89 45 fc             	mov    %eax,-0x4(%ebp)
 945:	8b 45 f8             	mov    -0x8(%ebp),%eax
 948:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 94b:	76 d4                	jbe    921 <free+0x19>
 94d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 950:	8b 00                	mov    (%eax),%eax
 952:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 955:	76 ca                	jbe    921 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 957:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95a:	8b 40 04             	mov    0x4(%eax),%eax
 95d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 964:	8b 45 f8             	mov    -0x8(%ebp),%eax
 967:	01 c2                	add    %eax,%edx
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	8b 00                	mov    (%eax),%eax
 96e:	39 c2                	cmp    %eax,%edx
 970:	75 24                	jne    996 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 972:	8b 45 f8             	mov    -0x8(%ebp),%eax
 975:	8b 50 04             	mov    0x4(%eax),%edx
 978:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97b:	8b 00                	mov    (%eax),%eax
 97d:	8b 40 04             	mov    0x4(%eax),%eax
 980:	01 c2                	add    %eax,%edx
 982:	8b 45 f8             	mov    -0x8(%ebp),%eax
 985:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 988:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98b:	8b 00                	mov    (%eax),%eax
 98d:	8b 10                	mov    (%eax),%edx
 98f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 992:	89 10                	mov    %edx,(%eax)
 994:	eb 0a                	jmp    9a0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 996:	8b 45 fc             	mov    -0x4(%ebp),%eax
 999:	8b 10                	mov    (%eax),%edx
 99b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a3:	8b 40 04             	mov    0x4(%eax),%eax
 9a6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b0:	01 d0                	add    %edx,%eax
 9b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9b5:	75 20                	jne    9d7 <free+0xcf>
    p->s.size += bp->s.size;
 9b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ba:	8b 50 04             	mov    0x4(%eax),%edx
 9bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c0:	8b 40 04             	mov    0x4(%eax),%eax
 9c3:	01 c2                	add    %eax,%edx
 9c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ce:	8b 10                	mov    (%eax),%edx
 9d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d3:	89 10                	mov    %edx,(%eax)
 9d5:	eb 08                	jmp    9df <free+0xd7>
  } else
    p->s.ptr = bp;
 9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9da:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9dd:	89 10                	mov    %edx,(%eax)
  freep = p;
 9df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e2:	a3 a0 0f 00 00       	mov    %eax,0xfa0
}
 9e7:	c9                   	leave  
 9e8:	c3                   	ret    

000009e9 <morecore>:

static Header*
morecore(uint nu)
{
 9e9:	55                   	push   %ebp
 9ea:	89 e5                	mov    %esp,%ebp
 9ec:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9ef:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9f6:	77 07                	ja     9ff <morecore+0x16>
    nu = 4096;
 9f8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9ff:	8b 45 08             	mov    0x8(%ebp),%eax
 a02:	c1 e0 03             	shl    $0x3,%eax
 a05:	89 04 24             	mov    %eax,(%esp)
 a08:	e8 3f fc ff ff       	call   64c <sbrk>
 a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a10:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a14:	75 07                	jne    a1d <morecore+0x34>
    return 0;
 a16:	b8 00 00 00 00       	mov    $0x0,%eax
 a1b:	eb 22                	jmp    a3f <morecore+0x56>
  hp = (Header*)p;
 a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a26:	8b 55 08             	mov    0x8(%ebp),%edx
 a29:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2f:	83 c0 08             	add    $0x8,%eax
 a32:	89 04 24             	mov    %eax,(%esp)
 a35:	e8 ce fe ff ff       	call   908 <free>
  return freep;
 a3a:	a1 a0 0f 00 00       	mov    0xfa0,%eax
}
 a3f:	c9                   	leave  
 a40:	c3                   	ret    

00000a41 <malloc>:

void*
malloc(uint nbytes)
{
 a41:	55                   	push   %ebp
 a42:	89 e5                	mov    %esp,%ebp
 a44:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a47:	8b 45 08             	mov    0x8(%ebp),%eax
 a4a:	83 c0 07             	add    $0x7,%eax
 a4d:	c1 e8 03             	shr    $0x3,%eax
 a50:	83 c0 01             	add    $0x1,%eax
 a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a56:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a5e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a62:	75 23                	jne    a87 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a64:	c7 45 f0 98 0f 00 00 	movl   $0xf98,-0x10(%ebp)
 a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6e:	a3 a0 0f 00 00       	mov    %eax,0xfa0
 a73:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 a78:	a3 98 0f 00 00       	mov    %eax,0xf98
    base.s.size = 0;
 a7d:	c7 05 9c 0f 00 00 00 	movl   $0x0,0xf9c
 a84:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a8a:	8b 00                	mov    (%eax),%eax
 a8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a92:	8b 40 04             	mov    0x4(%eax),%eax
 a95:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a98:	72 4d                	jb     ae7 <malloc+0xa6>
      if(p->s.size == nunits)
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	8b 40 04             	mov    0x4(%eax),%eax
 aa0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aa3:	75 0c                	jne    ab1 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa8:	8b 10                	mov    (%eax),%edx
 aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aad:	89 10                	mov    %edx,(%eax)
 aaf:	eb 26                	jmp    ad7 <malloc+0x96>
      else {
        p->s.size -= nunits;
 ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab4:	8b 40 04             	mov    0x4(%eax),%eax
 ab7:	2b 45 ec             	sub    -0x14(%ebp),%eax
 aba:	89 c2                	mov    %eax,%edx
 abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abf:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ac5:	8b 40 04             	mov    0x4(%eax),%eax
 ac8:	c1 e0 03             	shl    $0x3,%eax
 acb:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ad4:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ada:	a3 a0 0f 00 00       	mov    %eax,0xfa0
      return (void*)(p + 1);
 adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae2:	83 c0 08             	add    $0x8,%eax
 ae5:	eb 38                	jmp    b1f <malloc+0xde>
    }
    if(p == freep)
 ae7:	a1 a0 0f 00 00       	mov    0xfa0,%eax
 aec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aef:	75 1b                	jne    b0c <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 af4:	89 04 24             	mov    %eax,(%esp)
 af7:	e8 ed fe ff ff       	call   9e9 <morecore>
 afc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 aff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b03:	75 07                	jne    b0c <malloc+0xcb>
        return 0;
 b05:	b8 00 00 00 00       	mov    $0x0,%eax
 b0a:	eb 13                	jmp    b1f <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b15:	8b 00                	mov    (%eax),%eax
 b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b1a:	e9 70 ff ff ff       	jmp    a8f <malloc+0x4e>
}
 b1f:	c9                   	leave  
 b20:	c3                   	ret    
 b21:	66 90                	xchg   %ax,%ax
 b23:	90                   	nop

00000b24 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
 b24:	55                   	push   %ebp
 b25:	89 e5                	mov    %esp,%ebp
 b27:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
 b2a:	8b 55 08             	mov    0x8(%ebp),%edx
 b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
 b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
 b33:	f0 87 02             	lock xchg %eax,(%edx)
 b36:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
 b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 b3c:	c9                   	leave  
 b3d:	c3                   	ret    

00000b3e <mutex_init>:
#include "types.h"
#include "user.h"
#include "x86.h"
#include "threadlib.h"

void mutex_init(mutex_t *m) {
 b3e:	55                   	push   %ebp
 b3f:	89 e5                	mov    %esp,%ebp
  // 0 indicates that lock is available, 1 that it is held by a thread
  m->flag = 0;
 b41:	8b 45 08             	mov    0x8(%ebp),%eax
 b44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
 b4a:	5d                   	pop    %ebp
 b4b:	c3                   	ret    

00000b4c <mutex_lock>:

void mutex_lock(mutex_t *m)
{
 b4c:	55                   	push   %ebp
 b4d:	89 e5                	mov    %esp,%ebp
 b4f:	83 ec 08             	sub    $0x8,%esp
  while (xchg(&m->flag, 1) == 1); // spin-wait (do nothing)
 b52:	90                   	nop
 b53:	8b 45 08             	mov    0x8(%ebp),%eax
 b56:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
 b5d:	00 
 b5e:	89 04 24             	mov    %eax,(%esp)
 b61:	e8 be ff ff ff       	call   b24 <xchg>
 b66:	83 f8 01             	cmp    $0x1,%eax
 b69:	74 e8                	je     b53 <mutex_lock+0x7>
}
 b6b:	c9                   	leave  
 b6c:	c3                   	ret    

00000b6d <mutex_unlock>:

void mutex_unlock(mutex_t *m)
{
 b6d:	55                   	push   %ebp
 b6e:	89 e5                	mov    %esp,%ebp
  m->flag = 0;
 b70:	8b 45 08             	mov    0x8(%ebp),%eax
 b73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
} 
 b79:	5d                   	pop    %ebp
 b7a:	c3                   	ret    

00000b7b <thread_create>:
  if(!pid) (*start_routine)(arg);
  else return pid;
}*/

int thread_create(void(*child)(void*), void *arg_ptr)
{
 b7b:	55                   	push   %ebp
 b7c:	89 e5                	mov    %esp,%ebp
 b7e:	83 ec 28             	sub    $0x28,%esp
	void *stack = malloc(4096);
 b81:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 b88:	e8 b4 fe ff ff       	call   a41 <malloc>
 b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int clone_pid = clone(child, arg_ptr, stack);
 b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b93:	89 44 24 08          	mov    %eax,0x8(%esp)
 b97:	8b 45 0c             	mov    0xc(%ebp),%eax
 b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
 b9e:	8b 45 08             	mov    0x8(%ebp),%eax
 ba1:	89 04 24             	mov    %eax,(%esp)
 ba4:	e8 bb fa ff ff       	call   664 <clone>
 ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return clone_pid;
 bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 baf:	c9                   	leave  
 bb0:	c3                   	ret    

00000bb1 <thread_join>:

int thread_join(void)
{
 bb1:	55                   	push   %ebp
 bb2:	89 e5                	mov    %esp,%ebp
 bb4:	83 ec 28             	sub    $0x28,%esp
    void *join_s;
    int join_pid = join(&join_s);
 bb7:	8d 45 f0             	lea    -0x10(%ebp),%eax
 bba:	89 04 24             	mov    %eax,(%esp)
 bbd:	e8 aa fa ff ff       	call   66c <join>
 bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return join_pid;
 bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc8:	c9                   	leave  
 bc9:	c3                   	ret    
