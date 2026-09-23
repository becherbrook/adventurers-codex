from fastapi import FastAPI

from src.classes import classes

app = FastAPI()


@app.get("/classes")
def get_classes():
	return classes


@app.get("/classes/{class_name}")
def get_class(class_name: str):
	return classes[class_name]
