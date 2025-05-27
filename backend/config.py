import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    MONGO_URI = os.getenv("MONGO_URI", "mongodb+srv://mini_books:mini_books@users.mat5xne.mongodb.net/mini_books") 