import pytest
from src.services.land import save_land_changes
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session
import json

@pytest.fixture(scope="module")
def test_user_with_land():
    # Test kullanıcısı oluştur
    user = User(
        name="Save Changes User",
        email="savechanges@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    # Test arsası ekle - pending_changes alanı ekle
    land = Land(
        name="Değişiklik Arsası",
        location="Konya, Selçuklu",
        size=7500,
        owner_id=user.id,
        pending_changes=json.dumps({
            "name": "Yeni İsim",
            "location": "Konya, Meram",
            "soil_analysis": {
                "ph": 7.2,
                "nitrogen": 1.5
            }
        })
    )
    db_session.add(land)
    db_session.commit()
    
    yield {"user": user, "land": land}
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_save_land_changes_success(test_user_with_land):
    """Kullanıcı arsa üzerindeki değişiklikleri kaydedebilmeli"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    result = save_land_changes(user.id, land.id)
    
    assert result is not None
    assert result["success"] is True
    assert "land" in result
    assert result["land"]["name"] == "Yeni İsim"
    assert result["land"]["location"] == "Konya, Meram"
    assert result["land"]["soil_analysis"]["ph"] == 7.2
    assert result["land"]["soil_analysis"]["nitrogen"] == 1.5
    assert result["land"]["pending_changes"] is None

def test_save_land_changes_no_changes(test_user_with_land):
    """Değişiklik olmadan kaydetme isteği başarısız olmalı"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    # Değişiklikleri kaydettikten sonra tekrar kaydetmeye çalışma
    result = save_land_changes(user.id, land.id)
    
    assert result["success"] is False
    assert "No pending changes" in result["message"]