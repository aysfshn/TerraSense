import pytest
from src.services.advice import get_land_advice
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session
import json

@pytest.fixture(scope="module")
def test_user_with_land():
    # Test kullanıcısı oluştur
    user = User(
        name="Advice Test User",
        email="advicetest@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    # Toprak analizi verisi olan test arsası ekle
    land = Land(
        name="Tavsiye Arsası",
        location="Mersin, Yenişehir",
        size=6200,
        owner_id=user.id,
        soil_analysis=json.dumps({
            "ph": 7.8,
            "nitrogen": 0.9,
            "phosphorus": 1.2,
            "potassium": 1.8,
            "organic_matter": 2.5,
            "texture": "Kumlu-Tınlı"
        })
    )
    db_session.add(land)
    db_session.commit()
    
    yield {"user": user, "land": land}
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_get_crop_advice(test_user_with_land):
    """Kullanıcı arsaya özel ürün tavsiyesi alabilmeli"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    question = "Bu arsada hangi ürünler yetiştirilebilir?"
    
    result = get_land_advice(user.id, land.id, question)
    
    assert result is not None
    assert result["success"] is True
    assert "advice" in result
    assert len(result["advice"]) > 0

def test_get_fertilizer_advice(test_user_with_land):
    """Kullanıcı arsaya özel gübreleme tavsiyesi alabilmeli"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    question = "Bu arsa için nasıl bir gübreleme yapmalıyım?"
    
    result = get_land_advice(user.id, land.id, question)
    
    assert result is not None
    assert result["success"] is True
    assert "advice" in result
    assert "gübre" in result["advice"]  # Tavsiyede "gübre" kelimesi geçmeli

def test_get_advice_unauthorized(test_user_with_land):
    """Kullanıcı başkasının arsası için tavsiye alamamalı"""
    land = test_user_with_land["land"]
    
    # Farklı bir kullanıcı oluştur
    other_user = User(
        name="Other Advice User",
        email="otheradvice@example.com",
        password="hashedpassword123"
    )
    db_session.add(other_user)
    db_session.commit()
    
    question = "Bu arsada hangi ürünler yetiştirilebilir?"
    result = get_land_advice(other_user.id, land.id, question)
    
    assert result["success"] is False
    assert "not authorized" in result["message"]
    
    # Temizlik
    User.query.filter_by(id=other_user.id).delete()
    db_session.commit()