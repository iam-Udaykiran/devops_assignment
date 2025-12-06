locals {
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3

    mkdir -p /opt/app
    cat > /opt/app/app.py << 'PYEOF'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from the DevOps assignment!"

@app.route("/health")
def health():
    return "ok"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PYEOF

    pip3 install flask

    # run in background
    nohup python3 /opt/app/app.py > /var/log/app.log 2>&1 &
  EOF
}

