import pytest
from datetime import datetime
from src.services.land import get_user_lands, sort_lands
from src.models.user import User
from src.models.land import Land
from src.config.database import db_session

@pytest.fixture(scope="module")
def test_user_with_lands():
    # Test kullanıcısı oluştur
    user = User(
        name="Sort Test User",
        email="sorttest@example.com",
        password="hashedpassword123"
    )
    db_session.add(user)
    db_session.commit()
    
    # Test arsaları ekle
    lands = [
        Land(
            name="Küçük Arsa",
            location="Ankara",
            size=1000,
            created_at=datetime(2023, 1, 15),
            owner_id=user.id
        ),
        Land(
            name="Büyük Arsa",
            location="İzmir",
            size=8000,
            created_at=datetime(2023, 3, 10),
            owner_id=user.id
        ),
        Land(
            name="Orta Arsa",
            location="İstanbul",
            size=4500,
            created_at=datetime(2023, 2, 20),
            owner_id=user.id
        )
    ]
    
    for land in lands:
        db_session.add(land)
    
    db_session.commit()
    
    yield user
    
    # Temizlik
    Land.query.filter_by(owner_id=user.id).delete()
    User.query.filter_by(id=user.id).delete()
    db_session.commit()

def test_sort_lands_by_name(test_user_with_lands):
    """Arsalar isme göre sıralanabilmeli"""
    sort_options = {"field": "name", "order": "asc"}
    sorted_lands = sort_lands(test_user_with_lands.id, sort_options)
    
    assert sorted_lands is not None
    assert len(sorted_lands) == 3
    assert sorted_lands[0].name == "Büyük Arsa"
    assert sorted_lands[1].name == "Küçük Arsa"
    assert sorted_lands[2].name == "Orta Arsa"

def test_sort_lands_by_size(test_user_with_lands):
    """Arsalar büyüklüğe göre sıralanabilmeli"""
    sort_options = {"field": "size", "order": "desc"}
    sorted_lands = sort_lands(test_user_with_lands.id, sort_options)
    
    assert sorted_lands is not None
    assert len(sorted_lands) == 3
    assert sorted_lands[0].size == 8000
    assert sorted_lands[1].size == 4500
    assert sorted_lands[2].size == 1000

def test_sort_lands_by_created_at(test_user_with_lands):
    """Arsalar eklenme tarihine göre sıralanabilmeli"""
    sort_options = {"field": "created_at", "order": "asc"}
    sorted_lands = sort_lands(test_user_with_lands.id, sort_options)
    
    assert sorted_lands is not None
    assert len(sorted_lands) == 3
    assert sorted_lands[0].name == "Küçük Arsa"
    assert sorted_lands[1].name == "Orta Arsa"
    assert sorted_lands[2].name == "Büyük Arsa"