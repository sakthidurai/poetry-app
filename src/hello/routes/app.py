"""Inside Quart app"""
from quart import Quart
from hello.services import response as res

app = Quart(__name__)


@app.get("/echo")
async def echo():
    """Inside echo method"""
    return res.get_response()

if __name__ == "__main__":
    app.run(host='0.0.0.0',port=8080)
