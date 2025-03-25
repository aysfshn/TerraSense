import pytest
from src.services.auth import login, register
from src.models.user import User
from src.config.database import db_session
from werkzeug.security import generate_password_hash

@pytest.fixture(scope="module")
def setup_login_user():
    # Test kullanıcısı oluştur
    user_data = {
        "name": "Login Test User",
        "email": "logintest@example.com",
        "password": "Password123!"
    }
    register(user_data)
    
    yield
    
    # Temizlik
    User.query.filter_by(email="logintest@example.com").delete()
    db_session.commit()

def test_login_success(setup_login_user):
    """Geçerli kimlik bilgileriyle giriş yapabilmeli"""
    login_data = {
        "email": "logintest@example.com",
        "password": "Password123!"
    }
    
    result = login(login_data)
    
    assert result is not None
    assert result["success"] is True
    assert "token" in result
    assert "user" in result
    assert result["user"]["email"] == login_data["email"]

def test_login_wrong_password(setup_login_user):
    """Yanlış şifre ile giriş yapılamamalı"""
    login_data = {
        "email": "logintest@example.com",
        "password": "WrongPassword123!"
    }
    
    result = login(login_data)
    
    assert result["success"] is False
    assert "Invalid credentials" in result["message"]

def test_login_nonexistent_user():
    """Olmayan kullanıcı ile giriş yapılamamalı"""
    login_data = {
        "email": "nonexistent@example.com",
        "password": "Password123!"
    }
    
    result = login(login_data)
    
    assert result["success"] is False
    assert "User not found" in result["message"]