/**
 * Created by lucasveron 10/10/2018
 */

#define BASE64_END '='
#define DECODE_ERROR 100

static unsigned char encoding_table[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
                                         'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
                                         'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
                                         'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
                                         'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
                                         'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
                                         'w', 'x', 'y', 'z', '0', '1', '2', '3',
                                         '4', '5', '6', '7', '8', '9', '+', '/'};

static int encoding_table_size = 64;

/**
 * Retorna la representación del char en la tabla.
 * pre: character es válido(pertenece a la tabla)
 * ó es el caracter '='.
 * post: retorna la representación(int) del character
 * en la tabla encoding.
 *
 */
unsigned char DecodeChar(char character){
	unsigned char i;
	for(i = 0;i<encoding_table_size;i++){
		if(encoding_table[i] == character){
			return i;
		}
	}
    if (character == '=')
        return 0;
    return DECODE_ERROR;
}

/**
 * Retorna un buffer de 3 aracteres con el decode de 4 caracteres en base64.
 * Pre: el buffer input contiene 4 caracteres. El buffer output tiene por lo menos 3 caracteres
 * Post: retorna un buffer de 3 byte con los caracteres en ASCII. retorna 0 si error 1 si ok
 */
unsigned char Decode(unsigned char *buf_input, unsigned char *buf_output) {
    unsigned char chars[4];
    unsigned int i;
    for (i = 0; i < 4; ++i) {
        chars[i] = DecodeChar(buf_input[i]);
        if (chars[i] == DECODE_ERROR)
            return 0;
    }

    unsigned char char1_aux = chars[0] << 2;
	//Tomo los 2 ultimos bits de char2
    unsigned char char2_aux = chars[1] >> 4;
	char1_aux = char1_aux | char2_aux;
    buf_output[0] = char1_aux;

	//Tomo los ultimos 4b del char2 y los 4b primeros del char3
    char1_aux = chars[1] << 4;
    char2_aux = chars[2] >> 2;
	char2_aux = char1_aux | char2_aux;
    buf_output[1] = char2_aux;

	//Tomo los ultimos 2b del char3 + los bits del char4
    char1_aux = chars[2] << 6;
    buf_output[2] = char1_aux | chars[3];
    return 1;
}
