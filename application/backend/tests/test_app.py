import pytest
from unittest.mock import patch, MagicMock
from app import app
from bson.objectid import ObjectId

@pytest.fixture
def client():
    app.config['TESTING'] = True

    # Mock the MongoDB client
    with patch('app.mongo') as mock_mongo:
        valid_object_id = ObjectId("64dbf7f7e5a4c2c8a2e6f000")  # Example valid ObjectId
        mock_mongo.db.todos.find.return_value = []  # Mock an empty todos collection
        mock_mongo.db.todos.insert_one.return_value = MagicMock(inserted_id=valid_object_id)
        mock_mongo.db.todos.update_one.return_value = MagicMock(acknowledged=True)
        mock_mongo.db.todos.delete_one.return_value = MagicMock(deleted_count=1)
        with app.test_client() as client:
            yield client


def test_health(client):
    """Test the health endpoint."""
    response = client.get('/api/health')
    assert response.status_code == 200
    assert response.json == {"status": "healthy"}


def test_create_todo(client):
    """Test creating a new todo."""
    response = client.post('/api/todos', json={"todo": "Write unit tests"})
    assert response.status_code == 201
    assert "todo" in response.json
    assert response.json["todo"] == "Write unit tests"


def test_get_todos(client):
    """Test getting all todos."""
    response = client.get('/api/todos')
    assert response.status_code == 200
    assert isinstance(response.json, list)


def test_update_todo_status(client):
    """Test updating a todo's status."""
    valid_object_id = "64dbf7f7e5a4c2c8a2e6f000"  # Example valid ObjectId as string
    response = client.put(f'/api/todos/{valid_object_id}', json={"status": True})
    assert response.status_code == 200
    assert response.json["acknowledged"] is True


def test_delete_todo(client):
    """Test deleting a todo."""
    valid_object_id = "64dbf7f7e5a4c2c8a2e6f000"  # Example valid ObjectId as string
    response = client.delete(f'/api/todos/{valid_object_id}')
    assert response.status_code == 200
    assert response.json["acknowledged"] is True
