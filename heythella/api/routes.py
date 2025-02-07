from flask import Response

def hey_there_fella():
    return Response(
        "Whose soul are you tormenting now?", 
        status=200,
        mimetype='text/plain'
    )

@app.route('/heytherefella')
def hey_there_fella():
    return hey_there_fella()
