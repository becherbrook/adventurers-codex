import logging
import psycopg

from fastapi import FastAPI, HTTPException

from src.database import get_connection

logging.basicConfig(level=logging.INFO)

app = FastAPI()
logger = logging.getLogger(__name__)

@app.get("/health")
def health_check():
    try:
        conn = get_connection()
        conn.close()
        return {"status": "healthy", "database": "connected"}

    except psycopg.OperationalError:
        logger.error("Health check database connection failed")
        raise HTTPException(
            status_code=503,
            detail={"status": "unhealthy", "database": "unavailable"},
        )

@app.get("/classes")
def get_classes():
    try:
        conn = get_connection()
        cur = conn.cursor()

        cur.execute("SELECT id, name, hit_die FROM classes ORDER BY id")
        rows = cur.fetchall()

        cur.close()
        conn.close()

    except psycopg.OperationalError:
        logger.error("Database connection failed")
        raise
    return {
        row[0]: {
            "name": row[1],
            "hit_die": row[2],
        }
        for row in rows
    }

@app.get("/classes/{class_name}")
def get_class(class_name: str):
    logger.info("Looking up class: %s", class_name)
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
        logger.warning("Class not found: %s", class_name)
        raise HTTPException(status_code=404, detail="Class not found")

    logger.info("Class found: %s", class_name)

    return {
        "name": row[0],
        "hit_die": row[1],
    }
