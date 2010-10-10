/* 7zCrc.h */

#ifndef __7Z_CRC_H
#define __7Z_CRC_H

#include <stddef.h>
#include <sys/types.h>

extern u_int32_t g_CrcTable[256];
void InitCrcTable();

void CrcInit(u_int32_t *crc);
u_int32_t CrcGetDigest(u_int32_t *crc);
void CrcUpdateUInt8(u_int32_t *crc, u_int8_t v);
void CrcUpdateUInt16(u_int32_t *crc, u_int16_t v);
void CrcUpdateUInt32(u_int32_t *crc, u_int32_t v);
void CrcUpdateUInt64(u_int32_t *crc, u_int64_t v);
void CrcUpdate(u_int32_t *crc, const void *data, size_t size);
 
u_int32_t CrcCalculateDigest(const void *data, size_t size);
int CrcVerifyDigest(u_int32_t digest, const void *data, size_t size);

#endif
