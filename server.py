#!/usr/bin/env python3
import http.server
import socketserver
import os
import urllib.parse
import urllib.request
import json
import sys

PORT = 4321
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

def get_service_key():
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    if key:
        return key
    env_file = os.path.join(DIRECTORY, ".env")
    if os.path.exists(env_file):
        with open(env_file, "r") as f:
            for line in f:
                if line.strip().startswith("SUPABASE_SERVICE_ROLE_KEY="):
                    return line.strip().split("=", 1)[1].strip()
    return ""

SERVICE_ROLE_KEY = get_service_key()

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

        # 4. Patient health profile page (/ho-so, /ho-so-suc-khoe)
        if parsed.path in ('/ho-so', '/ho-so-suc-khoe'):
            hoso_file = os.path.join(DIRECTORY, 'ho-so.html')
            if os.path.exists(hoso_file):
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.end_headers()
                with open(hoso_file, 'rb') as f:
                    self.wfile.write(f.read())
                return

        # 4. Any missing webpage route (e.g. /don-vi-nam-hoc-va-ho-tro-sinh-san, /tin-tuc, etc.)
        # Redirect directly to original domain https://benhvienhungvuong.vn/...
        target_url = f"https://benhvienhungvuong.vn{self.path}"
        self.send_response(302)
        self.send_header('Location', target_url)
        self.end_headers()
        return

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == '/api/auth/register':
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode('utf-8')
            try:
                data = json.loads(body)
                phone = data.get('phone', '').strip()
                name = data.get('name', '').strip()
                password = data.get('password', '')
                
                email = f"{phone}@hungvuong.hospital"
                payload = json.dumps({
                    "email": email,
                    "password": password,
                    "email_confirm": True,
                    "user_metadata": {
                        "phone": phone,
                        "full_name": name
                    }
                }).encode('utf-8')

                req = urllib.request.Request(
                    "https://tfnxmcseexinbgkzwmwh.supabase.co/auth/v1/admin/users",
                    data=payload,
                    headers={
                        "Content-Type": "application/json",
                        "apikey": SERVICE_ROLE_KEY,
                        "Authorization": f"Bearer {SERVICE_ROLE_KEY}"
                    },
                    method="POST"
                )
                with urllib.request.urlopen(req, timeout=5) as response:
                    res_body = response.read()
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/json')
                    self.end_headers()
                    self.wfile.write(res_body)
                    return
            except urllib.error.HTTPError as e:
                err_content = e.read()
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(err_content)
                return
            except Exception as e:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e), "success": False}).encode('utf-8'))
                return

        if parsed.path == '/api/auth/auto-confirm':
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode('utf-8')
            try:
                data = json.loads(body)
                user_id = data.get('user_id')
                if user_id:
                    req = urllib.request.Request(
                        f"https://tfnxmcseexinbgkzwmwh.supabase.co/auth/v1/admin/users/{user_id}",
                        data=json.dumps({"email_confirm": True}).encode('utf-8'),
                        headers={
                            "Content-Type": "application/json",
                            "apikey": SERVICE_ROLE_KEY,
                            "Authorization": f"Bearer {SERVICE_ROLE_KEY}"
                        },
                        method="PUT"
                    )
                    with urllib.request.urlopen(req, timeout=5) as response:
                        self.send_response(200)
                        self.send_header('Content-Type', 'application/json')
                        self.end_headers()
                        self.wfile.write(b'{"success": true}')
                        return
            except Exception as e:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e), "success": False}).encode('utf-8'))
                return
        self.send_response(404)
        self.end_headers()

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
