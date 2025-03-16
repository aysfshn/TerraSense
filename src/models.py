from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    ad = db.Column(db.String(50), nullable=False)
    soyad = db.Column(db.String(50), nullable=False)
    telefon = db.Column(db.String(15), unique=True, nullable=True)
    kayit_tarihi = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    son_giris = db.Column(db.DateTime, nullable=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'email': self.email,
            'ad': self.ad,
            'soyad': self.soyad,
            'telefon': self.telefon,
            'kayit_tarihi': str(self.kayit_tarihi),
            'son_giris': str(self.son_giris) if self.son_giris else None
        } 