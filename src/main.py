from fastapi import FastAPI, HTTPException

from src.classes import classes

app = FastAPI()


@app.get("/classes")
def get_classes():
	return classes


@app.get("/classes/{class_name}")
def get_class(class_name: str):
    if class_name not in classes:
        raise HTTPException(status_code=404, detail="Class not found")

    return classes[class_name]
