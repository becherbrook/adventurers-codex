from fastapi.testclient import TestClient

from src.main import app


client = TestClient(app)


def test_get_classes():
    response = client.get("/classes")

    assert response.status_code == 200
    assert "fighter" in response.json()
    assert "wizard" in response.json()
    assert "thief" in response.json()
    assert "cleric" in response.json()

def test_get_fighter():
    response = client.get("/classes/fighter")

    assert response.status_code == 200
    assert response.json() == {
        "name": "Fighter",
        "hit_die": 10,
    }

def test_get_unknown_class():
    response = client.get("/classes/paladin")

    assert response.status_code == 404
