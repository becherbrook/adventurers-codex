from fastapi import FastAPI, HTTPException

from src.database import get_connection

app = FastAPI()

@app.get("/classes")
def get_classes():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT id, name, hit_die FROM classes ORDER BY id")
    rows = cur.fetchall()

    cur.close()
    conn.close()

    return {
        row[0]: {
            "name": row[1],
            "hit_die": row[2],
        }
        for row in rows
    }

@app.get("/classes/{class_name}")
def get_class(class_name: str):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        "SELECT name, hit_die FROM classes WHERE id = %s",
        (class_name,),
    )
    row = cur.fetchone()

    cur.close()
    conn.close()

    if row is None:
        raise HTTPException(status_code=404, detail="Class not found")

    return {
        "name": row[0],
        "hit_die": row[1],
    }
