import pytest
from src.services.land import update_land
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session

@pytest.fixture(scope="module")
def test_user_with_land():
    # Test kullanıcısı oluştur
    user = User(
        name="Update Test User",
        email="updatetest@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    # Test arsası ekle
    land = Land(
        name="Düzenlenecek Arsa",
        location="Bursa, Nilüfer",
        size=3500,
        owner_id=user.id
    )
    db_session.add(land)
    db_session.commit()
    
    yield {"user": user, "land": land}
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_update_land_success(test_user_with_land):
    """Kullanıcı arsasını düzenleyebilmeli"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    update_data = {
        "name": "Güncellenmiş Arsa",
        "location": "Bursa, Osmangazi",
        "size": 4000
    }
    
    result = update_land(user.id, land.id, update_data)
    
    assert result is not None
    assert result["success"] is True
    assert "land" in result
    assert result["land"]["name"] == update_data["name"]
    assert result["land"]["location"] == update_data["location"]
    assert result["land"]["size"] == update_data["size"]

def test_update_land_unauthorized(test_user_with_land):
    """Kullanıcı başka birine ait arsayı düzenleyememeli"""
    land = test_user_with_land["land"]
    
    # Farklı bir kullanıcı oluştur
    other_user = User(
        name="Other User",
        email="other@example.com",
        password="hashedpassword123"
    )
    db_session.add(other_user)
    db_session.commit()
    
    update_data = {
        "name": "Başkasının Arsası",
    }
    
    result = update_land(other_user.id, land.id, update_data)
    
    assert result["success"] is False
    assert "not authorized" in result["message"]
    
    # Temizlik
    User.query.filter_by(id=other_user.id).delete()
    db_session.commit()