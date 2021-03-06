/**
 * Created by gatti2602 on 12/09/18.
 * Main
 */

#define FALSE 0
#define TRUE 1

#include <getopt.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>

#define CMD_ENCODE 1
#define CMD_DECODE 0
#define CMD_NOENCODE 2
#define FALSE 0
#define TRUE 1
#define ERROR 1
#define OK 0

#include "base64.h"

/****************************
 * DECLARACION DE FUNCIONES *
 ****************************/

typedef struct{
    FILE* file;
    char eof;
} File;

typedef struct {
    File input;
    File output;
    const char* input_route;
    const char* output_route;
    char error;
    char encode_opt;
} CommandOptions;

/**
 * Inicializa TDA CommandOptions
 * Pre: Puntero a Command Options escribible
 * Post: CommandOptions Inicializados a valores por default
 * Valores default:
 *      input: stdin
 *      output stdout
 *      error: FALSE
 *      encode_opt: decode
 */
void CommandCreate(CommandOptions* opt);

/**
 * Setea ruta de entrada
 * Pre: ruta valida
 * Post: ruta lista para abrir file
 */
void CommandSetInput(CommandOptions* opt, const char* input);

/**
 * Setea ruta de salida
 * Pre: ruta valida
 * Post: ruta lista para abrir file
 */
void CommandSetOutput(CommandOptions* opt, const char* output);

/**Setea Command Option
 * Pre: opt inicializado
 * Post: Setea el encoding.
 *      Si string no es encode/decode setea opt error flag.
 */
void CommandSetEncodeOpt(CommandOptions* opt, const char* encode_opt);

/**
 * Devuelve el flag de error
 */
char CommandHasError(CommandOptions *opt);

/**
 * Indica que hubo un error
 */
void CommandSetError(CommandOptions *opt);

/**
 * Ejecuta el comando
 * Pre: Asume parametros previamente validados y ok
 * Post: Ejecuta el comando generando la salida esperada
 *       Devuelve 0 si error y 1 si OK.
 */
char CommandProcess(CommandOptions* opt);

/**
 * Help Command
 * Imprime por salida estandar los distintos comandos posibles.
 * Pre: N/A
 * Post: N/A
 */
void CommandHelp();

/**
 * Imprime la ayuda por la salida de errores
 */
void CommandErrArg();

/**
 * Version Command
 * Imprime por salida estandar la version del codigo
 * Pre: N/A
 * Post: N/A
 */
void CommandVersion();

/**
 * Recibe los archivos abiertos y debe ejecutar la operacion de codificacion
 * Pre: opt->input posee el stream de entrada
 *      opt->output posee el stream de salida
 *      opt->encode_opt posee la opcion de codificacion
 * Post: Datos procesados y escritos en el stream, si error devuelve 0, sino 1.
 */
char _CommandEncodeDecode(CommandOptions *opt);

/**
 * Construye el TDA.
 * Post: TDA construido
 */
void FileCreate(File *f);

/**
 * Abre un File, devuelve 0 (NULL) si falla
 * Pre: Ptr a File Inicializado ,
 *      Ruta a archivo, si es 0 (NULL) utiliza stdin
 */
char FileOpenForRead(File* file, const char* route);

/**
 * Abre un File, devuelve 0 (NULL) si falla
 * Pre: Ptr a File Inicializado ,
 *      Ruta a archivo, si es 0 (NULL) utiliza stdout
 */
char FileOpenForWrite(File* file, const char* route);

/*
 * Cierra archivo abierto
 * Pre: Archivo previamente abierto
 */
int FileClose(File* file);

/*********************************
 * FIN: DECLARACION DE FUNCIONES *
 *********************************/

/***************************
 * DEFINICION DE FUNCIONES *
 ***************************/

void CommandHelp(){
    printf("Options:\n");
    printf("  -V, --version    Print version and quit.\n");
    printf("  -h, --help       Print this information.\n");
    printf("  -i, --input      Location of the input file.\n");
    printf("  -o, --output     Location of the output file.\n");
    printf("  -a, --action     Program action: encode (default) or decode.\n");
    printf("Examples:\n");
    printf("  tp1 -a encode -i ~/input -o ~/output\n");
    printf("  tp1 -a decode\n");
}

void CommandVersion() {
    printf("Version: 0.2\n");
}

void CommandCreate(CommandOptions *opt) {
    FileCreate(&opt->input);
    FileCreate(&opt->output);
    opt->error = FALSE;
    opt->encode_opt = CMD_ENCODE;
    opt->input_route = 0;
    opt->output_route = 0;
}

void CommandSetInput(CommandOptions *opt, const char *input) {
    opt->input_route = input;
}

void CommandSetOutput(CommandOptions *opt, const char *output) {
    opt->output_route = output;
}

void CommandSetEncodeOpt(CommandOptions *opt, const char *encode_opt) {
	if(strcmp(encode_opt,"decode") == 0) {
	    opt->encode_opt = CMD_DECODE;
	} else {
	    opt->encode_opt = CMD_ENCODE;
	}
}

char CommandHasError(CommandOptions *opt) {
    return opt->error || opt->encode_opt == CMD_NOENCODE;
}

void CommandSetError(CommandOptions *opt) {
    opt->error = TRUE;
}

char CommandProcess(CommandOptions *opt) {
    opt->error = FileOpenForRead(&opt->input, opt->input_route);

    if(opt->error != ERROR){
        opt->error = FileOpenForWrite(&opt->output, opt->output_route);

	if(opt->error != ERROR){
		opt->error = _CommandEncodeDecode(opt);
		FileClose(&opt->input);
		FileClose(&opt->output);
        } else {
		FileClose(&opt->input);
        }
    }
    return opt->error;
}

char _CommandEncodeDecode(CommandOptions *opt) {
    if(opt->encode_opt == CMD_ENCODE){
	int filein = fileno((opt->input).file);
	int fileout = fileno((opt->output).file);
	int res = base64_encode(filein, fileout);
	if(res != 0)
		fprintf(stderr, "%s\n",errmsg[res]);
		
    }

   if (opt->encode_opt == CMD_DECODE) {
       	int filein = fileno((opt->input).file);
	int fileout = fileno((opt->output).file);
	int res = base64_decode(filein, fileout);
	if(res != 0)
		fprintf(stderr, "%s\n",errmsg[res]);
   }
	
    return opt->error;
}

void CommandErrArg() {
    fprintf(stderr, "Invalid Arguments\n");
    fprintf(stderr,"Options:\n");
    fprintf(stderr,"  -V, --version    Print version and quit.\n");
    fprintf(stderr,"  -h, --help       Print this information.\n");
    fprintf(stderr,"  -i, --input      Location of the input file.\n");
    fprintf(stderr,"  -o, --output     Location of the output file.\n");
    fprintf(stderr,"  -a, --action     Program action: encode (default) or decode.\n");
    fprintf(stderr,"Examples:\n");
    fprintf(stderr,"  tp1 -a encode -i ~/input -o ~/output\n");
    fprintf(stderr,"  tp1 -a decode\n");
}

void FileCreate(File *file){
    file->file = 0;
    file->eof = 0;
}

char FileOpenForRead(File* file, const char *route ){
    if(route == NULL) {
        file->file = stdin;
    } else {
        file->file = fopen(route, "rb");
        if (file->file == NULL) {
            int err = errno;
            fprintf(stderr, "File Open Error; %s\n", strerror(err));
            return ERROR;
        }
    }
    return OK;
}

char FileOpenForWrite(File* file, const char *route ) {
    if(route == NULL) {
        file->file = stdout;
    } else {
        file->file = fopen(route, "wb");
        if (file->file == NULL) {
            int err = errno;
            fprintf(stderr, "File Open Error; %s\n", strerror(err));
            return ERROR;
        }
    }
    return OK;
}

int FileClose(File* file){
    if(file->file == stdin || file->file == stdout)
        return OK;

    int result = fclose(file->file);
    if (result == EOF){
        int err = errno;
        fprintf(stderr, "File Close Error; %s\n", strerror(err));
        return ERROR;
    }
    return OK;
}

/********************************
 * FIN: DEFINICION DE FUNCIONES *
 ********************************/

int main(int argc, char** argv) {
    struct option arg_long[] = {
            {"input",   required_argument,  NULL,  'i'},
            {"output",  required_argument,  NULL,  'o'},
            {"action",  required_argument,  NULL,  'a'},
            {"help",    no_argument,        NULL,  'h'},
            {"version", no_argument,        NULL,  'V'},
    };
    char arg_opt_str[] = "i:o:a:hV";
    int arg_opt;
    int arg_opt_idx = 0;
    char should_finish = FALSE;

    CommandOptions cmd_opt;
    CommandCreate(&cmd_opt);

    while((arg_opt =
                   getopt_long(argc, argv, arg_opt_str, arg_long, &arg_opt_idx)) != -1 && !should_finish) {
        switch(arg_opt){
        	case 'i':
		if(strcmp(optarg, "-") != 0)
        		CommandSetInput(&cmd_opt, optarg);
        	break;
        	case 'o':
		if(strcmp(optarg, "-") != 0)
                	CommandSetOutput(&cmd_opt, optarg);
                break;
        	case 'h':
        		CommandHelp();
                should_finish = TRUE;
                break;
        	case 'V':
        		CommandVersion();
                should_finish = TRUE;
                break;
        	case 'a':
        	    CommandSetEncodeOpt(&cmd_opt, optarg);
				break;
        	default:
        		CommandSetError(&cmd_opt);
        		break;
        }
    }

    if(should_finish)
        return 0;

    if(!CommandHasError(&cmd_opt)) {
        CommandProcess(&cmd_opt);
    } else {
        CommandErrArg();
        return 1;
    }
    return 0;
}
