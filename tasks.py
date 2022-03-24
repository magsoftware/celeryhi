import time
import random
from celery import Celery

app = Celery('tasks', broker='redis://localhost:6379/0', backend='redis')

@app.task
def hi(name):
    time.sleep(random.randint(1,10))
    return f"Hi {name}!"

if __name__ == "__main__":
    r = hi.delay("there")
    while not r.ready():
        print(f"task {r} executed with status {r.status}")
        time.sleep(1)
    print(f"task {r} executed with status {r.status} result '{r.get()}'")
