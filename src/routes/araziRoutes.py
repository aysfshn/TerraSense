from flask import Blueprint, jsonify, request
from src.models import db
from src.models.arazi import Arazi
from src.utils.auth import token_required
from ..utils.ai_helper import arazi_tavsiyesi_al
import json

arazi_bp = Blueprint('arazi', __name__)

@arazi_bp.route('/', methods=['POST'])
@token_required
def arazi_ekle(current_user):
    data = request.get_json()
    
    # Gerekli alanları kontrol et
    required_fields = ['adi', 'konum', 'toprak_analizi', 'butce', 'arazi_tipi']
    for field in required_fields:
        if field not in data:
            return jsonify({'hata': f'{field} alanı gerekli'}), 400
    
    try:
        butce = float(data['butce'])
    except ValueError:
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
            return jsonify({'hata': 'Arazi büyüklüğü sayısal bir değer olmalı'}), 400
    
    # Çalışan sayısı kontrolü
    if 'calisan_sayisi' in data:
        try:
            data['calisan_sayisi'] = int(data['calisan_sayisi'])
        except ValueError:
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
    except Exception as e:
        db.session.rollback()
        print(f"Veritabanı hatası: {str(e)}")  # Konsola yazdır
        return jsonify({
            'hata': 'Arazi eklenirken bir hata oluştu',
            'detay': str(e)
        }), 500
    
    return jsonify({
        'mesaj': 'Arazi başarıyla eklendi',
        'arazi': yeni_arazi.to_dict()
    }), 201

@arazi_bp.route('/', methods=['GET'])
@token_required
def arazileri_listele(current_user):
    araziler = Arazi.query.filter_by(kullanici_id=current_user.id).all()
    return jsonify({
        'araziler': [arazi.to_dict() for arazi in araziler]
    })

@arazi_bp.route('/<int:arazi_id>', methods=['GET'])
@token_required
def arazi_detay(current_user, arazi_id):
    arazi = Arazi.query.filter_by(id=arazi_id, kullanici_id=current_user.id).first()
    if not arazi:
        return jsonify({'hata': 'Arazi bulunamadı'}), 404
    
    return jsonify(arazi.to_dict())

@arazi_bp.route('/<int:arazi_id>', methods=['PUT'])
@token_required
def arazi_guncelle(current_user, arazi_id):
    arazi = Arazi.query.filter_by(id=arazi_id, kullanici_id=current_user.id).first()
    if not arazi:
        return jsonify({'hata': 'Arazi bulunamadı'}), 404
    
    data = request.get_json()
    
    # Sayısal değerleri kontrol et
    if 'butce' in data:
        try:
            data['butce'] = float(data['butce'])
        except ValueError:
            return jsonify({'hata': 'Bütçe sayısal bir değer olmalı'}), 400
    
    if 'buyukluk' in data:
        try:
            data['buyukluk'] = float(data['buyukluk'])
        except ValueError:
            return jsonify({'hata': 'Arazi büyüklüğü sayısal bir değer olmalı'}), 400
    
    if 'calisan_sayisi' in data:
        try:
            data['calisan_sayisi'] = int(data['calisan_sayisi'])
        except ValueError:
            return jsonify({'hata': 'Çalışan sayısı tam sayı olmalı'}), 400
    
    # Liste tipindeki verileri JSON string'e çevir
    if 'son_urunler' in data and isinstance(data['son_urunler'], list):
        data['son_urunler'] = json.dumps(data['son_urunler'])
    if 'sorunlar' in data and isinstance(data['sorunlar'], list):
        data['sorunlar'] = json.dumps(data['sorunlar'])
    if 'ekipmanlar' in data and isinstance(data['ekipmanlar'], list):
        data['ekipmanlar'] = json.dumps(data['ekipmanlar'])
    if 'don_durumlari' in data and isinstance(data['don_durumlari'], list):
        data['don_durumlari'] = json.dumps(data['don_durumlari'])
    
    # Tüm alanları güncelle
    for field in data:
        if hasattr(arazi, field):
            setattr(arazi, field, data[field])
    
    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({'hata': 'Arazi güncellenirken bir hata oluştu'}), 500
    
    return jsonify({
        'mesaj': 'Arazi başarıyla güncellendi',
        'arazi': arazi.to_dict()
    })

@arazi_bp.route('/<int:arazi_id>', methods=['DELETE'])
@token_required
def arazi_sil(current_user, arazi_id):
    arazi = Arazi.query.filter_by(id=arazi_id, kullanici_id=current_user.id).first()
    if not arazi:
        return jsonify({'hata': 'Arazi bulunamadı'}), 404
    
    try:
        db.session.delete(arazi)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({'hata': 'Arazi silinirken bir hata oluştu'}), 500
    
    return jsonify({
        'mesaj': 'Arazi başarıyla silindi'
    }) 


@arazi_bp.route('/tavsiye/<int:arazi_id>', methods=['GET'])
def arazi_tavsiyesi(arazi_id):
    """
    Belirli bir arazi için OpenAI'dan tarım tavsiyeleri alır
    """
    try:
        # Araziyi veritabanından al
        arazi = Arazi.query.get_or_404(arazi_id)
        
        # Arazi verilerini sözlük formatına çevir
        arazi_data = arazi.to_dict()
        
        # OpenAI'dan tavsiye al
        tavsiye_sonucu = arazi_tavsiyesi_al(arazi_data)
        
        if 'hata' in tavsiye_sonucu:
            return jsonify({
                'basarili': False,
                'mesaj': 'Tavsiye alınırken bir hata oluştu',
                'hata': tavsiye_sonucu['detay']
            }), 500
            
        return jsonify({
            'basarili': True,
            'arazi_id': arazi_id,
            'arazi_adi': arazi.adi,
            'tavsiyeler': tavsiye_sonucu['tavsiyeler'],
            'olusturulma_tarihi': tavsiye_sonucu['olusturulma_tarihi']
        })
        
    except Exception as e:
        return jsonify({
            'basarili': False,
            'mesaj': 'Arazi bilgileri alınırken bir hata oluştu',
            'hata': str(e)
        }), 500 