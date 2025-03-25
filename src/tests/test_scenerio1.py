import requests

BASE_URL = "http://127.0.0.1:5000"

def main():
    # 1) Kullanıcı kayıt
    register_payload = {
        "email": "test@gmail.com",
        "password": "123456",
        "ad": "Mehmet",
        "soyad": "Test"
        # "telefon": "5554443322"  # Opsiyonel
    }
    print("=== 1) Kayıt İsteği Gönderiliyor... ===")
    r = requests.post(f"{BASE_URL}/auth/kayit", json=register_payload)
    print("Cevap:", r.status_code, r.json())
    
    # 2) Kullanıcı giriş (token elde etme)
    login_payload = {
        "email": "test@gmail.com",
        "password": "123456"
    }
    print("\n=== 2) Giriş İsteği Gönderiliyor... ===")
    r = requests.post(f"{BASE_URL}/auth/giris", json=login_payload)
    print("Cevap:", r.status_code, r.json())
    
    if r.status_code != 200:
        print("Giriş yapılamadı, senaryo devam etmeyecek.")
        return
    
    

if __name__ == "__main__":
    main()
