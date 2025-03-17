from datetime import datetime
from . import db

class Arazi(db.Model):
    __tablename__ = 'araziler'
    
    id = db.Column(db.Integer, primary_key=True)
    kullanici_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    # Temel arazi bilgileri
    adi = db.Column(db.String(100), nullable=False)
    konum = db.Column(db.String(200), nullable=False)
    toprak_analizi = db.Column(db.String(50), nullable=False)
    butce = db.Column(db.Float, nullable=False)
    arazi_tipi = db.Column(db.String(50), nullable=False)
    
    # Yeni eklenen arazi özellikleri
    buyukluk = db.Column(db.Float, nullable=True)  # dönüm/hektar
    buyukluk_birimi = db.Column(db.String(10), nullable=True)  # 'donum' veya 'hektar'
    arazi_yapisi = db.Column(db.String(50), nullable=True)  # Düz, Hafif eğimli, Çok engebeli
    
    # Toprak özellikleri
    toprak_rengi = db.Column(db.String(50), nullable=True)  # Açık kahverengi, Koyu kahverengi, Kırmızımsı, Diğer
    toprak_yapisi = db.Column(db.String(50), nullable=True)  # Kumlu, Tınlı, Killi
    tas_durumu = db.Column(db.String(50), nullable=True)  # Az taşlı, Çok taşlı, Taşsız
    su_durumu = db.Column(db.String(50), nullable=True)  # Çabuk su çeker, Uzun süre su kalır, Normal
    
    # Sulama bilgileri
    sulama_kaynagi = db.Column(db.String(50), nullable=True)  # Kuyu, Nehir, Baraj, Yağmur suyu, Sulama yapılmıyor
    sulama_yontemi = db.Column(db.String(50), nullable=True)  # Damla sulama, Yağmurlama, Salma sulama, Sulama yapılmıyor
    
    # Üretim ve sorunlar
    son_urunler = db.Column(db.String(500), nullable=True)  # JSON olarak saklanacak
    sorunlar = db.Column(db.String(500), nullable=True)  # JSON olarak saklanacak
    
    # Ekipman ve işgücü
    ekipmanlar = db.Column(db.String(500), nullable=True)  # JSON olarak saklanacak
    calisan_sayisi = db.Column(db.Integer, nullable=True)
    
    # İklim özellikleri
    don_durumlari = db.Column(db.String(500), nullable=True)  # JSON olarak saklanacak
    
    # Finansal bilgiler
    toplam_gider = db.Column(db.Float, default=0.0)
    toplam_gelir = db.Column(db.Float, default=0.0)
    
    # Zaman bilgileri
    olusturulma_tarihi = db.Column(db.DateTime, default=datetime.utcnow)
    guncelleme_tarihi = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'kullanici_id': self.kullanici_id,
            'adi': self.adi,
            'konum': self.konum,
            'toprak_analizi': self.toprak_analizi,
            'butce': self.butce,
            'arazi_tipi': self.arazi_tipi,
            'buyukluk': self.buyukluk,
            'buyukluk_birimi': self.buyukluk_birimi,
            'arazi_yapisi': self.arazi_yapisi,
            'toprak_rengi': self.toprak_rengi,
            'toprak_yapisi': self.toprak_yapisi,
            'tas_durumu': self.tas_durumu,
            'su_durumu': self.su_durumu,
            'sulama_kaynagi': self.sulama_kaynagi,
            'sulama_yontemi': self.sulama_yontemi,
            'son_urunler': self.son_urunler,
            'sorunlar': self.sorunlar,
            'ekipmanlar': self.ekipmanlar,
            'calisan_sayisi': self.calisan_sayisi,
            'don_durumlari': self.don_durumlari,
            'toplam_gider': self.toplam_gider,
            'toplam_gelir': self.toplam_gelir,
            'olusturulma_tarihi': str(self.olusturulma_tarihi),
            'guncelleme_tarihi': str(self.guncelleme_tarihi)
        } 