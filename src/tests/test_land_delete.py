import pytest
from src.services.land import delete_land
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session

@pytest.fixture(scope="module")
def test_user_with_land():
    # Test kullanıcısı oluştur
    user = User(
        name="Delete Test User",
        email="deletetest@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    # Test arsası ekle
    land = Land(
        name="Silinecek Arsa",
        location="Eskişehir, Tepebaşı",
        size=3200,
        owner_id=user.id
    )
    db_session.add(land)
    db_session.commit()
    
    yield {"user": user, "land": land}
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_delete_land_success(test_user_with_land):
    """Kullanıcı arsasını silebilmeli (soft delete)"""
    user = test_user_with_land["user"]
    land = test_user_with_land["land"]
    
    result = delete_land(user.id, land.id)
    
    assert result is not None
    assert result["success"] is True
    
    # Arsanın durumunu kontrol et
    deleted_land = Land.query.get(land.id)
    assert deleted_land is not None
    assert deleted_land.is_deleted is True
    assert deleted_land.deleted_at is not None

def test_delete_land_unauthorized(test_user_with_land):
    """Kullanıcı başkasının arsasını silememeli"""
    land = test_user_with_land["land"]
    
    # Başka bir kullanıcı oluştur
    other_user = User(
        name="Other User",
        email="otherdelete@example.com",
        password="hashedpassword123"
    )
    db_session.add(other_user)
    db_session.commit()
    
    result = delete_land(other_user.id, land.id)
    
    assert result["success"] is False
    assert "not authorized" in result["message"]
    
    # Temizlik
    User.query.filter_by(id=other_user.id).delete()
    db_session.commit()