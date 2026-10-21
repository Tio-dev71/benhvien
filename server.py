#!/usr/bin/env python3
import http.server
import socketserver
import os
import urllib.parse
import sys

PORT = 4321
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class HospitalHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        clean_path = parsed.path.lstrip('/')
        filepath = os.path.join(DIRECTORY, clean_path)

        # 1. Existing static file
        if clean_path and os.path.isfile(filepath):
            return super().do_GET()

        # 2. Root index
        if parsed.path == '/' or clean_path == '':
            return super().do_GET()

        # 3. Known static assets that are missing (e.g. css/js/images)
        static_exts = ('.css', '.js', '.png', '.jpg', '.jpeg', '.svg', '.gif', '.ico', '.woff', '.woff2', '.ttf')
        if any(parsed.path.lower().endswith(ext) for ext in static_exts):
            return super().do_GET()

        # 4. Any missing webpage route (e.g. /don-vi-nam-hoc-va-ho-tro-sinh-san, /tin-tuc, etc.)
        # Serve the beautiful centered development.html page!
        dev_file = os.path.join(DIRECTORY, 'development.html')
        if os.path.exists(dev_file):
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            with open(dev_file, 'rb') as f:
                self.wfile.write(f.read())
            return

        return super().do_GET()

    do_HEAD = do_GET

if __name__ == '__main__':
    # Allow port reuse immediately
    socketserver.TCPServer.allow_reuse_address = True
    try:
        with socketserver.TCPServer(("", PORT), HospitalHandler) as httpd:
            print(f"Hospital Clone Server running at http://localhost:{PORT}")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")
        sys.exit(0)
