from fastapi.testclient import TestClient
from app.main_api import app

client = TestClient(app)

def test_read_main():
    response = client.get("/say_hello")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}
