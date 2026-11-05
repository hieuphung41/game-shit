#!/usr/bin/env python3
"""Serve a Godot web export locally with cross-origin isolation headers.

Usage: serve_web.py <build-dir> [port]   (default port 8060, binds 127.0.0.1)
"""
import functools
import http.server
import sys


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    port = int(argv[1]) if len(argv) > 1 else 8060
    handler = functools.partial(Handler, directory=argv[0])
    with http.server.ThreadingHTTPServer(("127.0.0.1", port), handler) as httpd:
        print(f"Serving {argv[0]} at http://127.0.0.1:{port}/  (Ctrl+C to stop)")
        httpd.serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
