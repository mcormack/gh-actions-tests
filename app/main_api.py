from fastapi import FastAPI

app = FastAPI()

@app.get("/say_hello")
async def say_hello():
    return {"message": "Hello World"}
