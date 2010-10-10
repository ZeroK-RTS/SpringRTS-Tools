/* 7zCrc.c */

#include "7zCrc.h"

#define kCrcPoly 0xEDB88320

u_int32_t g_CrcTable[256];

void InitCrcTable()
{
	u_int32_t i;
	for (i = 0; i < 256; i++)
	{
		u_int32_t r = i;
		int j;
		for (j = 0; j < 8; j++)
			if (r & 1) 
				r = (r >> 1) ^ kCrcPoly;
			else		 
				r >>= 1;
		g_CrcTable[i] = r;
	}
}

void CrcInit(u_int32_t *crc) { *crc = 0xFFFFFFFF; }
u_int32_t CrcGetDigest(u_int32_t *crc) { return *crc ^ 0xFFFFFFFF; } 

void CrcUpdateUInt8(u_int32_t *crc, u_int8_t b)
{
	*crc = g_CrcTable[((u_int8_t)(*crc)) ^ b] ^ (*crc >> 8);
}

void CrcUpdateUInt16(u_int32_t *crc, u_int16_t v)
{
	CrcUpdateUInt8(crc, (u_int8_t)v);
	CrcUpdateUInt8(crc, (u_int8_t)(v >> 8));
}

void CrcUpdateUInt32(u_int32_t *crc, u_int32_t v)
{
	int i;
	for (i = 0; i < 4; i++)
		CrcUpdateUInt8(crc, (u_int8_t)(v >> (8 * i)));
}

void CrcUpdateUInt64(u_int32_t *crc, u_int64_t v)
{
	int i;
	for (i = 0; i < 8; i++)
	{
		CrcUpdateUInt8(crc, (u_int8_t)(v));
		v >>= 8;
	}
}

void CrcUpdate(u_int32_t *crc, const void *data, size_t size)
{
	u_int32_t v = *crc;
	const u_int8_t *p = (const u_int8_t *)data;
	for (; size > 0 ; size--, p++)
		v = g_CrcTable[((u_int8_t)(v)) ^ *p] ^ (v >> 8);
	*crc = v;
}

u_int32_t CrcCalculateDigest(const void *data, size_t size)
{
	u_int32_t crc;
	CrcInit(&crc);
	CrcUpdate(&crc, data, size);
	return CrcGetDigest(&crc);
}

int CrcVerifyDigest(u_int32_t digest, const void *data, size_t size)
{
	return (CrcCalculateDigest(data, size) == digest);
}
