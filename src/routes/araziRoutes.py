from flask import Blueprint, jsonify, request
from src.models import db
from src.models.arazi import Arazi
from src.utils.auth import token_required
from ..utils.ai_helper import arazi_tavsiyesi_al
from src.utils.logger import logger
import json

arazi_bp = Blueprint('arazi', __name__)

@arazi_bp.route('/', methods=['POST'])
@token_required
def arazi_ekle(current_user):
    try:
        data = request.get_json()
        logger.log_data_operation("Arazi Ekleme", f"Kullanıcı: {current_user.email} - Arazi: {data.get('adi')}")
        
        # Gerekli alanları kontrol et
        required_fields = ['adi', 'konum', 'toprak_analizi', 'butce', 'arazi_tipi']
        for field in required_fields:
            if field not in data:
                logger.log_error(f"Arazi ekleme hatası: {field} alanı eksik - Kullanıcı: {current_user.email}")
                return jsonify({'hata': f'{field} alanı gerekli'}), 400
        
        try:
            butce = float(data['butce'])
        except ValueError:
            logger.log_error(f"Arazi ekleme hatası: Geçersiz bütçe değeri - Kullanıcı: {current_user.email}")
            return jsonify({'hata': 'Bütçe sayısal bir değer olmalı'}), 400

        # Liste tipindeki verileri JSON string'e çevir
        if 'son_urunler' in data and isinstance(data['son_urunler'], list):
            data['son_urunler'] = json.dumps(data['son_urunler'])
        if 'sorunlar' in data and isinstance(data['sorunlar'], list):
            data['sorunlar'] = json.dumps(data['sorunlar'])
        if 'ekipmanlar' in data and isinstance(data['ekipmanlar'], list):
            data['ekipmanlar'] = json.dumps(data['ekipmanlar'])
        if 'don_durumlari' in data and isinstance(data['don_durumlari'], list):
            data['don_durumlari'] = json.dumps(data['don_durumlari'])
        
        # Büyüklük kontrolü
        if 'buyukluk' in data:
            try:
                data['buyukluk'] = float(data['buyukluk'])
            except ValueError:
                logger.log_error(f"Arazi ekleme hatası: Geçersiz büyüklük değeri - Kullanıcı: {current_user.email}")
                return jsonify({'hata': 'Arazi büyüklüğü sayısal bir değer olmalı'}), 400
        
        # Çalışan sayısı kontrolü
        if 'calisan_sayisi' in data:
            try:
                data['calisan_sayisi'] = int(data['calisan_sayisi'])
            except ValueError:
                logger.log_error(f"Arazi ekleme hatası: Geçersiz çalışan sayısı - Kullanıcı: {current_user.email}")
                return jsonify({'hata': 'Çalışan sayısı tam sayı olmalı'}), 400
        
        # Yeni arazi oluştur
        yeni_arazi = Arazi(
            kullanici_id=current_user.id,
            adi=data['adi'],
            konum=data['konum'],
            toprak_analizi=data['toprak_analizi'],
            butce=butce,
            arazi_tipi=data['arazi_tipi'],
            buyukluk=data.get('buyukluk'),
            buyukluk_birimi=data.get('buyukluk_birimi'),
            arazi_yapisi=data.get('arazi_yapisi'),
            toprak_rengi=data.get('toprak_rengi'),
            toprak_yapisi=data.get('toprak_yapisi'),
            tas_durumu=data.get('tas_durumu'),
            su_durumu=data.get('su_durumu'),
            sulama_kaynagi=data.get('sulama_kaynagi'),
            sulama_yontemi=data.get('sulama_yontemi'),
            son_urunler=data.get('son_urunler'),
            sorunlar=data.get('sorunlar'),
            ekipmanlar=data.get('ekipmanlar'),
            calisan_sayisi=data.get('calisan_sayisi'),
            don_durumlari=data.get('don_durumlari')
        )
        
        try:
            db.session.add(yeni_arazi)
            db.session.commit()
            logger.log_data_operation("Arazi Ekleme Başarılı", f"Kullanıcı: {current_user.email} - Arazi: {data['adi']}")
            return jsonify({
                'mesaj': 'Arazi başarıyla eklendi',
                'arazi': yeni_arazi.to_dict()
            }), 201
        except Exception as e:
            db.session.rollback()
            logger.log_error(f"Arazi ekleme veritabanı hatası - Kullanıcı: {current_user.email}", e)
            return jsonify({
                'hata': 'Arazi eklenirken bir hata oluştu',
                'detay': str(e)
            }), 500

    except Exception as e:
        logger.log_error(f"Beklenmeyen arazi ekleme hatası - Kullanıcı: {current_user.email}", e)
        return jsonify({'hata': 'Beklenmeyen bir hata oluştu'}), 500

@arazi_bp.route('/', methods=['GET'])
@token_required
def arazileri_listele(current_user):
    try:
        logger.log_data_operation("Arazi Listeleme", f"Kullanıcı: {current_user.email}")
        araziler = Arazi.query.filter_by(kullanici_id=current_user.id).all()
        return jsonify({
            'araziler': [arazi.to_dict() for arazi in araziler]
        })
    except Exception as e:
        logger.log_error(f"Arazi listeleme hatası - Kullanıcı: {current_user.email}", e)
        return jsonify({'hata': 'Araziler listelenirken bir hata oluştu'}), 500

@arazi_bp.route('/<int:arazi_id>', methods=['GET'])
@token_required
def arazi_detay(current_user, arazi_id):
    try:
        logger.log_data_operation("Arazi Detay Görüntüleme", f"Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
        arazi = Arazi.query.filter_by(id=arazi_id, kullanici_id=current_user.id).first()
        
        if not arazi:
            logger.log_error(f"Arazi detay hatası: Arazi bulunamadı - Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
            return jsonify({'hata': 'Arazi bulunamadı'}), 404
            
        return jsonify(arazi.to_dict())
    except Exception as e:
        logger.log_error(f"Arazi detay görüntüleme hatası - Kullanıcı: {current_user.email}", e)
        return jsonify({'hata': 'Arazi detayları alınırken bir hata oluştu'}), 500

@arazi_bp.route('/<int:arazi_id>/', methods=['PUT'])
@token_required
def arazi_guncelle(current_user, arazi_id):
    try:
        data = request.get_json()
        logger.log_data_operation("Arazi Güncelleme", f"Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
        
        arazi = Arazi.query.filter_by(id=arazi_id, kullanici_id=current_user.id).first()
        
        if not arazi:
            logger.log_error(f"Arazi güncelleme hatası: Arazi bulunamadı - Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
            return jsonify({'hata': 'Arazi bulunamadı'}), 404

        # Güncelleme işlemleri...
        for key, value in data.items():
            if hasattr(arazi, key):
                setattr(arazi, key, value)

        try:
            db.session.commit()
            logger.log_data_operation("Arazi Güncelleme Başarılı", f"Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
            return jsonify({
                'mesaj': 'Arazi başarıyla güncellendi',
                'arazi': arazi.to_dict()
            })
        except Exception as e:
            db.session.rollback()
            logger.log_error(f"Arazi güncelleme veritabanı hatası - Kullanıcı: {current_user.email}", e)
            return jsonify({'hata': 'Arazi güncellenirken bir hata oluştu'}), 500

    except Exception as e:
        logger.log_error(f"Beklenmeyen arazi güncelleme hatası - Kullanıcı: {current_user.email}", e)
        return jsonify({'hata': 'Beklenmeyen bir hata oluştu'}), 500

@arazi_bp.route('/<int:arazi_id>', methods=['DELETE'])
@token_required
def arazi_sil(current_user, arazi_id):
    try:
        logger.log_data_operation("Arazi Silme", f"Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
        arazi = Arazi.query.filter_by(id=arazi_id, kullanici_id=current_user.id).first()
        
        if not arazi:
            logger.log_error(f"Arazi silme hatası: Arazi bulunamadı - Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
            return jsonify({'hata': 'Arazi bulunamadı'}), 404

        try:
            db.session.delete(arazi)
            db.session.commit()
            logger.log_data_operation("Arazi Silme Başarılı", f"Kullanıcı: {current_user.email} - Arazi ID: {arazi_id}")
            return jsonify({'mesaj': 'Arazi başarıyla silindi'})
        except Exception as e:
            db.session.rollback()
            logger.log_error(f"Arazi silme veritabanı hatası - Kullanıcı: {current_user.email}", e)
            return jsonify({'hata': 'Arazi silinirken bir hata oluştu'}), 500

    except Exception as e:
        logger.log_error(f"Beklenmeyen arazi silme hatası - Kullanıcı: {current_user.email}", e)
        return jsonify({'hata': 'Beklenmeyen bir hata oluştu'}), 500

@arazi_bp.route('/tavsiye/<int:arazi_id>', methods=['GET'])
def arazi_tavsiyesi(arazi_id):
    try:
        logger.log_data_operation("Arazi Tavsiyesi", f"Arazi ID: {arazi_id}")
        tavsiye = arazi_tavsiyesi_al(arazi_id)
        logger.log_data_operation("Arazi Tavsiyesi Başarılı", f"Arazi ID: {arazi_id}")
        return jsonify(tavsiye)
    except Exception as e:
        logger.log_error(f"Arazi tavsiyesi hatası - Arazi ID: {arazi_id}", e)
        return jsonify({'hata': 'Arazi tavsiyesi alınırken bir hata oluştu'}), 500 