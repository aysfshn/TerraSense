# tests/app.py

import pytest
from src.models.arazi import Arazi
from src.models.user import User
from src.routes.araziRoutes import AraziRouter
from src.routes.authRoutes import AuthRouter

def test_kullanici_arazi_ekler():
    # Kullanıcı ve arazi oluştur
    user = User(kullanici_adi="test_user", sifre="password123")
    arazi = Arazi(adi="Deneme Arazi", alan=1000, kullanici=user)

    # Kullanıcının arazi ekleme işlemi
    result = AraziRouter.arazi_ekle(user, arazi)
    
    assert result == "Arazi başarıyla eklendi."

def test_kullanici_arazi_siler():
    # Kullanıcı ve arazi oluştur
    user = User(kullanici_adi="test_user", sifre="password123")
    arazi = Arazi(adi="Deneme Arazi", alan=1000, kullanici=user)

    # Kullanıcının arazi silme işlemi
    AraziRouter.arazi_ekle(user, arazi)
    result = AraziRouter.arazi_sil(user, "Deneme Arazi")

    assert result == "Arazi başarıyla silindi."

def test_kullanici_kayit_olur():
    # Yeni bir kullanıcı oluştur
    kullanici_adi = "yeni_kullanici"
    sifre = "gizliSifre"

    # Kullanıcının kayıt olma işlemi
    result = AuthRouter.kayit_ol(kullanici_adi, sifre)

    assert result == "Kayıt başarıyla tamamlandı."

def test_kullanici_giris_yapar():
    # Kullanıcı oluştur ve kayıt et
    kullanici_adi = "test_user"
    sifre = "password123"
    AuthRouter.kayit_ol(kullanici_adi, sifre)

    # Kullanıcının giriş yapma işlemi
    result = AuthRouter.giris_yap(kullanici_adi, sifre)

    assert result == "Giriş başarılı."
