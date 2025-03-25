from flask import Blueprint, jsonify, request
from src.models import db, User
from src.utils.auth import generate_token, token_required
import datetime
from email_validator import validate_email, EmailNotValidError
from src.utils.logger import logger

# Blueprint oluştur
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/kayit', methods=['POST'])
def kayit():
    try:
        data = request.get_json()
        logger.log_data_operation("Kullanıcı Kaydı", f"Yeni kayıt isteği: {data.get('email')}")

        # Gerekli alanları kontrol et
        required_fields = ['email', 'password', 'ad', 'soyad']
        for field in required_fields:
            if field not in data:
                logger.log_error(f"Kayıt hatası: {field} alanı eksik")
                return jsonify({'hata': f'{field} alanı gerekli'}), 400

        # Email formatını doğrula
        try:
            validate_email(data['email'])
        except EmailNotValidError:
            logger.log_error(f"Kayıt hatası: Geçersiz email formatı - {data.get('email')}")
            return jsonify({'hata': 'Geçersiz email formatı'}), 400

        # Email'in benzersiz olduğunu kontrol et
        if User.query.filter_by(email=data['email']).first():
            logger.log_error(f"Kayıt hatası: Email zaten kayıtlı - {data.get('email')}")
            return jsonify({'hata': 'Bu email adresi zaten kayıtlı'}), 400

        # Telefon numarası varsa benzersizliğini kontrol et
        if 'telefon' in data and data['telefon']:
            if User.query.filter_by(telefon=data['telefon']).first():
                logger.log_error(f"Kayıt hatası: Telefon zaten kayıtlı - {data.get('telefon')}")
                return jsonify({'hata': 'Bu telefon numarası zaten kayıtlı'}), 400

        # Yeni kullanıcı oluştur
        new_user = User(
            email=data['email'],
            ad=data['ad'],
            soyad=data['soyad'],
            telefon=data.get('telefon')
        )
        new_user.set_password(data['password'])

        try:
            db.session.add(new_user)
            db.session.commit()
            logger.log_user_activity("Kayıt", data['email'], "Kullanıcı başarıyla kaydedildi")
            return jsonify({
                'mesaj': 'Kayıt başarılı',
                'kullanici': new_user.to_dict()
            }), 201
        except Exception as e:
            db.session.rollback()
            logger.log_error("Kayıt işlemi başarısız", e)
            return jsonify({'hata': 'Kayıt işlemi başarısız'}), 500

    except Exception as e:
        logger.log_error("Beklenmeyen kayıt hatası", e)
        return jsonify({'hata': 'Beklenmeyen bir hata oluştu'}), 500

@auth_bp.route('/giris', methods=['POST'])
def giris():
    try:
        data = request.get_json()
        logger.log_data_operation("Kullanıcı Girişi", f"Giriş denemesi: {data.get('email')}")

        if not data or not data.get('email') or not data.get('password'):
            logger.log_error("Giriş hatası: Eksik bilgi")
            return jsonify({'hata': 'Email ve şifre gerekli'}), 400

        user = User.query.filter_by(email=data['email']).first()

        if not user or not user.check_password(data['password']):
            logger.log_error(f"Giriş hatası: Geçersiz kimlik bilgileri - {data.get('email')}")
            return jsonify({'hata': 'Geçersiz email veya şifre'}), 401

        # Son giriş zamanını güncelle
        user.son_giris = datetime.datetime.utcnow()
        db.session.commit()

        token = generate_token(user.id)
        logger.log_user_activity("Giriş", data['email'], "Kullanıcı başarıyla giriş yaptı")

        return jsonify({
            'token': token,
            'kullanici': user.to_dict()
        })

    except Exception as e:
        logger.log_error("Beklenmeyen giriş hatası", e)
        return jsonify({'hata': 'Beklenmeyen bir hata oluştu'}), 500

@auth_bp.route('/profil', methods=['GET'])
@token_required
def profil(current_user):
    try:
        logger.log_user_activity("Profil Görüntüleme", current_user.email)
        return jsonify(current_user.to_dict())
    except Exception as e:
        logger.log_error("Profil görüntüleme hatası", e)
        return jsonify({'hata': 'Profil bilgileri alınamadı'}), 500