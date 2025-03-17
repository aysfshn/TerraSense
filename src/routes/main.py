from flask import Blueprint, jsonify

# Blueprint oluştur
main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def ana_sayfa():
    return jsonify({
        'mesaj': 'TerraSense API\'sine Hoş Geldiniz',
        'durum': 'çalışıyor',
        'versiyon': '1.0.0'
    })