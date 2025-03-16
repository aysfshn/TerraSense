from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
import os
from models import db
from routes import auth_bp, main_bp

def create_app():
    # .env dosyasını yükle
    load_dotenv()

    # Flask uygulamasını oluştur
    app = Flask(__name__)

    # CORS'u etkinleştir
    CORS(app)

    # Uygulama konfigürasyonu
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'gelistirme-anahtari-123')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///terrasense.db')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # Veritabanını başlat
    db.init_app(app)

    # Blueprint'leri kaydet
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')

    # Veritabanı tablolarını oluştur
    with app.app_context():
        db.create_all()

    return app 