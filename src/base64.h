#ifndef TP1_BASE64_H
#define TP1_BASE64_H

extern const char* errmsg[];

int base64_encode(int infd, int outfd);
int base64_decode(int infd, int outfd);

#endif
