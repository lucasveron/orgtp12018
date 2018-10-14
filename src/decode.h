/**
 * Created by lucasveron on 10/10/18
 */

#ifndef TP0_DECODE_H
#define TP0_DECODE_H

/**
 * Retorna la representación en int del char
 * en la tabla.
 */
unsigned char DecodeChar(char toDecode);

/**
 * Retorna un buffer de 3 aracteres con el decode de 4 caracteres en base64.
 * Pre: el buffer input contiene 4 caracteres. El buffer output tiene por lo menos 3 caracteres
 * Post: retorna un buffer de 3 byte con los caracteres en ASCII. retorna 0 si error 1 si ok
 */
unsigned char Decode(unsigned char *buf_input, unsigned char *buf_output);

#endif //TP0_DECODE_H
