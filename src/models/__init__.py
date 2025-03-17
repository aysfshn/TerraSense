from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# Modelleri import et
from .user import User
from .arazi import Arazi 