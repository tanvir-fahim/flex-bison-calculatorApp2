import http.server
import json
import os
import platform
import subprocess

HOST = "0.0.0.0"
PORT = int(os.environ.get("PORT", 8080))
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

IS_WINDOWS = platform.system() == "Windows"
EXEC_NAME = "calc.exe" if IS_WINDOWS else "calc"
EXEC_PATH = os.path.join(BASE_DIR, EXEC_NAME)


def build_compiler():
    """Automatically builds Flex/Bison sources on server startup."""
    print("⚡ Checking compiler binary...")
    try:
        subprocess.run(["bison", "-d", "cal.y"], cwd=BASE_DIR, check=True)
        subprocess.run(["flex", "cal.l"], cwd=BASE_DIR, check=True)

        cmd = ["gcc", "cal.tab.c", "lex.yy.c", "-o", EXEC_NAME]
        if not IS_WINDOWS:
            cmd.append("-lm")

        subprocess.run(cmd, cwd=BASE_DIR, check=True)
        print("✅ Compilation successful!")
    except Exception as e:
        print(f"⚠️ Note on compilation step: {e}")


class Handler(http.server.BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            file_path = os.path.join(BASE_DIR, "index.html")
            content_type = "text/html; charset=utf-8"
        elif self.path == "/style.css":
            file_path = os.path.join(BASE_DIR, "style.css")
            content_type = "text/css"
        elif self.path == "/script.js":
            file_path = os.path.join(BASE_DIR, "script.js")
            content_type = "application/javascript"
        else:
            self.send_error(404)
            return

        with open(file_path, "rb") as file:
            data = file.read()

        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self):
        if self.path != "/calculate":
            self.send_error(404)
            return

        length = int(self.headers.get("Content-Length", 0))
        data = self.rfile.read(length)

        try:
            request = json.loads(data.decode("utf-8"))
            expression = request["expression"]

            run_cmd = [EXEC_PATH] if IS_WINDOWS else [f"./{EXEC_NAME}"]
            process = subprocess.run(
                run_cmd,
                input=expression + "\n",
                text=True,
                capture_output=True,
                cwd=BASE_DIR,
            )

            if process.stderr.strip():
                result = {"error": process.stderr.strip()}
            else:
                result = {"result": process.stdout.strip()}

            response = json.dumps(result).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(response)

        except Exception as e:
            response = json.dumps({"error": str(e)}).encode("utf-8")
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(response)


if __name__ == "__main__":
    build_compiler()
    print(f"🚀 Calculator Server running at http://{HOST}:{PORT}")
    server = http.server.HTTPServer((HOST, PORT), Handler)
    server.serve_forever()