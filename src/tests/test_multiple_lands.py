import pytest
from src.services.land import add_land, get_user_lands
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session

@pytest.fixture(scope="module")
def test_user():
    # Test kullanıcısı oluştur
    user = User(
        name="Multiple Land User",
        email="multiland@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    yield user
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_add_multiple_lands(test_user):
    """Kullanıcı birden fazla arsa ekleyebilmeli"""
    # İlk arsa ekleme
    land1 = {
        "name": "Arsa 1",
        "location": "İzmir, Karşıyaka",
        "size": 3000
    }
    
    # İkinci arsa ekleme
    land2 = {
        "name": "Arsa 2",
        "location": "İstanbul, Kadıköy",
        "size": 4500
    }
    
    # Üçüncü arsa ekleme
    land3 = {
        "name": "Arsa 3",
        "location": "Antalya, Konyaaltı",
        "size": 6000
    }
    
    result1 = add_land(test_user.id, land1)
    result2 = add_land(test_user.id, land2)
    result3 = add_land(test_user.id, land3)
    
    assert result1["success"] is True
    assert result2["success"] is True
    assert result3["success"] is True
    
    # Kullanıcının tüm arsalarını getirme
    user_lands = get_user_lands(test_user.id)
    
    assert user_lands is not None
    assert len(user_lands) == 3
    
    # Arsa isimlerini kontrol etme
    land_names = [land.name for land in user_lands]
    assert "Arsa 1" in land_names
    assert "Arsa 2" in land_names
    assert "Arsa 3" in land_names