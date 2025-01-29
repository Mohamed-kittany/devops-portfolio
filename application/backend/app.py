import os #
import time
from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from bson.objectid import ObjectId
from flask_cors import CORS
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST


# Flask app initialization
app = Flask(__name__)
app.config["MONGO_URI"] = os.getenv("MONGO_URI", "mongodb://localhost:27017/todo")
mongo = PyMongo(app)
CORS(app)

# Prometheus metrics
REQUEST_COUNT = Counter(
    "http_requests_total", "Total HTTP requests", ["method", "endpoint", "http_status"]
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds", "HTTP request latency", ["method", "endpoint"]
)

# Global variables
start_time = time.time()


# Utility function: Format ObjectId for JSON responses
def format_todos(todos):
    for todo in todos:
        todo["_id"] = str(todo["_id"])
    return todos


# Middleware: Track request latency
@app.before_request
def start_timer():
    """Start timer for request latency."""
    request.start_time = time.time()


@app.after_request
def log_request(response):
    """Log metrics after each request."""
    latency = time.time() - request.start_time
    endpoint = request.endpoint or "unknown"
    REQUEST_COUNT.labels(
        method=request.method, endpoint=endpoint, http_status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(method=request.method, endpoint=endpoint).observe(latency)
    return response


# Routes
@app.route("/api/health", methods=["GET"])
def health():
    """Health check endpoint."""
    return jsonify({"status": "healthy"}), 200


@app.route("/api/metrics", methods=["GET"])
def metrics():
    """Metrics endpoint for Prometheus."""
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


@app.route("/api/todos", methods=["GET", "POST"])
def todos():
    """Handle GET and POST requests for todos."""
    if request.method == "GET":
        todos = list(mongo.db.todos.find())
        return jsonify(format_todos(todos))
    elif request.method == "POST":
        data = request.json
        if not data.get("todo"):
            return jsonify({"message": "Todo content is required"}), 400
        new_todo = {"todo": data["todo"], "status": False}
        result = mongo.db.todos.insert_one(new_todo)
        new_todo["_id"] = str(result.inserted_id)
        return jsonify(new_todo), 201


@app.route("/api/todos/<todo_id>", methods=["PUT", "DELETE"])
def todo_item(todo_id):
    """Handle PUT and DELETE requests for a specific todo."""
    if request.method == "PUT":
        data = request.json
        if "status" not in data:
            return jsonify({"message": "Status field is required"}), 400
        mongo.db.todos.update_one(
            {"_id": ObjectId(todo_id)}, {"$set": {"status": data["status"]}}
        )
        return jsonify({"acknowledged": True}), 200
    elif request.method == "DELETE":
        result = mongo.db.todos.delete_one({"_id": ObjectId(todo_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Todo not found"}), 404
        return jsonify({"acknowledged": True}), 200


# Application entry point
if __name__ == "__main__":
    app_host = os.getenv("APP_HOST", "0.0.0.0")
    app_port = int(os.getenv("APP_PORT", 5000))
    app.run(host=app_host, port=app_port)
