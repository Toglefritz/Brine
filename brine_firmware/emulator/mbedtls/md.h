/**
 * @file mbedtls/md.h
 * @brief HMAC-SHA256 implementation for the native emulator using OpenSSL.
 *
 * Provides the same mbedtls API surface used by FirebaseService::generateHMAC()
 * but backed by OpenSSL's HMAC functions, which are available on macOS by default.
 */
#ifndef MBEDTLS_MD_H_EMULATOR
#define MBEDTLS_MD_H_EMULATOR

#include <cstdint>
#include <cstring>
#include <CommonCrypto/CommonHMAC.h>

#define MBEDTLS_MD_SHA256 6

typedef int mbedtls_md_type_t;

/// Opaque info struct (only SHA256 is supported).
typedef struct {
  mbedtls_md_type_t type;
  int digest_size;
} mbedtls_md_info_t;

/// HMAC context that accumulates key and data for a single operation.
typedef struct {
  const mbedtls_md_info_t *md_info;
  uint8_t key[256];
  size_t key_len;
  uint8_t data[4096];
  size_t data_len;
} mbedtls_md_context_t;

static const mbedtls_md_info_t _sha256_info = {MBEDTLS_MD_SHA256, 32};

inline void mbedtls_md_init(mbedtls_md_context_t *ctx) {
  memset(ctx, 0, sizeof(*ctx));
}

inline void mbedtls_md_free(mbedtls_md_context_t *) {}

inline const mbedtls_md_info_t *
mbedtls_md_info_from_type(mbedtls_md_type_t type) {
  if (type == MBEDTLS_MD_SHA256) return &_sha256_info;
  return nullptr;
}

inline int mbedtls_md_setup(mbedtls_md_context_t *ctx,
                            const mbedtls_md_info_t *info, int) {
  ctx->md_info = info;
  return 0;
}

inline int mbedtls_md_hmac_starts(mbedtls_md_context_t *ctx,
                                  const unsigned char *key, size_t keylen) {
  if (keylen > sizeof(ctx->key)) return -1;
  memcpy(ctx->key, key, keylen);
  ctx->key_len = keylen;
  ctx->data_len = 0;
  return 0;
}

inline int mbedtls_md_hmac_update(mbedtls_md_context_t *ctx,
                                  const unsigned char *input, size_t ilen) {
  if (ctx->data_len + ilen > sizeof(ctx->data)) return -1;
  memcpy(ctx->data + ctx->data_len, input, ilen);
  ctx->data_len += ilen;
  return 0;
}

inline int mbedtls_md_hmac_finish(mbedtls_md_context_t *ctx,
                                  unsigned char *output) {
  CCHmac(kCCHmacAlgSHA256, ctx->key, ctx->key_len, ctx->data, ctx->data_len,
         output);
  return 0;
}

#endif // MBEDTLS_MD_H_EMULATOR
