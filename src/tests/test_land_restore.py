import pytest
from datetime import datetime
from src.services.land import restore_land
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session

@pytest.fixture(scope="module")
def test_user_with_deleted_land():
    # Test kullanıcısı oluştur
    user = User(
        name="Restore Test User",
        email="restoretest@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    # Silinmiş bir test arsası ekle
    land = Land(
        name="Geri Yüklenecek Arsa",
        location="Samsun, Atakum",
        size=4800,
        owner_id=user.id,
        is_deleted=True,
        deleted_at=datetime.now()
    )
    db_session.add(land)
    db_session.commit()
    
    yield {"user": user, "land": land}
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_restore_land_success(test_user_with_deleted_land):
    """Kullanıcı silinen arsasını geri yükleyebilmeli"""
    user = test_user_with_deleted_land["user"]
    land = test_user_with_deleted_land["land"]
    
    result = restore_land(user.id, land.id)
    
    assert result is not None
    assert result["success"] is True
    
    # Arsanın durumunu kontrol et
    restored_land = Land.query.get(land.id)
    assert restored_land is not None
    assert restored_land.is_deleted is False
    assert restored_land.deleted_at is None

def test_restore_land_not_deleted(test_user_with_deleted_land):
    """Silinmeyen bir arsayı geri yükleme isteği başarısız olmalı"""
    user = test_user_with_deleted_land["user"]
    land = test_user_with_deleted_land["land"]
    
    # Zaten geri yüklenmiş arsayı tekrar geri yüklemeye çalışma
    result = restore_land(user.id, land.id)
    
    assert result["success"] is False
    assert "not deleted" in result["message"]