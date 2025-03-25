from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
import os
from .models import db
from .routes.authRoutes import auth_bp
from .routes.main import main_bp
from .routes.araziRoutes import arazi_bp
from .utils.logger import logger

def create_app():
    # Logger'ı başlat
    logger.log_module_start("TerraSense Uygulaması")

    try:
        # .env dosyasını yükle
        load_dotenv()
        logger.log_debug("Çevre değişkenleri yüklendi")

        # Flask uygulamasını oluştur
        app = Flask(__name__)
        logger.log_module_start("Flask Uygulaması")

        # CORS'u etkinleştir
        CORS(app)
        logger.log_debug("CORS etkinleştirildi")

        # Uygulama konfigürasyonu
        app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'gelistirme-anahtari-123')
        app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///terrasense.db')
        app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
        logger.log_debug("Uygulama konfigürasyonu tamamlandı")

        # Veritabanını başlat
        db.init_app(app)
        logger.log_module_start("Veritabanı Bağlantısı")

        # Blueprint'leri kaydet
        app.register_blueprint(main_bp)
        app.register_blueprint(auth_bp, url_prefix='/auth')
        app.register_blueprint(arazi_bp, url_prefix='/arazi')
        logger.log_debug("Blueprint'ler kaydedildi")

        # Veritabanı tablolarını oluştur
        with app.app_context():
            db.create_all()
            logger.log_data_operation("Veritabanı Tabloları", "Tüm tablolar oluşturuldu")

        logger.log_module_start("Uygulama Başlatma Tamamlandı")
        return app

    except Exception as e:
        logger.log_error("Uygulama başlatılırken hata oluştu", e)
        raise 