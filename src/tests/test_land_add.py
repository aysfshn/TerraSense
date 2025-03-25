import unittest
from models import User, db
from app import create_app

class UserModelTestCase(unittest.TestCase):
    def setUp(self):
        """Test veritabanını oluştur ve kullanıcıyı ekle."""
        self.app = create_app()
        self.app.config['TESTING'] = True
        self.client = self.app.test_client()
        self.app_context = self.app.app_context()
        self.app_context.push()
        db.create_all()

    def tearDown(self):
        """Test veritabanını temizle."""
        db.session.remove()
        db.drop_all()
        self.app_context.pop()

    def test_user_creation(self):
        """Kullanıcı oluşturma testi."""
        user = User(
            email="test@example.com",
            password="Test1234!",  # Şifre oluşturulurken hashlenir.
            ad="Test",
            soyad="User",
            telefon="1234567890"
        )
        db.session.add(user)
        db.session.commit()

        # Veritabanından kullanıcıyı al ve doğrula
        retrieved_user = User.query.filter_by(email="test@example.com").first()
        self.assertIsNotNone(retrieved_user)
        self.assertEqual(retrieved_user.ad, "Test")
        self.assertEqual(retrieved_user.soyad, "User")
        self.assertEqual(retrieved_user.telefon, "1234567890")
        self.assertTrue(retrieved_user.check_password("Test1234!"))  # Şifre doğrulama

if __name__ == '__main__':
    unittest.main()
