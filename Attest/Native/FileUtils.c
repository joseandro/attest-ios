//
//  FileUtils.c
//  Attest
//
//  Created by Joseandro Luiz on 02/10/19.
//  Copyright © 2019 Joseandro Luiz. All rights reserved.
//

#include "FileUtils.h"
#include <errno.h>
#include <string.h>
int const KBYTE = 1000;

int createFile(char *name, long long sizeInBytes){
    char *home = getenv("HOME");
    char *localFolder = "/Documents/";
    char path[2048];

    strcpy(path, home);
    strcat(path, localFolder);
    strcat(path, name);

    const size_t NBytesInBuffer = KBYTE * KBYTE; //1MB

    /* fill buffer, if you like */
    const char buffer[NBytesInBuffer] = {"a"};

    FILE* const file = fopen(path, "w+");
    const size_t ElementSize = sizeof(buffer[0]);

    uint64_t nBytesWritten = 0;
    while (sizeInBytes > nBytesWritten) {
        nBytesWritten += ElementSize * fwrite(buffer, ElementSize, NBytesInBuffer, file);
    }

    fclose(file);
    

    return (nBytesWritten == sizeInBytes);
}
