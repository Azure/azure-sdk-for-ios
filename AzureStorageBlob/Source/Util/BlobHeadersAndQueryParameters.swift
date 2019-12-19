// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCore
import Foundation

// TODO: Revisit this naming and structure prior to Preview 1
public class BlobHeadersAndQueryParameters {
    public static let headers: [String] = LoggingPolicy.defaultAllowHeaders + [
        "Access-Control-Allow-Origin", "Cache-Control", "Content-Length", "Content-Type", "Date", "Request-Id",
        "traceparent", "Transfer-Encoding", "User-Agent", "x-ms-client-request-id", "x-ms-date", "x-ms-error-code",
        "x-ms-request-id", "x-ms-return-client-request-id", "x-ms-version", "Accept-Ranges", "Content-Disposition",
        "Content-Encoding", "Content-Language", "Content-MD5", "Content-Range", "ETag", "Last-Modified", "Server",
        "Vary", "x-ms-content-crc64", "x-ms-copy-action", "x-ms-copy-completion-time", "x-ms-copy-id",
        "x-ms-copy-progress", "x-ms-copy-status", "x-ms-has-immutability-policy", "x-ms-has-legal-hold",
        "x-ms-lease-state", "x-ms-lease-status", "x-ms-range", "x-ms-request-server-encrypted",
        "x-ms-server-encrypted", "x-ms-snapshot", "x-ms-source-range", "If-Match", "If-Modified-Since",
        "If-None-Match", "If-Unmodified-Since", "x-ms-access-tier", "x-ms-access-tier-change-time",
        "x-ms-access-tier-inferred", "x-ms-account-kind", "x-ms-archive-status", "x-ms-blob-append-offset",
        "x-ms-blob-cache-control", "x-ms-blob-committed-block-count", "x-ms-blob-condition-appendpos",
        "x-ms-blob-condition-maxsize", "x-ms-blob-content-disposition", "x-ms-blob-content-encoding",
        "x-ms-blob-content-language", "x-ms-blob-content-length", "x-ms-blob-content-md5", "x-ms-blob-content-type",
        "x-ms-blob-public-access", "x-ms-blob-sequence-number", "x-ms-blob-type", "x-ms-copy-destination-snapshot",
        "x-ms-creation-time", "x-ms-default-encryption-scope", "x-ms-delete-snapshots",
        "x-ms-delete-type-permanent", "x-ms-deny-encryption-scope-override", "x-ms-encryption-algorithm",
        "x-ms-if-sequence-number-eq", "x-ms-if-sequence-number-le", "x-ms-if-sequence-number-lt",
        "x-ms-incremental-copy", "x-ms-lease-action", "x-ms-lease-break-period", "x-ms-lease-duration",
        "x-ms-lease-id", "x-ms-lease-time", "x-ms-page-write", "x-ms-proposed-lease-id",
        "x-ms-range-get-content-md5", "x-ms-rehydrate-priority", "x-ms-sequence-number-action", "x-ms-sku-name",
        "x-ms-source-content-md5", "x-ms-source-if-match", "x-ms-source-if-modified-since",
        "x-ms-source-if-none-match", "x-ms-source-if-unmodified-since", "x-ms-tag-count",
        "x-ms-encryption-key-sha256"
    ]

    public static let queryParameters: [String] = [
        "comp", "maxresults", "rscc", "rscd", "rsce", "rscl", "rsct", "se", "si", "sip", "sp", "spr", "sr", "srt",
        "ss", "st", "sv", "include", "marker", "prefix", "copyid", "restype", "blockid", "blocklisttype",
        "delimiter", "prevsnapshot", "ske", "skoid", "sks", "skt", "sktid", "skv", "snapshot"
    ]
}
