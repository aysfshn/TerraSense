from flask import Blueprint, jsonify, request
from models import db, User
from utils.auth import generate_token, token_required
import datetime
from email_validator import validate_email, EmailNotValidError

# Blueprint oluştur
auth_bp = Blueprint('auth', __name__)
main_bp = Blueprint('main', __name__)

# Ana sayfa route'ları
@main_bp.route('/')
def ana_sayfa():
    return jsonify({
        'mesaj': 'TerraSense API\'sine Hoş Geldiniz',
        'durum': 'çalışıyor',
        'versiyon': '1.0.0'
    })

# Kimlik doğrulama route'ları
@auth_bp.route('/kayit', methods=['POST'])
def kayit():
    data = request.get_json()

    # Gerekli alanları kontrol et
    required_fields = ['email', 'password', 'ad', 'soyad']
    for field in required_fields:
        if field not in data:
            return jsonify({'hata': f'{field} alanı gerekli'}), 400

    # Email formatını doğrula
    try:
        validate_email(data['email'])
    except EmailNotValidError:
        return jsonify({'hata': 'Geçersiz email formatı'}), 400

    # Email'in benzersiz olduğunu kontrol et
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'hata': 'Bu email adresi zaten kayıtlı'}), 400

    # Telefon numarası varsa benzersizliğini kontrol et
    if 'telefon' in data and data['telefon']:
        if User.query.filter_by(telefon=data['telefon']).first():
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
    except Exception as e:
        db.session.rollback()
        return jsonify({'hata': 'Kayıt işlemi başarısız'}), 500

    return jsonify({
        'mesaj': 'Kayıt başarılı',
        'kullanici': new_user.to_dict()
    }), 201

@auth_bp.route('/giris', methods=['POST'])
def giris():
    data = request.get_json()

    if not data or not data.get('email') or not data.get('password'):
        return jsonify({'hata': 'Email ve şifre gerekli'}), 400

    user = User.query.filter_by(email=data['email']).first()

    if not user or not user.check_password(data['password']):
        return jsonify({'hata': 'Geçersiz email veya şifre'}), 401

    # Son giriş zamanını güncelle
    user.son_giris = datetime.datetime.utcnow()
    db.session.commit()

    token = generate_token(user.id)

    return jsonify({
        'token': token,
        'kullanici': user.to_dict()
    })

@auth_bp.route('/profil', methods=['GET'])
@token_required
def profil(current_user):
    return jsonify(current_user.to_dict()) 