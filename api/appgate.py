from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def hello():
    return "<h1 style='color:blue'>Hello! This is Appgate world!</h1>"

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=9000, debug=True)
