import pytest
from src.models.arazi import Arazi
from src.models.user import User

def test_add_land_success():
    """Kullanıcı yeni bir arsa ekleyebilmeli"""
    # Test kullanıcısı oluştur
    user = User(
        name="Land Test User",
        email="landtest@example.com",
        password="hashedpassword123"
    )
    
    # Test arsa verisi
    land_data = {
        "name": "Test Arsası",
        "location": "Ankara, Çankaya",
        "size": 5000,  # m²
        "coordinates": {
            "latitude": 39.925533,
            "longitude": 32.866287
        }
    }
    
    # Arsa nesnesi oluştur
    land = Arazi(
        name=land_data["name"],
        location=land_data["location"],
        size=land_data["size"],
        latitude=land_data["coordinates"]["latitude"],
        longitude=land_data["coordinates"]["longitude"],
        owner_id=user.id
    )
    
    # Assertions
    assert land is not None
    assert land.name == land_data["name"]
    assert land.location == land_data["location"]
    assert land.size == land_data["size"]
    assert land.latitude == land_data["coordinates"]["latitude"]
    assert land.longitude == land_data["coordinates"]["longitude"]
    assert land.owner_id == user.id

def test_add_land_invalid_location():
    """Geçersiz konumla arsa eklenememeli"""
    # Test kullanıcısı oluştur
    user = User(
        name="Land Test User",
        email="landtest@example.com",
        password="hashedpassword123"
    )
    
    # Geçersiz arsa verisi
    land_data = {
        "name": "Geçersiz Arsa",
        "location": "",  # Boş konum
        "size": 5000,
        "coordinates": {
            "latitude": None,
            "longitude": None
        }
    }
    
    # Arsa nesnesi oluşturmayı dene
    with pytest.raises(ValueError) as exc_info:
        Arazi(
            name=land_data["name"],
            location=land_data["location"],
            size=land_data["size"],
            latitude=land_data["coordinates"]["latitude"],
            longitude=land_data["coordinates"]["longitude"],
            owner_id=user.id
        )
    
    assert "Valid location is required" in str(exc_info.value)