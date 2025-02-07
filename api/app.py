from flask import Flask

app = Flask(__name__)

@app.route('/heytherefella')
def hey_there():
    return "Whose soul are you tormenting now?"

if __name__ == '__main__':
    app.run(debug=True)
