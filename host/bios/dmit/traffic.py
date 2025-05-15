from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess
import os

interface = "eth0"
cmd = f"vnstat --oneline -i {interface} | awk -F ';' '{{print $11}}'"

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/traffic':
            result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            output = result.stdout or result.stderr

            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(output.encode())
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

if __name__ == '__main__':
    port = int(os.getenv("PORT", "8000"))
    print(f"Serving on http://localhost:{port}")
    server = HTTPServer(('0.0.0.0', port), SimpleHandler)
    server.serve_forever()