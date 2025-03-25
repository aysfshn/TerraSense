import pytest
from src.services.auth import register
from src.models.user import User
from src.config.database import db_session

@pytest.fixture(scope="module")
def setup_db():
    # Test başlamadan önce
    yield
    # Test bittikten sonra temizlik
    User.query.filter_by(email="test@example.com").delete()
    db_session.commit()

def test_user_registration_success(setup_db):
    """Kullanıcı başarıyla kayıt olabilmeli"""
    user_data = {
        "name": "Test User",
        "email": "test@example.com",
        "password": "Password123!"
    }
    
    result = register(user_data)
    
    assert result is not None
    assert result["success"] is True
    assert "user" in result
    assert result["user"]["email"] == user_data["email"]
    assert result["user"]["password"] != user_data["password"]  # Şifre hash'lenmeli

def test_user_registration_duplicate_email(setup_db):
    """Aynı email ile tekrar kayıt yapılamamalı"""
    user_data = {
        "name": "Test User Again",
        "email": "test@example.com",
        "password": "Password123!"
    }
    
    result = register(user_data)
    
    assert result["success"] is False
    assert "email already exists" in result["message"]