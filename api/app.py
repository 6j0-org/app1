from flask import Flask

app = Flask(__name__)

@app.route('/')
def hey_there():
    return "Try /heytherefella"

@app.route('/heytherefella')
def hey_there():
    return "Whose soul are you tormenting now?"

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
