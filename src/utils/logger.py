import logging
import os
from datetime import datetime
from logging.handlers import RotatingFileHandler

class Logger:
    _instance = None
    _initialized = False

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(Logger, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if not Logger._initialized:
            self.logger = logging.getLogger('TerraSense')
            self.logger.setLevel(logging.DEBUG)

            # Log dosyası için klasör oluştur
            log_dir = 'logs'
            if not os.path.exists(log_dir):
                os.makedirs(log_dir)

            # Log dosyası adı (tarih ile)
            log_file = os.path.join(log_dir, f'terrasense_{datetime.now().strftime("%Y%m%d")}.log')

            # Dosya handler'ı (rotating file handler)
            file_handler = RotatingFileHandler(
                log_file,
                maxBytes=10*1024*1024,  # 10MB
                backupCount=5,
                encoding='utf-8'
            )
            file_handler.setLevel(logging.DEBUG)

            # Console handler
            console_handler = logging.StreamHandler()
            console_handler.setLevel(logging.INFO)

            # Format
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            file_handler.setFormatter(formatter)
            console_handler.setFormatter(formatter)

            # Handler'ları ekle
            self.logger.addHandler(file_handler)
            self.logger.addHandler(console_handler)

            Logger._initialized = True

    def log_module_start(self, module_name):
        """Modül başlatıldığında log kaydı"""
        self.logger.info(f"Modül başlatıldı: {module_name}")

    def log_error(self, error_msg, exception=None):
        """Hata durumunda log kaydı"""
        if exception:
            self.logger.error(f"Hata: {error_msg} - Exception: {str(exception)}", exc_info=True)
        else:
            self.logger.error(f"Hata: {error_msg}")

    def log_data_operation(self, operation_type, details):
        """Veri işleme operasyonları için log kaydı"""
        self.logger.info(f"Veri İşlemi - {operation_type}: {details}")

    def log_user_activity(self, activity_type, username, details=None):
        """Kullanıcı aktiviteleri için log kaydı"""
        if details:
            self.logger.info(f"Kullanıcı Aktivitesi - {activity_type} - Kullanıcı: {username} - Detaylar: {details}")
        else:
            self.logger.info(f"Kullanıcı Aktivitesi - {activity_type} - Kullanıcı: {username}")

    def log_debug(self, message):
        """Debug seviyesinde log kaydı"""
        self.logger.debug(message)

# Global logger instance
logger = Logger() 