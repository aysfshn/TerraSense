import pytest
from src.services.land import update_soil_analysis
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session

@pytest.fixture(scope="module")
def test_user_with_land():
    # Test kullanıcısı oluştur
    user = User(
        name="Soil Test User",
        email="soiltest@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    # Test arsası ekle
    land = Land(
        name="Toprak Analizi Arsası",
        location="Adana, Seyhan",
        size=5500,
        owner_id=user.id
    )
    db_session.add(land)
    db_session.commit()
    
    yield {"user": user, "land": land}
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_update_soil_analysis_success(test_user_with_land):
    """Kullanıcı toprak analizi sonuçlarını girebilmeli"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    soil_data = {
        "ph": 6.8,
        "nitrogen": 1.2,
        "phosphorus": 0.8,
        "potassium": 1.5,
        "organic_matter": 3.2,
        "moisture": 28.5,
        "texture": "Killi-Tınlı"
    }
    
    result = update_soil_analysis(user.id, land.id, soil_data)
    
    assert result is not None
    assert result["success"] is True
    assert "land" in result
    assert result["land"]["soil_analysis"] is not None
    assert result["land"]["soil_analysis"]["ph"] == soil_data["ph"]
    assert result["land"]["soil_analysis"]["nitrogen"] == soil_data["nitrogen"]
    assert result["land"]["soil_analysis"]["texture"] == soil_data["texture"]

def test_update_soil_analysis_invalid_ph(test_user_with_land):
    """Geçersiz pH değeri girilememeli"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    invalid_soil_data = {
        "ph": 15,  # Geçersiz pH (0-14 arası olmalı)
        "nitrogen": 1.2
    }
    
    result = update_soil_analysis(user.id, land.id, invalid_soil_data)
    
    assert result["success"] is False
    assert "Invalid pH value" in result["message"]