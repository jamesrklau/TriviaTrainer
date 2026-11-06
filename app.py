
from flask import Flask, jsonify


def create_app():
    app = Flask(__name__)

    @app.get("/api/health")
    def health_check():
        return jsonify({
            "status": "ok",
            "service": "triviatrainer-backend"
        }), 200

    return app


app = create_app()


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5005,
        debug=False
    )
