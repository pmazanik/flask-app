from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    return f"Hello from Flask on EKS! ENV: {os.environ.get('ENV', 'dev')}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
